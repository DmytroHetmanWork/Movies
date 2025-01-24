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
    
    // Initializer to create MoviePreviewModel from MovieItemDTO
    init(from dto: MovieItemDTO, genreMap: [Int: String] = [:]) {
        self.title = dto.title
        self.year = String(dto.releaseDate.prefix(4)) // Extract year from release date
        self.genres = dto.genreIds
            .compactMap { genreMap[$0] } // Map genre IDs to genre names using the genreMap
            .joined(separator: ", ") // Combine genres into a comma-separated string
        self.rating = String(format: "%.1f", dto.voteAverage) // Format rating to 1 decimal place
        self.imagePath = dto.posterPath
        self.image = nil // Set this to nil or fetch the image asynchronously elsewhere
    }
}
