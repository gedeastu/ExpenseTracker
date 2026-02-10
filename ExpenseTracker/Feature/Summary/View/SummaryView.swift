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
                                value: vm.metrics.totalIncome,
                                color: .green
                            )
                            SummaryKPICard(
                                title: "Expense",
                                value: vm.metrics.totalExpense,
                                color: .red
                            )
                        }

                        SummaryKPICard(
                            title: "Balance",
                            value: vm.metrics.balance,
                            color: vm.metrics.balance >= 0 ? .green : .red
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
                        SummaryBarChart(data: vm.chartData)
                    }
                }
                .padding()
            }
        }
    }
}
