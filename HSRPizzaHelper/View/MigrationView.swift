//
//  MigrationView.swift
//  HSRPizzaHelper
//
//  Created by ShikiSuen on 2024/10/22.
//

import SwiftUI

public struct MigrationView: View {
    @MainActor public var body: some View {
        NavigationStack {
            Form {
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
            .formStyle(.grouped)
            .navigationTitle("tab.migration")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
