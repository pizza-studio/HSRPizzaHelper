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
        RectangularDailyNoteWidget()
        RectangularGIStyleWidget()
        SmallSquareDailyNoteWidget()
        LargeSquareDailyNoteWidget()
        SquareGIStyleWidget()
        if #available(iOSApplicationExtension 16.0, *) {
            CommonStaminaLockscreenWidget()
        }
        #if canImport(ActivityKit)
        if #available(iOSApplicationExtension 16.1, *) {
            DailyNoteCountDownLiveActivity()
        }
        #endif
    }
}
