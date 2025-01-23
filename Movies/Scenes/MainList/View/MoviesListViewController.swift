//
//  MoviesListViewController.swift
//  Movies
//
//  Created by Dmytro Hetman on 22.01.2025.
//

import UIKit

final class MoviesListViewController: UIViewController {
    
    private let moviesTableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private let searchBar = {
        let searchBar = UISearchBar()
        searchBar.text = ""
        searchBar.placeholder = "Search"
        return searchBar
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }

    private func setup() {
        setupTableView()
    }
    
    private func setupTableView() {
        
    }
}

