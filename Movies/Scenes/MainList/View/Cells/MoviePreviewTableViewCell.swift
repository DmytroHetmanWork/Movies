//
//  MoviePreviewTableViewCell.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import UIKit
import DataCache

final class MoviePreviewTableViewCell: UITableViewCell {
    
    private let containerView = UIView()
    private let backgroundImage = UIImageView()
    private let titleYearLabel = PaddingLabel()
//    private let titleYearLabel = UILabel()
    private let genresLabel = PaddingLabel()
    private let ratingLabel = PaddingLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        backgroundImage.image = nil
        titleYearLabel.text?.removeAll()
        genresLabel.text?.removeAll()
        ratingLabel.text?.removeAll()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        titleYearLabel.layer.cornerRadius = 4
        titleYearLabel.layer.masksToBounds = true
        
        genresLabel.layer.cornerRadius = 4
        genresLabel.layer.masksToBounds = true
        
        ratingLabel.layer.cornerRadius = 4
        ratingLabel.layer.masksToBounds = true
    }
    
    private func setup() {
        setupViews()
        setupLayout()
    }
    
    private func setupViews() {
        backgroundColor = .clear
        
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.clipsToBounds = true
        backgroundImage.backgroundColor = .lightGray
        
        titleYearLabel.font = .boldSystemFont(ofSize: 20)
        titleYearLabel.numberOfLines = 2
        titleYearLabel.backgroundColor = .white.withAlphaComponent(0.75)
        titleYearLabel.textColor = .black
//        titleYearLabel.lineBreakMode = .byWordWrapping
        titleYearLabel.lineBreakStrategy = []
        titleYearLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        genresLabel.font = .systemFont(ofSize: 16, weight: .medium)
        genresLabel.backgroundColor = .white.withAlphaComponent(0.75)
        genresLabel.textColor = .gray
        
        ratingLabel.font = .systemFont(ofSize: 16, weight: .medium)
        ratingLabel.backgroundColor = .black.withAlphaComponent(0.75)
        ratingLabel.textColor = .white
        ratingLabel.textAlignment = .right
        
    }
    
    private func setupLayout() {
        // Container View Setup
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        contentView.addSubview(containerView)

        // Background Image Setup
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(backgroundImage)
        
        // Title & Year Label Setup
        titleYearLabel.translatesAutoresizingMaskIntoConstraints = false
        titleYearLabel.textColor = .black
        containerView.addSubview(titleYearLabel)

        // Genres Label Setup
        genresLabel.translatesAutoresizingMaskIntoConstraints = false
        genresLabel.textColor = .gray
        containerView.addSubview(genresLabel)

        // Rating Label Setup
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.textColor = .white
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
            titleYearLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
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
        titleYearLabel.text = "\(model.title), \(model.year)"
        genresLabel.text = model.genres
        ratingLabel.text = "Rating \(model.rating)"
        
        if DataCache.instance.hasData(forKey: model.imagePath) {
            backgroundImage.image = DataCache.instance.readImage(forKey: model.imagePath)
        } else {
            model.imagePath.load(completion: { [weak self] result in
                switch result {
                case .success(let image):
                    self?.backgroundImage.image = image
                    DataCache.instance.write(image: image, forKey: model.imagePath)
                case .failure(_):
                    self?.backgroundImage.image = UIImage.remove
                }  
            })
        }
        
    }
}
