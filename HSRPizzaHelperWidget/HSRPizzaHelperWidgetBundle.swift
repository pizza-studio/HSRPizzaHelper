//
//  HSRPizzaHelperWidgetBundle.swift
//  HSRPizzaHelperWidget
//
//  Created by 戴藏龙 on 2023/5/6.
//

import SwiftUI
import WidgetKit

@main
struct HSRPizzaHelperWidgetBundle: WidgetBundle {
    var body: some Widget {
//        HSRPizzaHelperWidget()
        #if canImport(ActivityKit)
        if #available(iOSApplicationExtension 16.1, *) {
            HSRPizzaHelperWidgetLiveActivity()
        }
        #endif
    }
}
