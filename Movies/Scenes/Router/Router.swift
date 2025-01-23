//
//  Router.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import UIKit

protocol MoviesRouter {
    var navigationController: UINavigationController? { get set }
    var assemblyBuilder: AssemblyBuilderProtocol? { get set }
}

protocol RouterProtocol: MoviesRouter {
    func startMoviesListViewController()
    func selectSorting()
    func showMovieDetail(by id: Int)
    func showTrailer()
}


final class Router: RouterProtocol {
    
    var navigationController: UINavigationController?
    var assemblyBuilder: AssemblyBuilderProtocol?
    
    init(navigationController: UINavigationController, assemblyBuilder: AssemblyBuilderProtocol) {
        self.navigationController = navigationController
        self.assemblyBuilder = assemblyBuilder
    }
    
    func startMoviesListViewController() {
        guard let moviesListVC = assemblyBuilder?.createMoviesModule(router: self) else { return }
        navigationController?.viewControllers = [moviesListVC]
    }
    
    func selectSorting() {
        
    }
    
    func showMovieDetail(by id: Int) {
        
    }
    
    func showTrailer() {
        
    }
    
}
