//
//  ImagesListControllerSpy.swift.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 18.11.2025.
//

import Foundation
@testable import ImageFeed

final class ImagesListControllerSpy: ImagesListControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var updateTableViewAnimatedCalled: Bool = false
    
    func showProgressHUD() {}
    func hideProgressHUD() {}
    
    func updateTableViewAnimated(with oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
    }
    
    func configure(presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
    }
}
