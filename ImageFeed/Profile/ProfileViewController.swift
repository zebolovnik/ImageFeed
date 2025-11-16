//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 16.10.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Constants
    private enum Constants {
        static let avatarSize: CGFloat = 70
        static let avatarCornerRadius: CGFloat = 35
        static let avatarLeading: CGFloat = 16
        static let avatarTop: CGFloat = 32
        
        static let nameTopOffset: CGFloat = 8
        static let loginTopOffset: CGFloat = 8
        static let descriptionTopOffset: CGFloat = 8
        static let logoutTrailing: CGFloat = -16
    }
    
    // MARK: - UI элементы
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black")
        
        setupAvatarImageView()
        setupLabels()
        setupLogoutButton()
        
        // CHANGE: обновление UI из сохраненного профиля
        updateUIFromProfile()
    }
}

// MARK: - Private UI setup
private extension ProfileViewController {
    
    func setupAvatarImageView() {
        avatarImageView.image = UIImage(named: "avatar")
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = Constants.avatarCornerRadius
        avatarImageView.clipsToBounds = true
        view.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.avatarLeading),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.avatarTop),
            avatarImageView.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: Constants.avatarSize)
        ])
    }
    
    private func setupLabels() {
        // Имя
        nameLabel.text = ""
        nameLabel.textColor = UIColor(named: "YP White")
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Логин
        loginNameLabel.text = ""
        loginNameLabel.textColor = UIColor(named: "YP Gray")
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Описание
        descriptionLabel.text = ""
        descriptionLabel.textColor = UIColor(named: "YP White")
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        
        [nameLabel, loginNameLabel, descriptionLabel].forEach { view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: Constants.nameTopOffset),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Constants.loginTopOffset),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: Constants.descriptionTopOffset),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ])
    }
    
    func setupLogoutButton() {
        logoutButton.setImage(UIImage(named: "logout_button"), for: .normal)
        logoutButton.tintColor = UIColor(named: "YP Red")
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: Constants.logoutTrailing)
        ])
    }
    
    // CHANGE: обновление UI из сохраненного профиля
    func updateUIFromProfile() {
        guard let profile = ProfileService.shared.profile else { return }
        
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
}

// MARK: - Actions
private extension ProfileViewController {
    @objc func didTapLogoutButton() {
        print("Logout tapped")
    }
}
