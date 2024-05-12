//
//  ThanksView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/5/5.
//

import SwiftUI

// swiftlint:disable line_length
struct ThanksView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("sys.thank.headline")
                .font(.footnote)
            Divider()
            Group {
                Text(verbatim: "AlertToast - elai950\nhttps://github.com/elai950/AlertToast")
                Text(verbatim: "Mantis - guoyingtao\nhttps://github.com/guoyingtao/Mantis")
                Text(verbatim: "SFSafeSymbols\nhttps://github.com/SFSafeSymbols/SFSafeSymbols")
                Text(verbatim: "SwifterSwift\nhttps://github.com/SwifterSwift/SwifterSwift")
                Text(verbatim: "Defaults - Sindre Sorhus\nhttps://github.com/sindresorhus/Defaults")
                Text(verbatim: "Enka API - Enka Network\nhttps://enka.network/?hsr")
                Text(verbatim: "MiHoMo Origin API Mirror - MiHoMo\nhttps://github.com/Mar-7th/March7th-Docs")
                Text(verbatim: "StarRailScore - Mobyw @ Mar-7th\nhttps://github.com/Mar-7th/StarRailScore")
                Text(
                    verbatim: "Genshin Artifact Rating System - Alice Workshop\nhttps://github.com/Kamihimmel/artifactrating"
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

// swiftlint:enable line_length
