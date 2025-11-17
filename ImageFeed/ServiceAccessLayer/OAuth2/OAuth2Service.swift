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

struct OAuthTokenResponseBody: Codable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
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
        
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        // ADDED: логирование запроса
        print("[fetchAuthToken] Making OAuth request with code:", code.prefix(10) + "...")
        print("[fetchAuthToken] Request URL:", request.url?.absoluteString ?? "nil")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            // ADDED: детальное логирование результата
            print("[fetchAuthToken] OAuth result received")
            
            DispatchQueue.main.async {
                self?.task = nil
                self?.lastCode = nil
            }
            
            switch result {
            case .success(let responseBody):
                print("✅ OAuth SUCCESS - Token received:", responseBody.accessToken.prefix(10) + "...")
                print("✅ Full token length:", responseBody.accessToken.count)
                self?.tokenStorage.token = responseBody.accessToken
                
                // ADDED: проверка сохранения токена
                if let savedToken = self?.tokenStorage.token {
                    print("✅ Token saved successfully:", savedToken.prefix(10) + "...")
                } else {
                    print("❌ Token NOT saved to storage!")
                }
                
                DispatchQueue.main.async {
                    completion(.success(responseBody.accessToken))
                }
            case .failure(let error):
                print("❌ OAuth FAILED - Error:", error)
                print("❌ Error type:", type(of: error))
                
                // ADDED: дополнительная информация для NetworkError
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .httpStatusCode(let code):
                        print("❌ HTTP Status Code:", code)
                    case .decodingError(let decodingError):
                        print("❌ Decoding Error:", decodingError)
                    case .urlRequestError(let requestError):
                        print("❌ Request Error:", requestError)
                    case .urlSessionError:
                        print("❌ URL Session Error")
                    case .invalidRequest:
                        print("❌ Invalid Request")
                    }
                }
                
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
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
