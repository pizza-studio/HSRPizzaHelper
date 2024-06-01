// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import EnkaKitHSR
import Foundation
import SwiftUI

// MARK: - AvatarShowCaseView

public struct AvatarShowCaseView: View {
    // MARK: Lifecycle

    public init(
        selection: Int = 0,
        profile: EnkaHSR.ProfileSummarized,
        onClose: (() -> Void)? = nil
    ) {
        let safeSelection = profile.summarizedAvatars.firstIndex {
            $0.mainInfo.uniqueCharId == selection
        } ?? 0
        self.onClose = onClose
        self.profile = profile
        self.showingCharacterIdentifier = profile.summarizedAvatars[safeSelection].mainInfo.uniqueCharId
    }

    // MARK: Public

    public var body: some View {
        if hasNoAvatars {
            blankView()
        } else {
            GeometryReader { geometry in
                actualView()
                    .environmentObject(orientation)
                    .overlay(alignment: .top) {
                        HelpTextForScrollingOnDesktopComputer(.horizontal).padding()
                    }.onChange(of: geometry.size) { _ in
                        showingCharacterIdentifier = $showingCharacterIdentifier.wrappedValue // 强制重新渲染整个画面。
                    }
            }
        }
    }

    public var hasNoAvatars: Bool {
        profile.summarizedAvatars.isEmpty
    }

    @ViewBuilder
    public func blankView() -> some View {
        Text("🗑️")
    }

    @ViewBuilder
    public func actualView() -> some View {
        TabView(selection: $showingCharacterIdentifier.animation()) {
            // TabView 以 EnkaID 为依据。
            ForEach(profile.summarizedAvatars) { avatar in
                EachAvatarStatView(data: avatar, background: false)
                    .fixedSize()
                    .compositingGroup()
                    .scaleEffect(scaleRatioCompatible)
                    .contextMenu {
                        Group {
                            Button("app.detailPortal.avatar.summarzeToClipboard.asText") {
                                Clipboard.writeString(avatar.asText)
                            }
                            Button("app.detailPortal.avatar.summarzeToClipboard.asMD") {
                                Clipboard.writeString(avatar.asMarkDown)
                            }
                            #if os(OSX) || targetEnvironment(macCatalyst)
                            Divider()
                            ForEach(profile.summarizedAvatars) { theAvatar in
                                Button(theAvatar.mainInfo.name) {
                                    withAnimation {
                                        showingCharacterIdentifier = theAvatar.mainInfo.uniqueCharId
                                    }
                                }
                            }
                            #endif
                        }
                    }
            }
        }
        #if !os(OSX)
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        #endif
        .onTapGesture {
            onClose?()
        }
        .background {
            avatar?.asBackground()
                .scaledToFill()
                .scaleEffect(1.2)
                .ignoresSafeArea(.all)
        }
        .onChange(of: showingCharacterIdentifier) { _ in
            #if canImport(UIKit)
            let selectionGenerator = UISelectionFeedbackGenerator()
            selectionGenerator.selectionChanged()
            #endif
        }
        .clipped()
        .ignoresSafeArea(.all)
        #if !os(OSX)
            .statusBarHidden(true)
        #endif
    }

    // MARK: Private

    @State private var showingCharacterIdentifier: Int
    @ObservedObject private var profile: EnkaHSR.ProfileSummarized
    @StateObject private var orientation = DeviceOrientation()

    private let onClose: (() -> Void)?

    private var avatar: EnkaHSR.AvatarSummarized? {
        profile.summarizedAvatars.first(where: { avatar in
            avatar.mainInfo.uniqueCharId == showingCharacterIdentifier
        })
    }

    private var scaleRatioCompatible: CGFloat {
        DeviceOrientation.scaleRatioCompatible
    }
}

extension EnkaHSR.ProfileSummarized {
    public func asView() -> AvatarShowCaseView {
        .init(profile: self)
    }
}

// MARK: - EachAvatarStatView_Previews

#if DEBUG
struct AvatarShowCaseView_Previews: PreviewProvider {
    static let summary: EnkaHSR.ProfileSummarized = {
        // swiftlint:disable force_try
        // swiftlint:disable force_unwrapping
        // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
        let enkaDatabase = EnkaHSR.EnkaDB(locTag: "ja")!
        let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
            separator: "/"
        ).dropFirst()
        let testDataPath: String = packageRootPath + "/Tests/TestData/"
        let filePath = testDataPath + "TestQueryResultEnka.json"
        let dataURL = URL(fileURLWithPath: filePath)
        let profile = try! Data(contentsOf: dataURL).parseAs(EnkaHSR.QueryRelated.QueriedProfile.self)
        let summary = profile.detailInfo!.summarize(theDB: enkaDatabase)
        EnkaHSR.assetPathRoot = "\(packageRootPath)/../../Assets"
        return summary
        // swiftlint:enable force_try
        // swiftlint:enable force_unwrapping
    }()

    static var previews: some View {
        summary.asView()
    }
}
#endif
