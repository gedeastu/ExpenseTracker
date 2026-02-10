//
//  TransactionType.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 26/01/26.
//

import Foundation
enum TransactionType: String, CaseIterable {
    case income
    case expense
    var displayName: String {
        self == .expense ? "Expense" : "Income"
    }
}
