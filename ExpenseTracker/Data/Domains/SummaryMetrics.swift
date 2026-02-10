//
//  SummaryMetrics.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 05/02/26.
//

import Foundation

struct SummaryMetrics {
    let totalIncome: Double
    let totalExpense: Double
    let transactionCount: Int

    var balance: Double {
        totalIncome - totalExpense
    }
}
