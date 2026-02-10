//
//  EmptyExpenseView.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 24/01/26.
//

import Foundation
import SwiftUI
import Lottie

struct EmptyExpenseView:View{
    var body: some View {
        LottieView(animation: .named("Empty Box")).configure({
            LottieAnimation in LottieAnimation.contentMode = .scaleToFill
        }).playbackMode(.playing(
            .toProgress(1, loopMode: .loop)
        )).frame(width: 220,height: 120)
        Text("No Transactions yet").foregroundColor(.gray).fontWeight(.bold).opacity(0.7);
    }
}
