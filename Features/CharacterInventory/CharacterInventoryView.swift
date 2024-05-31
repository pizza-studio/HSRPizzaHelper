// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import EnkaKitHSR
import EnkaSwiftUIViews
import Flow
import HBMihoyoAPI
import SFSafeSymbols
import SwiftUI

// MARK: - CharacterInventoryView

struct CharacterInventoryView: View {
    // MARK: Internal

    @EnvironmentObject var vmDPV: DetailPortalViewModel

    var data: MiHoYoAPI.CharacterInventory

    @State var expanded: Bool = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 3) {
                    Text(characterStats)
                    Text(goldStats)
                }.font(.footnote)
            }.listRowMaterialBackground()
            Group {
                if expanded {
                    allAvatarListFull
                } else {
                    allAvatarListCondensed
                }
            }.listRowMaterialBackground()
        }
        .scrollContentBackground(.hidden)
        .listContainerBackground()
        .navigationTitle("app.characters.title")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Picker("", selection: $expanded.animation()) {
                    Text("detailPortal.inventoryView.expand.tabText").tag(true)
                    Text("detailPortal.inventoryView.collapse.tabText").tag(false)
                }
                .pickerStyle(.menu)
                Menu {
                    ForEach(
                        AllAvatarListDisplayType.allCases,
                        id: \.rawValue
                    ) { choice in
                        Button(String(localized: .init(choice.rawValue))) {
                            withAnimation {
                                allAvatarListDisplayType = choice
                            }
                        }
                    }
                } label: {
                    Image(systemSymbol: .arrowLeftArrowRightCircle)
                }
            }
        }
        .refreshable {
            vmDPV.refresh()
        }
    }

    @ViewBuilder var allAvatarListFull: some View {
        Section {
            ForEach(showingAvatars, id: \.id) { avatar in
                AvatarListItem(avatar: avatar, condensed: false)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background {
                        if let commonCharData = EnkaHSR.Sputnik.sharedDB.characters[avatar.id.description] {
                            let elementColor = commonCharData.element.themeColor.suiColor
                            let bgPath = EnkaWebIcon(
                                iconString: commonCharData.avatarBaseType.iconFilePath
                            )
                            .scaledToFill()
                            .colorMultiply(elementColor)
                            .opacity(0.05)
                            if #unavailable(iOS 17) {
                                bgPath.frame(maxHeight: 63).clipped()
                            } else {
                                bgPath
                            }
                        }
                    }
                    .compositingGroup()
            }
        }
        .textCase(.none)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }

    @ViewBuilder var allAvatarListCondensed: some View {
        HStack(alignment: .center) {
            Spacer()
            HFlow(spacing: flowSpacing) {
                ForEach(showingAvatars, id: \.id) { avatar in
                    AvatarListItem(avatar: avatar, condensed: true)
                        .padding(.vertical, 4)
                        .compositingGroup()
                }
            }
            #if !os(OSX) && !targetEnvironment(macCatalyst)
            .listRowInsets(.init(top: 4, leading: 3, bottom: 4, trailing: 1))
            #endif
            Spacer()
        }
    }

    #if !os(OSX) && !targetEnvironment(macCatalyst)
    let flowSpacing: CGFloat = 4
    #else
    let flowSpacing: CGFloat = 2
    #endif

    struct GoldNum {
        let allGold, charGold, weaponGold: Int
    }

    func goldNum(data: MiHoYoAPI.CharacterInventory)
        -> GoldNum {
        var charGold = 0
        var weaponGold = 0
        for avatar in data.avatarList {
            if avatar.id.description.prefix(1) == "8" {
                continue
            }
            if avatar.rarity == 5 {
                charGold += 1
                charGold += avatar.rank
            }
            if let equip = avatar.equip, equip.rarity == 5 {
                weaponGold += equip.rank
            }
        }
        return .init(
            allGold: charGold + weaponGold,
            charGold: charGold,
            weaponGold: weaponGold
        )
    }

    // MARK: Private

    private enum AllAvatarListDisplayType: String, CaseIterable {
        case all = "app.characters.filter.all"
        case star5 = "app.characters.filter.5star"
        case star4 = "app.characters.filter.4star"
    }

    @Environment(\.dismiss) private var dismiss

    @State private var allAvatarListDisplayType: AllAvatarListDisplayType = .all

    private var characterStats: LocalizedStringKey {
        let aaa = data.avatarList.count
        let bbb = data.avatarList.filter { $0.rarity == 5 }.count
        let ccc = data.avatarList.filter { $0.rarity == 4 }.count
        // swiftlint:disable:next line_length
        return "app.characters.count.character:\(aaa, specifier: "%lld")\(bbb, specifier: "%lld")\(ccc, specifier: "%lld")"
    }

    private var goldStats: LocalizedStringKey {
        let ddd = goldNum(data: data).allGold
        let eee = goldNum(data: data).charGold
        let fff = goldNum(data: data).weaponGold
        return "app.characters.count.golds:\(ddd, specifier: "%lld")\(eee, specifier: "%lld")\(fff, specifier: "%lld")"
    }

    private var showingAvatars: [MiHoYoAPI.CharacterInventory.HYAvatar] {
        switch allAvatarListDisplayType {
        case .all:
            return data.avatarList
        case .star4:
            return data.avatarList.filter { $0.rarity == 4 }
        case .star5:
            return data.avatarList.filter { $0.rarity == 5 }
        }
    }
}

// MARK: - AvatarListItem

struct AvatarListItem: View {
    let avatar: MiHoYoAPI.CharacterInventory.HYAvatar

    @State var condensed: Bool

    var charName: String {
        if EnkaHSR.Sputnik.sharedDB.characters.keys.contains(avatar.id.description) {
            let nameObj = EnkaHSR.CharacterName(pid: avatar.id)
            return nameObj.i18n(theDB: EnkaHSR.Sputnik.sharedDB)
        } else {
            return avatar.name
        }
    }

    var body: some View {
        HStack(spacing: condensed ? 0 : 3) {
            ZStack(alignment: .bottomLeading) {
                Group {
                    if let charIdExp = EnkaHSR.AvatarSummarized.CharacterID(id: avatar.id.description) {
                        charIdExp.avatarPhoto(size: 55, circleClipped: true, clipToHead: true)
                    } else {
                        Color.gray.frame(width: 55, height: 55, alignment: .top).clipShape(Circle())
                            .overlay(alignment: .top) {
                                WebImage(urlStr: avatar.icon).clipShape(Circle())
                            }
                    }
                }
                .frame(width: 55, height: 55)
                .clipShape(Circle())
            }
            .frame(width: condensed ? 70 : 75, alignment: .leading)
            .corneredTag(
                verbatim: "Lv.\(avatar.level)",
                alignment: .topTrailing
            )
            .corneredTag(
                "detailPortal.ECDDV.constellation.unit:\(avatar.rank)",
                alignment: .trailing
            )
            if !condensed {
                VStack(spacing: 3) {
                    HStack(alignment: .lastTextBaseline, spacing: 5) {
                        Text(charName)
                            .font(.system(size: 20)).bold().fontWidth(.compressed)
                            .fixedSize(horizontal: true, vertical: false)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        Spacer()
                    }

                    HStack(spacing: 0) {
                        if let artifacts = avatar.relics {
                            ForEach(artifacts, id: \.id) { reliquary in
                                Group {
                                    WebImage(urlStr: reliquary.icon)
                                        .scaledToFit()
                                }
                                .frame(width: 20, height: 20)
                            }
                        }
                        if let artifactsExtra = avatar.ornaments {
                            ForEach(artifactsExtra, id: \.id) { reliquary in
                                Group {
                                    WebImage(urlStr: reliquary.icon)
                                        .scaledToFit()
                                }
                                .frame(width: 20, height: 20)
                            }
                        }
                        Spacer().frame(height: 20)
                    }
                }
                if let equip = avatar.equip {
                    ZStack(alignment: .bottomLeading) {
                        WebImage(urlStr: equip.icon)
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                    }
                    .corneredTag(
                        LocalizedStringKey("weapon.affix:\(equip.rank)"),
                        alignment: .topLeading
                    )
                    .corneredTag(
                        verbatim: "Lv.\(equip.level)",
                        alignment: .bottomTrailing
                    )
                }
            }
        }
    }
}