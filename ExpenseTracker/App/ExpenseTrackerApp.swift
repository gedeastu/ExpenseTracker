//
//  ExpenseTrackerApp.swift
//  ExpenseTracker
//
//  Created by Gede Astu Nugraha on 23/01/26.
//

import SwiftUI

@main
struct ExpenseTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(context:persistenceController.container.viewContext)
                .environment(
                    \.managedObjectContext,
                    persistenceController.container.viewContext
                )
        }
    }
}
