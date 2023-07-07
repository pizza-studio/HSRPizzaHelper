//
//  HSRPizzaHelperWatchApp.swift
//  HSRPizzaHelperWatch Watch App
//
//  Created by Bill Haku on 2023/7/7.
//

import SwiftUI

@main
struct HSRPizzaHelperWatchWatchApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
