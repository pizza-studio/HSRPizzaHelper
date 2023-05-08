//
//  WidgetBackgroundExtension.swift
//  HSRPizzaHelperWidgetConfigurationIntent
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation

extension WidgetBackground {
    var filename: String {
        identifier!.deletingPathExtension
    }

    var fileExtension: String {
        identifier!.pathExtension
    }
}
