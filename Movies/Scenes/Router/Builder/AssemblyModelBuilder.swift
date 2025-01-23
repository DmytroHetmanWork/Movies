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
        let presenter = MoviesListPresenter()
        let view = MoviesListViewController(presenter: presenter)
        return view
    }
}
