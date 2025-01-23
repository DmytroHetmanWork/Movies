//
//  AssemblyModelBuilder.swift
//  Movies
//
//  Created by Dmytro Hetman on 23.01.2025.
//

import UIKit

protocol AssemblyBuilderProtocol {
    func createMoviesModule(router: RouterProtocol) -> UIViewController

}

class AssemblyModelBuilder: AssemblyBuilderProtocol {
    func createMoviesModule(router: RouterProtocol) -> UIViewController {
        let view = MoviesListViewController()
        let presenter = MoviesListPresenter()
        return view
    }
}
