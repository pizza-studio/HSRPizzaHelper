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
                Text("AlertToast - elai950\nhttps://github.com/elai950/AlertToast")
                Text("SFSafeSymbols\nhttps://github.com/SFSafeSymbols/SFSafeSymbols")
                Text("SwifterSwift\nhttps://github.com/SwifterSwift/SwifterSwift")
                Text("SwiftyUserDefaults - subshinejr\nhttps://github.com/sunshinejr/SwiftyUserDefaults")
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
