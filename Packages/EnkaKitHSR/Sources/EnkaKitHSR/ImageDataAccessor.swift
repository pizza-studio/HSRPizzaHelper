// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import CoreGraphics
import Foundation
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

extension EnkaHSR {
    public static func queryImageAsset(for assetName: String) -> CGImage? {
        #if os(macOS)
        guard let image = Bundle.module.image(forResource: assetName) else { return nil }
        var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        return imageRef
        #elseif os(iOS)
        return UIImage(named: assetName, in: Bundle.module, compatibleWith: nil)?.cgImage
        #else
        return nil
        #endif
    }
}
