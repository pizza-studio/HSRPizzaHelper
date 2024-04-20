// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
import HBEnkaAPI
import SwiftUI

// MARK: - AvatarShowCaseView

public struct AvatarShowCaseView: View {
    // MARK: Lifecycle

    public init(
        selection: Int = 0,
        profile: EnkaHSR.ProfileSummarized,
        onClose: (() -> Void)? = nil
    ) {
        var safeSelection = 0
        checkMatch: for (i, avatar) in profile.summarizedAvatars.enumerated() {
            if avatar.mainInfo.uniqueCharId == selection {
                safeSelection = i
                break checkMatch
            }
        }
        self.selection = safeSelection
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
                        showTabViewIndex = $showTabViewIndex.wrappedValue // 强制重新渲染整个画面。
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
                avatar.asView(background: false)
            }
        }
        #if !os(OSX)
        .tabViewStyle(
            .page(indexDisplayMode: showTabViewIndex ? .automatic : .never)
        )
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
            withAnimation(.easeIn(duration: 0.1)) {
                showTabViewIndex = true
            }
        }
        .ignoresSafeArea()
        #if !os(OSX)
            .statusBarHidden(true)
        #endif
            .onAppear {
                showTabViewIndex = true
            }
            .onChange(of: showTabViewIndex) { newValue in
                if newValue == true {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                        withAnimation {
                            showTabViewIndex = false
                        }
                    }
                }
            }
        #if os(OSX) || targetEnvironment(macCatalyst)
            .contextMenu {
                Group {
                    ForEach(profile.summarizedAvatars) { avatar in
                        Button(avatar.mainInfo.localizedName) {
                            withAnimation {
                                showingCharacterIdentifier = avatar.mainInfo.uniqueCharId
                            }
                        }
                    }
                }
            }
        #endif
    }

    // MARK: Internal

    @State var selection: Int = 0

    let onClose: (() -> Void)?

    @State var showTabViewIndex: Bool = false

    @State var showingCharacterIdentifier: Int

    @ObservedObject var profile: EnkaHSR.ProfileSummarized
    @StateObject var orientation = DeviceOrientation()

    var avatar: EnkaHSR.AvatarSummarized? {
        profile.summarizedAvatars.first(where: { avatar in
            avatar.mainInfo.uniqueCharId == showingCharacterIdentifier
        })
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
    }()

    static var previews: some View {
        summary.asView()
    }
}
#endif
