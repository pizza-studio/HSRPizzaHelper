//
//  DisplayOptionsView.swift
//  HSRPizzaHelper
//
//  Created by ShikiSuen on 2023/10/2.
//

import Defaults
import DefaultsKeys
import HBEnkaAPI
import SwiftUI

struct DisplayOptionsView: View {
    // MARK: Internal

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
                Toggle(isOn: $useGuestGachaEvaluator) {
                    Text("setting.uirelated.useguestgachaevaluator")
                }
            }

            Section {
                Toggle(isOn: $animateOnCallingCharacterShowcase) {
                    Text("setting.uirelated.showCase.animateOnCallingCharacterShowcase.title")
                }
            }
        }
    }

    // MARK: Private

    @Default(.useGuestGachaEvaluator) private var useGuestGachaEvaluator
    @Default(.animateOnCallingCharacterShowcase)  private var animateOnCallingCharacterShowcase: Bool
}
