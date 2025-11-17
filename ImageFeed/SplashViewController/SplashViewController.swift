//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 02.11.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            // Если есть токен, загружаем профиль и потом переходим
            fetchProfileAndSwitch(token: token)
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
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
                // CHANGE: ждем завершения загрузки аватарки перед переходом
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { avatarResult in
                    switch avatarResult {
                    case .success(let avatarURL):
                        print("✅ Avatar URL loaded:", avatarURL)
                    case .failure(let error):
                        print("❌ Avatar URL load failed:", error)
                    }
                    // Переходим только после попытки загрузки аватарки
                    self.switchToTabBarController()
                }
            case .failure(let error):
                print("❌ Profile fetch failed:", error.localizedDescription)
                self.switchToTabBarController()
            }
        }
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        // Закрываем AuthViewController и переходим на главный экран
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self, let token = self.storage.token else { return }
            self.fetchProfileAndSwitch(token: token)
        }
    }
}
