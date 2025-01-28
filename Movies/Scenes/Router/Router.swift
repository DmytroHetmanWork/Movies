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
    func showMovieDetail(by id: Int)
    func showTrailer(by id: YouTubeVideoID)
}


final class Router: RouterProtocol {
    
    var navigationController: UINavigationController?
    var assemblyBuilder: AssemblyBuilderProtocol?
    
    init(navigationController: UINavigationController, assemblyBuilder: AssemblyBuilderProtocol) {
        self.navigationController = navigationController
        self.assemblyBuilder = assemblyBuilder
        
        setupNetworkListener()
    }
    
    func startMoviesListViewController() {
        guard let moviesListVC = assemblyBuilder?.createMoviesModule(router: self) else { return }
        navigationController?.viewControllers = [moviesListVC]
    }
    
    func showMovieDetail(by id: Int) {
        guard let movieDetailsVC = assemblyBuilder?.createMoviesDetails(by: id, router: self) else { return }
        navigationController?.pushViewController(movieDetailsVC, animated: true)
    }
    
    func showTrailer(by id: YouTubeVideoID) {
        guard let playerVC = assemblyBuilder?.createTrailerPlayer(by: id) else { return }
        
        playerVC.modalPresentationStyle = .fullScreen
        navigationController?.present(playerVC, animated: true)
    }
    
    // MARK: - Network layer
    
    private func setupNetworkListener() {
        let networkListener = NetworkListener.shared
        
        networkListener.setConnectionLostClosure { [weak self] in
            DispatchQueue.main.async {
                self?.navigationController?.showAlert(error: NetworkError.youAreOffline)
            }
        }
        
        networkListener.setConnectionBackClosure {
            DispatchQueue.main.async {
                print("Internet is back!")
            }
        }
        
        networkListener.startMonitoring()
    }
    
}
