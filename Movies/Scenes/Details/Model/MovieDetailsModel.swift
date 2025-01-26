//
//  MovieDetailsModel.swift
//  Movies
//
//  Created by Dmytro Hetman on 26.01.2025.
//

import Foundation

struct MovieDetailsModel {
    
    let title: String
    let description: String
    let genres: String
    let rating: String
    let posterPath: String
    let originCountry: String
    let year: String
    
    var countryYear: String? {
        switch (originCountry.isEmpty, year.isEmpty) {
        case (false, false):
            return "\(originCountry), \(year)"
        case (false, true):
            return originCountry
        case (true, false):
            return year
        default:
            return nil
        }
    }
    
}
