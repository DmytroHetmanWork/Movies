//
//  MoviePreviewModel.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import UIKit
import DataCache

struct MoviePreviewModel: Hashable {
    let id: Int
    let title: String
    let year: String
    let genres: String
    let rating: String
    let imagePath: String
    let image: UIImage?
    
    init?(from dto: MovieItemDTO, genres: [GenreItemDTO]) {
        self.id = dto.id
        self.title = dto.title
        self.year = String(dto.releaseDate.prefix(4))
        self.genres = dto.genreIds
            .compactMap { genreId in
                genres.first(where: { $0.id == genreId })?.name
            }
            .joined(separator: ", ")
        self.rating = String(format: "%.1f", dto.voteAverage)
        self.imagePath = dto.posterPath
        self.image = nil
    }

}
