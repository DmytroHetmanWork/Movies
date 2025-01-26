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
        if originCountry.isEmpty && !year.isEmpty {
            return year
        } else if !originCountry.isEmpty && year.isEmpty {
            return originCountry
        } else if !originCountry.isEmpty && !year.isEmpty {
            return "\(originCountry), \(year)"
        } else {
            return nil
        }
    }
    
}
