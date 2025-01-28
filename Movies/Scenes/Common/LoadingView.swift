//
//  LoadingView.swift
//  Movies
//
//  Created by Dmytro Hetman on 28.01.2025.
//

import UIKit

final class LoadingView: UIView {
    
    private let back = UIView()
    private let indicator = UIActivityIndicatorView(style: .large)
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        back.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        back.layer.cornerRadius = 10
        back.translatesAutoresizingMaskIntoConstraints = false
        addSubview(back)
        
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        back.addSubview(indicator)
        
        indicator.startAnimating()
        
        NSLayoutConstraint.activate([
            back.centerXAnchor.constraint(equalTo: centerXAnchor),
            back.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -100),
            back.widthAnchor.constraint(equalToConstant: 100),
            back.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: back.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: back.centerYAnchor)
        ])
    }
}
