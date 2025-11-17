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
    private let urlSession = URLSession.shared
    
    private(set) var photos: [Photo] = []
    
    func fetchPhotosNextPage(completion: @escaping (Result<[Photo], Error>) -> Void) {
        guard task == nil else {
            print("[fetchPhotosNextPage] the page is still loading")
            return
        }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        let perPage = 10
        
        guard let request = makePhotoRequest(page: nextPage, perPage: perPage) else {
            print("[fetchPhotosNextPage] invalid request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let photoResults):
                var photos: [Photo] = []
                for photoResult in photoResults {
                    guard
                        let thumbImageURL = photoResult.urls.thumb ?? photoResult.urls.small,
                        let largeImageURL = photoResult.urls.regular ?? photoResult.urls.full ?? photoResult.urls.raw
                    else {
                        continue
                    }
                    
                    let photo = Photo(
                        id: photoResult.id,
                        size: CGSize(width: photoResult.width, height: photoResult.height),
                        createdAt: self?.dateFormatter.date(from: photoResult.createdAt),
                        welcomeDescription: photoResult.description,
                        thumbImageURL: thumbImageURL,
                        largeImageURL: largeImageURL,
                        fullImageURL: largeImageURL,
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
                    completion(.success(photos))
                }
                
            case .failure(let error):
                print("[fetchPhotosNextPage] Download error: \(error.localizedDescription)")
                completion(.failure(error))
            }
            
            DispatchQueue.main.async {
                self?.task = nil
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
            print("[changeLike] invalid request")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikePhotosResult, Error>) in
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
                print("Error in changeLike: NetworkError - \(error)")
                completion(.failure(error))
            }
            
            DispatchQueue.main.async {
                self?.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makePhotoRequest(page: Int, perPage: Int) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[fetchPhotosNextPage] the Token is missing")
            return nil
        }
        
        var urlComponents = URLComponents(url: Constants.photosURL, resolvingAgainstBaseURL: false)
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        
        guard let url = urlComponents?.url else {
            print("[fetchPhotosNextPage] Couldn't generate URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[makeLikeRequest] the Token is missing")
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
