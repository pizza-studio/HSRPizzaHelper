//
//  HSRPizzaHelperWidgetLiveActivity.swift
//  HSRPizzaHelperWidget
//
//  Created by 戴藏龙 on 2023/5/6.
//

#if canImport(ActivityKit)

import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - HSRPizzaHelperWidgetAttributes

@available(iOSApplicationExtension 16.1, *)
struct HSRPizzaHelperWidgetAttributes: ActivityAttributes {
    // MARK: Public

    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var value: Int
    }

    // MARK: Internal

    // Fixed non-changing properties about your activity go here!
    var name: String
}

// MARK: - HSRPizzaHelperWidgetLiveActivity

@available(iOSApplicationExtension 16.1, *)
struct DailyNoteCountDownLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HSRPizzaHelperWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("Min")
            }
            .keylineTint(Color.red)
        }
    }
}

// MARK: - HSRPizzaHelperWidgetLiveActivity_Previews

@available(iOSApplicationExtension 16.2, *)
struct HSRPizzaHelperWidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = HSRPizzaHelperWidgetAttributes(name: "Me")
    static let contentState = HSRPizzaHelperWidgetAttributes.ContentState(value: 3)

    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Island Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Island Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}

#endif
