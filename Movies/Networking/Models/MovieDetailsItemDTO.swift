//
//  MovieDetailsItemDTO.swift
//  Movies
//
//  Created by Dmytro Hetman on 26.01.2025.
//

import Foundation
import DataCache

struct MovieDetailsDTO: Codable {
    let adult: Bool
    let genres: [GenreItemDTO]
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
        case genres
        case originCountry = "origin_country"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case posterPath = "poster_path"
        case releaseDate = "release_date"
    }
}

extension MovieDetailsDTO {
    func parseToModel() -> MovieDetailsModel {
        return MovieDetailsModel(
            title: title,
            description: overview,
            genres: genres
                .map { genre in
                    genre.name
                }
                .joined(separator: ", "),
            rating: voteCount == 0 ? "Not rated" : String(format: "Rating %.1f", voteAverage),
            posterPath: posterPath ?? "",
            originCountry: originCountry
                .compactMap { code in
                    code.countryName
                }
                .joined(separator: ", "),
            year: String(releaseDate.prefix(4))
        )
    }
}
