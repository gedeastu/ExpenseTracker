//
//  CurrencyAPI.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 15/02/26.
//

import Foundation

enum CurrencyAPI {

    private static let baseURL = "https://open.er-api.com/v6/latest"

    static func latest(base: String) -> URL? {
        let urlString = "\(baseURL)/\(base.uppercased())"
        return URL(string: urlString)
    }
}
