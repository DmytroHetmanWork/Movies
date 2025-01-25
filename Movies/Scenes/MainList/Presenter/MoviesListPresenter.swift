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
    func loadMore(isRefreshing: Bool, _ completion: ((Result<(), NetworkError>) -> Void)?)
    func checkWhenToLoad(on indexPath: IndexPath)
    
    func search(by text: String, isRefreshing: Bool, completion: @escaping (Result<(), NetworkError>) -> Void)
}

final class MoviesListPresenter: MoviesListPresenterProtocol {
    
    enum MoviesSectionModel: Int {
        case movies
    }
    
    private var currentSortBy: SortMoviesOption = .popularityDesc
    private var moviesListStatus = PageStatusModel()
    private var searchedMoviesStatus = PageStatusModel()
    
    private var isLoadingMovies = false
    
    private var isSearching = false
    private var queryText = "" {
        didSet {
            isSearching = !queryText.isEmpty
        }
    }
    private var debounceTimer: Timer?
    private let debounceDelay: TimeInterval = 2
    
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
        
        loadMore(isRefreshing: true) { result in
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
            if dataSource.diffable.snapshot().numberOfItems(inSection: currentSection) - 4 == indexPath.row {
                if isSearching {
                    search(by: queryText, completion: { _ in })
                } else {
                    loadMore()
                }
            }
        }
    }
    
    func refreshMovies(withNewSorting newSorting: SortMoviesOption?) {
        if isSearching {
            resetSearchedPageStats()
            
            search(by: queryText, isRefreshing: true, completion: { [weak self]_ in
                self?.moviesListView.endRefreshing()
            })
        } else {
            resetPageStats()
            
            if let newSorting {
                currentSortBy = newSorting
            }
            
            loadMore(isRefreshing: true) { [weak self] result in
                switch result {
                case .success(_):
                    self?.moviesListView.endRefreshing()
                case .failure(let error):
                    print("func to show \(error) alert")
                }
                
            }
        }
    }
    
    func loadMore(isRefreshing: Bool = false, _ completion: ((Result<(), NetworkError>) -> Void)? = nil) {
        print("called loading data")
        guard !isLoadingMovies else { return }
        isLoadingMovies = true
        moviesListView?.showLoadingFooter()
        guard moviesListStatus.currentPage <= moviesListStatus.maxPossiblePagesToLoad,
              moviesListStatus.currentPage <= moviesListStatus.totalLoadedPages
        else {
            completion?(.success(()))
            self.isLoadingMovies = false
            return
        }
        
        networkService
        .perform(
            .get,
            MoviesEndpoint.discoverMovie,
            DiscoverMoviesList(
                page: moviesListStatus.nextPageToLoad,
                sortBy: currentSortBy
            ),
            completion: { [weak self] result in
                switch result {
                case .data(let data):
                    guard let data,
                          let moviesResults = try? JSONDecoder().decode(MoviesListDTO.self, from: data)
                    else { return }
                    
                    self?.updateState(with: moviesResults, shouldReset: isRefreshing)
                    self?.moviesListView?.hideLoadingFooter()
                    completion?(.success(()))
                case .error(let error):
                    completion?(.failure(error))
                }
                self?.isLoadingMovies = false
                
            })
    }
    
    func search(by text: String, isRefreshing: Bool = false, completion: @escaping (Result<(), NetworkError>) -> Void) {
        
        guard searchedMoviesStatus.currentPage <= searchedMoviesStatus.maxPossiblePagesToLoad,
              searchedMoviesStatus.currentPage <= searchedMoviesStatus.totalLoadedPages
        else {
            completion(.success(()))
            self.isLoadingMovies = false
            return
        }
        
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty
        else {
            isSearching = false
            dataSource.resetMoviesList()
            resetSearch()
            self.isLoadingMovies = false
            return
        }
        moviesListView?.showLoadingFooter()
        debounceTimer?.invalidate()
            
        debounceTimer = Timer
            .scheduledTimer(
                withTimeInterval: isRefreshing ? 0 : debounceDelay,
                repeats: false
            ) { [weak self] _ in
            guard let self else { return }
            
            isSearching = true
            print(trimmedText)
            
            guard !isLoadingMovies else { return }
            isLoadingMovies = true
            
            
            let isNewQueryText = queryText != trimmedText
            
            if isNewQueryText {
                resetSearchedPageStats()
                queryText = trimmedText
            }
            
            
            networkService
                .perform(
                    .get,
                    MoviesEndpoint.searchMoive,
                    SearchMovieList(
                        query: queryText,
                        page: searchedMoviesStatus.nextPageToLoad
                    ),
                    completion: { [weak self] result in
                        switch result {
                        case .data(let data):
                            guard let self,
                                  let data,
                                  let moviesResults = try? JSONDecoder().decode(MoviesListDTO.self, from: data)
                            else { return }
                            print(queryText)
                            updateState(with: moviesResults, shouldReset: isRefreshing || isNewQueryText, isSearching: isSearching)
                            print(moviesResults)
                            moviesListView?.hideLoadingFooter()
                            completion(.success(()))
                        case .error(let networkError):
                            completion(.failure(networkError))
                        }
                        self?.isLoadingMovies = false
                    })
        }
    }
    
    func updateState(with model: MoviesListDTO, shouldReset: Bool = false, isSearching: Bool = false) {
        
        guard let data = DataCache.instance.readData(forKey: CacheItemKey.movieGenresList.rawValue),
              let genres = try? JSONDecoder().decode([GenreItemDTO].self, from: data)
        else { return }
        
        let movies = model.results.compactMap {
            let newValue = MoviePreviewModel(from: $0, genres: genres)
            if let newValue, (isSearching ?
                !dataSource.movies.contains(newValue) :
                !dataSource.searchedMovies.contains(newValue)
                || shouldReset) {
                return newValue
            }
            return nil
        }
        
        if isSearching {
            dataSource.updateForSearch(with: movies, shouldReset: shouldReset)
            
            moviesListView.reloadData()
            
            searchedMoviesStatus.currentPage = model.page
            searchedMoviesStatus.nextPageToLoad = searchedMoviesStatus.currentPage + 1
            searchedMoviesStatus.maxPossiblePagesToLoad = model.totalPages
            
            incrementTotalLoadedSearchedPage()
        } else {
            dataSource.update(with: movies, shouldReset: shouldReset)
            
            moviesListView.reloadData()
            
            moviesListStatus.currentPage = model.page
            moviesListStatus.nextPageToLoad = moviesListStatus.currentPage + 1
            moviesListStatus.maxPossiblePagesToLoad = model.totalPages
            
            incrementTotalLoadedPage()
        }
        
        
    }
    
    private func resetSearch() {
        isSearching = false
        resetSearchedPageStats()
        moviesListView.reloadData()
        print("reloaded data after empty string")
        print(dataSource.diffable.snapshot().itemIdentifiers(inSection: .movies))
    }
    
    private func resetPageStats() {
        moviesListStatus.reset()
    }
    
    private func incrementTotalLoadedPage() {
        moviesListStatus.totalLoadedPages += 1
    }
    
    private func resetSearchedPageStats() {
        searchedMoviesStatus.reset()
    }
    
    private func incrementTotalLoadedSearchedPage() {
        searchedMoviesStatus.totalLoadedPages += 1
    }
    
}
