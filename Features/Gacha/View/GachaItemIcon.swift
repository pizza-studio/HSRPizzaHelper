// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import EnkaSwiftUIViews
import HBMihoyoAPI
import SwiftUI

public struct GachaItemIcon: View {
    // MARK: Lifecycle

    public init(item: GachaItemProtocol, size: CGFloat = 35) {
        self.item = item
        self.size = size
    }

    // MARK: Public

    public var body: some View {
        Group {
            if useGenshinStyleCharacterPhotos,
               item.itemType == .characters,
               let iconView = IDPhotoView(pid: item.itemID, size, .cutHead) {
                iconView
            } else if let uiImage = item.icon {
                Image(uiImage: uiImage).resizable().scaledToFit()
            } else {
                Image(systemSymbol: .questionmarkCircle).resizable().scaledToFit()
            }
        }
        .background {
            Image(item.rank.backgroundKey)
                .scaledToFit()
                .scaleEffect(1.5)
                .offset(y: 3)
        }
        .clipShape(Circle())
        .contentShape(Circle())
        .frame(width: size, height: size)
    }

    // MARK: Private

    private let item: GachaItemProtocol
    private let size: CGFloat

    @Default(.useGenshinStyleCharacterPhotos) private var useGenshinStyleCharacterPhotos: Bool
}
