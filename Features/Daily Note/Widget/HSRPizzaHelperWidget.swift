////
////  HSRPizzaHelperWidget.swift
////  HSRPizzaHelperWidget
////
////  Created by 戴藏龙 on 2023/5/6.
////
//
// import Intents
// import SwiftUI
// import WidgetKit
//
//// MARK: - Provider
//
// struct Provider: IntentTimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
//    }
//
//    func getSnapshot(
////        for configuration: ConfigurationIntent,
//        in context: Context,
//        completion: @escaping (SimpleEntry) -> ()
//    ) {
//        let entry = SimpleEntry(date: Date(), configuration: configuration)
//        completion(entry)
//    }
//
//    func getTimeline(
//        for configuration: ConfigurationIntent,
//        in context: Context,
//        completion: @escaping (Timeline<Entry>) -> ()
//    ) {
//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, configuration: configuration)
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
// }
//
//// MARK: - SimpleEntry
//
// struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let configuration: ConfigurationIntent
// }
//
//// MARK: - HSRPizzaHelperWidgetEntryView
//
// struct HSRPizzaHelperWidgetEntryView: View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        Text(entry.date, style: .time)
//    }
// }
//
//// MARK: - HSRPizzaHelperWidget
//
// struct HSRPizzaHelperWidget: Widget {
//    let kind: String = "HSRPizzaHelperWidget"
//
//    var body: some WidgetConfiguration {
//        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
//            HSRPizzaHelperWidgetEntryView(entry: entry)
//        }
//        .configurationDisplayName("My Widget")
//        .description("This is an example widget.")
//    }
// }
//
//// MARK: - HSRPizzaHelperWidget_Previews
//
// struct HSRPizzaHelperWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        HSRPizzaHelperWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
// }
