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
    private let titleYearLabelView = PaddingLabelView(backgroundColor: .white.withAlphaComponent(0.75))
    private let genresLabel = PaddingLabelView(backgroundColor: .white.withAlphaComponent(0.75))
    private let ratingLabel = PaddingLabelView(backgroundColor: .black.withAlphaComponent(0.75))
    
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
        titleYearLabelView.label.text?.removeAll()
        genresLabel.text?.removeAll()
        ratingLabel.text?.removeAll()
        backgroundImage.stopLoading()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        containerView.addStandardShadow()
        
        titleYearLabelView.layer.cornerRadius = 4
        titleYearLabelView.layer.masksToBounds = true
        
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
        selectionStyle = .none
        
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.clipsToBounds = true
        backgroundImage.backgroundColor = .lightGray
        
        titleYearLabelView.font = .boldSystemFont(ofSize: 20)
        titleYearLabelView.textColor = .black
        
        genresLabel.font = .systemFont(ofSize: 16, weight: .medium)
        genresLabel.textColor = .black
        
        
        
        ratingLabel.font = .systemFont(ofSize: 16, weight: .medium)
        ratingLabel.backgroundColor = .black.withAlphaComponent(0.75)
        ratingLabel.textColor = .white
        ratingLabel.textAlignment = .center
        
    }
    
    private func setupLayout() {
        // Container View Setup
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        // Background Image Setup
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(backgroundImage)
        
        // Title & Year Label Setup
        titleYearLabelView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleYearLabelView)

        // Genres Label Setup
        genresLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(genresLabel)

        // Rating Label Setup
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
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

            titleYearLabelView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleYearLabelView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16),
            titleYearLabelView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleYearLabelView.bottomAnchor.constraint(lessThanOrEqualTo: genresLabel.topAnchor, constant: -16),


            
            // Genres Label Constraints
            genresLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            genresLabel.trailingAnchor.constraint(lessThanOrEqualTo: ratingLabel.leadingAnchor, constant: -16),
            genresLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            // Rating Label Constraints
            ratingLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            ratingLabel.widthAnchor.constraint(equalToConstant: 90),
            ratingLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }

    func config(from model: MoviePreviewModel) {
        titleYearLabelView.label.text = "\(model.title), \(model.year)"
        genresLabel.text = model.genres
        ratingLabel.text = model.rating
        
        if DataCache.instance.hasData(forKey: model.imagePath) {
            backgroundImage.image = DataCache.instance.readImage(forKey: model.imagePath)
        } else {
            backgroundImage.startLoading()
            model.imagePath.load(completion: { [weak self] result in
                switch result {
                case .success(let image):
                    self?.backgroundImage.image = image
                    DataCache.instance.write(image: image, forKey: model.imagePath)
                case .failure(_):
                    self?.backgroundImage.image = UIImage.imageCellBackPlaceholder
                }
                self?.backgroundImage.stopLoading()
            })
        }
        
    }
}
