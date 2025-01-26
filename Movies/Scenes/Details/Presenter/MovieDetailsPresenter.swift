//
//  MovieDetailsPresenter.swift
//  Movies
//
//  Created by Dmytro Hetman on 26.01.2025.
//

import Foundation

protocol MovieDetailsPresenterProtocol: AnyObject {

    var id: Int { get }
    
}

final class MovieDetailsPresenter: MovieDetailsPresenterProtocol {
    
    let id: Int
    
    init(id: Int) {
        self.id = id
    }
    
}
