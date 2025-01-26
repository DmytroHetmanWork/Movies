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
    func viewDidLoad()
    
}

final class MovieDetailsPresenter: MovieDetailsPresenterProtocol {
    
    private weak var view: MovieDetailsViewProtocol?
    let movieID: Int
    
    private var movie: MovieDetailsModel?
    
    private var networkService: AlamoNetworkingServiceProtocol
    
    var navigationTitle: String {
        movie?.title ?? "Loading..."
    }
    
    init(movieID: Int, networkService: AlamoNetworkingServiceProtocol) {
        self.movieID = movieID
        self.networkService = networkService
    }
    
    func attachView(_ view: MovieDetailsViewProtocol) {
        self.view = view
//        view.updateNavigationTitle(navigationTitle)
        loadMovieDetails { result in
            switch result {
            case .success(let success):
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
                            completion(.failure(.failedToDecodeDetails))
                            return
                        }
                        
                        self?.movie = details.parseToModel()
                        
                        self?.viewDidLoad()
                        
                        completion(.success(()))
                    case .error(let networkError):
                        print(networkError)
                    }
            })
    }
    
    func viewDidLoad() {
        DispatchQueue.main.async { [weak self] in
            guard let self, let movie else { return }
            view?.updateNavigationTitle(navigationTitle)
            view?.display(movie)
            if let image = DataCache.instance.readImage(forKey: movie.posterPath)  {
                view?.displayImage(image)
            } else {
                AlamoNetworking<MovieImageEndpoint>(
                    APIHost.themoviedbImage,
                    headers: MoviesAPIHeader.value
                )
                .perform(.get, MovieImageEndpoint(imagePath: movie.posterPath), MovieImage(), completion: { [weak self] result in
                    
                    switch result {
                    case .data(let data):
                        guard let data else {
                            self?.view?.displayImage(.imageCellBackPlaceholder)
                            return
                        }
                        
                        guard let image = UIImage(data: data) else {
                            self?.view?.displayImage(.imageCellBackPlaceholder)
                            return
                        }
                        
                        DataCache.instance.write(image: image, forKey: movie.posterPath)
                        self?.view?.displayImage(image)
                        
                    case .error(let networkError):
                        print("error")
                    }
                })
                
                
            }
            
        }
    }
}

