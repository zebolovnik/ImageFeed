//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 02.11.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let key = "BearerToken"
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: key)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: key)
            } else {
                KeychainWrapper.standard.removeObject(forKey: key)
            }
        }
    }
    
    func clearToken() {
        token = nil
    }
}
