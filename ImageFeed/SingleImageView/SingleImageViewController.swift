//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 18.10.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            
            imageView.image = image
            imageView.frame.size = image.size
        }
    }
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size

    }

    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    // --- НОВОЕ: вспомогательная функция для выставления размера imageView и contentSize ---
    private func updateImageViewFrame() {
        guard isViewLoaded, let image = imageView.image else { return }
        
        // разрешаем imageView работать через frame (не через Auto Layout)
        imageView.translatesAutoresizingMaskIntoConstraints = true
        
        // размер imageView = размер картинки
        imageView.frame.size = image.size
        scrollView.contentSize = image.size
    }
    
}

// --- НОВОЕ: UIScrollViewDelegate для зума ---
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}
