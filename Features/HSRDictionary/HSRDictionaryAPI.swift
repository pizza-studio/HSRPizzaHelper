//
//  HSRDictionary.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/7/30.
//

import Foundation

// MARK: - HSRDictionaryAPI

enum HSRDictionaryAPI {}

extension HSRDictionaryAPI {
    static func translation(query: String, page: Int, pageSize: Int) async throws -> HSRDictionaryTranslationResult {
        var components = URLComponents()

        components.scheme = "https"

        components.host = "hsrdict-api.pizzastudio.org"

        components.path = "/v1/translations/\(query)"

        components.queryItems = [.init(name: "page", value: "\(page)"), .init(name: "page_size", value: "\(pageSize)")]

        let url = components.url!

        let request = URLRequest(url: url)

        let (data, _) = try await URLSession.shared.data(for: request)

        return try JSONDecoder().decode(HSRDictionaryTranslationResult.self, from: data)
    }
}
