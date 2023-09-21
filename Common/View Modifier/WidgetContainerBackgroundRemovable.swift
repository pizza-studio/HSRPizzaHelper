//
//  WidgetContainerBackgroundRemovable.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/9/20.
//

import Foundation
import SwiftUI

extension WidgetConfiguration {
    func widgetContainerBackgroundRemovable(_ isRemovable: Bool) -> some WidgetConfiguration {
        if #available(iOS 17.0, iOSApplicationExtension 17.0, *) {
            return self.containerBackgroundRemovable(isRemovable)
        } else {
            return self
        }
    }
}
