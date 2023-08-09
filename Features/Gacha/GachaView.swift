//
//  GachaView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/9.
//

import SwiftUI

struct GachaView: View {
    // MARK: Internal

    var body: some View {
        List {
            Section {
                NavigationLink("Get Gacha Record") {
                    GetGachaRecordView()
                }
            }
            Section {
                ForEach(gachaItems) { item in
                    HStack {
                        Text(item.name)
                    }
                }
            }
        }
        .inlineNavigationTitle("Gacha Record")
    }

    // MARK: Private

    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \GachaItemMO.time, ascending: false),
    ], animation: .default) private var gachaItems: FetchedResults<GachaItemMO>
}
