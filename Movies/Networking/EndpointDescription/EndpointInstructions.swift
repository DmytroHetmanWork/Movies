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
    
    init(includeAdult: Bool = false, includeVideo: Bool = true, language: AvailableLanguages = .enUS, page: Int, sortBy option: SortMoviesOption) {
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

struct SearchMovieList: NetworkRequestBodyConvertible {
    
    let query: String
    let includeAdult: Bool
    let language: AvailableLanguages
    let page: Int
    
    init(query: String, includeAdult: Bool = false, language: AvailableLanguages = .enUS, page: Int) {
        self.query = query
        self.includeAdult = includeAdult
        self.language = language
        self.page = page
    }
    
    var data: Data? { nil }
    
    var queryItems: [URLQueryItem]? {
        [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "include_adult", value: includeAdult.description),
            URLQueryItem(name: "language", value: language.rawValue),
            URLQueryItem(name: "page", value:  "\(page)"),
        ]
    }
    var parameters: [String : Any]? { nil }
}

struct MovieGenres: NetworkRequestBodyConvertible {
    
    let language: AvailableLanguages
    
    init(language: AvailableLanguages = .enUS) {
        self.language = language
    }
    
    var data: Data? { nil }
    var queryItems: [URLQueryItem]? {
        [
            URLQueryItem(name: "language", value: language.rawValue),
        ]
    }
    var parameters: [String : Any]? { nil }
}

struct MovieImage: NetworkRequestBodyConvertible {
    var data: Data? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var parameters: [String : Any]? { nil }
}

struct MovieDetails: NetworkRequestBodyConvertible {
    var data: Data? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var parameters: [String : Any]? { nil }
}

struct MovieVideos: NetworkRequestBodyConvertible {
    var data: Data? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var parameters: [String : Any]? { nil }
}
