//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 02.11.2025.
//

import Foundation

final class OAuth2TokenStorage {
    // ADDED: синглтон
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let key = "BearerToken"
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: key)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
