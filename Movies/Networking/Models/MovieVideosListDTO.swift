//
//  MovieVideosListDTO.swift
//  Movies
//
//  Created by Dmytro Hetman on 28.01.2025.
//

import Foundation

struct MovieVideosListDTO: Codable {
    
    enum VideoType: String {
        case trailer = "Trailer"
    }
    
    enum VideoSite: String {
        case youtube = "YouTube"
    }
    
    let results: [MovieVideoItemDTO]
    
    func getTrailerModel() -> MovieTrailerModel? {
        guard let trailer = results.last(
            where: {
                $0.type == VideoType.trailer.rawValue && $0.site == VideoSite.youtube.rawValue
            })
        else {
            return nil
        }
        return MovieTrailerModel(id: trailer.key)
    }
}

struct MovieVideoItemDTO: Codable {
    
    let site: String
    let type: String
    let key: String
    
}
