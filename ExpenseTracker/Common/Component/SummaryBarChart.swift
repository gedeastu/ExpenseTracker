//
//  SummaryBarChart.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 06/02/26.
//

import Foundation
import SwiftUI
import Charts

struct SummaryBarChart: View {

    let data: [SummaryChartEntry]
    let currencyCode: String

    var body: some View {
        Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value("Waktu", item.label),
                    y: .value("Total", item.total)
                )
                .foregroundStyle(.green)
                .annotation(position: .top) {
                    Text(formatCurrency(item.total))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(height: 220)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(formatCurrency(doubleValue))
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: data)
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}
