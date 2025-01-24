//
//  Endpoint.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import Foundation

enum MoviesEndpoint: String, Endpoint {
    
    case discoverMovie = "discover/movie"
    case movieGenresList = "genre/movie/list"
    case searchMoive = "search/movie"
    
    var pathComponent: String {
        rawValue
    }
    
}

struct MovieImageEndpoint: Endpoint {
    
    let imagePath: String
    
    init(imagePath: String) {
        self.imagePath = imagePath
    }
    
    var pathComponent: String {
        imagePath
    }
    
}
