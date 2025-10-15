//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 13.10.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var gradientView: UIView!
    
    private let gradientLayer = CAGradientLayer()
    
    // Метод для включения/выключения лайка
    func setIsLiked(_ isLiked: Bool) {
        let imageName = isLiked ? "like_button_on" : "like_button_off" // имена картинок сердечка в ресурсах
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.4).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
    
}
