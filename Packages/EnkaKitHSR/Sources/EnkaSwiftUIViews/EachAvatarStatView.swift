// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import EnkaKitHSR
import Foundation
import SwiftUI

// MARK: - EachAvatarStatView

public struct EachAvatarStatView: View {
    // MARK: Lifecycle

    public init(data: EnkaHSR.AvatarSummarized, background: Bool = false) {
        self.showBackground = background
        self.data = data
    }

    // MARK: Public

    public let data: EnkaHSR.AvatarSummarized

    public var body: some View {
        // 按照 iPhone SE2-SE3 的标准画面解析度（375 × 667）制作。
        LazyVStack(spacing: outerContentSpacing) {
            data.mainInfo.asView(fontSize: fontSize)
            LazyVStack(spacing: 2 * Self.zoomFactor) {
                data.equippedWeapon?.asView(fontSize: fontSize)
                propertyGrid
                artifactRatingSummaryRow
            }
            .padding(.horizontal, 11 * Self.zoomFactor)
            .padding(.vertical, 6 * Self.zoomFactor)
            .background {
                Color.black.opacity(0.2)
                    .clipShape(.rect(cornerSize: .init(width: fontSize * 0.5, height: fontSize * 0.5)))
            }
            artifactGrid
        }
        .preferredColorScheme(.dark)
        .frame(width: 375 * Self.zoomFactor) // 输出画面刚好 375*500，可同时相容于 iPad。
        .padding(Self.spacingDeltaAmount * 7)
        .padding(.vertical, Self.spacingDeltaAmount * 5)
        .background {
            if showBackground {
                ZStack {
                    Color(hue: 0, saturation: 0, brightness: 0.1)
                    data.asBackground()
                        .scaledToFill()
                        .scaleEffect(1.2)
                }
                .compositingGroup()
                .ignoresSafeArea(.all)
            }
        }
        // .showDimension()
    }

    // MARK: Internal

    @Default(.enableArtifactRatingInShowcase) var enableArtifactRatingInShowcase: Bool

    @ViewBuilder var artifactRatingSummaryRow: some View {
        if enableArtifactRatingInShowcase, let ratingResult = data.artifactRatingResult {
            HStack {
                Text(verbatim: " → " + data.mainInfo.terms.artifactRatingName)
                    .fontWidth(.compressed)
                Spacer()
                Text(
                    verbatim: ratingResult.sumExpression
                        + ratingResult.allpt.description
                        + "(\(ratingResult.result))"
                )
                .fontWeight(.bold)
                .fontWidth(.condensed)
            }
            .font(.system(size: fontSize * 0.7))
            .opacity(0.9)
            .padding(.top, 2)
        }
    }

    @ViewBuilder var propertyGrid: some View {
        let gridColumnsFixed = [GridItem](repeating: .init(.flexible()), count: 2)
        LazyVGrid(columns: gridColumnsFixed, spacing: 0) {
            let max = data.avatarPropertiesA.count
            ForEach(0 ..< max, id: \.self) {
                let property1 = data.avatarPropertiesA[$0]
                let property2 = data.avatarPropertiesB[$0]
                AttributeTagPair(
                    icon: property1.type.iconAssetName,
                    title: property1.localizedTitle,
                    valueStr: property1.valueString,
                    fontSize: fontSize * 0.8
                )
                AttributeTagPair(
                    icon: property2.type.iconAssetName,
                    title: property2.localizedTitle,
                    valueStr: property2.valueString,
                    fontSize: fontSize * 0.8
                )
            }
        }
    }

    @ViewBuilder var artifactGrid: some View {
        let gridColumnsFixed = [GridItem](repeating: .init(), count: 2)
        LazyVGrid(columns: gridColumnsFixed, spacing: outerContentSpacing) {
            ForEach(data.artifacts) { currentArtifact in
                currentArtifact.asView(fontSize: fontSize, langTag: data.mainInfo.terms.langTag)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.bottom, 18 * Self.zoomFactor)
    }

    // MARK: Private

    private static let zoomFactor: CGFloat = {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        return 1.3
        #else
        return 1.66
        #endif
    }()

    private static let spacingDeltaAmount: CGFloat = 5

    @Environment(\.verticalSizeClass) private var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    private let showBackground: Bool

    private var shouldOptimizeForPhone: Bool {
        #if os(macOS) || targetEnvironment(macCatalyst)
        return false
        #else
        // ref: https://forums.developer.apple.com/forums/thread/126878
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.regular, .regular): return false
        default: return true
        }
        #endif
    }

    private var fontSize: CGFloat {
        (shouldOptimizeForPhone ? 17 : 15) * Self.zoomFactor
    }

    private var outerContentSpacing: CGFloat {
        (shouldOptimizeForPhone ? 8 : 4) * Self.zoomFactor
    }

    private var innerContentSpacing: CGFloat {
        (shouldOptimizeForPhone ? 4 : 2) * Self.zoomFactor
    }
}

extension EnkaHSR.AvatarSummarized {
    public func asView(background: Bool = false) -> EachAvatarStatView {
        .init(data: self, background: background)
    }

    @ViewBuilder
    public func asBackground() -> some View {
        EnkaHSR.queryImageAssetSUI(for: mainInfo.idExpressable.photoAssetName)?
            .resizable()
            .aspectRatio(contentMode: .fill)
            .blur(radius: 60)
            .saturation(3)
            .opacity(0.47)
    }

    @ViewBuilder
    public func asPortrait() -> some View {
        EnkaHSR.queryImageAssetSUI(for: mainInfo.idExpressable.photoAssetName)?
            .resizable()
            .aspectRatio(contentMode: .fit)
            .background {
                Color.black.opacity(0.165)
            }
    }

    /// 显示角色的扑克牌尺寸肖像，以身份证素材裁切而成。
    @ViewBuilder
    public func asCardIcon(
        _ size: CGFloat
    )
        -> some View {
        mainInfo.cardIcon(size: size)
    }
}

extension EnkaHSR.AvatarSummarized.AvatarMainInfo {
    @ViewBuilder
    public func avatarPhoto(size: CGFloat, circleClipped: Bool = true, clipToHead: Bool = false) -> some View {
        idExpressable.avatarPhoto(size: size, circleClipped: circleClipped, clipToHead: clipToHead)
    }

    /// 显示角色的扑克牌尺寸肖像，以身份证素材裁切而成。
    @ViewBuilder
    public func cardIcon(size: CGFloat) -> some View {
        idExpressable.cardIcon(size: size)
    }

    @ViewBuilder
    public func asView(fontSize: CGFloat) -> some View {
        HStack(alignment: .bottom, spacing: fontSize * 0.55) {
            avatarPhoto(size: fontSize * 5)
            LazyVStack(spacing: 0) {
                HStack(alignment: .bottom) {
                    Text(name)
                        .font(.system(size: fontSize * 1.6))
                        .fontWeight(.bold)
                        .lineLimit(1).fixedSize()
                        .minimumScaleFactor(0.5)
                    Spacer()
                    ZStack(alignment: .center) {
                        Color.black.opacity(0.1)
                            .clipShape(Circle())
                        EnkaHSR.queryImageAssetSUI(for: lifePath.iconAssetName)?.resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                    }.frame(
                        width: fontSize * 2.6,
                        height: fontSize * 2
                    ).overlay(alignment: .bottomTrailing) {
                        ZStack(alignment: .center) {
                            Color.black.opacity(0.05)
                                .clipShape(Circle())
                            EnkaHSR.queryImageAssetSUI(for: element.iconAssetName)?.resizable()
                                .brightness(0.1)
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                        }.frame(
                            width: fontSize * 0.95,
                            height: fontSize * 0.95
                        )
                        .background {
                            Color.black.clipShape(Circle()).blurMaterialBackground().opacity(0.3)
                        }
                    }
                }
                .shadow(radius: 5)
                HStack {
                    LazyVStack(spacing: 1) {
                        AttributeTagPair(
                            title: terms.levelName, valueStr: self.avatarLevel.description,
                            fontSize: fontSize * 0.8
                        )
                        AttributeTagPair(
                            title: terms.constellationName, valueStr: "E\(self.constellation)",
                            fontSize: fontSize * 0.8
                        )
                    }.shadow(radius: 10)
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        ForEach(baseSkills.toArray, id: \.type) { skill in
                            skill.asView(fontSize: fontSize).fixedSize()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .minimumScaleFactor(0.5)
                }.fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

extension EnkaHSR.AvatarSummarized.AvatarMainInfo.BaseSkillSet.BaseSkill {
    func levelDisplay(size: CGFloat) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("\(baseLevel)").font(.system(size: size * 0.8, weight: .heavy))
            if let additionalLevel = self.levelAddition {
                Text("+\(additionalLevel)").font(.system(size: size * 0.65, weight: .black))
            }
        }
        .foregroundStyle(.white) // Always use white color for the text of these information.
    }

    @ViewBuilder
    public func asView(fontSize: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            LazyVStack {
                ZStack(alignment: .center) {
                    Color.black.opacity(0.1)
                        .clipShape(Circle())
                    EnkaHSR.queryImageAssetSUI(for: iconAssetName)?.resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .scaleEffect(0.8)
                        .shadow(radius: 5)
                }.frame(
                    width: fontSize * 2.2,
                    height: fontSize * 2
                )
                Spacer()
            }
            // 这里不用 corneredTag，因为要动态调整图示与等级数字之间的显示距离。
            // 而且 skill.levelDisplay 也不是纯文本，而是 some View。
            ZStack(alignment: .center) {
                Color.black.opacity(0.1)
                    .clipShape(Capsule())
                levelDisplay(size: fontSize * 0.9)
                    .padding(.horizontal, 4)
                    .shadow(
                        color: Color(.sRGBLinear, white: 0, opacity: 1),
                        radius: 3
                    )
            }.frame(height: fontSize).fixedSize()
        }
    }
}

// MARK: - WeaponPanelView

private struct WeaponPanelView: View {
    // MARK: Lifecycle

    public init(for weapon: EnkaHSR.AvatarSummarized.WeaponPanel, fontSize: CGFloat) {
        self.fontSize = fontSize
        self.weapon = weapon
        self.iconImg = EnkaHSR.queryWeaponImageSUI(for: weapon.enkaId.description)
    }

    // MARK: Public

    public var body: some View {
        HStack(spacing: fontSize * 0.4) {
            iconImg?
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background {
                    Color.primary.opacity(0.075)
                        .clipShape(Circle())
                }
                .frame(maxWidth: fontSize * 4.46)
                .corneredTag(
                    verbatim: corneredTagText,
                    alignment: .bottom, textSize: fontSize * 0.8
                )
            LazyVStack(alignment: .leading, spacing: 2) {
                Text(weapon.localizedName)
                    .font(.system(size: fontSize, weight: .bold))
                    .fontWidth(.compressed)
                Divider().overlay {
                    Color.primary.opacity(0.6)
                }.padding(.vertical, 2)
                HStack {
                    ForEach(weapon.basicProps, id: \.type) { propUnit in
                        AttributeTagPair(
                            icon: propUnit.iconAssetName,
                            title: "",
                            valueStr: "+\(propUnit.valueString)",
                            fontSize: fontSize * 0.8
                        ).fixedSize()
                    }
                }
                HStack {
                    ForEach(weapon.specialProps, id: \.type) { propUnit in
                        AttributeTagPair(
                            icon: propUnit.iconAssetName,
                            title: "",
                            valueStr: "+\(propUnit.valueString)",
                            fontSize: fontSize * 0.8
                        )
                    }.fixedSize()
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: Internal

    var corneredTagText: String {
        "Lv.\(weapon.trainedLevel) ★\(weapon.rarityStars) ❖\(weapon.refinement)"
    }

    // MARK: Private

    private let weapon: EnkaHSR.AvatarSummarized.WeaponPanel
    private let fontSize: CGFloat
    private let iconImg: Image?
}

extension EnkaHSR.AvatarSummarized.WeaponPanel {
    @ViewBuilder
    public func asView(fontSize: CGFloat) -> some View {
        WeaponPanelView(for: self, fontSize: fontSize)
    }
}

extension EnkaHSR.AvatarSummarized.ArtifactInfo {
    private func scoreText(lang: String) -> String {
        guard Defaults[.enableArtifactRatingInShowcase] else { return "" }
        let unit = EnkaHSR.EnkaDB.ExtraTerms(lang: lang).artifactRatingUnit
        if let score = ratedScore?.description {
            return score + unit
        }
        return ""
    }

    @ViewBuilder
    public func asView(fontSize: CGFloat, langTag: String) -> some View {
        coreBody(fontSize: fontSize, langTag: langTag)
            .padding(.vertical, fontSize * 0.13)
            .padding(.horizontal, fontSize * 0.3)
            .background {
                Color.black.opacity(0.2)
                    .clipShape(.rect(cornerSize: .init(width: fontSize * 0.5, height: fontSize * 0.5)))
            }
    }

    @ViewBuilder
    private func coreBody(fontSize: CGFloat, langTag: String) -> some View {
        HStack(alignment: .top) {
            Color.clear.frame(width: fontSize * 2.6)
            LazyVStack(spacing: 0) {
                AttributeTagPair(
                    icon: mainProp.iconAssetName,
                    title: "",
                    valueStr: mainProp.valueString,
                    fontSize: fontSize * 0.86
                )
                Divider().overlay {
                    Color.primary.opacity(0.6)
                }
                let gridColumnsFixed = [GridItem](repeating: .init(), count: 2)
                LazyVGrid(columns: gridColumnsFixed, spacing: 0) {
                    ForEach(self.subProps) { prop in
                        HStack(spacing: 0) {
                            if let assetName = prop.iconAssetName {
                                EnkaHSR.queryImageAssetSUI(for: assetName)?
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: fontSize * 1.25, height: fontSize * 1.25)
                            }
                            Text(prop.valueString)
                                .lineLimit(1)
                                .font(.system(size: fontSize * 0.86))
                                .fontWidth(.compressed)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .minimumScaleFactor(0.5)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(height: fontSize * 4)
        .fixedSize(horizontal: false, vertical: true)
        .shadow(radius: 10)
        .corneredTag(
            verbatim: "Lv.\(trainedLevel) ★\(rarityStars)",
            alignment: .bottomLeading, textSize: fontSize * 0.7
        )
        .background(alignment: .topLeading) {
            EnkaHSR.queryImageAssetSUI(for: iconAssetName)?
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(0.9)
                .corneredTag(
                    verbatim: scoreText(lang: langTag),
                    alignment: .bottomLeading, textSize: fontSize * 0.8
                )
                .scaleEffect(0.8, anchor: .topLeading)
        }
    }
}

// MARK: - AttributeTagPair

public struct AttributeTagPair: View {
    // MARK: Lifecycle

    public init(
        icon iconAssetName: String? = nil,
        title: String,
        valueStr: String,
        fontSize givenFontSize: CGFloat
    ) {
        self.title = title
        self.valueStr = valueStr
        self.fontSize = givenFontSize
        self.shortenedTitle = {
            var title = title
            EnkaHSR.Element.elementConversionDict.forEach { key, value in
                title = title.replacingOccurrences(of: key, with: value)
            }
            let suffix = title.count > 18 ? "…" : ""
            return "\(title.prefix(18))\(suffix)"
        }()

        if let iconAssetName = iconAssetName, let img = EnkaHSR.queryImageAssetSUI(for: iconAssetName) {
            self.iconImg = img.resizable()
        } else {
            self.iconImg = nil
        }
    }

    // MARK: Public

    public let title: String
    public let valueStr: String
    public let fontSize: CGFloat
    public let shortenedTitle: String
    public let iconImg: Image?

    public var body: some View {
        HStack(spacing: 0) {
            iconImg?
                .aspectRatio(contentMode: .fit)
                .frame(width: fontSize * 1.5, height: fontSize * 1.5)
            Text(shortenedTitle)
                .fixedSize()
                .lineLimit(1)
            Spacer().frame(minWidth: 1)
            Text(valueStr)
                .fixedSize()
                .lineLimit(1)
                .font(.system(size: fontSize))
                .fontWidth(.compressed)
                .fontWeight(.bold)
                .padding(.horizontal, 5)
                .background {
                    Color.secondary.opacity(0.2).clipShape(.capsule)
                }
        }.font(.system(size: fontSize))
            .fontWidth(.compressed)
            .fontWeight(.regular)
    }
}

// MARK: - View Dimension Measurement

extension View {
    func showDimension() -> some View {
        #if DEBUG
        overlay(
            GeometryReader { geometry in
                Text(geometry.size.debugDescription)
                    .background(.red)
            }
        )
        #else
        self
        #endif
    }
}

// MARK: - EachAvatarStatView_Previews

#if DEBUG
struct EachAvatarStatView_Previews: PreviewProvider {
    static let summaries: [EnkaHSR.AvatarSummarized] = {
        // swiftlint:disable force_try
        // swiftlint:disable force_unwrapping
        // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
        let enkaDatabase = EnkaHSR.EnkaDB(locTag: "zh-cn")!
        let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
            separator: "/"
        ).dropFirst()
        let testDataPath: String = packageRootPath + "/Tests/TestData/"
        let filePath = testDataPath + "TestQueryResultEnka.json"
        let dataURL = URL(fileURLWithPath: filePath)
        let profile = try! Data(contentsOf: dataURL).parseAs(EnkaHSR.QueryRelated.QueriedProfile.self)
        let summaries = profile.detailInfo!.avatarDetailList.map { $0.summarize(theDB: enkaDatabase)! }
        EnkaHSR.assetPathRoot = "\(packageRootPath)/../../Assets"
        return summaries
        // swiftlint:enable force_try
        // swiftlint:enable force_unwrapping
    }()

    static var previews: some View {
        TabView {
            ForEach(summaries) { summary in
                summary.asView(background: true)
                    .tabItem {
                        Text(summary.mainInfo.name)
                    }
            }
        }
    }
}
#endif
