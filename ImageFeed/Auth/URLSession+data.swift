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
                if 200 ..< 300 ~= httpResponse.statusCode {
                    fulfillCompletionOnMain(.success(data))
                } else {
                    // ADDED: логирование ошибок
                    print("[dataTask]: NetworkError - код ошибки \(httpResponse.statusCode)")
                    fulfillCompletionOnMain(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                }
            } else if let error = error {
                // ADDED: логирование ошибок
                print("[dataTask]: NetworkError - \(error.localizedDescription)")
                fulfillCompletionOnMain(.failure(NetworkError.urlRequestError(error)))
            } else {
                // ADDED: логирование ошибок
                print("[dataTask]: NetworkError - неизвестная ошибка сессии")
                fulfillCompletionOnMain(.failure(NetworkError.urlSessionError))
            }
        }
        
        return task
    }
}

// ADDED: метод objectTask для декодирования
extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    // ADDED: логирование ошибок декодирования
                    print("[objectTask]: Ошибка декодирования - \(error.localizedDescription)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                // ADDED: логирование ошибок запроса
                print("[objectTask]: Ошибка запроса - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        return task
    }
}
