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
                    print("HTTP Error \(httpResponse.statusCode):", String(data: data, encoding: .utf8) ?? "No response body")
                    fulfillCompletionOnMain(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                }
            } else if let error = error {
                print("URL request error:", error)
                fulfillCompletionOnMain(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("URL session error: No data, response, or error")
                fulfillCompletionOnMain(.failure(NetworkError.urlSessionError))
            }
        }
        
        return task
    }
}
