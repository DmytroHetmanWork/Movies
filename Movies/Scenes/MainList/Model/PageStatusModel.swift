//
//  PageStatusModel.swift
//  Movies
//
//  Created by Dmytro Hetman on 24.01.2025.
//

import Foundation

struct PageStatusModel {
    var currentPage = 0
    var nextPageToLoad = 1
    var totalLoadedPages = 0
    var maxPossiblePagesToLoad = 0
    
    mutating func reset() {
        currentPage = 0
        nextPageToLoad = 1
        totalLoadedPages = 0
        maxPossiblePagesToLoad = 0
    }
}
