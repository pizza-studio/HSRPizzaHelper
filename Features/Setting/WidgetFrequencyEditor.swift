//
//  WidgetFrequencyEditor.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/9.
//

import SwiftUI
import SwiftyUserDefaults

struct WidgetFrequencyEditor: View {
    @StateObject var widgetRefreshFrequencyInHour: ObservableSwiftyUserDefault =
        .init(keyPath: \.widgetRefreshFrequencyInHour)

    var body: some View {
        HStack {
            Text("setting.widget.refresh.frequency.title")
            Spacer()
            Menu {
                ForEach(4 ... 6, id: \.self) { number in
                    Button(
                        String(
                            format: "setting.widget.refresh.frequency.value"
                                .localized(comment: "%lld Hr"),
                            Int(number)
                        ),
                        action: {
                            widgetRefreshFrequencyInHour.value = Double(number)
                        }
                    )
                }
            } label: {
                Text(
                    String(
                        format: "setting.widget.refresh.frequency.everyvalue"
                            .localized(comment: "%lld Hr"),
                        Int(widgetRefreshFrequencyInHour.value)
                    )
                )
            }
        }
    }
}
