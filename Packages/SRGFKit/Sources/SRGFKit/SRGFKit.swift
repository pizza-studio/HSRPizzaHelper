// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

public enum SRGFKit {
    public static let sharedGachaMeta: Data = {
        let url = Bundle.module.url(forResource: "gacha_meta", withExtension: "json")!
        return try! Data(contentsOf: url)
    }()
}
