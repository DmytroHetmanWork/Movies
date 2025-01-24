//
//  String+Extension.swift
//  Movies
//
//  Created by Dmytro Hetman on 24.01.2025.
//

import Foundation
import UIKit

extension String {
    
    func add(_ pathComponent: String, _ parameters: NetworkRequestBodyConvertible) -> String {
        let hostWithPath = self.appending(pathComponent)
        var urlComps = URLComponents(string: hostWithPath)!
        urlComps.queryItems = parameters.queryItems
        return urlComps.url?.absoluteString ?? ""
    }
    
    func load(completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        AlamoNetworking<MovieImageEndpoint>(
            APIHost.themoviedbImage,
            headers: MoviesAPIHeader.value
        )
        .perform(
            .get,
            MovieImageEndpoint(imagePath: self),
            MovieImage(),
            completion: { result in
                switch result {
                case .data(let data):
                    guard let data,
                          let image = UIImage(data: data)
                    else { return }
                    
                    completion(.success(image))
                case .error(let networkError):
                    completion(.failure(networkError))
                }
            }
        )
    }
    
}
