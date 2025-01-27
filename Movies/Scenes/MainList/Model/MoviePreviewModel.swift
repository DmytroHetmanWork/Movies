//
//  MoviePreviewModel.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import UIKit

struct MoviePreviewModel: Hashable {
    let id: Int
    let title: String
    let year: String
    let genres: String
    let rating: String
    let imagePath: String
    
    let imageURL: URL?
    
    init?(from dto: MovieItemDTO, genres: [GenreItemDTO]) {
        self.id = dto.id
        self.title = dto.title
        self.year = String(dto.releaseDate.prefix(4))
        self.genres = dto.genreIds
            .compactMap { genreId in
                genres.first(where: { $0.id == genreId })?.name
            }
            .joined(separator: ", ")
        self.rating = dto.voteCount == 0 ? "Not rated" : String(format: "Rating %.1f", dto.voteAverage)
        self.imagePath = dto.posterPath ?? ""
        
        self.imageURL = URL(string: APIHost.themoviedbImagePreview + imagePath)
        
    }
    
    

}
