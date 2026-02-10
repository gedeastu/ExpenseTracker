//
//  NumberFormatter+Currency.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 30/01/26.
//

import Foundation

extension NumberFormatter {
    static let currencyID: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        return formatter
    }()
}

