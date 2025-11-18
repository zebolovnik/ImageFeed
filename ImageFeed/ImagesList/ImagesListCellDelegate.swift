//
//  ImagesListCellDelegate.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 18.11.2025.
//
import Foundation

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}
