//
//  HSRPizzaHelperApp.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import StoreKit
import SwiftUI

@main
struct HSRPizzaHelperApp: App {
    let persistenceController = PersistenceController.shared

    @StateObject var storeManager = StoreManager()

    let productIDs = {
        print("Apple ID Region: \(SKPaymentQueue.default().storefront?.countryCode ?? "unknown")")
        switch SKPaymentQueue.default().storefront?.countryCode {
        case "CHN":
            return [
                "Canglong.HSRPizzaHelper.IAP.1",
                "Canglong.HSRPizzaHelper.IAP.6",
                "Canglong.HSRPizzaHelper.IAP.30",
                "Canglong.HSRPizzaHelper.IAP.98",
                "Canglong.HSRPizzaHelper.IAP.198",
                "Canglong.HSRPizzaHelper.IAP.328",
                "Canglong.HSRPizzaHelper.IAP.648",
            ]
        default:
            return [
                "Canglong.HSRPizzaHelper.IAP.6",
                "Canglong.HSRPizzaHelper.IAP.30",
                "Canglong.HSRPizzaHelper.IAP.98",
                "Canglong.HSRPizzaHelper.IAP.198",
                "Canglong.HSRPizzaHelper.IAP.328",
                "Canglong.HSRPizzaHelper.IAP.648",
            ]
        }
    }()

    var body: some Scene {
        WindowGroup {
            #if !os(watchOS)
            // StoreManager cannot be used in watchOS App
            ContentView(storeManager: storeManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    SKPaymentQueue.default().add(storeManager)
                    storeManager.getProducts(productIDs: productIDs)
                }
            #endif
        }
    }
}
