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
    func configEmptyTableState(isShowing: Bool)
}

final class MoviesListViewController: UIViewController, MoviesListView {
    
    enum C {
        static let sortBtnImage = UIImage(systemName: "arrow.up.arrow.down")?
            .withTintColor(.black, renderingMode: .alwaysOriginal)
    }
    
    // MARK: - UI Items
    
    private let labelTitle = UILabel()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.isTranslucent = true
        searchBar.alpha = 1
        searchBar.backgroundColor = UIColor.lightGray
        searchBar.tintColor = .black
        searchBar.barStyle = .default
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.placeholder = "Search"
        return searchBar
    }()
    
    private let refreshControl = UIRefreshControl()

    let moviesTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private let emptyTableLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "No results found"
        label.textColor = .black
        return label
    }()
    
    // MARK: - Presenter
    
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
        presenter.moviesListView = self
        
        setupTableView()
        setupDatasource()
        setupSearhBar()
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        
        
        setupNavigationBar()
        setupLayout()
    }
    
    private func setupNavigationBar() {
        labelTitle.text = presenter.currentSortBy.navigationTitle
        labelTitle.textColor = .black
        labelTitle.font = .systemFont(ofSize: 18, weight: .semibold)
        labelTitle.textAlignment = .center

        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        if let navigationBarHeight = navigationController?.navigationBar.bounds.height {
            labelTitle.heightAnchor.constraint(equalToConstant: navigationBarHeight).isActive = true
        }
        
        labelTitle.widthAnchor.constraint(equalToConstant: 200).isActive = true

        navigationItem.titleView = labelTitle
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: C.sortBtnImage, style: .plain, target: self, action: #selector(tappedOnSort))
    }
    
    private func setupLayout() {
        view.addSubview(searchBar)
        view.addSubview(moviesTableView)
        view.addSubview(emptyTableLabel)

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        moviesTableView.translatesAutoresizingMaskIntoConstraints = false
        emptyTableLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            moviesTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            moviesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            moviesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            moviesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyTableLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 50),
            emptyTableLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyTableLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Setup tableView
    
    private func setupTableView() {
        moviesTableView.register(cellType: MoviePreviewTableViewCell.self)
        moviesTableView.delegate = self
        moviesTableView.rowHeight = 300
        moviesTableView.tableFooterView = .createLoadingFooter(in: moviesTableView.contentSize)
        
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        moviesTableView.addSubview(refreshControl)
        
        emptyTableLabel.isHidden = true
    }
    
    func setupDatasource() {
        presenter.setupDatasource()
    }
    
    func reloadData() {
        DispatchQueue.main.async { [weak self] in
            self?.moviesTableView.reloadData()
        }
    }
    
    // MARK: - SearchBar
    
    private func setupSearhBar() {
        searchBar.delegate = self
        
        let tapOnView = UITapGestureRecognizer(target: self, action: #selector(resignFromSearchBar))
        navigationController?.navigationBar.addGestureRecognizer(tapOnView)
    }
    
    @objc private func resignFromSearchBar() {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Loading flow
    
    @objc func refresh(_ sender: AnyObject) {
        checkConnection { isConnected in
            if isConnected {
                presenter.refreshMovies(withNewSorting: nil)
            } else {
                endRefreshing()
            }
        }
    }
    
    func endRefreshing() {
        refreshControl.endRefreshing()
    }
    
    func showLoadingFooter() {
        moviesTableView.tableFooterView?.isHidden = false
    }

    func hideLoadingFooter() {
        moviesTableView.tableFooterView?.isHidden = true
    }
    
    func configEmptyTableState(isShowing: Bool) {
        emptyTableLabel.isHidden = !isShowing
    }
    
    // MARK: - Sorting
    
    @objc private func tappedOnSort() {
        checkConnection { isConnected in
            if isConnected {
                let alert = UIAlertController(
                    title: "Choose Option",
                    message: "Select sorting option for displaying desired movies",
                    preferredStyle: .actionSheet
                )
                
                SortMoviesOption.allCases.forEach { option in
                    let isSelected = option == presenter.currentSortBy
                    let action = UIAlertAction(
                        title: option.navigationTitle,
                        style: .default,
                        handler: { [weak self] _ in
                            self?.presenter.refreshMovies(withNewSorting: option)
                            self?.labelTitle.text = option.navigationTitle
                        }
                    )
                    if isSelected {
                        action.setValue(true, forKey: "checked")
                    }
                    alert.addAction(action)
                }
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func checkConnection(completion: (Bool) -> Void) {
        if !NetworkListener.shared.isReachable {
            endRefreshing()
            showAlert(error: NetworkError.youAreOffline)
            completion(false)
        } else {
            completion(true)
        }
    }
    
}


extension MoviesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.checkWhenToLoad(on: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkConnection { isConnected in
            if isConnected {
                presenter.retrieveMovieIdToShow(by: indexPath.row)
            }
        }
    }
}

extension MoviesListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = !searchText.isEmpty
        if searchText.isEmpty {
            searchBar.resignFirstResponder()
        }

        presenter.search(
            by: searchText,
            isRefreshing: false,
            completion: { _ in })
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
}
