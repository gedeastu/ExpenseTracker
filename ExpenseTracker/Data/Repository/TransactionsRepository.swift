//
//  TransactionsRepository.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 26/01/26.
//

import Foundation
import CoreData
import Combine

final class TransactionRepository {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchTransactions() -> [TransactionEntity] {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)
        ]

        return (try? context.fetch(request)) ?? []
    }
    
    func createTransaction(
        title: String,
        amount: Double,
        type: TransactionType,
        category: String,
        date: Date
    ) {
        let transaction = TransactionEntity(context: context)

        transaction.id = UUID()
        transaction.title = title
        transaction.amount = amount
        transaction.type = type.rawValue
        transaction.category = category
        transaction.date = date
        transaction.created_at = Date()
        transaction.updated_at = Date()
        transaction.isSynced = false
        transaction.is_deleted = false

        saveContext()
    }
    
    private func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
    
    func updateTransaction(
        _ transaction: TransactionEntity,
        title: String,
        amount: Double,
        category: String,
        type: TransactionType,
        date: Date
    ) {
        transaction.title = title
        transaction.amount = amount
        transaction.category = category
        transaction.date = date
        transaction.type = type.rawValue
        transaction.updated_at = Date()
        transaction.isSynced = false

        saveContext()
    }

    func deleteTransaction(_ transaction: TransactionEntity) {
        transaction.is_deleted = true
        transaction.updated_at = Date()
        transaction.isSynced = false
        do{
            try saveContext()
        }catch{
            print("Failed to delete transaction:", error)
        }
    }
    
    func undoDelete(_ transaction: TransactionEntity) {
        transaction.is_deleted = false
        transaction.updated_at = Date()
        transaction.isSynced = false
        do{
            try saveContext()
        }catch{
            print("Failed to undo delete transaction:", error)
        }
    }
}
