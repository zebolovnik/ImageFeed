//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 18.11.2025.
//

import Foundation

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    
    func viewDidLoad() {
        updateProfile()
        updateAvatar()
    }
    
    func updateAvatar() {
        guard let profileImageURL = profileImageService.avatarURL,
              let url = URL(string: profileImageURL) else { return }
        view?.updateAvatar(with: url)
    }
    
    func updateProfile() {
        guard let profile = profileService.profile else { return }
        view?.updateProfile(profile: profile)
    }
    
    func didTapLogoutButton() {
        view?.showExitAllert()
    }
    
    func logout() {
        profileLogoutService.logout()
    }
}
