//
//  SummaryChartEntry.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 06/02/26.
//

import Foundation

struct SummaryChartEntry: Identifiable, Equatable {
    let id: String
    let label: String
    let total: Double
}
