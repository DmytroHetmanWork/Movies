//
//  UIImageView+Extension.swift
//  Movies
//
//  Created by Dmytro Hetman on 24.01.2025.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    enum ActivityIndicatorTag: Int {
        case value = 999
    }
    
    func startLoading() {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.tag = ActivityIndicatorTag.value.rawValue
        activityIndicator.center = self.center
        activityIndicator.startAnimating()
        self.addSubview(activityIndicator)
    }
    
    func stopLoading() {
        if let activityIndicator = self.viewWithTag(ActivityIndicatorTag.value.rawValue) as? UIActivityIndicatorView {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
        
    }
}

extension UIImageView {
    func setImage(with url: URL, and placeholder: UIImage = UIImage.imageCellBackPlaceholder) {
        self.kf.indicatorType = .activity
        self.kf.setImage(with: url,
                         placeholder: placeholder,
                         options: [.transition(.fade(0.3))])
    }
}
