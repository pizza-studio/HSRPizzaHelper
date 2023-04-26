//
//  HSRPizzaHelperApp.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//

import SwiftUI

@main
struct HSRPizzaHelperApp: App {

    let viewModel: ViewModel = .shared
    #if !os(watchOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    #endif
    @StateObject
    var storeManager = StoreManager()

    var body: some Scene {
        WindowGroup {
            ContentView(storeManager: storeManager)
                .environmentObject(viewModel)
        }
    }
}
