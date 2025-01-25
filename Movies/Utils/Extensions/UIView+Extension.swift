//
//  UIView+Extension.swift
//  Movies
//
//  Created by Dmytro Hetman on 24.01.2025.
//

import UIKit

extension UIView {
    func addStandardShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
    }
    
    static func createLoadingFooter(in frame: CGSize) -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50))
        footerView.backgroundColor = .clear
        
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.startAnimating()
        activityIndicator.color = .black
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        footerView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor)
        ])
        
        return footerView
    }
}
