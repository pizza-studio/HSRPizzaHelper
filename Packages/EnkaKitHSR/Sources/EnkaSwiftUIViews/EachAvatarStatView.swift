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
        VStack(spacing: outerContentSpacing) {
            Group {
                data.mainInfo.asView(fontSize: fontSize)
                VStack(spacing: 2 * zoomFactor) {
                    data.equippedWeapon?.asView(fontSize: fontSize)
                    HStack {
                        VStack(spacing: 0) {
                            ForEach(data.avatarPropertiesA, id: \.type) { property in
                                AttributeTagPair(
                                    icon: property.type.iconFilePath,
                                    title: property.localizedTitle,
                                    valueStr: property.valueString,
                                    fontSize: fontSize * 0.8,
                                    dash: false
                                )
                            }
                        }
                        Divider().overlay {
                            Color.primary.opacity(0.3)
                        }
                        VStack(spacing: 0) {
                            ForEach(data.avatarPropertiesB, id: \.type) { property in
                                AttributeTagPair(
                                    icon: property.type.iconFilePath,
                                    title: property.localizedTitle,
                                    valueStr: property.valueString,
                                    fontSize: fontSize * 0.8,
                                    dash: false
                                )
                            }
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .minimumScaleFactor(0.5)
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
                .padding(.horizontal, 11 * zoomFactor)
                .padding(.vertical, 6 * zoomFactor)
                .background {
                    Color.black.opacity(0.2)
                        .clipShape(.rect(cornerSize: .init(width: fontSize * 0.5, height: fontSize * 0.5)))
                }
                StaggeredGrid(
                    columns: 2,
                    outerPadding: false,
                    scroll: false,
                    spacing: outerContentSpacing, list: data.artifacts
                ) { currentArtifact in
                    currentArtifact.asView(fontSize: fontSize, langTag: data.mainInfo.terms.langTag)
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 18 * zoomFactor)
            }
            .frame(width: 353 * zoomFactor)
            .padding(.top, 8 * zoomFactor)
            if shouldOptimizeForPhone {
                Spacer().frame(maxHeight: 100)
            }
        }
        .preferredColorScheme(.dark)
        .frame(width: 375 * zoomFactor) // 输出画面刚好 375*500，可同时相容于 iPad。
        .background {
            if showBackground {
                data.asBackground()
            }
        }
        // .showDimension()
        .scaleEffect(scaleRatioCompatible)
    }

    // MARK: Internal

    @Default(.enableArtifactRatingInShowcase) var enableArtifactRatingInShowcase: Bool

    // MARK: Private

    @Environment(\.verticalSizeClass) private var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    @StateObject private var orientation = DeviceOrientation()

    private let showBackground: Bool

    private var scaleRatioCompatible: CGFloat {
        DeviceOrientation.scaleRatioCompatible
    }

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

    private var zoomFactor: CGFloat {
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        return 1.3
        #else
        return 1.66
        #endif
    }

    private var fontSize: CGFloat {
        (shouldOptimizeForPhone ? 17 : 15) * zoomFactor
    }

    private var outerContentSpacing: CGFloat {
        (shouldOptimizeForPhone ? 8 : 4) * zoomFactor
    }

    private var innerContentSpacing: CGFloat {
        (shouldOptimizeForPhone ? 4 : 2) * zoomFactor
    }
}

extension EnkaHSR.AvatarSummarized {
    public func asView(background: Bool = false) -> EachAvatarStatView {
        .init(data: self, background: background)
    }

    @ViewBuilder
    public func asBackground() -> some View {
        ResIcon(mainInfo.photoFilePath) {
            $0.resizable()
        } placeholder: {
            AnyView(Color.clear)
        }
        .aspectRatio(contentMode: .fill)
        .blur(radius: 60)
        .saturation(3)
        .opacity(0.47)
    }

    @ViewBuilder
    public func asPortrait() -> some View {
        ResIcon(mainInfo.photoFilePath) {
            $0.resizable()
        } placeholder: {
            AnyView(Color.clear)
        }
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
        let cutType: IDPhotoView.IconType = clipToHead ? .cutHead : .cutShoulder
        if let idPhotoView = IDPhotoView(pid: uniqueCharId.description, size, cutType) {
            idPhotoView
        } else {
            let result = ResIcon(photoFilePath) {
                $0.resizable()
            } placeholder: {
                AnyView(Color.clear)
            }
            .aspectRatio(contentMode: .fit)
            .scaleEffect(1.5, anchor: .top)
            .scaleEffect(1.4)
            .frame(maxWidth: size, maxHeight: size)
            // Draw.
            let bgColor = Color.black.opacity(0.165)
            Group {
                if circleClipped {
                    result
                        .background { bgColor }
                        .clipShape(Circle())
                        .contentShape(Circle())
                } else {
                    result
                        .background { bgColor }
                        .clipShape(Rectangle())
                        .contentShape(Rectangle())
                }
            }
            .compositingGroup()
        }
    }

    /// 显示角色的扑克牌尺寸肖像，以身份证素材裁切而成。
    @ViewBuilder
    public func cardIcon(size: CGFloat) -> some View {
        if let idPhotoView = IDPhotoView(pid: uniqueCharId.description, size, .asCard) {
            idPhotoView
        } else {
            ResIcon(photoFilePath) {
                $0.resizable()
            } placeholder: {
                AnyView(Color.clear)
            }
            .aspectRatio(contentMode: .fit)
            .scaleEffect(1.5, anchor: .top)
            .scaleEffect(1.4)
            .frame(width: size * 0.74, height: size)
            .background {
                Color.black.opacity(0.165)
            }
            .clipShape(RoundedRectangle(cornerRadius: size / 10))
            .contentShape(RoundedRectangle(cornerRadius: size / 10))
            .compositingGroup()
        }
    }

    @ViewBuilder
    public func asView(fontSize: CGFloat) -> some View {
        HStack(alignment: .bottom, spacing: fontSize * 0.55) {
            avatarPhoto(size: fontSize * 5)
            VStack(spacing: 0) {
                HStack(alignment: .bottom) {
                    Text(localizedName)
                        .font(.system(size: fontSize * 1.6))
                        .fontWeight(.bold)
                        .lineLimit(1).fixedSize()
                        .minimumScaleFactor(0.5)
                    Spacer()
                    ZStack(alignment: .center) {
                        Color.black.opacity(0.1)
                            .clipShape(Circle())
                        ResIcon(lifePath.iconFilePath) {
                            $0.resizable()
                        } placeholder: {
                            AnyView(Color.clear)
                        }
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                    }.frame(
                        width: fontSize * 2.6,
                        height: fontSize * 2
                    ).overlay(alignment: .bottomTrailing) {
                        ZStack(alignment: .center) {
                            Color.black.opacity(0.05)
                                .clipShape(Circle())
                            ResIcon(element.iconFilePath) {
                                $0.resizable()
                            } placeholder: {
                                AnyView(Color.clear)
                            }
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
                    VStack(spacing: 1) {
                        AttributeTagPair(
                            title: terms.levelName, valueStr: self.avatarLevel.description,
                            fontSize: fontSize * 0.8, dash: false
                        )
                        AttributeTagPair(
                            title: terms.constellationName, valueStr: "E\(self.constellation)",
                            fontSize: fontSize * 0.8, dash: false
                        )
                    }.shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
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
            VStack {
                ZStack(alignment: .center) {
                    Color.black.opacity(0.1)
                        .clipShape(Circle())
                    ResIcon(iconFilePath) {
                        $0.resizable()
                    } placeholder: {
                        AnyView(Color.clear)
                    }
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

extension EnkaHSR.AvatarSummarized.WeaponPanel {
    @ViewBuilder
    public func asView(fontSize: CGFloat) -> some View {
        HStack(spacing: fontSize * 0.4) {
            ResIcon(iconFilePath) {
                $0.resizable()
            } placeholder: {
                AnyView(Color.clear)
            }
            .aspectRatio(contentMode: .fit)
            .background {
                Color.primary.opacity(0.075)
                    .clipShape(Circle())
            }
            .frame(maxWidth: fontSize * 4.46)
            .corneredTag(
                verbatim: "Lv.\(trainedLevel) ★\(rarityStars) ❖\(refinement)",
                alignment: .bottom, textSize: fontSize * 0.8
            )
            VStack(alignment: .leading, spacing: 2) {
                Text(localizedName)
                    .font(.system(size: fontSize, weight: .bold))
                    .fontWidth(.compressed)
                Divider().overlay {
                    Color.primary.opacity(0.6)
                }.padding(.vertical, 2)
                HStack {
                    ForEach(basicProps, id: \.type) { propUnit in
                        AttributeTagPair(
                            icon: propUnit.iconFilePath,
                            title: "",
                            valueStr: "+\(propUnit.valueString)",
                            fontSize: fontSize * 0.8,
                            dash: false
                        ).fixedSize()
                    }
                }
                HStack {
                    ForEach(specialProps, id: \.type) { propUnit in
                        AttributeTagPair(
                            icon: propUnit.iconFilePath,
                            title: "",
                            valueStr: "+\(propUnit.valueString)",
                            fontSize: fontSize * 0.8,
                            dash: false
                        )
                    }.fixedSize()
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
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
            VStack(spacing: 0) {
                AttributeTagPair(
                    icon: mainProp.iconFilePath,
                    title: "",
                    valueStr: mainProp.valueString,
                    fontSize: fontSize * 0.86,
                    dash: false
                )
                Divider().overlay(.primary)
                StaggeredGrid(
                    columns: 2,
                    outerPadding: false,
                    scroll: false,
                    spacing: 0,
                    list: self.subProps
                ) { prop in
                    HStack(spacing: 0) {
                        if let iconPath = prop.iconFilePath {
                            ResIcon(iconPath) {
                                $0.resizable()
                            } placeholder: {
                                AnyView(Color.clear)
                            }
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
            ResIcon(iconFilePath) {
                $0.resizable()
            } placeholder: {
                AnyView(Color.clear)
            }
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
        icon iconPath: String? = nil,
        title: String,
        valueStr: String,
        fontSize givenFontSize: CGFloat,
        dash withDashLine: Bool = true
    ) {
        self.iconPath = iconPath
        self.title = title
        self.valueStr = valueStr
        self.withDashLine = withDashLine
        self.fontSize = givenFontSize
    }

    // MARK: Public

    public let iconPath: String?
    public let title: String
    public let valueStr: String
    public let withDashLine: Bool
    public let fontSize: CGFloat

    public var shortenedTitle: String {
        var title = title
        EnkaHSR.Element.elementConversionDict.forEach { key, value in
            title = title.replacingOccurrences(of: key, with: value)
        }
        let suffix = title.count > 18 ? "…" : ""
        return "\(title.prefix(18))\(suffix)"
    }

    public var body: some View {
        HStack(spacing: 0) {
            if let iconPath = iconPath {
                ResIcon(iconPath) {
                    $0.resizable()
                } placeholder: {
                    AnyView(Color.clear)
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: fontSize * 1.5, height: fontSize * 1.5)
            }
            Text(shortenedTitle)
                .fixedSize()
                .lineLimit(1)
            if withDashLine {
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 1, alignment: .center)
                    .padding(.horizontal, 4)
            } else {
                Spacer().frame(minWidth: 1)
            }
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
                        Text(summary.mainInfo.localizedName)
                    }
            }
        }
    }
}
#endif
