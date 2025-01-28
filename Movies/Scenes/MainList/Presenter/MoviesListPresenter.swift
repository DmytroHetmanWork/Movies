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
    
    func showCachedItems()
}

final class MoviesListPresenter: MoviesListPresenterProtocol {
    
    enum MoviesSectionModel: Int {
        case movies
    }
    
    // MARK: - Current state values
    
    private(set) var currentSortBy: SortMoviesOption = .popularityDesc
    private var moviesListStatus = PageStatusModel()
    private var searchedMoviesStatus = PageStatusModel()
    
    private var isLoadingMovies = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if isLoadingMovies {
                    moviesListView?.showLoadingFooter()
                } else {
                    moviesListView?.hideLoadingFooter()
                }
            }
        }
    }
    
    // MARK: - Searching state values
    
    private var isSearching = false
    private var queryText = "" {
        didSet {
            isSearching = !queryText.isEmpty
        }
    }
    private var debounceTimer: Timer?
    private let debounceDelay: TimeInterval = 0
    
    // MARK: - Private properties
    
    private var networkService: AlamoNetworkingServiceProtocol
    private var dataSource: MoviesDataSource!
    
    // MARK: - View
    
    weak var moviesListView: MoviesListView!
    
    // MARK: - Flow handlers
    
    var didSelectMovieWithId: ((Int) -> Void)?
    
    // MARK: - Initializer
    
    init(networkService: AlamoNetworkingServiceProtocol) {
        self.networkService = networkService
        
    }
    
    // MARK: - Functions
    
    func setupDatasource() {
        dataSource = MoviesDataSource(tableView: moviesListView.moviesTableView)
        moviesListView.moviesTableView.dataSource = dataSource.diffable
    
        if DataCache.instance.hasData(forKey: CacheItemKey.movieGenresList.rawValue) {
            self.initialLoading()
        } else {
            self.loadMoviesGenres { [weak self] result in
                switch result {
                case .success(_):
                    self?.initialLoading()
                case .failure(let error):
                    self?.moviesListView.showNetworkError(error)
                    
                    NetworkListener.shared.addRetryableTask { [weak self] in
                        self?.setupDatasource()
                    }
                }
                
                if !NetworkListener.shared.isReachable {
                    self?.moviesListView.showNetworkLostAlert()
                }
            }
        }
        
    }
    
    func loadMore(isRefreshing: Bool = false, _ completion: ((Result<(), NetworkError>) -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if !NetworkListener.shared.isReachable {
                showCachedItems()
            } else {
                DispatchQueue.global().async { [weak self] in
                    guard let self else { return }
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
            }
        }
        
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
        if !NetworkListener.shared.isReachable {
            searchInOfflineMode(for: trimmedText)
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
                guard let self else { return }
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    moviesListView.showNetworkError(error)
                }
                moviesListView.updateNavigationTitle(currentSortBy.navigationTitle)
                moviesListView.endRefreshing()
            }
        }
    }
    
    // MARK: - Pagination
    
    func checkWhenToLoad(on indexPath: IndexPath) {
        if dataSource.diffable.snapshot().numberOfSections - 1 == indexPath.section {
            let currentSection = dataSource.diffable.snapshot().sectionIdentifiers[indexPath.section]
            if dataSource.diffable.snapshot().numberOfItems(inSection: currentSection) - 3 == indexPath.row {
                if NetworkListener.shared.isReachable {
                    if isSearching {
                        search(by: queryText, completion: { [weak self] result in
                            switch result {
                            case .success(_):
                                break
                            case .failure(let error):
                                self?.moviesListView.showNetworkError(error)
                            }
                        })
                    } else {
                        loadMore()
                    }
                }
            }
        }
    }
    
    // MARK: - Interaction with cell
    
    func retrieveMovieIdToShow(by row: Int) {
        let movieId = isSearching ? dataSource.searchedMovies[row].id  : dataSource.movies[row].id
        didSelectMovieWithId?(movieId)
    }
    
    // MARK: - Cache
    
    func showCachedItems() {
        applyCachedMovies()
    }
    
    // MARK: - Private functions
    
    private func initialLoading() {
        loadMore(isRefreshing: true) { [weak self] result in
            switch result {
            case .success():
                self?.moviesListView.configEmptyTableState(isShowing: false)
            case .failure(let error):
                self?.moviesListView.showNetworkError(error)
            }
            self?.moviesListView.endRefreshing()
        }
    }
    
    private func loadMoviesGenres(_ completion: ((Result<(), NetworkError>) -> Void)? = nil) {
        networkService
            .perform(
                .get,
                MoviesEndpoint.movieGenresList,
                MovieGenres(),
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
                            completion?(.failure(.apiIssue))
                        }

                    case .error(let networkError):
                        completion?(.failure(networkError))
                    }
                    
                }
            )
    }
    
    private func searchInOfflineMode(for text: String) {
        
        isSearching = true
        let filteredMovies = dataSource.movies.filter { movie in
            movie.title.lowercased().contains(text.lowercased())
        }
        
        moviesListView?.configEmptyTableState(isShowing: filteredMovies.isEmpty)
        
        DispatchQueue.main.async { [weak self] in
            self?.dataSource.updateForSearch(with: filteredMovies, shouldReset: true)
            self?.isLoadingMovies = false
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

        networkService
            .perform(
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
                
                isLoadingMovies = false
            }
        )
    }
    
    private func applyCachedMovies() {
        let cachedMovies = loadCachedMovies()
        guard !cachedMovies.isEmpty else {
            moviesListView.configEmptyTableState(isShowing: cachedMovies.isEmpty)
            return
        }
        
        dataSource.update(with: cachedMovies, shouldReset: true)
        moviesListView.reloadData()
        moviesListView.updateNavigationTitle(.localized(LocalizedKey.Title.cachedMovies))
    }
    
}

// MARK: - Helpers to reset values

private extension MoviesListPresenter {
    
    func resetSearch() {
        isSearching = false
        resetSearchedPageStats()
        moviesListView.reloadData()
    }
    
    func resetPageStats() {
        moviesListStatus.reset()
    }
    
    func incrementTotalLoadedPage() {
        moviesListStatus.totalLoadedPages += 1
    }
    
    func resetSearchedPageStats() {
        searchedMoviesStatus.reset()
    }
    
    func incrementTotalLoadedSearchedPage() {
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
        if isSearching {
            updateViewState(for: model, isSearching: true)
        }
        
        guard let genres = loadGenres() else { return }
        var cachedMovies = loadCachedMovies()
        
        let movies = prepareMovies(
            from: model.results,
            genres: genres,
            isSearching: isSearching,
            shouldReset: shouldReset,
            cachedMovies: &cachedMovies
        )
        
        cacheMovies(cachedMovies)
        
        if isSearching {
            updateSearchState(with: model, movies: movies, shouldReset: shouldReset)
        } else {
            updateRegularState(with: model, movies: movies, shouldReset: shouldReset)
        }
    }

    func loadGenres() -> [GenreItemDTO]? {
        guard let data = DataCache.instance.readData(forKey: CacheItemKey.movieGenresList.rawValue),
              let genres = try? JSONDecoder().decode([GenreItemDTO].self, from: data) else {
            return nil
        }
        return genres
    }

    func loadCachedMovies() -> [MoviePreviewModel] {
        guard let cachedData = DataCache.instance.readData(forKey: CacheItemKey.moviesDownloaded.rawValue),
              let movies = try? JSONDecoder().decode([MoviePreviewModel].self, from: cachedData) else {
            return []
        }
        return movies
    }

    func cacheMovies(_ movies: [MoviePreviewModel]) {
        if let cachedData = try? JSONEncoder().encode(movies) {
            DataCache.instance.write(data: cachedData, forKey: CacheItemKey.moviesDownloaded.rawValue)
        }
    }

    func prepareMovies(
        from results: [MovieItemDTO],
        genres: [GenreItemDTO],
        isSearching: Bool,
        shouldReset: Bool,
        cachedMovies: inout [MoviePreviewModel]
    ) -> [MoviePreviewModel] {
        return results.compactMap {
            let newValue = MoviePreviewModel(from: $0, genres: genres)
            let moviesList = isSearching ? dataSource.searchedMovies : dataSource.movies
            
            if let newValue, (!moviesList.contains(newValue) || shouldReset) {
                if !cachedMovies.contains(newValue) {
                    cachedMovies.append(newValue)
                }
                return newValue
            }
            return nil
        }
    }

    func updateViewState(for model: MoviesListDTO, isSearching: Bool) {
        moviesListView?.configEmptyTableState(isShowing: model.results.isEmpty)
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
