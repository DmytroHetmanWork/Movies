//
//  DataCache+Extension.swift
//  Movies
//
//  Created by Dmytro Hetman on 26.01.2025.
//

import DataCache

extension DataCache {
    func fetchDecodedData<T: Decodable>(forKey key: String, as type: T.Type) -> T? {
        guard let data = readData(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

