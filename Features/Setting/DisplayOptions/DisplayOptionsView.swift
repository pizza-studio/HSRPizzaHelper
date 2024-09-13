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
import GachaKitHSR
import GachaMetaDB
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

    @ViewBuilder var artifactRatingSystemCreditView: some View {
        let raw =
            LocalizedStringResource(
                stringLiteral: "setting.uirelated.showCase.enableArtifactRating.credit"
            )
        let attrStr = try? AttributedString(
            markdown: String(localized: raw),
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )
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
                Toggle(isOn: $restoreTabOnLaunching) {
                    Text("setting.uirelated.restoreTabOnLaunching")
                }
                Picker("settings.display.appWallpaper", selection: $wallpaper) {
                    ForEach(Wallpaper.allCases, id: \.rawValue) { currentWP in
                        Label {
                            Text(currentWP.localizedTitle)
                        } icon: {
                            Circle()
                                .foregroundStyle(Color.clear)
                                .background(alignment: .topTrailing) {
                                    currentWP.image?
                                        .resizable()
                                        .scaledToFill()
                                        .scaleEffect(2)
                                }
                                .compositingGroup()
                                .clipShape(Circle())
                                .frame(width: 30, height: 30)
                        }.tag(currentWP)
                    }
                }
                .pickerStyle(.navigationLink)
            }

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
                Toggle(isOn: $useRealCharacterNames) {
                    Text("settings.display.useRealCharacterNames")
                }
            }

            Section {
                Toggle(isOn: $useGenshinStyleCharacterPhotos) {
                    Text("setting.uirelated.useGenshinStyleCharacterPhotos")
                }
                NavigationLink {
                    List {
                        Section {
                            AllCharacterPhotoSpecimenView(columns: specimenColumns, scroll: false) {
                                Array(GachaMeta.sharedDB.mainDB.keys)
                            }
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

            Section {
                Toggle(isOn: $enableArtifactRatingInShowcase) {
                    Text("setting.uirelated.showCase.enableArtifactRating.title")
                }
            } footer: {
                artifactRatingSystemCreditView
            }
        }
    }

    // MARK: Private

    private let specimentText = String(
        localized: .init(stringLiteral: "detailPortal.AllCharacterPhotoSpecimen")
    )

    @Default(.restoreTabOnLaunching) private var restoreTabOnLaunching: Bool
    @Default(.wallpaper) private var wallpaper: Wallpaper
    @Default(.useGuestGachaEvaluator) private var useGuestGachaEvaluator
    @Default(.animateOnCallingCharacterShowcase) private var animateOnCallingCharacterShowcase: Bool
    @Default(.useGenshinStyleCharacterPhotos) private var useGenshinStyleCharacterPhotos: Bool
    @Default(.enableArtifactRatingInShowcase) var enableArtifactRatingInShowcase: Bool
    @Default(.useRealCharacterNames) private var useRealCharacterNames: Bool

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    private var specimenColumns: Int {
        horizontalSizeClass == .compact ? 3 : 6
    }
}
