//
//  MovieDetailsView.swift
//  Movies
//
//  Created by Dmytro Hetman on 26.01.2025.
//

import UIKit

protocol MovieDetailsCallZoomViewDelegate: AnyObject {
    func showFull(_ image: UIImage?)
}

final class MovieDetailsView: UIView {
    
    // MARK: - Views
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .black
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "play.circle"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 14)
        textView.backgroundColor = .clear
        textView.textColor = .darkGray
        textView.isScrollEnabled = true
        textView.isEditable = false
        textView.textAlignment = .justified
        textView.showsVerticalScrollIndicator = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private var shimmerViews: [UIView] = []
    
    // MARK: - Delegates
    
    weak var delegate: MovieDetailsCallZoomViewDelegate?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        addShimmer(to: [imageView, nameLabel, detailsLabel, genreLabel, ratingLabel])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .white
        addSubviews()
        setupLayout()
        setupGestures()
    }
    
    private func setupGestures() {
        let tapOnImage = UITapGestureRecognizer(target: self, action: #selector(tappedOnImage))
        imageView.addGestureRecognizer(tapOnImage)
        imageView.isUserInteractionEnabled = true
    }
    
    @objc private func tappedOnImage() {
        delegate?.showFull(imageView.image)
    }
    
    private func addSubviews() {
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(detailsLabel)
        addSubview(genreLabel)
        addSubview(playButton)
        addSubview(ratingLabel)
        addSubview(descriptionTextView)
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 9/16),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            nameLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
            
            detailsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            detailsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            detailsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            detailsLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
            
            genreLabel.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: 8),
            genreLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            genreLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            genreLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
            
            playButton.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 16),
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            playButton.widthAnchor.constraint(equalToConstant: 40),
            playButton.heightAnchor.constraint(equalTo: playButton.widthAnchor),
            
            ratingLabel.centerYAnchor.constraint(equalTo: playButton.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            ratingLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            ratingLabel.heightAnchor.constraint(equalToConstant: 20),
            
            descriptionTextView.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            descriptionTextView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Public Setters
    
    func set(_ movie: MovieDetailsModel) {
        removeShimmer(from: [imageView, nameLabel, detailsLabel, genreLabel, ratingLabel])
        
        nameLabel.text = movie.title
        detailsLabel.text = movie.countryYear
        genreLabel.text = movie.genres
        switch movie.rating {
        case .none:
            ratingLabel.text = .localized(LocalizedKey.Title.notRated)
        case .some(let value):
            ratingLabel.text = "\(String.localized(LocalizedKey.Title.rating)): \(value)"
        }
        
        descriptionTextView.text = movie.description
        
        imageView.setImage(with: movie.imageURL!)
        
    }

}
