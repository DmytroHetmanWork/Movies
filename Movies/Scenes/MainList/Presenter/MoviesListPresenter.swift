//
//  MoviesListPresenter.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import UIKit
import DataCache

protocol MoviesListPresenterProtocol: AnyObject {
    var currentSortBy: SortMoviesOption { get }
    var moviesListView: MoviesListView! { get set }
    
    func setupDatasource()
    func refreshMovies(withNewSorting newSorting: SortMoviesOption?)
    func loadMore(isRefreshing: Bool, _ completion: ((Result<(), NetworkError>) -> Void)?)
    func checkWhenToLoad(on indexPath: IndexPath)
    
    func search(by text: String, isRefreshing: Bool, completion: @escaping (Result<(), NetworkError>) -> Void)
    
    func retrieveMovieIdToShow(by row: Int)
    var didSelectMovieWithId: ((Int) -> Void)? { get set }
}

final class MoviesListPresenter: MoviesListPresenterProtocol {
    
    enum MoviesSectionModel: Int {
        case movies
    }
    
    private(set) var currentSortBy: SortMoviesOption = .popularityDesc
    private var moviesListStatus = PageStatusModel()
    private var searchedMoviesStatus = PageStatusModel()
    
    private var isLoadingMovies = false {
        didSet {
            if isLoadingMovies {
                moviesListView?.showLoadingFooter()
            } else {
                moviesListView?.hideLoadingFooter()
            }
        }
    }
    
    private var isSearching = false
    private var queryText = "" {
        didSet {
            isSearching = !queryText.isEmpty
        }
    }
    private var debounceTimer: Timer?
    private let debounceDelay: TimeInterval = 0
    
    private var networkService: AlamoNetworkingServiceProtocol
    private var dataSource: MoviesDataSource!
    
    weak var moviesListView: MoviesListView!
    
    var didSelectMovieWithId: ((Int) -> Void)?
    
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
                            completion?(.success(()))
                        } catch {
                            print("Failed to encode genres: \(error.localizedDescription)")
                            completion?(.failure(.failedToDecodeGenres))
                        }

                    case .error(let networkError):
                        print("func to show \(networkError) alert")
                        completion?(.failure(networkError))
                    }
                    
                }
            )
    }
    
    func loadMore(isRefreshing: Bool = false, _ completion: ((Result<(), NetworkError>) -> Void)? = nil) {
        guard !isLoadingMovies else { return }
        isLoadingMovies = true
        
        loadMovies(
            endpoint: .discoverMovie,
            parameters: DiscoverMoviesList(
                page: moviesListStatus.nextPageToLoad,
                sortBy: currentSortBy
            ),
            shouldReset: isRefreshing,
            isSearch: false,
            completion: completion
        )
    }

    func search(by text: String, isRefreshing: Bool = false, completion: @escaping (Result<(), NetworkError>) -> Void) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            isSearching = false
            dataSource.resetMoviesList()
            resetSearch()
            isLoadingMovies = false
            return
        }
        
        guard !isLoadingMovies else { return }
        isLoadingMovies = true
        
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(
            withTimeInterval: debounceDelay,
            repeats: false
        ) { [weak self] _ in
            guard let self else { return }
            
            let isNewQueryText = queryText != trimmedText
            if isNewQueryText {
                resetSearchedPageStats()
                queryText = trimmedText
            }
            
            loadMovies(
                endpoint: .searchMoive,
                parameters: SearchMovieList(
                    query: queryText,
                    page: searchedMoviesStatus.nextPageToLoad
                ),
                shouldReset: isRefreshing || isNewQueryText,
                isSearch: true,
                completion: completion
            )
        }
    }

    private func loadMovies(
        endpoint: MoviesEndpoint,
        parameters: NetworkRequestBodyConvertible,
        shouldReset: Bool,
        isSearch: Bool,
        completion: ((Result<(), NetworkError>) -> Void)? = nil
    ) {

        let status = isSearch ? searchedMoviesStatus : moviesListStatus
        guard status.currentPage <= status.maxPossiblePagesToLoad,
              status.currentPage <= status.totalLoadedPages
        else {
            completion?(.success(()))
            isLoadingMovies = false
            return
        }

        networkService.perform(
            .get,
            endpoint,
            parameters,
            completion: { [weak self] result in
                guard let self else { return }
                switch result {
                case .data(let data):
                    guard let data,
                          let moviesResults = try? JSONDecoder().decode(MoviesListDTO.self, from: data)
                    else { return }
                    self.updateState(
                        with: moviesResults,
                        shouldReset: shouldReset,
                        isSearching: isSearch
                    )
                    completion?(.success(()))
                case .error(let error):
                    completion?(.failure(error))
                }
                self.isLoadingMovies = false
                print("after loading: \(isLoadingMovies)")
            }
        )
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
    
    func checkWhenToLoad(on indexPath: IndexPath) {
        if dataSource.diffable.snapshot().numberOfSections - 1 == indexPath.section {
            let currentSection = dataSource.diffable.snapshot().sectionIdentifiers[indexPath.section]
            if dataSource.diffable.snapshot().numberOfItems(inSection: currentSection) - 3 == indexPath.row {
                if isSearching {
                    search(by: queryText, completion: { _ in })
                } else {
                    loadMore()
                }
            }
        }
    }
    
    func retrieveMovieIdToShow(by row: Int) {
        let movieId = isSearching ? dataSource.searchedMovies[row].id  : dataSource.movies[row].id
        didSelectMovieWithId?(movieId)
    }
    
}

// MARK: - Helpers to reset values
private extension MoviesListPresenter {
    
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

// MARK: - Helpers update state
private extension MoviesListPresenter {
    func updateState(
        with model: MoviesListDTO,
        shouldReset: Bool = false,
        isSearching: Bool = false
    ) {
        
        guard let data = DataCache.instance.readData(forKey: CacheItemKey.movieGenresList.rawValue),
              let genres = try? JSONDecoder().decode([GenreItemDTO].self, from: data)
        else { return }
        
        let movies = model.results.compactMap {
            let newValue = MoviePreviewModel(from: $0, genres: genres)
            let moviesList = isSearching ? dataSource.searchedMovies : dataSource.movies
            if let newValue, (!moviesList.contains(newValue) || shouldReset) {
                return newValue
            }
            return nil
        }
        
        if isSearching {
            updateSearchState(with: model, movies: movies, shouldReset: shouldReset)
        } else {
            updateRegularState(with: model, movies: movies, shouldReset: shouldReset)
        }
        
    }
    
    func updateSearchState(with model: MoviesListDTO, movies: [MoviePreviewModel], shouldReset: Bool) {
        dataSource.updateForSearch(with: movies, shouldReset: shouldReset)
        moviesListView.reloadData()
        
        searchedMoviesStatus.currentPage = model.page
        searchedMoviesStatus.nextPageToLoad = model.page + 1
        searchedMoviesStatus.maxPossiblePagesToLoad = model.totalPages
        
        incrementTotalLoadedSearchedPage()
    }

    func updateRegularState(with model: MoviesListDTO, movies: [MoviePreviewModel], shouldReset: Bool) {
        dataSource.update(with: movies, shouldReset: shouldReset)
        moviesListView.reloadData()
        
        moviesListStatus.currentPage = model.page
        moviesListStatus.nextPageToLoad = model.page + 1
        moviesListStatus.maxPossiblePagesToLoad = model.totalPages
        
        incrementTotalLoadedPage()
    }
}
