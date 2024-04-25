// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Combine
import Defaults
import EnkaKitHSR
import Foundation
import SwiftUI

// MARK: - CaseQuerySection

public struct CaseQuerySection: View {
    // MARK: Lifecycle

    @MainActor
    public init(theDB: EnkaHSR.EnkaDB, uid: Int? = nil) {
        self.theDB = theDB
        self.givenUID = uid
    }

    // MARK: Public

    public var body: some View {
        Section {
            TextField("UID", value: $givenUID, format: .number.grouping(.never))
            #if !os(OSX) && !targetEnvironment(macCatalyst)
                .keyboardType(.decimalPad)
            #endif
                .disabled(delegate.state == .busy)
            Button {
                Task {
                    delegate.update(givenUID: givenUID)
                }
            } label: {
                HStack {
                    Text("detailPortal.OtherCase.LinkName")
                    if delegate.state == .busy {
                        Spacer()
                        ProgressView()
                    }
                }
            }
            .disabled(delegate.state == .busy || !isUIDValid)
            if let result = delegate.currentInfo {
                NavigationLink(value: result) {
                    Text("\(result.nickname) (\(result.uid.description))")
                }
            }
            if let errorMsg = delegate.errorMsg {
                Text(errorMsg).font(.caption2)
            }
        } header: {
            Text("detailPortal.OtherCase.Title")
        }
    }

    // MARK: Internal

    @State var givenUID: Int?

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

#if DEBUG
struct CaseQuerySection_Previews: PreviewProvider {
    static let enkaDatabase: EnkaHSR.EnkaDB = {
        // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
        let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
            separator: "/"
        ).dropFirst()
        EnkaHSR.assetPathRoot = "\(packageRootPath)/../../Assets"
        // swiftlint:disable force_try
        return EnkaHSR.EnkaDB(locTag: "ja")!
        // swiftlint:enable force_try
    }()

    static var previews: some View {
        NavigationView {
            List {
                CaseQuerySection(theDB: enkaDatabase)
            }
        }
    }
}
#endif
