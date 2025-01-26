//
//  AssemblyModelBuilder.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import UIKit

protocol AssemblyBuilderProtocol {
    func createMoviesModule(router: RouterProtocol) -> UIViewController
    func createMoviesDetails(by id: Int, router: RouterProtocol) -> UIViewController
}

final class AssemblyModelBuilder: AssemblyBuilderProtocol {
    func createMoviesModule(router: RouterProtocol) -> UIViewController {
        let presenter = MoviesListPresenter(
            networkService: AlamoNetworking<MoviesEndpoint>(
                APIHost.themoviedb,
                headers: MoviesAPIHeader.value
            )
        )
        presenter.didSelectMovieWithId = { id in
            router.showMovieDetail(by: id)
        }
        let view = MoviesListViewController(presenter: presenter)
        return view
    }
    
    func createMoviesDetails(by id: Int, router: RouterProtocol) -> UIViewController {
        let presenter = MovieDetailsPresenter(
            movieID: id,
            networkService: AlamoNetworking<MovieDetailsEndpoint>(
                APIHost.themoviedb,
                headers: MoviesAPIHeader.value
            )
        )
        
        let view = MovieDetailsViewController(presenter: presenter)
        return view
    }
}
