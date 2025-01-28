//
//  MoviePreviewModel.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import UIKit

struct MoviePreviewModel: Hashable, Codable {
    enum Rating: Hashable, Equatable, Codable {
        case none
        case some(String)
    }
    
    let id: Int
    let title: String
    let year: String
    let genres: String
    let rating: Rating
    let imageURL: URL?
    
    init?(from dto: MovieItemDTO, genres: [GenreItemDTO]) {
        self.id = dto.id
        self.title = dto.title
        self.year = String(dto.releaseDate.prefix(4))
        self.imageURL = URL(string: APIHost.themoviedbImagePreview + (dto.posterPath ?? ""))
        
        self.genres = dto.genreIds
            .compactMap { genreId in
                return genres.first(where: { $0.id == genreId })?.name
            }
            .joined(separator: ", ")

        self.rating = dto.voteCount == 0 ? .none : .some(String(format: "%.1f", dto.voteAverage))
    }
}
