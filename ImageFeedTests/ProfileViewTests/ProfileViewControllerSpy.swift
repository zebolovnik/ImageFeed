//
//  ProfileViewControllerSpy.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 18.11.2025.
//

import Foundation
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    var showExitAlertCalled: Bool = false
    var updateAvatarCalled: Bool = false
    var username: String?
    var name: String?
    var loginName: String?
    var bio: String?
    
    func updateProfile(profile: Profile) {
        username = profile.username
        name = profile.name
        loginName = profile.loginName
        bio = profile.bio
    }
    
    func updateAvatar(with url: URL) {
        updateAvatarCalled = true
    }
    
    func showExitAllert() {
        showExitAlertCalled = true
    }
}
