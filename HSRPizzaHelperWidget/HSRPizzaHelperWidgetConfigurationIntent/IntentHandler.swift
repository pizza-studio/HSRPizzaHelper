//
//  IntentHandler.swift
//  HSRPizzaHelperWidgetConfigurationIntent
//
//  Created by 戴藏龙 on 2023/5/6.
//

import Intents

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any? {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.

        switch intent {
        case is GIStyleSquareWidgetConfigurationIntent, is LargeSquareWidgetConfigurationIntent,
             is SmallSquareWidgetConfigurationIntent:
            return SquareWidgetConfigurationIntentHandler()
        case is GIStyleRectangularWidgetConfigurationIntent, is RectangularWidgetConfigurationIntent:
            return RectangularWidgetConfigurationIntentHandler()
        case is LockscreenWidgetConfigurationIntent:
            return LockscreenWidgetConfigurationIntentHandler()
        default:
            return nil
        }
    }
}
