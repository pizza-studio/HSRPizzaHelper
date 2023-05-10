//
//  WidgetBackgroundExtension.swift
//  HSRPizzaHelperWidgetConfigurationIntent
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation

extension WidgetBackground {

    /// The filename of the widget background.
    var filename: String {
        identifier!.deletingPathExtension
    }

    /// The file extension of the widget background.
    var fileExtension: String {
        identifier!.pathExtension
    }
}
