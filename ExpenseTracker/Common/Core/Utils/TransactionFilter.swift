//
//  TransactionFilters.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 05/02/26.
//

import Foundation

func filterTransactions(
    _ transactions: [TransactionEntity],
    range: SummaryRange,
    reference: Date = Date()
) -> [TransactionEntity] {

    let calendar = Calendar.current
    let startDate = range.startDate(reference: reference)
    let endDate = range.endDate(reference: reference)

    return transactions.filter { transaction in
        guard
            let date = transaction.date,
            transaction.is_deleted == false
        else {
            return false
        }

        return date >= startDate && date < endDate
    }
}
