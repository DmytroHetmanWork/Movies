//
//  MoviePreviewTableViewCell.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import UIKit

final class MoviePreviewTableViewCell: UITableViewCell {
    
    private let containerView = UIView()
    private let backgroundImage = UIImageView()
    private let titleYearLabel = UILabel()
    private let genresLabel = UILabel()
    private let ratingLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        // Container View Setup
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        contentView.addSubview(containerView)

        // Background Image Setup
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.clipsToBounds = true
        backgroundImage.backgroundColor = .lightGray // Placeholder background color
        containerView.addSubview(backgroundImage)
        
        // Title & Year Label Setup
        titleYearLabel.translatesAutoresizingMaskIntoConstraints = false
        titleYearLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleYearLabel.textColor = .black
        containerView.addSubview(titleYearLabel)

        // Genres Label Setup
        genresLabel.translatesAutoresizingMaskIntoConstraints = false
        genresLabel.font = UIFont.systemFont(ofSize: 14)
        genresLabel.textColor = .gray
        containerView.addSubview(genresLabel)

        // Rating Label Setup
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = UIFont.systemFont(ofSize: 14)
        ratingLabel.textColor = .gray
        ratingLabel.textAlignment = .right
        containerView.addSubview(ratingLabel)

        // Constraints
        NSLayoutConstraint.activate([
            // Container View Constraints
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Background Image Constraints
            backgroundImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            backgroundImage.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            // Title & Year Label Constraints
            titleYearLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleYearLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            
            // Genres Label Constraints
            genresLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            genresLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            // Rating Label Constraints
            ratingLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            ratingLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }

    func config(from model: MoviePreviewModel) {
        // Example model configuration (you need to define MovieModel)
        titleYearLabel.text = "\(model.title), \(model.year)"
        genresLabel.text = model.genres
        ratingLabel.text = model.rating
        backgroundImage.image = model.image
    }
}
