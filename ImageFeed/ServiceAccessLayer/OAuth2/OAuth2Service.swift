//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 02.11.2025.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

struct OAuthTokenResponseBody: Decodable {
    let access_token: String
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let tokenStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        // CHANGE: добавлена проверка на повторный запрос с тем же кодом
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        // CHANGE: отмена предыдущего запроса
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] result in
            // CHANGE: сброс состояния после завершения запроса
            DispatchQueue.main.async {
                self?.task = nil
                self?.lastCode = nil
            }
            
            switch result {
            case .success(let data):
                do {
                    let responseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    self?.tokenStorage.token = responseBody.access_token
                    print("OAuth token received:", responseBody.access_token)
                    DispatchQueue.main.async {
                        completion(.success(responseBody.access_token))
                    }
                } catch {
                    print("Decoding error:", error)
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.decodingError(error)))
                    }
                }
                
            case .failure(let error):
                print("Network error:", error)
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        // CHANGE: сохранение текущей задачи
        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "unsplash.com"
        urlComponents.path = "/oauth/token"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}
