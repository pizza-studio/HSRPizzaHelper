// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import EnkaKitHSR
import Foundation
import SwiftUI

// MARK: - ShowCaseListView

public struct ShowCaseListView: View {
    // MARK: Lifecycle

    public init(profile: EnkaHSR.ProfileSummarized, expanded: Bool = false) {
        self.profile = profile
        self.expanded = expanded
    }

    // MARK: Public

    @State public var expanded: Bool

    public var body: some View {
        if !expanded {
            bodyAsCardCase
        } else {
            bodyAsNavList
        }
    }

    @ViewBuilder public var bodyAsNavList: some View {
        ScrollView {
            Spacer()
            VStack {
                Divided {
                    // TabView 以 EnkaID 为依据，不能仅依赖资料本身的 Identifiable 特性。
                    ForEach(profile.summarizedAvatars, id: \.mainInfo.uniqueCharId) { avatar in
                        Button {
                            tapticMedium()
                            var transaction = Transaction()
                            transaction.animation = .easeInOut
                            transaction.disablesAnimations = !animateOnCallingCharacterShowcase
                            withTransaction(transaction) {
                                // TabView 以 EnkaId 为依据。
                                showingCharacterIdentifier = avatar.mainInfo.uniqueCharId
                            }
                        } label: {
                            HStack(alignment: .center) {
                                let intel = avatar.mainInfo
                                let strLevel = "\(intel.levelName): \(intel.avatarLevel)"
                                let strEL = "\(intel.constellationName): \(intel.constellation)"
                                intel.avatarPhoto(size: Font.baseFontSize * 3, circleClipped: true)
                                VStack(alignment: .leading) {
                                    Text(verbatim: intel.localizedName).font(.headline).fontWeight(.bold)
                                    HStack {
                                        Text(verbatim: strLevel)
                                        Spacer()
                                        Text(verbatim: strEL)
                                    }.font(.subheadline)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
        }
        #if !os(OSX)
        .fullScreenCover(item: $showingCharacterIdentifier) { enkaId in
            fullScreenCover(id: enkaId)
        }
        #endif
    }

    @ViewBuilder public var bodyAsCardCase: some View {
        // （Enka 被天空岛服务器喂屎的情形会导致 profile.summarizedAvatars 成为空阵列。）
        if profile.summarizedAvatars.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading) {
                ScrollView(.horizontal) {
                    HStack {
                        // TabView 以 EnkaID 为依据，不能仅依赖资料本身的 Identifiable 特性。
                        ForEach(profile.summarizedAvatars, id: \.mainInfo.uniqueCharId) { avatar in
                            Button {
                                tapticMedium()
                                var transaction = Transaction()
                                transaction.animation = .easeInOut
                                transaction.disablesAnimations = !animateOnCallingCharacterShowcase
                                withTransaction(transaction) {
                                    // TabView 以 EnkaId 为依据。
                                    showingCharacterIdentifier = avatar.mainInfo.uniqueCharId
                                }
                            } label: {
                                avatar.asCardIcon(75)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
                HelpTextForScrollingOnDesktopComputer(.horizontal)
            }
            #if !os(OSX)
            .fullScreenCover(item: $showingCharacterIdentifier) { enkaId in
                fullScreenCover(id: enkaId)
            }
            #endif
        }
    }

    // MARK: Internal

    @State var showingCharacterIdentifier: Int?
    @Default(.animateOnCallingCharacterShowcase) var animateOnCallingCharacterShowcase: Bool
    @ObservedObject var profile: EnkaHSR.ProfileSummarized

    @ViewBuilder
    func fullScreenCover(id enkaId: Int) -> some View {
        AvatarShowCaseView(
            selection: enkaId,
            profile: profile
        ) {
            var transaction = Transaction()
            transaction.animation = .easeInOut
            transaction.disablesAnimations = !animateOnCallingCharacterShowcase
            withTransaction(transaction) {
                showingCharacterIdentifier = nil
            }
        }
        .environment(\.colorScheme, .dark)
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss

    private func tapticMedium() {
        #if !os(OSX)
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
        #endif
    }
}

// MARK: - Int + Identifiable

extension Int: Identifiable {
    public var id: String { description }
}

extension EnkaHSR.QueryRelated.DetailInfo {
    public func asView(theDB: EnkaHSR.EnkaDB, expanded: Bool = false) -> ShowCaseListView {
        .init(profile: summarize(theDB: theDB), expanded: expanded)
    }
}

// MARK: - EachAvatarStatView_Previews

#if DEBUG
struct ShowCaseListView_Previews: PreviewProvider {
    static let enkaDatabase = EnkaHSR.EnkaDB(locTag: "ja")!
    static let detailInfo: EnkaHSR.QueryRelated.DetailInfo = {
        // swiftlint:disable force_try
        // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
        let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
            separator: "/"
        ).dropFirst()
        let testDataPath: String = packageRootPath + "/Tests/TestData/"
        let filePath = testDataPath + "TestQueryResultEnka.json"
        let dataURL = URL(fileURLWithPath: filePath)
        let profile = try! Data(contentsOf: dataURL).parseAs(EnkaHSR.QueryRelated.QueriedProfile.self)
        EnkaHSR.assetPathRoot = "\(packageRootPath)/../../Assets"
        return profile.detailInfo!
        // swiftlint:enable force_try
    }()

    static var previews: some View {
        detailInfo.asView(theDB: enkaDatabase).frame(width: 510, height: 720)
    }
}
#endif
