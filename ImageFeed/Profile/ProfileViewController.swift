//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 16.10.2025.
//

import UIKit
// ADDED: импорт Kingfisher
import Kingfisher

final class ProfileViewController: UIViewController {
    
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
    
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "YP Black")
        
        setupAvatarImageView()
        setupLabels()
        setupLogoutButton()
        
        updateUIFromProfile()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        
        updateAvatar()
    }
}

// MARK: - Private UI setup
private extension ProfileViewController {
    
    func setupAvatarImageView() {
        // CHANGE: убрана моковая картинка, будет загружаться из сети
        avatarImageView.image = nil
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
        nameLabel.text = ""
        nameLabel.textColor = UIColor(named: "YP White")
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        loginNameLabel.text = ""
        loginNameLabel.textColor = UIColor(named: "YP Gray")
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    func updateUIFromProfile() {
        guard let profile = ProfileService.shared.profile else { return }
        
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
    }
    
    // CHANGE: реализация загрузки аватарки через Kingfisher
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { return }
        
        print("🔄 Loading avatar from:", profileImageURL)
        
        let processor = RoundCornerImageProcessor(cornerRadius: Constants.avatarCornerRadius)
        avatarImageView.kf.indicatorType = .activity
        
        // CHANGE: улучшенные параметры загрузки
        avatarImageView.kf.setImage(
            with: imageUrl,
            placeholder: UIImage(named: "avatar"), // временная заглушка
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.2)), // плавное появление
                .cacheOriginalImage // кэшируем оригинал для лучшего качества
            ]) { result in
                switch result {
                case .success(let value):
                    print("✅ Avatar loaded from:", value.cacheType)
                case .failure(let error):
                    print("❌ Avatar load failed:", error)
                    // Пробуем загрузить еще раз при ошибке
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.avatarImageView.kf.setImage(with: imageUrl)
                    }
                }
            }
    }
}

// MARK: - Actions
private extension ProfileViewController {
    @objc func didTapLogoutButton() {
        print("Logout tapped")
    }
}
