//
//  ProfileViewPresenterSpy.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 18.11.2025.
//

import Foundation
@testable import ImageFeed

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = false
    
    func logout() { }
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    func didTapLogoutButton() { }
    func updateAvatar() { }
    func updateProfile() { }
}
