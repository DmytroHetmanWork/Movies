//
//  MoviePreviewModel.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import UIKit

struct MoviePreviewModel: Hashable {
    let title: String
    let year: String
    let genres: String
    let rating: String
    let imagePath: String
    let image: UIImage?
    
    init(from dto: MovieItemDTO, genreMap: [Int: String] = [:]) {
        self.title = dto.title
        self.year = String(dto.releaseDate.prefix(4))
        self.genres = dto.genreIds
            .compactMap { genreMap[$0] }
            .joined(separator: ", ")
        self.rating = String(format: "%.1f", dto.voteAverage)
        self.imagePath = dto.posterPath
        self.image = nil
    }
}
