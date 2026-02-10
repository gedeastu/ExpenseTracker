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

    var body: some View {
        Chart {
            ForEach(data) { item in
                BarMark(
                    x: .value("Waktu", item.label),
                    y: .value("Total", item.total)
                )
                .foregroundStyle(.green)
            }
        }
        .frame(height: 220)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .animation(.easeInOut(duration: 0.25), value: data)
    }
}
