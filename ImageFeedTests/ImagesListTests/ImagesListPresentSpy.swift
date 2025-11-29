//
//  ImagesListPresentSpy.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 18.11.2025.
//

import Foundation
import CoreGraphics
@testable import ImageFeed

final class ImagesListPresentSpy: ImagesListPresenterProtocol {
    var view: ImagesListControllerProtocol?
    var viewDidLoadCalled: Bool = false
    var didTapLikeCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func getPhoto(for indexPath: IndexPath) -> Photo {
        return Photo(
            id: "123test",
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "thumbImageURL",
            largeImageURL: "largeImageURL",
            fullImageURL: "fullImageURL",
            isLiked: false
        )
    }
    
    func photosCount() -> Int {
        return 10
    }
    
    func fetchPhotosNextPage() {}
    func didTapLike(for indexPath: IndexPath, with cell: ImagesListCell) {
        didTapLikeCalled = true
    }
    func updateTableView() {}
    func fetchNewPhotosPage(for indexPath: IndexPath) {}
}
