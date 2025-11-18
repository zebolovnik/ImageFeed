//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Nikolay Zebolov on 18.10.2025.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var photo: Photo? {
        didSet {
            guard isViewLoaded, let photo = photo else { return }
            loadAndDisplayImage(from: photo.largeImageURL)
        }
    }
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Отключаем влияние safe area на scrollView
        scrollView.contentInsetAdjustmentBehavior = .never
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 3.0
        
        if let photo = photo {
            loadAndDisplayImage(from: photo.largeImageURL)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Повторное центрирование после окончательной верстки
        if let image = imageView.image {
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func loadAndDisplayImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        UIBlockingProgressHUD.show()
        
        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let value):
                self?.imageView.image = value.image
                self?.imageView.frame.size = value.image.size
                self?.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error)")
                self?.showErrorAlert()
            }
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать еще раз?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            guard let self = self, let photo = self.photo else { return }
            self.loadAndDisplayImage(from: photo.largeImageURL)
        }))
        present(alert, animated: true)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        guard imageSize.width > 0, imageSize.height > 0 else {
            print("Image has invalid size: \(imageSize)")
            return
        }
        
        // Масштабируем, чтобы изображение заполняло экран (а не умещалось)
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        // Центрируем картинку по горизонтали и вертикали
        let newContentSize = scrollView.contentSize
        let x = max(0, (newContentSize.width - visibleRectSize.width) / 2)
        let y = max(0, (newContentSize.height - visibleRectSize.height) / 2)
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let imageView = scrollView.subviews.first as? UIImageView else { return }
        
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        // Центрируем картинку при зуме
        let verticalInset = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        let horizontalInset = max(0, (scrollViewSize.width - imageViewSize.width) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}
