// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation

extension MiHoMo.QueriedProfile {
    public static func fetch(lang: String = "en", uid: String) async throws -> Self {
        let langTag = lang.isEmpty ? "" : "&lang=\(lang)"
        let urlLink = "https://api.mihomo.me/sr_info_parsed/\(uid)?version=v2\(langTag)"
        // swiftlint:disable force_unwrapping
        let url = URL(string: urlLink)!
        // swiftlint:enable force_unwrapping
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let requestResult = try decoder.decode(
            Self.self,
            from: data
        )
        return requestResult
    }

    public static func fetchEnka(uid: String) async throws -> EnkaHSR.QueryRelated.QueriedProfile {
        let urlLink = "https://api.mihomo.me/sr_info/\(uid)"
        // swiftlint:disable force_unwrapping
        let url = URL(string: urlLink)!
        // swiftlint:enable force_unwrapping
        let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
        let decoder = JSONDecoder()
        let requestResult = try decoder.decode(
            EnkaHSR.QueryRelated.QueriedProfile.self,
            from: data
        )
        return requestResult
    }
}
