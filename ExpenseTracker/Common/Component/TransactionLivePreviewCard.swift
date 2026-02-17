//
//  TransactionLivePreviewCard.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 28/01/26.
//

import Foundation
import SwiftUI
struct TransactionPreviewCard: View {

    let title: String
    let amount: Double
    let type: TransactionType
    let category: String
    let date: Date
    let onEdit: () -> Void
    let showCurrencySymbol: Bool
    @AppStorage("selectedCurrency") private var selectedCurrency: String = "IDR"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayTitle)
                        .font(.headline)
                        .foregroundStyle(title.isEmpty ? .secondary : .primary)
                    Spacer()
                    HStack(spacing: 6) {
                        Text(displayCategory)
                        Text("•")
                        Text(type.displayName)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                Spacer(minLength: 1)

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(displayAmount)
                    }
                    .font(.headline)
                    .foregroundStyle(type == .expense ? .red : .green)
                    Spacer(minLength: 1)
                    Button {
                        onEdit()
                    } label: {
                        Image(systemName: "pencil").fontWeight(.bold)
                            .font(.system(size: 24)) 
                            .foregroundStyle(.green)
                    }
                    .buttonStyle(.borderless)
                }
            }

            Text(displayDate)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
    }

    private var displayTitle: String {
        title.isEmpty ? "Judul Transaksi" : title
    }

    private var displayAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "Rp"
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","

        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }

    private var displayCategory: String {
        guard !category.isEmpty else { return "Kategori" }
        return category
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    private var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
