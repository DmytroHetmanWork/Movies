//
//  AssemblyModelBuilder.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import UIKit

protocol AssemblyBuilderProtocol {
    func createMoviesModule(router: RouterProtocol) -> MoviesListView
    func createMoviesDetails(by id: Int, router: RouterProtocol) -> MovieDetailsViewProtocol
    func createTrailerPlayer(by videoID: YouTubeVideoID) -> UIViewController
}

final class AssemblyModelBuilder: AssemblyBuilderProtocol {
    func createMoviesModule(router: RouterProtocol) -> MoviesListView {
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
    
    func createMoviesDetails(by id: Int, router: RouterProtocol) -> MovieDetailsViewProtocol {
        let presenter = MovieDetailsPresenter(
            movieID: id,
            networkService: AlamoNetworking<MovieDetailsEndpoint>(
                APIHost.themoviedb,
                headers: MoviesAPIHeader.value
            )
        )
        
        presenter.didRequestTrailer = { id in
            router.showTrailer(by: id)
        }
        let view = MovieDetailsViewController(presenter: presenter)
        return view
    }
    
    func createTrailerPlayer(by videoID: YouTubeVideoID) -> UIViewController {
        let view = YouTubePlayerViewController(id: videoID)
        return view
    }
}
