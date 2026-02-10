//
//  UndoToast.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 02/02/26.
//
import Foundation
import SwiftUI
struct UndoToast: View {
    let title: String
    let actionTitle: String
    let onAction: () -> Void

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white)

            Spacer()

            Button(actionTitle, action: onAction)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
        }
        .padding()
        .background(.black.opacity(0.9))
        .cornerRadius(12)
        .padding(.horizontal)
        .shadow(radius: 6)
    }
}
