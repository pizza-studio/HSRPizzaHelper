// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
import SwiftUI

extension CGImage {
    func resized(size: CGSize, quality: CGInterpolationQuality = .high) -> CGImage? {
        // Ref: https://rockyshikoku.medium.com/resize-cgimage-baf23a0f58ab
        let width = Int(size.width)
        let height = Int(size.height)

        let bytesPerPixel = bitsPerPixel / bitsPerComponent
        let destBytesPerRow = width * bytesPerPixel

        guard let colorSpace = colorSpace else { return nil }
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: destBytesPerRow,
            space: colorSpace,
            bitmapInfo: alphaInfo.rawValue
        ) else { return nil }

        context.interpolationQuality = quality
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

        return context.makeImage()
    }
}
