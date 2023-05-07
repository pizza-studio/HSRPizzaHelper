//
//  WidgetAccountCard.swift
//  HSRPizzaHelperWidgetExtension
//
//  Created by 戴藏龙 on 2023/5/8.
//

import SFSafeSymbols
import SwiftUI

struct WidgetAccountCard: View {
    let accountName: String?

    var body: some View {
        if let accountName = accountName {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Image(systemSymbol: .personFill)
                Text(accountName)
            }
            .font(.footnote)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
        }
    }
}
