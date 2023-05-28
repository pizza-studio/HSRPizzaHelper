//
//  GlobalDonateView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/5/19.
//

import StoreKit
import SwiftUI

struct GlobalDonateView: View {
    // MARK: Internal

    let locale = Locale.current

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

    var body: some View {
        List {
            Section {
                Text("sys.donate.notes")
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)
            }

            Section(header: Text("sys.donate.items.title")) {
                if storeManager.myProducts.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
                ForEach(storeManager.myProducts, id: \.self) { product in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(String(format: "sys.donate.title %@".localized(), product.localizedPrice ?? "Unknwon"))
                                .font(.headline)
                            Text(product.localizedDescription)
                                .font(.caption2)
                        }
                        Spacer()
                        Button("sys.label.pay") {
                            storeManager.purchaseProduct(product: product)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .clipShape(Capsule())
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
        }
        .navigationTitle("sys.label.support")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            SKPaymentQueue.default().add(storeManager)
            storeManager.getProducts(productIDs: productIDs)
        }
    }

    // MARK: Private

    private func priceLocalized(product: SKProduct) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        return numberFormatter.string(from: product.price) ?? "Price Error"
    }
}
