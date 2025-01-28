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

fileprivate var shimmerAssociationKey: UInt8 = 0

extension UIView {
    
    // MARK: - Associated Dictionary for Shimmer Views
    private var shimmerViews: [UIView: UIView] {
        get {
            return objc_getAssociatedObject(self, &shimmerAssociationKey) as? [UIView: UIView] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &shimmerAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Add Shimmer to Subviews
    func addShimmer(to subviews: [UIView]) {
        for subview in subviews {
            guard shimmerViews[subview] == nil else { continue }
            
            let shimmerView = ShimmerView()
            addSubview(shimmerView)
            sendSubviewToBack(shimmerView)
            
            shimmerView.translatesAutoresizingMaskIntoConstraints = false
            shimmerView.backgroundColor = .lightGray.withAlphaComponent(0.5)
            shimmerView.layer.cornerRadius = 8
            shimmerView.layer.masksToBounds = true
            
            NSLayoutConstraint.activate([
                shimmerView.topAnchor.constraint(equalTo: subview.topAnchor),
                shimmerView.leadingAnchor.constraint(equalTo: subview.leadingAnchor),
                shimmerView.trailingAnchor.constraint(equalTo: subview.trailingAnchor),
                shimmerView.bottomAnchor.constraint(equalTo: subview.bottomAnchor)
            ])
            
            shimmerViews[subview] = shimmerView
        }
    }
    
    // MARK: - Remove Shimmer from Subviews
    func removeShimmer(from subviews: [UIView]) {
        for subview in subviews {
            if let shimmerView = shimmerViews[subview] {
                shimmerView.removeFromSuperview()
                shimmerViews.removeValue(forKey: subview)
            }
        }
    }
}
