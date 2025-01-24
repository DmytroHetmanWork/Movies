//
//  PaddingLabel.swift
//  Movies
//
//  Created by Dmytro Hetman on 24.01.2025.
//

import UIKit

final class PaddingLabelView: UIView {
    
    let label = UILabel()
    var paddingLeft: CGFloat = 4
    var paddingRight: CGFloat = 4
    var paddingTop: CGFloat = 4
    var paddingBottom: CGFloat = 4
    
    init(backgroundColor: UIColor = .clear) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Label Configuration
    private func setupLabel() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: paddingLeft),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -paddingRight),
            label.topAnchor.constraint(equalTo: topAnchor, constant: paddingTop),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -paddingBottom),
        ])
    }
    
    // MARK: - Public API for Label Properties
    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }
    
    var font: UIFont? {
        get { label.font }
        set { label.font = newValue }
    }
    
    var textColor: UIColor? {
        get { label.textColor }
        set { label.textColor = newValue }
    }
    
    var textAlignment: NSTextAlignment {
        get { label.textAlignment }
        set { label.textAlignment = newValue }
    }
    
    // MARK: - Update Padding
    func updatePadding(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        paddingTop = top
        paddingLeft = left
        paddingBottom = bottom
        paddingRight = right
        
        for constraint in constraints {
            if let firstItem = constraint.firstItem as? UILabel, firstItem == label {
                if constraint.firstAttribute == .leading {
                    constraint.constant = paddingLeft
                } else if constraint.firstAttribute == .trailing {
                    constraint.constant = -paddingRight
                } else if constraint.firstAttribute == .top {
                    constraint.constant = paddingTop
                } else if constraint.firstAttribute == .bottom {
                    constraint.constant = -paddingBottom
                }
            }
        }
    }
}

