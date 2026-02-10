//
//  TransactionsViewModel.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 26/01/26.
//

import Foundation
import CoreData
import Combine

final class TransactionViewModel: ObservableObject {

    @Published private(set) var transactions: [TransactionEntity] = []

    private let repository: TransactionRepository

    init(repository:TransactionRepository) {
        self.repository = repository
        loadTransactions()
    }

    func loadTransactions() {
        transactions = repository.fetchTransactions()
    }

    func addTransaction(
        title: String,
        amount: Double,
        type: TransactionType,
        category: String,
        date: Date
    ) {
        repository.createTransaction(
            title: title,
            amount: amount,
            type: type,
            category: category,
            date: date
        )
        loadTransactions()
    }

    func updateTransaction(
        transaction: TransactionEntity,
        title: String,
        amount: Double,
        type: TransactionType,
        category: String,
        date: Date
    ) {
        repository.updateTransaction(
            transaction,
            title: title,
            amount: amount,
            category: category,
            type: type,
            date: date
        )
        loadTransactions()
    }

    func deleteTransaction(_ transaction: TransactionEntity) {
        repository.deleteTransaction(transaction)
        loadTransactions()
    }

    func undoDeleteTransaction(_ transaction: TransactionEntity) {
        repository.undoDelete(transaction)
        loadTransactions()
    }
    
    func deleteTransactions(_ transactions: [TransactionEntity]) {
        transactions.forEach {
            repository.deleteTransaction($0)
        }
        loadTransactions()
    }

    func undoDeleteTransactions(_ transactions: [TransactionEntity]) {
        transactions.forEach {
            repository.undoDelete($0)
        }
        loadTransactions()
    }
}
