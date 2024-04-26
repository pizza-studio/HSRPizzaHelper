// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Combine
import Defaults
import EnkaKitHSR
import Foundation
import SFSafeSymbols
import SwiftUI

// MARK: - CaseQuerySection

public struct CaseQuerySection: View {
    // MARK: Lifecycle

    @MainActor
    public init(theDB: EnkaHSR.EnkaDB) {
        self.theDB = theDB
    }

    // MARK: Public

    public var body: some View {
        Section {
            HStack {
                textFieldView
                    .font(.system(.title))
                    .monospaced()
                    .fontWidth(.condensed)
                Group {
                    if delegate.state == .busy {
                        ProgressView()
                    } else {
                        Button(action: triggerUpdateTask) {
                            Image(systemSymbol: SFSymbol.magnifyingglassCircleFill)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .disabled(delegate.state == .busy || !isUIDValid)
                    }
                }
                .frame(height: Font.baseFontSize * 2)
            }
            if let result = delegate.currentInfo {
                NavigationLink(value: result) {
                    HStack {
                        ResIcon(result.accountPhotoFilePath(theDB: theDB)) {
                            $0.resizable()
                        } placeholder: {
                            AnyView(Color.clear)
                        }
                        .aspectRatio(contentMode: .fit)
                        .background { Color.black.opacity(0.165) }
                        .clipShape(Circle())
                        .contentShape(Circle())
                        .frame(width: Font.baseFontSize * 3)
                        VStack(alignment: .leading) {
                            Text(result.nickname).font(.headline).fontWeight(.bold)
                            Text(result.uid.description).font(.subheadline)
                        }
                        Spacer()
                    }
                }
            }
            if let errorMsg = delegate.errorMsg {
                Text(errorMsg).font(.caption2)
            }
        } header: {
            Text("detailPortal.OtherCase.Title")
        } footer: {
            let rawFooter = String(localized: "detailPortal.showCaseAPIServiceProviders.explain")
            let attrStr = (
                try? AttributedString(
                    markdown: rawFooter,
                    options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
                )
            ) ?? .init(stringLiteral: rawFooter)
            Text(attrStr)
        }
    }

    // MARK: Internal

    @State var givenUID: Int?

    @ViewBuilder var textFieldView: some View {
        TextField("UID", value: $givenUID, format: .number.grouping(.never))
        #if !os(OSX) && !targetEnvironment(macCatalyst)
            .keyboardType(.numberPad)
        #endif
            .onSubmit {
                if isUIDValid {
                    triggerUpdateTask()
                }
            }
            .disabled(delegate.state == .busy)
    }

    func triggerUpdateTask() {
        Task {
            delegate.update(givenUID: givenUID)
        }
    }

    // MARK: Private

    private var theDB: EnkaHSR.EnkaDB
    @StateObject private var delegate: Coordinator = .init()

    private var isUIDValid: Bool {
        guard let givenUID = givenUID else { return false }
        return (100_000_000 ... 9_999_999_999).contains(givenUID)
    }
}

// MARK: CaseQuerySection.Coordinator

extension CaseQuerySection {
    @MainActor
    private class Coordinator: ObservableObject {
        enum State: String, Sendable, Hashable, Identifiable {
            case busy
            case standBy

            // MARK: Public

            public var id: String { rawValue }
        }

        @Published var state: State = .standBy
        @Published var currentInfo: EnkaHSR.QueryRelated.DetailInfo?
        var task: Task<EnkaHSR.QueryRelated.DetailInfo?, Never>?

        @Published var errorMsg: String?

        func update(givenUID: Int?) {
            task?.cancel()
            guard let givenUID = givenUID else { return }
            withAnimation {
                self.task = Task {
                    self.state = .busy
                    currentInfo = nil
                    do {
                        let profile = try await EnkaHSR.Sputnik.getEnkaProfile(for: givenUID.description)
                        self.currentInfo = profile
                        state = .standBy
                        errorMsg = nil
                        return profile
                    } catch {
                        state = .standBy
                        errorMsg = error.localizedDescription
                        return nil
                    }
                }
            }
        }
    }
}

// MARK: - CaseQueryResultListView

public struct CaseQueryResultListView: View {
    // MARK: Lifecycle

    public init(profile: EnkaHSR.QueryRelated.DetailInfo, enkaDB: EnkaHSR.EnkaDB, wrapped: Bool = false) {
        self.profile = profile
        self.enkaDB = enkaDB
        self.wrapped = wrapped
    }

    // MARK: Public

    public var body: some View {
        if wrapped {
            List {
                coreBody
            }
            .navigationTitle(Text(verbatim: "\(profile.nickname) (\(profile.uid.description))"))
        } else {
            coreBody
        }
    }

    @ViewBuilder public var coreBody: some View {
        profile.asView(theDB: enkaDB, expanded: true)
    }

    // MARK: Private

    @State private var profile: EnkaHSR.QueryRelated.DetailInfo
    @State private var enkaDB: EnkaHSR.EnkaDB
    @State private var wrapped: Bool

    private var allAvatarSummaries: [EnkaHSR.AvatarSummarized] {
        profile.summarizeAllAvatars(theDB: enkaDB)
    }
}

#if DEBUG
struct CaseQuerySection_Previews: PreviewProvider {
    static let enkaDatabase: EnkaHSR.EnkaDB = {
        // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
        let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
            separator: "/"
        ).dropFirst()
        EnkaHSR.assetPathRoot = "\(packageRootPath)/../../Assets"
        // swiftlint:disable force_unwrapping
        return EnkaHSR.EnkaDB(locTag: "ja")!
        // swiftlint:enable force_unwrapping
    }()

    static var previews: some View {
        NavigationStack {
            List {
                CaseQuerySection(theDB: enkaDatabase)
            }
            .navigationDestination(for: EnkaHSR.QueryRelated.DetailInfo.self) { result in
                CaseQueryResultListView(profile: result, enkaDB: enkaDatabase, wrapped: true)
            }
        }
    }
}
#endif
