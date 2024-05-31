// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import EnkaKitHSR
import Foundation
import SwiftUI

extension EnkaHSR.AvatarSummarized.CharacterID {
    @ViewBuilder
    public func avatarPhoto(size: CGFloat, circleClipped: Bool = true, clipToHead: Bool = false) -> some View {
        CharacterIconView(charID: id, size: size, circleClipped: circleClipped, clipToHead: clipToHead)
    }

    /// 显示角色的扑克牌尺寸肖像，以身份证素材裁切而成。
    @ViewBuilder
    public func cardIcon(size: CGFloat) -> some View {
        CharacterIconView(charID: id, cardSize: size)
    }
}
