//
//  LocalizedKey.swift
//  Movies
//
//  Created by Dmytro Hetman on 28.01.2025.
//

enum LocalizedKey {
    
    enum Sorting {
        static let mostRevenue = "sorting_most_revenue"
        static let newestMovies = "sorting_newest_movies"
        static let oldestMovies = "sorting_oldest_movies"
        static let popularMovies = "sorting_popular_movies"
        static let titleAscending = "sorting_title_ascending"
        static let titleDescending = "sorting_title_descending"
    }
    
    enum Title {
        static let chooseOption = "title_choose_option"
        static let mainNavigation = "title_main_navigation"
        static let notRated = "title_not_rated"
        static let rating = "title_rating"
        static let search = "title_search"
        static let ok = "title_OK"
        static let noResultsFound = "title_no_results_table"
        static let error = "title_error"
    }
    
    enum Message {
        static let selectSorting = "message_select_sorting"
        static let offlineMode = "message_offline_mode"
        static let undefinedError = "message_undefined_error"
        static let apiIssue = "message_api_issue"
        static let invalidAPIKey = "message_invalid_api_key"
        static let noData = "message_no_data"
        static let networkError = "message_network_error_with_code"
    }
    
    static let cancel = "cancel"
    
}
