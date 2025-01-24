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
}
