//
//  CategoryType.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 28/01/26.
//

import Foundation
enum ExpenseCategory: String, CaseIterable, Identifiable {
    case food
    case transport
    case entertainment
    case bills
    case shopping
    case health
    case education
    case other

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car"
        case .entertainment: return "tv"
        case .bills: return "doc.text"
        case .shopping: return "bag"
        case .health: return "heart"
        case .education: return "book"
        case .other: return "ellipsis"
        }
    }
}

enum IncomeCategory: String, CaseIterable, Identifiable {
    case salary
    case bonus
    case freelance
    case investment
    case gift
    case other

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .salary: return "briefcase"
        case .bonus: return "star"
        case .freelance: return "laptopcomputer"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .gift: return "gift"
        case .other: return "ellipsis"
        }
    }
}

extension ExpenseCategory {
    var filterItem: CategoryFilterItem {
        CategoryFilterItem(
            rawValue: self.rawValue,
            title: self.title,
            icon: self.icon,
            type: .expense
        )
    }
}

extension IncomeCategory {
    var filterItem: CategoryFilterItem {
        CategoryFilterItem(
            rawValue: self.rawValue,
            title: self.title,
            icon: self.icon,
            type: .income
        )
    }
}
