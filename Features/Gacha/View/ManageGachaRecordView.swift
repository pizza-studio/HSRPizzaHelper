//
//  GachaSettingView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/9.
//

import CoreData
import SwiftUI

// MARK: - UIDAndName

private struct UIDAndName: Hashable, CustomStringConvertible {
    let uid: String
    let name: String?

    var description: String {
        if let name {
            return "\(name) (\(uid))"
        } else {
            return "\(uid)"
        }
    }
}

// MARK: - ManageGachaRecordView

struct ManageGachaRecordView: View {
    // MARK: Internal

    var body: some View {
        List {
            Section {
                Picker("gacha.manage.select_account", selection: $selectedUIDAndName) {
                    Group {
                        Text("gacha.manage.not_selected").tag(UIDAndName?.none)
                        ForEach(
                            availableUIDAndNames,
                            id: \.hashValue
                        ) { uidAndName in
                            Text(uidAndName.description)
                                .tag(Optional(uidAndName))
                        }
                    }
                }
                Button("gacha.manage.delete_all") {
                    isDeleteConfirmDialogueShow.toggle()
                }
                .disabled(selectedUIDAndName == nil)
            }
            Section {
                Button("gacha.manage.clean_duplicate") {
                    cleanedDuplicateItemCount = cleanDuplicatedItems()
                }
            } footer: {
                Text("gacha.manage.clean_duplicate.instruction")
            }
        }
        .onAppear {
            refreshAvailableUIDAndNames()
        }
        .confirmationDialog(
            "gacha.manage.delete.confirm",
            isPresented: $isDeleteConfirmDialogueShow,
            titleVisibility: .visible
        ) {
            Button(
                String(format: "gacha.manage.delete.confirm_delete".localized(), selectedUIDAndName?.description ?? ""),
                role: .destructive
            ) {
                guard let selectedUIDAndName else { return }
                let request = GachaItemMO.fetchRequest()
                request.predicate = NSPredicate(format: "uid = %@", selectedUIDAndName.uid)
                let items = try? viewContext.fetch(request)
                items?.forEach { item in
                    viewContext.delete(item)
                }
                try? viewContext.save()
                self.selectedUIDAndName = nil
                refreshAvailableUIDAndNames()
                isDeleteConfirmDialogueShow.toggle()
            }
            Button("sys.cancel", role: .cancel) {
                isDeleteConfirmDialogueShow.toggle()
            }
        }
        .alert("gacha.manage.clean_duplicate.alert.title", isPresented: Binding(get: {
            cleanedDuplicateItemCount != nil
        }, set: { newValue in
            if !newValue {
                cleanedDuplicateItemCount = nil
            }
        })) {
            Button("sys.ok") {
                cleanedDuplicateItemCount = nil
            }
        } message: {
            Text(String(
                format: "gacha.manage.clean_duplicate.alert.message".localized(),
                cleanedDuplicateItemCount ?? 0
            ))
        }
    }

    func cleanDuplicatedItems() -> Int {
        var deletedItemCount = 0
        viewContext.refreshAllObjects()
        let request = GachaItemMO.fetchRequest()
        do {
            let items = try viewContext.fetch(request)
            Dictionary(grouping: items) { item in
                item.id + item.uid
            }.forEach { _, items in
                if items.count > 1 {
                    items[1...].forEach { item in
                        viewContext.delete(item)
                        deletedItemCount += 1
                    }
                }
            }
            try? viewContext.save()
            return deletedItemCount
        } catch {
            print(error.localizedDescription)
            return deletedItemCount
        }
    }

    // MARK: Private

    @State private var selectedUIDAndName: UIDAndName?

    @State private var availableUIDAndNames: [UIDAndName] = []

    @State private var isDeleteConfirmDialogueShow: Bool = false

    @State private var cleanedDuplicateItemCount: Int?

    @Environment(\.managedObjectContext) private var viewContext

    private func refreshAvailableUIDAndNames() {
        availableUIDAndNames = getAvailableUIDAndNames()
    }

    private func getAvailableUIDAndNames() -> [UIDAndName] {
        let request =
            NSFetchRequest<NSFetchRequestResult>(entityName: "GachaItemMO")
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = ["uid"]
        if let fetchResult = try? viewContext
            .fetch(request) as? [[String: String]] {
            let uids = fetchResult.compactMap { $0["uid"] }
            return uids.map { uid in
                let request = Account.fetchRequest()
                request.predicate = NSPredicate(format: "uid = %@", uid)
                let accounts = try? viewContext.fetch(request)
                if let name = accounts?.first?.name {
                    return UIDAndName(uid: uid, name: name)
                } else {
                    return UIDAndName(uid: uid, name: nil)
                }
            }
        } else {
            return []
        }
    }
}
