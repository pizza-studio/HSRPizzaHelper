// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
import HBEnkaAPI
import SwiftUI

// MARK: - EachAvatarStatView

public struct EachAvatarStatView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    @StateObject private var orientation = DeviceOrientation()

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

    // MARK: Public

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

    public let data: EnkaHSR.AvatarSummarized

    public var body: some View {
        // 按照 iPhone SE2-SE3 的标准画面解析度（375 × 667）制作。
        VStack(spacing: outerContentSpacing) {
            Group {
                data.mainInfo.asView(fontSize: fontSize)
                VStack(spacing: 2 * zoomFactor) {
                    data.equippedWeapon.asView(fontSize: fontSize)
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
                    currentArtifact.asView(fontSize: fontSize)
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
            AsyncImage(url: URL(fileURLWithPath: data.mainInfo.photoFilePath)) { imageObj in
                imageObj
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 60)
                    .saturation(3)
                    .opacity(0.47)
            } placeholder: {
                Color.clear
            }
        }
        // .showDimension()
        .scaleEffect(scaleRatioCompatible)
    }
}

extension EnkaHSR.AvatarSummarized {
    public func asView() -> EachAvatarStatView {
        .init(data: self)
    }
}

extension EnkaHSR.AvatarSummarized.AvatarMainInfo {
    @ViewBuilder
    public func asView(fontSize: CGFloat) -> some View {
        HStack(alignment: .bottom, spacing: fontSize * 0.55) {
            AsyncImage(url: URL(fileURLWithPath: self.photoFilePath)) { imageObj in
                imageObj
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background {
                        Color.black.opacity(0.165)
                    }
            } placeholder: {
                Color.clear
            }
            .frame(maxWidth: fontSize * 5, maxHeight: fontSize * 5)
            .clipShape(Circle())
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
                        AsyncImage(url: URL(fileURLWithPath: lifePath.iconFilePath)) { imageObj in
                            imageObj.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Color.clear
                        }
                        .clipShape(Circle())
                    }.frame(
                        width: fontSize * 2.6,
                        height: fontSize * 2
                    ).overlay(alignment: .bottomTrailing) {
                        ZStack(alignment: .center) {
                            Color.black.opacity(0.05)
                                .clipShape(Circle())
                            AsyncImage(url: URL(fileURLWithPath: element.iconFilePath)) { imageObj in
                                imageObj
                                    .resizable()
                                    .brightness(0.1)
                            } placeholder: {
                                Color.clear
                            }
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
                            title: levelName, valueStr: self.avatarLevel.description,
                            fontSize: fontSize * 0.8, dash: false
                        )
                        AttributeTagPair(
                            title: constellationName, valueStr: "C\(self.constellation)",
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
    }

    @ViewBuilder
    public func asView(fontSize: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            VStack {
                ZStack(alignment: .center) {
                    Color.black.opacity(0.1)
                        .clipShape(Circle())
                    AsyncImage(url: URL(fileURLWithPath: iconFilePath)) { imageObj in
                        imageObj.resizable()
                    } placeholder: {
                        Color.clear
                    }
                    .clipShape(Circle())
                    .scaleEffect(0.8)
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
            }.frame(height: fontSize).fixedSize()
        }
    }
}

extension EnkaHSR.AvatarSummarized.WeaponPanel {
    @ViewBuilder
    public func asView(fontSize: CGFloat) -> some View {
        HStack(spacing: fontSize * 0.4) {
            AsyncImage(url: URL(fileURLWithPath: iconFilePath)) { imageObj in
                imageObj
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background {
                        Color.primary.opacity(0.075)
                            .clipShape(Circle())
                    }
            } placeholder: {
                Color.clear
            }
            .frame(maxWidth: fontSize * 4.46)
            .corneredTag(
                verbatim: "Lv.\(trainedLevel) ★\(rarityStars)",
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
    @ViewBuilder
    public func asView(fontSize: CGFloat) -> some View {
        coreBody(fontSize: fontSize)
            .padding(.vertical, fontSize * 0.13)
            .padding(.horizontal, fontSize * 0.3)
            .background {
                Color.black.opacity(0.2)
                    .clipShape(.rect(cornerSize: .init(width: fontSize * 0.5, height: fontSize * 0.5)))
            }
    }

    private func coreBody(fontSize: CGFloat) -> some View {
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
                            AsyncImage(url: URL(fileURLWithPath: iconPath)) { imageObj in
                                imageObj
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: fontSize * 1.25, height: fontSize * 1.25)
                            } placeholder: {
                                Color.clear
                            }
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
            AsyncImage(url: URL(fileURLWithPath: iconFilePath)) { imageObj in
                imageObj
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.9)
                    .scaleEffect(0.8, anchor: .topLeading)
            } placeholder: {
                Color.clear
            }
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
                AsyncImage(url: URL(fileURLWithPath: iconPath)) { imageObj in
                    imageObj.resizable()
                } placeholder: {
                    Color.clear.frame(width: fontSize * 1.25, height: fontSize * 1.25)
                }
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
    static let summary: EnkaHSR.AvatarSummarized = {
        // swiftlint:disable force_try
        // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
        let enkaDatabase = EnkaHSR.EnkaDB(locTag: "ja")!
        let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
            separator: "/"
        ).dropFirst()
        let testDataPath: String = packageRootPath + "/Tests/TestData/"
        let filePath = testDataPath + "TestQueryResultEnka.json"
        let dataURL = URL(fileURLWithPath: filePath)
        let profile = try! Data(contentsOf: dataURL).parseAs(EnkaHSR.QueryRelated.QueriedProfile.self)
        let summary = profile.detailInfo!.avatarDetailList[4].summarize(theDB: enkaDatabase)!
        EnkaHSR.assetPathRoot = "\(packageRootPath)/../../Assets"
        return summary
        // swiftlint:enable force_try
    }()

    static var previews: some View {
        summary.asView()
    }
}
#endif