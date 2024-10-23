//
//  MigrationView.swift
//  HSRPizzaHelper
//
//  Created by ShikiSuen on 2024/10/22.
//

import SwiftUI

public struct MigrationView: View {
    // MARK: Public

    public let sectionOnly: Bool

    @MainActor public var body: some View {
        if sectionOnly {
            coreSection
        } else {
            NavigationStack {
                Form {
                    coreSection
                }
                .formStyle(.grouped)
                .navigationTitle("tab.migration")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }

    // MARK: Internal

    @MainActor @ViewBuilder var coreSection: some View {
        Section {
            NavigationLink {
                ExportGachaView()
            } label: {
                Label {
                    Text("gacha.manage.uigf.export")
                } icon: {
                    Image(systemSymbol: .rectanglePortraitAndArrowRightFill)
                }
            }
            ProfileBackupRestoreButton()
        } header: {
            Text("tab.migration")
        } footer: {
            let raw =
                LocalizedStringResource(
                    stringLiteral: "pizza.migrationNotice"
                )
            let attrStr = try? AttributedString(
                markdown: String(localized: raw),
                options: .init(
                    allowsExtendedAttributes: true,
                    interpretedSyntax: .inlineOnlyPreservingWhitespace,
                    failurePolicy: .returnPartiallyParsedIfPossible
                )
            )
            if let attrStr = attrStr {
                Text(attrStr)
            } else {
                Text(raw)
            }
        }
    }
}
