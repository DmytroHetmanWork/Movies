//
//  MoviesListViewController.swift
//  Movies
//
//  Created by Dmytro Hetman on 22.01.2025.
//

import UIKit

final class MoviesListViewController: UIViewController {
    
    private let moviesTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.text = ""
        searchBar.placeholder = "Search"
        return searchBar
    }()
    
    private var presenter: MoviesListPresenterProtocol
    
    init(presenter: MoviesListPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupDataSource()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "Movies"

        // Add searchBar and tableView to the view
        view.addSubview(searchBar)
        view.addSubview(moviesTableView)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        moviesTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Layout for searchBar
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Layout for moviesTableView
            moviesTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            moviesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            moviesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            moviesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        moviesTableView.register(cellType: MoviePreviewTableViewCell.self)
    }

    private func setupDataSource() {
        dataSource = MoviesDataSource(tableView: moviesTableView)
    }
}

