//
//  EndpointInstructions.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import Foundation

struct DiscoverMoviesList: NetworkRequestBodyConvertible {
    
    var includeAdult: Bool
    var includeVideo: Bool
    var language: AvailableLanguages
    var page: Int
    var sortBy: SortMoviesOption
    
    init(includeAdult: Bool = false, includeVideo: Bool = false, language: AvailableLanguages = .enUS, page: Int, sortBy option: SortMoviesOption) {
        self.includeAdult = includeAdult
        self.includeVideo = includeVideo
        self.language = language
        self.page = page
        self.sortBy = option
    }
    
    var data: Data? { nil }
    
    var queryItems: [URLQueryItem]? {
        [
            URLQueryItem(name: "include_adult", value: includeAdult.description),
            URLQueryItem(name: "include_video", value: includeVideo.description),
            URLQueryItem(name: "language", value: language.rawValue),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "sort_by", value: sortBy.string),
        ]
    }
    var parameters: [String : Any]? { nil }
}

struct MovieImage: NetworkRequestBodyConvertible {
    var data: Data? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var parameters: [String : Any]? { nil }
}
