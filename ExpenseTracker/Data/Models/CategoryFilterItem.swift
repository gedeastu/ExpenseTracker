//
//  CategoryFilterItem.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 06/02/26.
//

import Foundation

enum CategoryType {
    case expense
    case income
}

struct CategoryFilterItem: Identifiable, Hashable {
    let id = UUID()
    let rawValue: String
    let title: String
    let icon: String
    let type: CategoryType
}
