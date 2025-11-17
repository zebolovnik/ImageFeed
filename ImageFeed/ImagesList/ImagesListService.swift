//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 18.11.2025.
//

import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    
    static let didChangeNotification = Notification.Name(
        rawValue: "ImagesListServiceDidChange"
    )

    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let dateFormatter = ISO8601DateFormatter()

    private(set) var photos: [Photo] = []

    func fetchPhotosNextPage() {
        guard task == nil else {
            print("the page is still loading")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        let perPage = 10

        guard let request = makePhotoRequest(page: nextPage, perPage: perPage) else {
            print("[fetchPhotosNextPage] invalid request")
            return
        }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                self?.task = nil
            }
            
            switch result {
            case .success(let photoResults):
                var photos: [Photo] = []
                for photoResult in photoResults {
                    guard
                        let thumbImageURL = photoResult.urls.thumb ?? photoResult.urls.small,
                        let largeImageURL = photoResult.urls.regular ?? photoResult.urls.full ?? photoResult.urls.raw
                    else {
                        print("Не удалось получить URL изображения")
                        continue
                    }
                    
                    let photo = Photo(
                        id: photoResult.id,
                        size: CGSize(width: photoResult.width, height: photoResult.height),
                        createdAt: self?.dateFormatter.date(from: photoResult.createdAt),
                        welcomeDescription: photoResult.description,
                        thumbImageURL: thumbImageURL,
                        largeImageURL: largeImageURL,
                        fullImageURL: largeImageURL, // Используем largeImageURL как fullImageURL
                        isLiked: photoResult.likedByUser
                    )
                    photos.append(photo)
                }
                
                DispatchQueue.main.async {
                    self?.photos.append(contentsOf: photos)
                    self?.lastLoadedPage = nextPage
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
                
            case .failure(let error):
                print("Ошибка загрузки: \(error.localizedDescription)")
            }
        }
        
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard task == nil else {
            print("[changeLike] the page is still loading")
            return
        }
        
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else {
            print("⚠️ invalid request")
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<LikePhotosResult, Error>) in
            DispatchQueue.main.async {
                self?.task = nil
            }
            
            switch result {
            case .success:
                if let index = self?.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self!.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        fullImageURL: photo.fullImageURL,
                        isLiked: !photo.isLiked
                    )
                    self?.photos[index] = newPhoto
                }
                completion(.success(()))
            case .failure(let error):
                print("Error in changeLike: \(error)")
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }

    private func makePhotoRequest(page: Int, perPage: Int) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("Ошибка при создании запроса: отсутствует токен")
            return nil
        }

        var urlComponents = URLComponents(url: Constants.photosURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]

        guard let url = urlComponents?.url else {
            print("Не удалось сформировать URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("Ошибка при создании запроса: отсутствует токен")
            return nil
        }
        
        let likeURL = Constants.photosURL.appendingPathComponent("\(photoId)/like")
        var request = URLRequest(url: likeURL)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func resetImages() {
        photos = []
    }
}
