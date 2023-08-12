//
//  GachaSettingView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/9.
//

import SwiftUI

struct ManageGachaRecordView: View {
    // MARK: Internal

    var body: some View {
        List {
            Button("Delete all records") {
                let items = try? viewContext.fetch(GachaItemMO.fetchRequest())
                items?.forEach { item in
                    viewContext.delete(item)
                }
                try? viewContext.save()
            }
        }
    }

    // MARK: Private

    @Environment(\.managedObjectContext) private var viewContext
}
