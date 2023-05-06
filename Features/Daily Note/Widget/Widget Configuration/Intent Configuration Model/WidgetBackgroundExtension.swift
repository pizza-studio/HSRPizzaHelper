//
//  WidgetBackgroundExtension.swift
//  HSRPizzaHelperWidgetConfigurationIntent
//
//  Created by 戴藏龙 on 2023/5/7.
//

import Foundation
import SwiftUI

extension WidgetBackground {
    func image() -> Image? {
        if let url = backgroundImageURL,
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        } else {
            return nil
        }
    }
}
