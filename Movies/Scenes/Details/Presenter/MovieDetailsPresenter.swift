//
//  MovieDetailsPresenter.swift
//  Movies
//
//  Created by Dmytro Hetman on 26.01.2025.
//

import Foundation
import DataCache

protocol MovieDetailsPresenterProtocol: AnyObject {
    func attachView(_ view: MovieDetailsViewProtocol)
    
    func showTrailer()
    var didRequestTrailer: ((YouTubeVideoID) -> Void)? { get set }
}

final class MovieDetailsPresenter: MovieDetailsPresenterProtocol {
    
    let movieID: Int
    
    private weak var view: MovieDetailsViewProtocol?
    
    private var movie: MovieDetailsModel?
    private var trailer: MovieTrailerModel?
    private var networkService: AlamoNetworkingServiceProtocol
    
    var didRequestTrailer: ((YouTubeVideoID) -> Void)?
    
    var navigationTitle: String {
        movie?.title ?? ""
    }
    
    init(movieID: Int, networkService: AlamoNetworkingServiceProtocol) {
        self.movieID = movieID
        self.networkService = networkService
    }
    
    func attachView(_ view: MovieDetailsViewProtocol) {
        self.view = view
        loadMovieDetails { result in
            switch result {
            case .success(_):
                break
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func loadMovieDetails(completion: @escaping (Result<(), NetworkError>) -> Void) {
        networkService
            .perform(
                .get,
                MovieDetailsEndpoint(id: "\(movieID)"),
                MovieDetails(),
                completion: { [weak self] result in
                
                    switch result {
                    case .data(let data):
                        guard let data else {
                            completion(.failure(.noData))
                            return
                        }
                              
                        guard let details = try? JSONDecoder().decode(MovieDetailsDTO.self, from: data) else {
                            completion(.failure(.apiIssue))
                            return
                        }
                        
                        self?.movie = details.parseToModel()
                        
                        self?.loadTrailerDetails(for: "\(details.id)") { result in
                            switch result {
                            case .success():
                                self?.viewDidLoad()
                                completion(.success(()))
                            case .failure(let networkError):
                                completion(.failure(networkError))
                            }
                        }
                        
                    case .error(let networkError):
                        completion(.failure(networkError))
                    }
            })
    }
    
    private func loadTrailerDetails(for id: String, completion: @escaping (Result<(), NetworkError>) -> Void) {
        AlamoNetworking<MovieVideosEndpoint>(APIHost.themoviedb, headers: MoviesAPIHeader.value)
            .perform(
                .get,
                MovieVideosEndpoint(id: id),
                MovieVideos(),
                completion: { [weak self] result in
                
                    switch result {
                    case .data(let data):
                        guard let data else {
                            completion(.failure(.noData))
                            return
                        }
                              
                        guard let trailer = try? JSONDecoder().decode(MovieVideosListDTO.self, from: data) else {
                            completion(.failure(.apiIssue))
                            return
                        }
                        
                        self?.trailer = trailer.getTrailerModel()
                        
                        completion(.success(()))
                    case .error(let networkError):
                        completion(.failure(networkError))
                    }
            })
    }
    
    private func viewDidLoad() {
        DispatchQueue.main.async { [weak self] in
            guard let self, let movie else { return }
            view?.display(movie)
            view?.updateNavigationTitle(navigationTitle)
            view?.setupTrailerButton(trailer != nil)
        }
    }
    
    func showTrailer() {
        guard let trailer else {
            view?.showAlert(.noData)
            return
        }
        
        didRequestTrailer?(YouTubeVideoID(value: "\(trailer.id)"))
    }
    
}

