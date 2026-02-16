//
//  SummaryKPICard.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 05/02/26.
//

import Foundation
import SwiftUI

struct SummaryKPICard: View {
    let title: String
    let value: Double
    let currencyCode: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(formatCurrency(value, currencyCode: currencyCode))
                .font(.headline)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }

    private func formatCurrency(_ value: Double, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = Locale(identifier: localeIdentifier(for: currencyCode))
        formatter.maximumFractionDigits = currencyCode == "IDR" ? 0 : 2
        return formatter.string(from: NSNumber(value: value)) ?? "\(currencyCode) 0"
    }

    private func localeIdentifier(for currencyCode: String) -> String {
        switch currencyCode {
        case "IDR": return "id_ID"
        case "USD": return "en_US"
        case "EUR": return "de_DE"
        case "JPY": return "ja_JP"
        case "SGD": return "en_SG"
        default: return Locale.current.identifier
        }
    }
}
