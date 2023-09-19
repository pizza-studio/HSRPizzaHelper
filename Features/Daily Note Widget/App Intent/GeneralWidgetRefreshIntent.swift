//
//  GeneralWidgetRefreshIntent.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/9/18.
//

import AppIntents
import Foundation

/// General intent for refresh widget timeline.
///
/// System will automatically update widget timeline after act an app intent. So this intent need do nothing.
@available(iOSApplicationExtension 16, iOS 16, *)
struct GeneralWidgetRefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh"

    func perform() async throws -> some IntentResult {
        .result()
    }
}
