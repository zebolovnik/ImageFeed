//
//  ProfileViewTests.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 18.11.2025.
//

import XCTest
@testable import ImageFeed

final class ProfileViewTests: XCTestCase {
    func testProfileViewControllerCallViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.configure(presenter)
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testUpdateAvatar() {
        //given
        let viewController = ProfileViewControllerSpy()
        guard let url = URL(string: "https://test.com") else { return }
        
        //when
        viewController.updateAvatar(with: url)
        
        //then
        XCTAssertTrue(viewController.updateAvatarCalled)
    }
    
    func testUpdateProfile() {
        //given
        let viewController = ProfileViewControllerSpy()
        let profile = Profile(username: "testUsername", name: "testName", loginName: "@test", bio: "testBio")
        
        //when
        viewController.updateProfile(profile: profile)
        
        //then
        XCTAssertEqual(viewController.username, "testUsername")
        XCTAssertEqual(viewController.name, "testName")
        XCTAssertEqual(viewController.loginName, "@test")
        XCTAssertEqual(viewController.bio, "testBio")
    }
    
    func testDidTapLogoutButton() {
        //given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        presenter.didTapLogoutButton()
        
        //then
        XCTAssertTrue(viewController.showExitAlertCalled)
    }
}
