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
    func loadMore()
    func newSortingSelected(sortBy: SortMoviesOption)
    func serch(by text: String)
}

final class MoviesListPresenter: MoviesListPresenterProtocol {
    
    enum MoviesSectionModel: Int {
        case movies
    }
    
    private var currentSortBy: SortMoviesOption = .popularityDesc
    private var currentPage: Int = 1
    private var totalPages: Int = 1
    
    private var networkService: AlamoNetworking<MoviesEndpoint>
    
    weak var moviesListView: MoviesListView!
    
    private var dataSource: MoviesDataSource!
    
    init(networkService: AlamoNetworking<MoviesEndpoint>) {
        self.networkService = networkService
        
    }
    
    func setupDatasource() {
        dataSource = MoviesDataSource(tableView: moviesListView.moviesTableView)
        moviesListView.moviesTableView.dataSource = dataSource.diffable
    }
    
    func loadMore() {
        guard currentPage <= totalPages else { return }
        
        networkService
        .perform(
            .get,
            .discoverMovie,
            DiscoverMoviesList(
                page: currentPage,
                sortBy: currentSortBy
            ),
            completion: { [weak self] result in
                switch result {
                case .data(let data):
                    guard let data,
                          let moviesResults = try? JSONDecoder().decode(MoviesListDTO.self, from: data)
                    else { return }
                    
                    let movies = moviesResults.results.map {
                        MoviePreviewModel(from: $0)
                    }
                    
                    self?.dataSource.update(with: movies)
                    
                    DispatchQueue.main.async {
                        self?.moviesListView.moviesTableView.reloadData()
                    }
                    
                    self?.incrementCurrentPage()
                case .error(let error):
                    print(error)
                }
            })
    }
    
    func newSortingSelected(sortBy: SortMoviesOption) {
        resetCurrentPage()
        
        networkService
        .perform(
            .get,
            .discoverMovie,
            DiscoverMoviesList(
                page: currentPage,
                sortBy: sortBy
            ),
            completion: { [weak self] result in
                switch result {
                case .data(let data):
                    guard let data,
                          let _ = try? JSONDecoder().decode(MoviesListDTO.self, from: data)
                    else { return }
                    self?.incrementCurrentPage()
                case .error(let error):
                    print(error)
                }
            })
    }
    
    func serch(by text: String) {
        //
    }
    
    private func resetCurrentPage() {
        currentPage = 1
        totalPages = 1
    }
    
    private func incrementCurrentPage() {
        currentPage += 1
        totalPages += 1
    }
    
}
