//
//  ImagesListViewTests.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 18.11.2025.
//

import XCTest
import CoreGraphics
@testable import ImageFeed

final class ImagesListViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController
        let presenter = ImagesListPresentSpy()
        viewController.configure(presenter: presenter)
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testGetPhoto() {
        //given
        let presenter = ImagesListPresentSpy()
        let testPhoto = Photo(
            id: "123test",
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "thumbImageURL",
            largeImageURL: "largeImageURL",
            fullImageURL: "fullImageURL",
            isLiked: false
        )
        let indexPath = IndexPath(row: 0, section: 0)
        
        //when
        let presenterPhoto = presenter.getPhoto(for: indexPath)
        
        //then
        XCTAssertEqual(testPhoto.id, presenterPhoto.id)
        XCTAssertEqual(testPhoto.thumbImageURL, presenterPhoto.thumbImageURL)
        XCTAssertEqual(testPhoto.isLiked, presenterPhoto.isLiked)
    }
    
    func testDidTapLikeCalled() {
        //given
        let viewController = ImagesListControllerSpy()
        let presenter = ImagesListPresentSpy()
        viewController.configure(presenter: presenter)
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = ImagesListCell()
        
        //when
        presenter.didTapLike(for: indexPath, with: cell)
        
        //then
        XCTAssertTrue(presenter.didTapLikeCalled)
    }
    
    func testUpdateTableViewAnimatedCalled() {
        //given
        let viewController = ImagesListControllerSpy()
        
        //when
        viewController.updateTableViewAnimated(with: 0, newCount: 1)
        
        //then
        XCTAssertTrue(viewController.updateTableViewAnimatedCalled)
    }
}
