//
//  UIImageView+Extension.swift
//  Movies
//
//  Created by Dmytro Hetman on 24.01.2025.
//

import UIKit

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
