//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 02.11.2025.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

extension URLSession {
    func data(for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        let fulfillCompletionOnMain: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data, let httpResponse = response as? HTTPURLResponse {
                print("[dataTask] HTTP Status Code: \(httpResponse.statusCode)")
                
                if 200 ..< 300 ~= httpResponse.statusCode {
                    fulfillCompletionOnMain(.success(data))
                } else {
                    let errorBody = String(data: data, encoding: .utf8) ?? "Unable to decode error body"
                    print("[dataTask]: NetworkError - код ошибки \(httpResponse.statusCode)")
                    print("[dataTask]: Error response body: \(errorBody)")
                    fulfillCompletionOnMain(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                }
            } else if let error = error {
                print("[dataTask]: NetworkError - \(error.localizedDescription)")
                fulfillCompletionOnMain(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("[dataTask]: NetworkError - неизвестная ошибка сессии")
                fulfillCompletionOnMain(.failure(NetworkError.urlSessionError))
            }
        }
        
        return task
    }
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                print("[objectTask] === RAW RESPONSE START ===")
                print("[objectTask] Data length: \(data.count) bytes")
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("[objectTask] Response body: \(responseString)")
                }
                print("[objectTask] === RAW RESPONSE END ===")
                
                do {
                    let decoder = JSONDecoder()
                    // CHANGE: убрана стратегия convertFromSnakeCase
                    // Поля уже маппятся через CodingKeys в структурах
                    
                    let decodedObject = try decoder.decode(T.self, from: data)
                    print("[objectTask] ✅ Decoding successful")
                    completion(.success(decodedObject))
                } catch {
                    print("[objectTask]: ❌ Ошибка декодирования - \(error)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                print("[objectTask]: ❌ Ошибка запроса - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        return task
    }
}
