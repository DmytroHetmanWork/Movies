//
//  MoviesListViewController.swift
//  Movies
//
//  Created by Dmytro Hetman on 22.01.2025.
//

import UIKit

protocol MoviesListView: AnyObject {
    var moviesTableView: UITableView { get }
    
    func setupDatasource()
    func reloadData()
    func endRefreshing()
}

final class MoviesListViewController: UIViewController, MoviesListView {
    
    
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = .clear
        searchBar.text = ""
        searchBar.placeholder = "Search"
        return searchBar
    }()
    
    let refreshControl = UIRefreshControl()

    let moviesTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
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
        presenter.moviesListView = self
        setupDatasource()
    }

    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.title = "Movies"
        

        
        
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
        moviesTableView.delegate = self
        moviesTableView.rowHeight = 300
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        moviesTableView.addSubview(refreshControl)
    }
    
    func setupDatasource() {
        presenter.setupDatasource()
    }
    
    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            self?.moviesTableView.reloadData()
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        presenter.refreshMovies(withNewSorting: nil)
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
}


extension MoviesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.checkWhenToLoad(on: indexPath)
    }
}
