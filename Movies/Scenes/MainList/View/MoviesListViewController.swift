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
    func showLoadingFooter()
    func hideLoadingFooter()
}

final class MoviesListViewController: UIViewController, MoviesListView {
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.isTranslucent = true
        searchBar.alpha = 1
        searchBar.backgroundColor = UIColor.lightGray
        searchBar.tintColor = .black
        searchBar.barStyle = .default
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
        
        setupSearhBar()
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        let labelTitle = UILabel()
        labelTitle.text = "Popular movies"
        labelTitle.textColor = .black
        labelTitle.font = .systemFont(ofSize: 16, weight: .medium)
        
        navigationItem.titleView = labelTitle
        
        
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
        moviesTableView.tableFooterView = .createLoadingFooter(in: moviesTableView.contentSize)
        
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
    
    private func setupSearhBar() {
        searchBar.delegate = self
    }
    
    @objc func refresh(_ sender: AnyObject) {
        presenter.refreshMovies(withNewSorting: nil)
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
    func showLoadingFooter() {
        moviesTableView.tableFooterView = .createLoadingFooter(in: moviesTableView.contentSize)
    }

    func hideLoadingFooter() {
        moviesTableView.tableFooterView = nil
    }
    
}


extension MoviesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.checkWhenToLoad(on: indexPath)
    }
}

extension MoviesListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.search(by: searchText, completion: { [weak self] result in
            
        })
    }
    
}
