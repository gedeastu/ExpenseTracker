//
//  CurrencyResponse.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 15/02/26.
//

import Foundation

struct CurrencyResponse: Decodable {
    let result: String
    let base_code: String
    let rates: [String: Double]
}
