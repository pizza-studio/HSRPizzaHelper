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

    @StateObject var storeManager: StoreManager
    let locale = Locale.current

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
                            Text(product.localizedTitle)
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
    }

    // MARK: Private

    private func priceLocalized(product: SKProduct) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        return numberFormatter.string(from: product.price) ?? "Price Error"
    }
}
