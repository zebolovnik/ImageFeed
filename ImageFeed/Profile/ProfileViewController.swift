//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 16.10.2025.
//

import UIKit
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
    private let profileLogoutService = ProfileLogoutService.shared
    
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
    
    @objc private func didTapLogoutButton() {
        showExitAlert()
    }
    
    private func showExitAlert() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        let noAction = UIAlertAction(title: "Нет", style: .default)
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self else { return }
            self.profileLogoutService.logout()
            self.switchToSplashScreen()
        }
        alert.addAction(noAction)
        alert.addAction(yesAction)
        present(alert, animated: true)
    }
    
    private func switchToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()
    }
}

// MARK: - Private UI setup
private extension ProfileViewController {
    
    func setupAvatarImageView() {
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
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { return }
        
        let processor = ResizingImageProcessor(
            referenceSize: CGSize(width: Constants.avatarSize, height: Constants.avatarSize)
        ).append(
            another: RoundCornerImageProcessor(cornerRadius: Constants.avatarSize / 2)
        )
        
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: imageUrl,
            placeholder: UIImage(named: "stub"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]) { result in
                switch result {
                case .success(let value):
                    print("✅ Avatar loaded from:", value.cacheType)
                case .failure(let error):
                    print("❌ Avatar load failed:", error)
                }
            }
    }
}
