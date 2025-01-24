//
//  GenresListDTO.swift
//  Movies
//
//  Created by Dmytro Hetman on 24.01.2025.
//

import Foundation

struct GenresListDTO: Codable {
    let genres: [GenreItemDTO]
}

struct GenreItemDTO: Codable {
    let id: Int
    let name: String
}
