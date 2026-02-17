//
//  SummaryView.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 25/01/26.
//

import Foundation
import SwiftUI
import CoreData

struct SummaryView: View {

    @StateObject private var vm: SummaryViewModel

    init(context: NSManagedObjectContext) {
        _vm = StateObject(
            wrappedValue: SummaryViewModel(context: context)
        )
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {

                    SummaryFilterBar(vm: vm)
                    
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            SummaryKPICard(
                                title: "Income",
                                value: vm.convertedIncome,
                                currencyCode: vm.selectedCurrency,
                                color: .green
                            )
                            SummaryKPICard(
                                title: "Expense",
                                value: vm.convertedExpense,
                                currencyCode: vm.selectedCurrency,
                                color: .red
                            )
                        }

                        SummaryKPICard(
                            title: "Balance",
                            value: vm.convertedBalance,
                            currencyCode: vm.selectedCurrency,
                            color: vm.convertedBalance >= 0 ? .green : .red
                        )
                    }

                    Text("\(vm.metrics.transactionCount) transaksi")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()
                    
                    if vm.chartData.isEmpty {
                        Text("Tidak ada data untuk ditampilkan")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(height: 220)
                    } else {
                        SummaryBarChart(data: vm.chartData, currencyCode: vm.selectedCurrency)
                    }
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 6) {
                            Image(systemName: "dollarsign.circle")
                                .foregroundColor(.green)

                            Picker("", selection: $vm.selectedCurrency) {

                                Text("🇮🇩 IDR").tag("IDR")

                                ForEach(vm.rates.keys.sorted(), id: \.self) { code in
                                    Text("\(flagEmoji(for: code)) \(code)")
                                        .tag(code)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                            .frame(width: 90)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Dynamic Flag Generator

    private func flagEmoji(for currency: String) -> String {
        let region = Locale.current.localizedString(forCurrencyCode: currency)?
            .split(separator: " ")
            .last?
            .uppercased() ?? currency

        return emojiFlag(for: regionCode(from: currency))
    }

    private func regionCode(from currency: String) -> String {
        if let locale = Locale.availableIdentifiers
            .compactMap({ Locale(identifier: $0) })
            .first(where: { $0.currency?.identifier == currency }),
           let region = locale.region?.identifier {
            return region
        }

        return String(currency.prefix(2)).uppercased()
    }

    private func emojiFlag(for regionCode: String) -> String {
        let base: UInt32 = 127397
        var scalarString = ""
        for scalar in regionCode.uppercased().unicodeScalars {
            if let flagScalar = UnicodeScalar(base + scalar.value) {
                scalarString.unicodeScalars.append(flagScalar)
            }
        }
        return scalarString.isEmpty ? "🏳️" : scalarString
    }

}
