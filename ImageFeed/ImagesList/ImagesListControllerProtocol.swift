//
//  ImagesListControllerProtocol.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 19.11.2025.
//

import Foundation

protocol ImagesListControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated(with oldCount: Int, newCount: Int)
    func showProgressHUD()
    func hideProgressHUD()
    func configure(presenter: ImagesListPresenterProtocol)
}
