// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
import HBEnkaAPI
import SwiftUI

private let baseFontSize: CGFloat = 16

// MARK: - EachAvatarStatView

public struct EachAvatarStatView: View {
    // MARK: Public

    public let data: EnkaHSR.AvatarSummarized

    public var body: some View {
        VStack(spacing: 6) {
            data.mainInfo
            VStack {
                data.equippedWeapon
                VStack(spacing: 0) {
                    ForEach(data.avatarProperties, id: \.type) { property in
                        AttributeTagPair(
                            icon: property.type.iconFilePath,
                            title: property.localizedTitle,
                            valueStr: property.valueString,
                            fontSize: baseFontSize * 0.95
                        )
                    }
                }
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background {
                Color.black.opacity(0.2)
                    .clipShape(.rect(cornerSize: .init(width: 12, height: 12)))
            }
            artifactsList
            Spacer()
        }
        .fixedSize(horizontal: true, vertical: false)
        .preferredColorScheme(.dark)
        .background {
            AsyncImage(url: URL(fileURLWithPath: data.mainInfo.photoFilePath)) { imageObj in
                imageObj
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 60)
                    .contrast(2)
                    .opacity(0.47)
            } placeholder: {
                Color.clear
            }
        }
    }

    // MARK: Private

    private var artifactsList: some View {
        StaggeredGrid(columns: 2, spacing: 4, list: data.artifacts) { currentArtifact in
            currentArtifact
        }
    }
}

extension EnkaHSR.AvatarSummarized {
    public func asView() -> EachAvatarStatView {
        .init(data: self)
    }
}

// MARK: - EnkaHSR.AvatarSummarized.AvatarMainInfo + View

extension EnkaHSR.AvatarSummarized.AvatarMainInfo: View {
    public var body: some View {
        HStack(spacing: 2) {
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
            .frame(maxWidth: 96, maxHeight: 86)
            .clipShape(Circle())
            VStack(spacing: 0) {
                HStack {
                    Text(localizedName)
                        .font(.system(size: 30))
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
                        width: baseFontSize * 2.6,
                        height: baseFontSize * 2
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
                            width: 18,
                            height: 18
                        )
                        .background {
                            Color.black.clipShape(Circle()).blurMaterialBackground().opacity(0.3)
                        }
                    }
                }
                .shadow(radius: 5)
                HStack {
                    VStack(spacing: 4) {
                        AttributeTagPair(
                            title: "等级", valueStr: self.avatarLevel.description,
                            fontSize: baseFontSize * 0.9, dash: false
                        )
                        AttributeTagPair(
                            title: "命之座", valueStr: "C\(self.constellation)",
                            fontSize: baseFontSize * 0.9, dash: false
                        )
                    }.frame(maxWidth: 120, maxHeight: .infinity)
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        ForEach(baseSkills.toArray, id: \.type) { skill in
                            skill.fixedSize()
                        }
                    }
                    .minimumScaleFactor(0.5)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - EnkaHSR.AvatarSummarized.AvatarMainInfo.BaseSkillSet.BaseSkill + View

extension EnkaHSR.AvatarSummarized.AvatarMainInfo.BaseSkillSet.BaseSkill: View {
    func levelDisplay(size: CGFloat) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("\(self.adjustedLevel)").font(.system(size: size * 0.93, weight: .heavy))
        }
    }

    public var body: some View {
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
                    width: baseFontSize * 2.2,
                    height: baseFontSize * 2.2
                )
                Spacer()
            }
            // 这里不用 corneredTag，因为要动态调整图示与等级数字之间的显示距离。
            // 而且 skill.levelDisplay 也不是纯文本，而是 some View。
            ZStack(alignment: .center) {
                Color.black.opacity(0.1)
                    .clipShape(Capsule())
                levelDisplay(size: baseFontSize * 0.9)
                    .padding(.horizontal, 4)
            }.frame(height: baseFontSize).fixedSize()
        }
    }
}

// MARK: - EnkaHSR.AvatarSummarized.WeaponPanel + View

extension EnkaHSR.AvatarSummarized.WeaponPanel: View {
    public var body: some View {
        HStack(spacing: 6) {
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
            .frame(maxWidth: 80)
            .corneredTag(
                verbatim: "Lv.\(trainedLevel) ★\(rarityStars)",
                alignment: .bottom, textSize: baseFontSize * 0.8
            )
            VStack(alignment: .leading, spacing: 1) {
                Text(localizedName)
                    .fontWeight(.bold)
                    .fontWidth(.condensed)
                Divider().overlay {
                    Color.primary.opacity(0.6)
                }
                ForEach(props, id: \.type) { propUnit in
                    AttributeTagPair(
                        icon: propUnit.iconFilePath,
                        title: propUnit.localizedTitle,
                        valueStr: propUnit.valueString,
                        fontSize: baseFontSize * 0.93,
                        dash: false
                    )
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - EnkaHSR.AvatarSummarized.ArtifactInfo + View

extension EnkaHSR.AvatarSummarized.ArtifactInfo: View {
    public var body: some View {
        coreBody.padding(.vertical, 2).padding(.leading, 2)
            .background {
                Color.black.opacity(0.2)
                    .clipShape(.rect(cornerSize: .init(width: 12, height: 12)))
            }
    }

    public var coreBody: some View {
        HStack {
            Color.clear.frame(width: 38)
            VStack(spacing: 0) {
                AttributeTagPair(
                    icon: mainProp.iconFilePath,
                    title: "",
                    valueStr: mainProp.valueString,
                    fontSize: 13,
                    dash: false
                )
                Divider().overlay(.primary)
                StaggeredGrid(columns: 2, spacing: 0, list: self.subProps) { prop in
                    HStack(spacing: 0) {
                        if let iconPath = prop.iconFilePath {
                            AsyncImage(url: URL(fileURLWithPath: iconPath)) { imageObj in
                                imageObj
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            } placeholder: {
                                Color.clear
                            }
                        }
                        Text(prop.valueString)
                            .lineLimit(1)
                            .font(.system(size: 13))
                            .fontWidth(.compressed)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .minimumScaleFactor(0.5)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 4)
        }
        .fixedSize(horizontal: false, vertical: true)
        .shadow(radius: 10)
        .corneredTag(
            verbatim: "Lv.\(trainedLevel) ★\(rarityStars)",
            alignment: .bottomLeading, textSize: baseFontSize * 0.7
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
        fontSize givenFontSize: CGFloat? = nil,
        dash withDashLine: Bool = true
    ) {
        self.iconPath = iconPath
        self.title = title
        self.valueStr = valueStr
        self.withDashLine = withDashLine
        self.fontSize = givenFontSize ?? baseFontSize
    }

    // MARK: Public

    public let iconPath: String?
    public let title: String
    public let valueStr: String
    public let withDashLine: Bool
    public let fontSize: CGFloat

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
            Text(title)
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
                .fontWidth(.condensed)
                .fontWeight(.bold)
                .padding(.horizontal, 5)
                .background {
                    Color.secondary.opacity(0.2).clipShape(.capsule)
                }
        }.font(.system(size: fontSize))
            .fontWidth(.condensed)
            .fontWeight(.regular)
    }
}

// MARK: - EachAvatarStatView_Previews

struct EachAvatarStatView_Previews: PreviewProvider {
    static let summary: EnkaHSR.AvatarSummarized = {
        // swiftlint:disable force_try
        // Note: Do not use #Preview. Otherwise, the preview won't be able to access the assets.
        let enkaDatabase = EnkaHSR.EnkaDB(locTag: "zh-tw")!
        let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
            separator: "/"
        ).dropFirst()
        let testDataPath: String = packageRootPath + "/Tests/TestData/"
        let filePath = testDataPath + "TestQueryResult.json"
        let dataURL = URL(fileURLWithPath: filePath)
        let profile = try! Data(contentsOf: dataURL).parseAs(EnkaHSR.QueryRelated.QueriedProfile.self)
        let summary = profile.detailInfo!.avatarDetailList[3].summarize(theDB: enkaDatabase)!
        EnkaHSR.assetPathRoot = "\(packageRootPath)/../../Assets"
        return summary
        // swiftlint:enable force_try
    }()

    static var previews: some View {
        summary.asView()
    }
}
