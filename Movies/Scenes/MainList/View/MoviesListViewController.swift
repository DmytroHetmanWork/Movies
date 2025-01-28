//
//  MoviesListViewController.swift
//  Movies
//
//  Created by Dmytro Hetman on 22.01.2025.
//

import UIKit

protocol MoviesListView: AnyObject, UIViewController {
    var moviesTableView: UITableView { get }
    
    func reloadData()
    func endRefreshing()
    func showLoadingFooter()
    func hideLoadingFooter()
    func configEmptyTableState(isShowing: Bool)
    func showNetworkLostAlert()
    func showNetworkError(_ error: NetworkError)
    
    func updateNavigationTitle(_ title: String)
    
    func showSearchingLoader(_ isShowing: Bool)
}

final class MoviesListViewController: UIViewController, MoviesListView {
    
    // MARK: - Const
    
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
        searchBar.placeholder = .localized(LocalizedKey.Title.search)
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
        label.text = .localized(LocalizedKey.Title.noResultsFound)
        label.textColor = .black
        return label
    }()
    
    private let loadingView = {
        let view = LoadingView()
        view.isHidden = true
        return view
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
    
    override var traitCollection: UITraitCollection {
      UITraitCollection(traitsFrom: [super.traitCollection, UITraitCollection(userInterfaceStyle: .light)])
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupLayout()
    }
    
    // MARK: - NavigationBar
    
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
    
    func updateNavigationTitle(_ title: String) {
        labelTitle.text = title
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        view.addSubview(searchBar)
        view.addSubview(moviesTableView)
        view.addSubview(emptyTableLabel)
        moviesTableView.addSubview(loadingView)
        

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        moviesTableView.translatesAutoresizingMaskIntoConstraints = false
        emptyTableLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false

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
            emptyTableLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            loadingView.topAnchor.constraint(equalTo: moviesTableView.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
    
    private func setupDatasource() {
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
    
    func showSearchingLoader(_ isShowing: Bool) {
        loadingView.isHidden = !isShowing
    }
    
    // MARK: - Loading flow
    
    @objc func refresh(_ sender: AnyObject) {
        checkConnection { isConnected in
            if isConnected {
                presenter.refreshMovies(withNewSorting: nil)
            } else {
                presenter.showCachedItems()
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
    
    func showNetworkLostAlert() {
        showAlert(error: NetworkError.youAreOffline, okAction: { [weak self] in
            DispatchQueue.main.async {
                self?.endRefreshing()
            }
        })
    }
    
    func showNetworkError(_ error: NetworkError) {
        showAlert(error: error)
    }
    
    // MARK: - Sorting
    
    @objc private func tappedOnSort() {
        checkConnection { isConnected in
            if isConnected {
                let alert = UIAlertController(
                    title: .localized(LocalizedKey.Title.chooseOption),
                    message: .localized(LocalizedKey.Message.selectSorting),
                    preferredStyle: .actionSheet
                )
                
                SortMoviesOption.allCases.forEach { option in
                    let isSelected = option == presenter.currentSortBy
                    let action = UIAlertAction(
                        title: option.navigationTitle,
                        style: .default,
                        handler: { [weak self] _ in
                            self?.presenter.refreshMovies(withNewSorting: option)
                            self?.updateNavigationTitle(option.navigationTitle)
                        }
                    )
                    if isSelected {
                        action.setValue(true, forKey: "checked")
                    }
                    alert.addAction(action)
                }
                
                alert.addAction(UIAlertAction(title: .localized(LocalizedKey.cancel), style: .cancel, handler: nil))
                
                present(alert, animated: true, completion: nil)
            } else {
                showNetworkLostAlert()
            }
        }
    }
    
    // MARK: - Network connection
    
    private func checkConnection(completion: (Bool) -> Void) {
        if !NetworkListener.shared.isReachable {
            completion(false)
        } else {
            completion(true)
        }
    }
    
}

    // MARK: - TableView Delegate

extension MoviesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.checkWhenToLoad(on: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkConnection { isConnected in
            if isConnected {
                presenter.retrieveMovieIdToShow(by: indexPath.row)
            } else {
                showNetworkLostAlert()
            }
        }
    }
}

// MARK: - SearchBar Delegate

extension MoviesListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = !searchText.isEmpty
        if searchText.isEmpty {
            searchBar.resignFirstResponder()
        }
        
        showSearchingLoader(true)
        presenter.search(
            by: searchText,
            isRefreshing: false,
            completion: { [weak self] _ in
                print(searchText)
                self?.showSearchingLoader(false)
            })
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
