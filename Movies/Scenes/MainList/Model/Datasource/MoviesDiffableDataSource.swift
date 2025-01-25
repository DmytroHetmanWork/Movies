//
//  MoviesDiffableDataSource.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import UIKit

final class MoviesDataSource {
    
    typealias Movies = [MoviePreviewModel]
    typealias SectionModel = MoviesListPresenter.MoviesSectionModel
    
    var movies: Movies = []
    var searchedMovies: Movies = []
    
    private(set) var diffable: UITableViewDiffableDataSource<SectionModel, MoviePreviewModel>!
    
    init(tableView: UITableView) {
        self.diffable = .init(
            tableView: tableView,
            cellProvider: { tableView, indexPath, movie in
                let cell: MoviePreviewTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.config(from: movie)
                return cell
            })
    }
    
    func resetMoviesList() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, MoviePreviewModel>()
        snapshot.appendSections([.movies])
        snapshot.appendItems(self.movies, toSection: .movies)
        diffable.apply(snapshot, animatingDifferences: true)
    }

    func update(with movies: [MoviePreviewModel], shouldReset: Bool = false) {
        if shouldReset {
            self.movies = movies
        } else {
            self.movies.append(contentsOf: movies)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, MoviePreviewModel>()
        snapshot.appendSections([.movies])
        snapshot.appendItems(self.movies, toSection: .movies)
        diffable.apply(snapshot, animatingDifferences: true)
    }
    
    func updateForSearch(with movies: [MoviePreviewModel], shouldReset: Bool = false) {
        if shouldReset {
            self.searchedMovies = movies
        } else {
            self.searchedMovies.append(contentsOf: movies)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, MoviePreviewModel>()
        snapshot.appendSections([.movies])
        snapshot.appendItems(self.searchedMovies, toSection: .movies)
        diffable.apply(snapshot, animatingDifferences: true)
    }
}
