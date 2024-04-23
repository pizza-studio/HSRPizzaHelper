// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import SwiftUI
extension AppConfig {
    @ViewBuilder
    public static func renderWaterMarkAppStr() -> some View {
        if let verStr = AppConfig.watermarkAppVersionStr {
            VStack(alignment: .center) {
                Spacer()
                Text(verStr)
                    .lineLimit(1)
                    .font(.caption2)
                    .fontWeight(.regular)
                    .foregroundColor(.secondary)
                    .padding(3)
                    .opacity(0.3)
                Spacer()
            }
        }
    }
}
