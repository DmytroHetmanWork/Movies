//
//  AppDelegate.swift
//  Movies
//
//  Created by Dmytro Hetman on 22.01.2025.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        AlamoNetworking<MoviesEndpoint>(
            APIHost.themoviedb,
            headers: MoviesAPIHeader.value
        )
        .perform(
            .get,
            .discoverMovie,
            DiscoverMoviesList(
                page: 1,
                sortBy: .popularityDesc
            ),
            completion: { result in
                switch result {
                case .data(let data):
                    guard let data,
                          let moviesList = try? JSONDecoder().decode(MoviesListDTO.self, from: data) else { return }
//                    print(moviesList.results)
                    
                    if let first = moviesList.results.last {
                        AlamoNetworking<MovieImageEndpoint>(
                            APIHost.themoviedbImage,
                            headers: MoviesAPIHeader.value
                        )
                        .perform(
                            .get,
                            .init(imagePath: first.posterPath),
                            MovieImage(),
                            completion: { result in
                                switch result {
                                case .data(let data):
                                if let data, let _ = UIImage(data: data) {
                                    print("Image laoded successfully!!!")
                                } else {

                                    guard let data, let res = try? JSONDecoder().decode(APIErrorResponse.self, from: data) else { return }
                                    print(res)
                                }
                            case .error(_):
                                print(NetworkError.failedToLoadImage)
                            }

                        })
                    }
                    
                case .error(_):
                    print(NetworkError.requestTimedOut)
                }
            })
        
        
        
        return true
    }

}



struct APIErrorResponse: Codable {
    let statusCode: Int
    let statusMessage: String
    let success: Bool

    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case statusMessage = "status_message"
        case success
    }
}

