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
                coreBody()
                    .environmentObject(orientation)
                    .overlay(alignment: .top) {
                        HelpTextForScrollingOnDesktopComputer(.horizontal).padding()
                    }.onChange(of: geometry.size) { _ in
                        showTabViewIndex = $showTabViewIndex.wrappedValue // 强制重新渲染整个画面。
                    }
            }
        }
    }

    @ViewBuilder
    public func coreBody() -> some View {
        TabView(selection: $showingCharacterIdentifier.animation()) {
            // TabView 以 EnkaID 为依据。
            ForEach(profile.summarizedAvatars) { avatar in
                framedCoreView(avatar)
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
            ZStack {
                Color(hue: 0, saturation: 0, brightness: 0.1)
                avatar?.asBackground()
                    .scaledToFill()
                    .scaleEffect(1.2)
                    .clipped()
            }
            .compositingGroup()
            .ignoresSafeArea(.all)
        }
        .contextMenu {
            if let avatar = avatar {
                Group {
                    Button("app.detailPortal.avatar.summarzeToClipboard.asText") {
                        Clipboard.writeString(avatar.asText)
                    }
                    Button("app.detailPortal.avatar.summarzeToClipboard.asMD") {
                        Clipboard.writeString(avatar.asMarkDown)
                    }
                    Divider()
                    ForEach(profile.summarizedAvatars) { theAvatar in
                        Button(theAvatar.mainInfo.name) {
                            withAnimation {
                                showingCharacterIdentifier = theAvatar.mainInfo.uniqueCharId
                            }
                        }
                    }
                }
            }
        }
        .clipped()
        .compositingGroup()
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
        #if !os(OSX)
        .statusBarHidden(true)
        #endif
    }

    // MARK: Internal

    @ViewBuilder
    func framedCoreView(_ avatar: EnkaHSR.AvatarSummarized) -> some View {
        VStack {
            Spacer().frame(width: 25, height: 10)
            /// Width is locked inside the EachAvatarStatView.
            EachAvatarStatView(data: avatar, background: false)
                .fixedSize()
                .scaleEffect(scaleRatioCompatible)
            Spacer().frame(width: 25, height: bottomSpacerHeight)
        }
    }

    @ViewBuilder
    func blankView() -> some View {
        Text("🗑️")
    }

    // MARK: Private

    @State private var selection: Int = 0

    private let onClose: (() -> Void)?

    @State private var showTabViewIndex: Bool = false

    @State private var showingCharacterIdentifier: Int

    @ObservedObject private var profile: EnkaHSR.ProfileSummarized
    @StateObject private var orientation = DeviceOrientation()
    private let bottomSpacerHeight: CGFloat = 20

    private var avatar: EnkaHSR.AvatarSummarized? {
        profile.summarizedAvatars.first(where: { avatar in
            avatar.mainInfo.uniqueCharId == showingCharacterIdentifier
        })
    }

    private var scaleRatioCompatible: CGFloat { DeviceOrientation.scaleRatioCompatible }

    private var hasNoAvatars: Bool { profile.summarizedAvatars.isEmpty }
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
