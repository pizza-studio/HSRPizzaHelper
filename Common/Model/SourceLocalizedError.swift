//
//  SourceLocalizedError.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/10.
//

import Foundation

struct SourceLocalizedError: LocalizedError {
    let source: Error

    var errorDescription: String? {
        source.localizedDescription
    }
}
