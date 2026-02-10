//
//  CategoryChip.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 06/02/26.
//

import Foundation
import SwiftUI
struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)

            Text(title)
                .font(.subheadline)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? Color.green.opacity(0.2) : Color.gray.opacity(0.15))
        )
        .foregroundColor(isSelected ? .green : .primary)
        .onTapGesture(perform: onTap)
    }
}
