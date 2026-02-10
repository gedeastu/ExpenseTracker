//
//  ExpensesView.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 25/01/26.
//

import Foundation
import SwiftUI
import CoreData

struct TransactionsView: View {
    let transactions: [TransactionEntity]
    let onEdit: (TransactionEntity) -> Void
    let onDelete: ([TransactionEntity]) -> Void

    @AppStorage("didShowSwipeHint") private var didShowSwipeHint = false
    @State private var selection = Set<NSManagedObjectID>()
    @Environment(\.editMode) private var editMode

    @State private var pendingDelete: [TransactionEntity] = []
    @State private var showDeleteConfirm = false

    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }

    var body: some View {
        VStack {
            if transactions.isEmpty {
                EmptyExpenseView()
            } else {

                if !didShowSwipeHint {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.draw")
                        Text("Geser transaksi ke kiri untuk menghapus")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            didShowSwipeHint = true
                        }
                    }
                }
                List(selection: $selection) {
                    ForEach(transactions, id: \.objectID) { transaction in
                        TransactionPreviewCard(
                            title: transaction.title ?? "",
                            amount: transaction.amount,
                            type: TransactionType(rawValue: transaction.type ?? "") ?? .expense,
                            category: transaction.category ?? "",
                            date: transaction.date ?? Date(),
                            onEdit: { if !isEditing {
                                editMode?.wrappedValue = .inactive
                                selection.removeAll()
                                onEdit(transaction)
                            }}
                        )
                        .tag(transaction.objectID)

                        .listRowInsets(
                            EdgeInsets(
                                top: 8,
                                leading: 10,
                                bottom: 8,
                                trailing: 16
                            )
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(.systemBackground))

                        .swipeActions {
                            Button(role: .destructive) {
                                pendingDelete = [transaction]
                                showDeleteConfirm = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                                    .tint(.red)
                            }
                        }
                        .contextMenu {
                            Button {
                                onEdit(transaction)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }

                            Button(role: .destructive) {
                                pendingDelete = [transaction]
                                showDeleteConfirm = true
                            } label: {
                                Label("Hapus", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .onLongPressGesture {
                            if !isEditing {
                                withAnimation {
                                    editMode?.wrappedValue = .active
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .environment(\.editMode, editMode)

            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing && !selection.isEmpty {
                    Button(role: .destructive) {
                        deleteSelected()
                    } label: {
                        Text("Hapus (\(selection.count))")
                            .foregroundColor(.red)
                    }
                }
            }

            ToolbarItem(placement: .navigationBarLeading) {
                Button(isEditing ? "Batal" : "Pilih") {
                    withAnimation {
                        if isEditing {
                            selection.removeAll()
                            editMode?.wrappedValue = .inactive
                        } else {
                            editMode?.wrappedValue = .active
                        }
                    }
                }
            }
        }
        .alert("Hapus Transaksi?",
               isPresented: $showDeleteConfirm) {

            Button("Hapus", role: .destructive) {
                onDelete(pendingDelete)
                pendingDelete = []
            }

            Button("Batal", role: .cancel) {
                pendingDelete = []
            }

        } message: {
            Text(pendingDelete.count > 1
                 ? "Apakah kamu yakin ingin menghapus \(pendingDelete.count) transaksi?"
                 : "Apakah kamu yakin ingin menghapus transaksi ini?")
        }
    }

    private func deleteSelected() {
        let selectedTransactions = transactions.filter {
            selection.contains($0.objectID)
        }

        guard !selectedTransactions.isEmpty else { return }

        pendingDelete = selectedTransactions
        showDeleteConfirm = true

        selection.removeAll()
        editMode?.wrappedValue = .inactive
    }
}
