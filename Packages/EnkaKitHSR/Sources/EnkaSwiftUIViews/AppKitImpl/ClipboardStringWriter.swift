// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
#if os(OSX)
import AppKit
#elseif os(iOS)
import UIKit
#endif

// MARK: - Clipboard

public enum Clipboard {
    public static func writeString(_ string: String) {
        #if os(OSX)
        NSPasteboard.general.setString(string, forType: .string)
        #elseif os(iOS)
        UIPasteboard.general.string = string
        #endif
    }
}
