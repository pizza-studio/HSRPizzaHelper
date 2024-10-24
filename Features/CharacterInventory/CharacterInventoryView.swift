// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import EnkaKitHSR
import EnkaSwiftUIViews
import HBMihoyoAPI
import SFSafeSymbols
import SwiftUI

// MARK: - CharacterInventoryView

struct CharacterInventoryView: View {
    // MARK: Lifecycle

    public init(data: MiHoYoAPI.CharacterInventory, isMiyousheUID: Bool) {
        self.data = data
        self.isMiyousheUID = isMiyousheUID
    }

    // MARK: Internal

    struct GoldNum {
        let allGold, charGold, weaponGold: Int
    }

    #if !os(OSX) && !targetEnvironment(macCatalyst)
    let flowSpacing: CGFloat = 4
    #else
    let flowSpacing: CGFloat = 2
    #endif

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 3) {
                    Text(characterStats)
                    if expanded {
                        if !isMiyousheUID {
                            Text(goldStats)
                        } else {
                            Text("app.characters.miyousheLimitations.description")
                        }
                    }
                }.font(.footnote)
            }.listRowMaterialBackground()
            Group {
                if expanded {
                    renderAllAvatarListFull()
                } else {
                    renderAllAvatarListCondensed()
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
    }

    @ViewBuilder
    func renderAllAvatarListFull() -> some View {
        Section {
            ForEach(showingAvatars, id: \.id) { avatar in
                AvatarListItem(avatar: avatar, condensed: false, limited: isMiyousheUID)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                    .background {
                        if let commonCharData = EnkaHSR.Sputnik.sharedDB.characters[avatar.id.description] {
                            let elementColor = commonCharData.element.themeColor.suiColor
                            let bgPath = EnkaHSR.queryImageAssetSUI(for: commonCharData.avatarBaseType.iconAssetName)?
                                .resizable()
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

    @ViewBuilder
    func renderAllAvatarListCondensed() -> some View {
        StaggeredGrid(
            columns: lineCapacity, outerPadding: false,
            scroll: false, spacing: 2, list: showingAvatars
        ) { avatar in
            // WIDTH: 70, HEIGHT: 63
            AvatarListItem(avatar: avatar, condensed: true)
                .padding(.vertical, 4)
                .compositingGroup()
        }
        .environmentObject(orientation)
        .overlay {
            GeometryReader { geometry in
                Color.clear.onAppear {
                    containerSize = geometry.size
                }.onChange(of: geometry.size) { newSize in
                    containerSize = newSize
                }
            }
        }
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

    private let data: MiHoYoAPI.CharacterInventory
    private let isMiyousheUID: Bool

    @State private var allAvatarListDisplayType: AllAvatarListDisplayType = .all
    @State private var expanded: Bool = false
    @State private var containerSize: CGSize = .init(width: 320, height: 320)
    @StateObject private var orientation = DeviceOrientation()
    @Environment(\.dismiss) private var dismiss

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

    private var lineCapacity: Int {
        Int(floor((containerSize.width - 20) / 70))
    }
}

// MARK: - AvatarListItem

struct AvatarListItem: View {
    // MARK: Lifecycle

    public init(avatar: MiHoYoAPI.CharacterInventory.HYAvatar, condensed: Bool, limited: Bool = false) {
        self.avatar = avatar
        self.condensed = condensed
        self.limited = limited // 是否被米游社限制了可提供的资料种类。
    }

    // MARK: Public

    public var body: some View {
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
                "detailPortal.ECDDV.eidolonResonance.unit:\(avatar.rank)",
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
                        ForEach(avatar.allArtifacts, id: \.id) { artifact in
                            Group {
                                if let img = queryArtifactImg(for: artifact) {
                                    img.resizable()
                                } else {
                                    WebImage(urlStr: artifact.icon).scaledToFit()
                                }
                            }
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        }
                        Spacer().frame(height: 20)
                    }
                }
                if !limited {
                    if let equip = avatar.equip {
                        ZStack(alignment: .bottomLeading) {
                            Group {
                                if let img = EnkaHSR.queryWeaponImageSUI(for: equip.id.description) {
                                    img.resizable()
                                } else {
                                    WebImage(urlStr: equip.icon)
                                }
                            }
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
                } else {
                    if let commonCharData = EnkaHSR.Sputnik.sharedDB.characters[avatar.id.description] {
                        EnkaHSR.queryImageAssetSUI(for: commonCharData.avatarBaseType.iconAssetName)?
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .padding(10)
                            .background {
                                Color.black.opacity(0.2).clipShape(Circle())
                            }
                            .frame(width: 50, height: 50)
                    }
                }
            }
        }
    }

    // MARK: Internal

    var charName: String {
        if EnkaHSR.Sputnik.sharedDB.characters.keys.contains(avatar.id.description) {
            let nameObj = EnkaHSR.CharacterName(pid: avatar.id)
            return nameObj.i18n(theDB: EnkaHSR.Sputnik.sharedDB, officialNameOnly: !useRealName)
        } else {
            return avatar.name
        }
    }

    @MainActor
    func queryArtifactImg(for target: any MiHoYoAPIArtifactProtocol) -> Image? {
        guard let neutralData = EnkaHSR.Sputnik.sharedDB.artifacts[target.id.description] else { return nil }
        guard let type = EnkaHSR.DBModels.Artifact.ArtifactType(typeID: target.pos)
        else { return nil } // Might need fix.
        let assetName = "relic_\(neutralData.setID)_\(type.assetSuffix)"
        return EnkaHSR.queryImageAssetSUI(for: assetName)
    }

    // MARK: Private

    private let avatar: MiHoYoAPI.CharacterInventory.HYAvatar
    private let limited: Bool

    @State private var condensed: Bool

    @Default(.useRealCharacterNames) private var useRealName: Bool
}
