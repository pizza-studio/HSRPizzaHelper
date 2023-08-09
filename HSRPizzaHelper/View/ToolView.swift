//
//  ToolView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/7/30.
//

import Foundation
import SwiftUI

struct ToolView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("app.tool.dictionary") {
                    HSRDictionaryView()
                }
                NavigationLink("gacha") {
                    GachaView()
                }
            }
            .navigationTitle("app.tool.title")
        }
    }
}
