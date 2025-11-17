//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 02.11.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    
    private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            fetchProfileAndSwitch(token: token)
        } else {
            presentAuthViewController()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func setupImageView() {
        let imageSplashScreenLogo = UIImage(named: "splashScreenLogo")
        imageView = UIImageView(image: imageSplashScreenLogo)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(
            withIdentifier: "AuthViewController"
        ) as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func fetchProfileAndSwitch(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                print("✅ Profile fetched successfully:", profile.username)
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { avatarResult in
                    switch avatarResult {
                    case .success(let avatarURL):
                        print("✅ Avatar URL loaded:", avatarURL)
                    case .failure(let error):
                        print("❌ Avatar URL load failed:", error)
                    }
                    self.switchToTabBarController()
                }
            case .failure(let error):
                print("❌ Profile fetch failed:", error.localizedDescription)
                self.switchToTabBarController()
            }
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self, let token = self.storage.token else { return }
            self.fetchProfileAndSwitch(token: token)
        }
    }
}
