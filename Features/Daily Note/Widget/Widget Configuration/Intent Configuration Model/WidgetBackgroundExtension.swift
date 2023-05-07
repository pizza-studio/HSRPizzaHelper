//
//  WidgetBackgroundExtension.swift
//  HSRPizzaHelperWidgetConfigurationIntent
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation
import SwiftUI

extension WidgetBackground {
    /// Get background image. 
    func image() -> Image? {
        if let url = backgroundImageUrl,
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
    }
}
