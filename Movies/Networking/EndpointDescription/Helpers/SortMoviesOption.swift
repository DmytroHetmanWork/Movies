//
//  SortMoviesOption.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import Foundation

enum SortMoviesOption: CaseIterable {
    case popularityDesc
    case revenueDesc
    case titleAsc
    case titleDesc
    case primaryReleaseDateAsc
    case primaryReleaseDateDesc
}

extension SortMoviesOption {
    var string: String {
        switch self {
        case .popularityDesc:
            "popularity.desc"
        case .revenueDesc:
            "revenue.desc"
        case .titleAsc:
            "title.asc"
        case .titleDesc:
            "title.desc"
        case .primaryReleaseDateAsc:
            "primary_release_date.asc"
        case .primaryReleaseDateDesc:
            "primary_release_date.desc"
        }
    }
    
    var navigationTitle: String {
        switch self {
        case .popularityDesc:
            .localized(LocalizedKey.Sorting.popularMovies)
        case .revenueDesc:
            .localized(LocalizedKey.Sorting.mostRevenue)
        case .titleAsc:
            .localized(LocalizedKey.Sorting.titleAscending)
        case .titleDesc:
            .localized(LocalizedKey.Sorting.titleDescending)
        case .primaryReleaseDateAsc:
            .localized(LocalizedKey.Sorting.oldestMovies)
        case .primaryReleaseDateDesc:
            .localized(LocalizedKey.Sorting.newestMovies)
        }
    }
    
}
