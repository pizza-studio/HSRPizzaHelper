//
//  Extensions.swift
//
//
//  Created by Bill Haku on 2023/3/25.
//

import CryptoKit
import Foundation

// MARK: - String

extension String {
    /// Localized string
    var localized: String {
        String(format: NSLocalizedString(self, comment: ""))
    }
}

extension String {
    /**
     - returns: the String, as an MD5 hash.
     */
    public var md5: String {
        let digest = Insecure.MD5.hash(data: Data(utf8))
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
