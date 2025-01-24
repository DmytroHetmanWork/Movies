//
//  MoviesListPresenter.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import UIKit
import DataCache

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
        
        if DataCache.instance.hasData(forKey: CacheItemKey.movieGenresList.rawValue) {
            initialLoading()
        } else {
            loadMoviesGenres { [weak self] result in
                switch result {
                case .success(_):
                    self?.initialLoading()
                case .failure(let error):
                    print("func to show \(error) alert")
                }
            }
        }
    }
    
    private func initialLoading() {
        
        loadMore(shouldReset: true) { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                print("func to show \(error) alert")
            }
        }
    }
    
    private func loadMoviesGenres(_ completion: ((Result<(), NetworkError>) -> Void)? = nil) {
        networkService
            .perform(
                .get,
                MoviesEndpoint.movieGenresList,
                MovieGenres(language: .enUS),
                completion: { result in
                
                    switch result {
                    case .data(let data):
                        guard let data,
                              let genresResults = try? JSONDecoder().decode(GenresListDTO.self, from: data)
                        else { return }
                        
                        do {
                            let encodedData = try JSONEncoder().encode(genresResults.genres)
                            DataCache.instance.write(data: encodedData, forKey: CacheItemKey.movieGenresList.rawValue)
                        } catch {
                            print("Failed to encode genres: \(error.localizedDescription)")
                        }

                    case .error(let networkError):
                        print("func to show \(networkError) alert")
                    }
                    
                }
            )
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
        print("called loading data")
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
        
        guard let data = DataCache.instance.readData(forKey: CacheItemKey.movieGenresList.rawValue),
              let genres = try? JSONDecoder().decode([GenreItemDTO].self, from: data)
        else { return }
        
        let movies = model.results.compactMap {
            let newValue = MoviePreviewModel(from: $0, genres: genres)
            if let newValue, (!dataSource.movies.contains(newValue) || shouldReset) {
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
