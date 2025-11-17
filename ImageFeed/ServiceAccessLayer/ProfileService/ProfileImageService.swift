//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 16.11.2025.
//

import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private(set) var avatarURL: String?
    
    private var task: URLSessionTask?
    
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                guard let self else { return }
                
                self.avatarURL = userResult.profileImage.medium
                completion(.success(userResult.profileImage.medium))
                
                // CHANGE: принудительно отправляем нотификацию
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": userResult.profileImage.medium]
                    )
                
                print("✅ Avatar URL notification sent")
                
            case .failure(let error):
                print("[fetchProfileImageURL]: Ошибка - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        let url = Constants.usersBaseURL.appendingPathComponent(username)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
