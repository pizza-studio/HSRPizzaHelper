//
//  ThanksView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/5/5.
//

import SwiftUI

struct ThanksView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("sys.thank.headline")
                .font(.footnote)
            Divider()
            Group {
                Text(
                    "SwiftPieChart - Nazar Ilamanov\nhttps://github.com/ilamanov/SwiftPieChart"
                )
            }
            .font(.caption)
            Divider()
            Group {
                Text("Game Account Data API - 米游社 (CN) / HoYoLAB (OS)")
            }
            .font(.caption)
            Spacer()
        }
        .padding()
        .navigationTitle("sys.thank.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}
