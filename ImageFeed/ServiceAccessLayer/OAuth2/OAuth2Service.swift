//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 02.11.2025.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let access_token: String
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let tokenStorage = OAuth2TokenStorage()
    
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let responseBody = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    self.tokenStorage.token = responseBody.access_token
                    print("OAuth token received:", responseBody.access_token)
                    completion(.success(responseBody.access_token))
                } catch {
                    print("Decoding error:", error)
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                print("Network error:", error)
                completion(.failure(error))
            }
        }
        
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
