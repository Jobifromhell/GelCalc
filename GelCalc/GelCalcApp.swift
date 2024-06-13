//
//  GelCalcApp.swift
//  GelCalc
//
//  Created by Olivier Jobin on 13/06/2024.
//

import SwiftUI

@main
struct GelCalcApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
