//
//  MovieDetailsItemDTO.swift
//  Movies
//
//  Created by Dmytro Hetman on 26.01.2025.
//

import Foundation

struct MovieDetailsDTO: Codable {
    let adult: Bool
    let genreIds: [Int]
    let originCountry: [String]
    let id: Int
    let title: String
    let overview: String
    let voteAverage: Double
    let voteCount: Int
    let posterPath: String?
    let releaseDate: String
    
    enum CodingKeys: String, CodingKey {
        case adult
        case id
        case title
        case overview
        case genreIds = "genre_ids"
        case originCountry = "origin_country"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
    }
}
