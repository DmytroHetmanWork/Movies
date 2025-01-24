//
//  MoviesListPresenter.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import UIKit

protocol MoviesListPresenterProtocol: AnyObject {
    var moviesListView: MoviesListView! { get set }
    
    func setupDatasource()
    func refreshMovies(withNewSorting newSorting: SortMoviesOption?)
    func loadMore(shouldReset: Bool, _ completion: ((Result<(), NetworkError>) -> Void)?)
    func checkWhenToLoad(on indexPath: IndexPath)
    func serch(by text: String)
}

final class MoviesListPresenter: MoviesListPresenterProtocol {
    
    enum MoviesSectionModel: Int {
        case movies
    }
    
    private var currentSortBy: SortMoviesOption = .popularityDesc
    private var currentPage = 0
    private var nextPageToLoad = 1
    private var totalLoadedPages = 0
    private var maxPossiblePagesToLoad = 0
    
    private var isLoadingMovies = false
    
    private var networkService: AlamoNetworkingServiceProtocol
    private var dataSource: MoviesDataSource!
    
    weak var moviesListView: MoviesListView!
    
    init(networkService: AlamoNetworkingServiceProtocol) {
        self.networkService = networkService
        
    }
    
    func setupDatasource() {
        dataSource = MoviesDataSource(tableView: moviesListView.moviesTableView)
        moviesListView.moviesTableView.dataSource = dataSource.diffable
        
        loadMore(shouldReset: true) { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                print("func to show \(error) alert")
            }
            
        }
    }
    
    func checkWhenToLoad(on indexPath: IndexPath) {
        if dataSource.diffable.snapshot().numberOfSections - 1 == indexPath.section {
            let currentSection = dataSource.diffable.snapshot().sectionIdentifiers[indexPath.section]
            if dataSource.diffable.snapshot().numberOfItems(inSection: currentSection) - 1 == indexPath.row {
                loadMore()
            }
        }
    }
    
    func refreshMovies(withNewSorting newSorting: SortMoviesOption?) {
        resetPageStats()
        
        if let newSorting {
            currentSortBy = newSorting
        }
        
        loadMore(shouldReset: true) { [weak self] result in
            switch result {
            case .success(_):
                self?.moviesListView.endRefreshing()
            case .failure(let error):
                print("func to show \(error) alert")
            }
            
        }
    }
    
    func loadMore(shouldReset: Bool = false, _ completion: ((Result<(), NetworkError>) -> Void)? = nil) {
        guard !isLoadingMovies else { return }
        isLoadingMovies = true
        guard currentPage <= maxPossiblePagesToLoad,
              currentPage <= totalLoadedPages
        else { return }
        
        networkService
        .perform(
            .get,
            MoviesEndpoint.discoverMovie,
            DiscoverMoviesList(
                page: nextPageToLoad,
                sortBy: currentSortBy
            ),
            completion: { [weak self] result in
                switch result {
                case .data(let data):
                    guard let data,
                          let moviesResults = try? JSONDecoder().decode(MoviesListDTO.self, from: data)
                    else { return }
                    
                    self?.updateState(with: moviesResults, shouldReset: shouldReset)
                    completion?(.success(()))
                case .error(let error):
                    completion?(.failure(error))
                }
                self?.isLoadingMovies = false
            })
    }
    
    func updateState(with model: MoviesListDTO, shouldReset: Bool = false) {
        
        let movies = model.results.compactMap {
            let newValue = MoviePreviewModel(from: $0)
            if !dataSource.movies.contains(newValue) || shouldReset {
                return newValue
            }
            return nil
        }
        
        dataSource.update(with: movies, shouldReset: shouldReset)
        
        moviesListView.reloadData()
        
        currentPage = model.page
        nextPageToLoad = currentPage + 1
        maxPossiblePagesToLoad = model.totalPages
        
        incrementTotalLoadedPage()
        
    }
    
    func serch(by text: String) {
        //
    }
    
    private func resetPageStats() {
        currentPage = 0
        nextPageToLoad = 1
        totalLoadedPages = 0
        maxPossiblePagesToLoad = 0
    }
    
    private func incrementTotalLoadedPage() {
        totalLoadedPages += 1
    }
    
}
