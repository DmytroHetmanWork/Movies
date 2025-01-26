//
//  ShimmerView.swift
//  Movies
//
//  Created by Dmytro Hetman on 26.01.2025.
//

import UIKit

final class ShimmerView: UIView {

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShimmer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupShimmer()
    }

    private func setupShimmer() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = [
            UIColor.lightGray.withAlphaComponent(0.4).cgColor,
            UIColor.lightGray.withAlphaComponent(0.05).cgColor,
            UIColor.lightGray.withAlphaComponent(0.4).cgColor
        ]
        gradientLayer.locations = [0, 0.4, 1]
        layer.addSublayer(gradientLayer)
        startShimmering()
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = 4
    }

    private func startShimmering() {
        let shimmerAnimation = CABasicAnimation(keyPath: "locations")
        shimmerAnimation.fromValue = [-1, -0.5, 0]
        shimmerAnimation.toValue = [1, 1.5, 2]
        shimmerAnimation.duration = 1.5
        shimmerAnimation.repeatCount = .infinity
        gradientLayer.add(shimmerAnimation, forKey: "shimmerEffect")
    }
}

