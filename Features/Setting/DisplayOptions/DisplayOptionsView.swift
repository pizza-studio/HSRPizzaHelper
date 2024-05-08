//
//  DisplayOptionsView.swift
//  HSRPizzaHelper
//
//  Created by ShikiSuen on 2023/10/2.
//

import Defaults
import DefaultsKeys
import EnkaKitHSR
import EnkaSwiftUIViews
import SwiftUI

struct DisplayOptionsView: View {
    // MARK: Internal

    var body: some View {
        Group {
            mainView()
        }
        .inlineNavigationTitle("setting.uirelated.title")
    }

    @ViewBuilder var disclaimerView: some View {
        let raw =
            LocalizedStringResource(
                stringLiteral: "setting.uirelated.useGenshinStyleCharacterPhotos.description"
            )
        let attrStr = try? AttributedString(markdown: String(localized: raw))
        if let attrStr = attrStr {
            Text(attrStr)
        } else {
            Text(raw)
        }
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

            Section {
                Toggle(isOn: $useGenshinStyleCharacterPhotos) {
                    Text("setting.uirelated.useGenshinStyleCharacterPhotos")
                }
                NavigationLink {
                    List {
                        Section {
                            AllCharacterPhotoSpecimenView(columns: specimenColumns, scroll: false)
                        } header: {
                            disclaimerView
                        }
                    }
                    .navigationTitle(specimentText)
                } label: {
                    Text(specimentText)
                }
            } footer: {
                disclaimerView
            }
        }
    }

    // MARK: Private

    private let specimentText = String(
        localized: .init(stringLiteral: "detailPortal.AllCharacterPhotoSpecimen")
    )

    @Default(.useGuestGachaEvaluator) private var useGuestGachaEvaluator
    @Default(.animateOnCallingCharacterShowcase) private var animateOnCallingCharacterShowcase: Bool
    @Default(.useGenshinStyleCharacterPhotos) private var useGenshinStyleCharacterPhotos: Bool

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    private var specimenColumns: Int {
        horizontalSizeClass == .compact ? 2 : 6
    }
}
