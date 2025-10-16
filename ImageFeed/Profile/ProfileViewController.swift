//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 16.10.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    @IBOutlet private var avatarImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var loginNameLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    
    @IBOutlet private var logoutButton: UIButton!
    
    @IBAction func didTapLogoutButton(_ sender: UIButton) {
        // TODO: добавить логику выхода позже
    }
    

}
