//
//  MoviesListPresenter.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import UIKit

protocol MoviesListPresenterProtocol: AnyObject {

}

final class MoviesListPresenter: MoviesListPresenterProtocol {
    
    enum MoviesSectionModel: Int {
        case movies
    }
    
    weak var moviesListView: MoviesListView!
    
    private var dataSource: MoviesDataSource!
    
    init() {
        dataSource = MoviesDataSource(tableView: moviesListView.moviesTableView)
    }
    
}
