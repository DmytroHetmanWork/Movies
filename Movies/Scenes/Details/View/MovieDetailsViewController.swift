//
//  MovieDetailsViewController.swift
//  Movies
//
//  Created by Dmytro Hetman on 26.01.2025.
//

import UIKit

protocol MovieDetailsView: AnyObject {
    
}

final class MovieDetailsViewController: UIViewController, MovieDetailsView {
    
    enum C {
        static let backBtnImage = UIImage(systemName: "chevron.backward")?
            .withTintColor(.black, renderingMode: .alwaysOriginal)
    }
    
    private let labelTitle = UILabel()
    
    private let presenter: MovieDetailsPresenterProtocol
    
    init(presenter: MovieDetailsPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        
        
        setupNavigationBar()
        setupLayout()
    }
    
    private func setupNavigationBar() {
        labelTitle.text = "\(presenter.id)"
        labelTitle.textColor = .black
        labelTitle.font = .systemFont(ofSize: 18, weight: .semibold)
        labelTitle.textAlignment = .center

        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        if let navigationBarHeight = navigationController?.navigationBar.bounds.height {
            labelTitle.heightAnchor.constraint(equalToConstant: navigationBarHeight).isActive = true
        }
        
        labelTitle.widthAnchor.constraint(equalToConstant: 200).isActive = true

        navigationItem.titleView = labelTitle
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: C.backBtnImage,
            style: .plain,
            target: self,
            action: #selector(tappedOnBack)
        )
    }

    private func setupLayout() {
        
    }
    
    @objc private func tappedOnBack() {
        navigationController?.popViewController(animated: true)
    }

}
