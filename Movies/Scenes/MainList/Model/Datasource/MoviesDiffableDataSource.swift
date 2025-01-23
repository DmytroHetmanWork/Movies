//
//  MoviesDiffableDataSource.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import UIKit

final class MoviesDataSource {
    
    typealias SectionModel = MoviesListPresenter.MoviesSectionModel
    
    private var diffable: UITableViewDiffableDataSource<SectionModel, MoviePreviewModel>!
    
    init(tableView: UITableView) {
        self.diffable = .init(
            tableView: tableView,
            cellProvider: { tableView, indexPath, movie in
                let cell: MoviePreviewTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.config(from: movie)
                return cell
            })
    }

    func update(with movies: [MoviePreviewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionModel, MoviePreviewModel>()
        snapshot.appendSections([.movies])
        snapshot.appendItems(movies, toSection: .movies)
        diffable.apply(snapshot, animatingDifferences: true)
    }
}
