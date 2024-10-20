//
//  HSRPizzaHelperApp.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import SwiftUI

@main
struct HSRPizzaHelperApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(\.horizontalSizeClass, .compact)
            #if targetEnvironment(macCatalyst)
                .frame(minWidth: 600, minHeight: 800)
            #endif
        }
    }
}
