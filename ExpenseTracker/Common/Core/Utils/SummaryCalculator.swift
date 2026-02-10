//
//  SummaryCalculator.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 05/02/26.
//

import Foundation

func calculateSummaryMetrics(
    from transactions: [TransactionEntity]
) -> SummaryMetrics {

    var income: Double = 0
    var expense: Double = 0

    for transaction in transactions {
        switch TransactionType(rawValue: transaction.type ?? "") {
        case .income:
            income += transaction.amount
        case .expense:
            expense += transaction.amount
        default:
            break
        }
    }

    return SummaryMetrics(
        totalIncome: income,
        totalExpense: expense,
        transactionCount: transactions.count
    )
}
