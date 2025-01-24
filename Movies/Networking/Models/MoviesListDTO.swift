//
//  MoviesListDTO.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import Foundation

struct MoviesListDTO: Codable {
    let page: Int
    let results: [MovieItemDTO]
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
    }
}

struct MovieItemDTO: Codable {
    let adult: Bool
    let genreIds: [Int]
    let id: Int
    let title: String
    let voteAverage: Double
    let posterPath: String
    let releaseDate: String
    
    enum CodingKeys: String, CodingKey {
        case adult
        case id
        case title
        case genreIds = "genre_ids"
        case voteAverage = "vote_average"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
    }
}
