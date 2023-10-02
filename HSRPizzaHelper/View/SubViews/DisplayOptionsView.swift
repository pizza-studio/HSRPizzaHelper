//
//  DisplayOptionsView.swift
//  HSRPizzaHelper
//
//  Created by ShikiSuen on 2023/10/2.
//

import SwiftUI
import SwiftyUserDefaults

struct DisplayOptionsView: View {
    @State var useGuestGachaEvaluator = Binding(
        get: {
            Defaults[\.useGuestGachaEvaluator]
        },
        set: {
            Defaults[\.useGuestGachaEvaluator] = $0
        }
    )

    var body: some View {
        Group {
            mainView()
        }
        .inlineNavigationTitle("setting.uirelated.title")
    }

    @ViewBuilder
    func mainView() -> some View {
        List {
            Section {
                Toggle(isOn: useGuestGachaEvaluator) {
                    Text("setting.uirelated.useguestgachaevaluator")
                }
            }
        }
    }
}
