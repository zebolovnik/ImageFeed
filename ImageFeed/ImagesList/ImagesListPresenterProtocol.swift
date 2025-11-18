//
//  ImagesListPresenterProtocol.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 19.11.2025.
//

import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListControllerProtocol? { get set }
    func viewDidLoad()
    func getPhoto(for indexPath: IndexPath) -> Photo
    func photosCount() -> Int
    func fetchPhotosNextPage()
    func didTapLike(for indexPath: IndexPath, with cell: ImagesListCell)
    func updateTableView()
    func fetchNewPhotosPage(for indexPath: IndexPath)
}
