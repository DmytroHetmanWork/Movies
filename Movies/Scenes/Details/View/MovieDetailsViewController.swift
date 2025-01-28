//
//  MovieDetailsViewController.swift
//  Movies
//
//  Created by Dmytro Hetman on 26.01.2025.
//

import UIKit

protocol MovieDetailsViewProtocol: AnyObject, UIViewController {
    func display(_ movie: MovieDetailsModel)
    func updateNavigationTitle(_ value: String)
    
    func setupTrailerButton(_ isShown: Bool)
    
    func showAlert(_ error: NetworkError)
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
        
        movieDetailsView.posterDelegate = self
        movieDetailsView.trailerDelegate = self
        presenter.attachView(self)
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
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
    
    func setupTrailerButton(_ isShown: Bool) {
        movieDetailsView.isTrailerButtonHidden(!isShown)
    }
    
    func showAlert(_ error: NetworkError) {
        showAlert(error: error)
    }
    
}

extension MovieDetailsViewController: MovieDetailsCallZoomViewDelegate {
    func showFull(_ image: UIImage?) {
        guard image != .imageCellBackPlaceholder else { return }
        let zoomVC = ZoomViewController(image: image)
        zoomVC.modalPresentationStyle = .pageSheet
        present(zoomVC, animated: true)
    }
}

extension MovieDetailsViewController: MovieDetailsShowTrailerDelegate {
    func showTrailer() {
        presenter.showTrailer()
    }
}
