//
//  MovieDetailsViewController.swift
//  Movies
//
//  Created by Dmytro Hetman on 26.01.2025.
//

import UIKit

protocol MovieDetailsViewProtocol: AnyObject {
    func display(_ movie: MovieDetailsModel)
    func displayImage(_ image: UIImage)
    func updateNavigationTitle(_ value: String)
}

final class MovieDetailsViewController: UIViewController, MovieDetailsViewProtocol {
    
    private let presenter: MovieDetailsPresenterProtocol
    private let movieDetailsView = MovieDetailsView()
    
    init(presenter: MovieDetailsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = movieDetailsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        presenter.attachView(self)
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward")?.withTintColor(.black, renderingMode: .alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(tappedOnBack)
        )
    }
    
    @objc private func tappedOnBack() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - MovieDetailsViewProtocol
    
    func updateNavigationTitle(_ value: String) {
        title = value
    }
    
    func display(_ movie: MovieDetailsModel) {
        movieDetailsView.set(movie)
    }
    
    func displayImage(_ image: UIImage) {
        movieDetailsView.set(image)
    }
    
}

