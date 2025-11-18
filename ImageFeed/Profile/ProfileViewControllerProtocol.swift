//
//  ProfileViewControllerProtocol.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 18.11.2025.
//

import Foundation

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func updateProfile(profile: Profile)
    func updateAvatar(with url: URL)
    func showExitAllert()
}
