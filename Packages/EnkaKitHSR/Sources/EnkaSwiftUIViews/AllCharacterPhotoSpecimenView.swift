// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import EnkaKitHSR
import Foundation
import SwiftUI

// MARK: - CharSpecimen

public struct CharSpecimen: Identifiable, Hashable {
    // MARK: Public

    public let id: String

    @ViewBuilder
    public static func renderAllSpecimen(
        scroll: Bool,
        columns: Int,
        size: Double,
        cutType: IDPhotoView.IconType = .cutShoulder,
        supplementalIDs: (() -> [String])? = nil
    )
        -> some View {
        let specimens = Self.allSpecimens(supplementalIDs: supplementalIDs?())
        let inner = StaggeredGrid(
            columns: columns, outerPadding: false, scroll: scroll, list: specimens
        ) { specimen in
            specimen.render(size: size, cutType: cutType)
        }
        if scroll {
            ScrollView {
                inner.padding()
            }
        } else {
            inner
        }
    }

    @ViewBuilder
    public func render(size: Double, cutType: IDPhotoView.IconType = .cutShoulder) -> some View {
        if let first = IDPhotoView(pid: id, size, cutType, forceRender: true) {
            first
        } else {
            IDPhotoFallbackView(pid: id, size, cutType)
        }
    }

    // MARK: Internal

    static func allSpecimens(supplementalIDs: [String]? = nil) -> [Self] {
        let ids = EnkaHSR.Sputnik.sharedDB.characters.keys.sorted() + (supplementalIDs ?? [])
        return Set<String>(ids).sorted().map { Self(id: $0) }
    }
}

// MARK: - AllCharacterPhotoSpecimenView

public struct AllCharacterPhotoSpecimenView: View {
    // MARK: Lifecycle

    public init(columns: Int = 4, scroll: Bool = true, supplementalIDs: (() -> [String])? = nil) {
        self.columns = Swift.max(1, columns)
        self.scroll = scroll
        self.supplementalIDs = supplementalIDs?() ?? []
    }

    // MARK: Public

    public var body: some View {
        coreBodyView.overlay {
            GeometryReader { geometry in
                Color.clear.onAppear {
                    containerSize = geometry.size
                }.onChange(of: geometry.size) { newSize in
                    containerSize = newSize
                }
            }
        }
    }

    // MARK: Internal

    @Namespace var animation

    @State var containerSize: CGSize = .init(width: 320, height: 320)

    @State var columns: Int

    @State var scroll: Bool

    @ViewBuilder var coreBodyView: some View {
        let base: CGFloat = scroll ? 1.2 : 1
        CharSpecimen.renderAllSpecimen(
            scroll: scroll,
            columns: columns,
            size: containerSize.width / (base * Double(columns)),
            cutType: .cutShoulder
        ) {
            supplementalIDs
        }
        .animation(.easeInOut, value: columns)
        .environmentObject(orientation)
    }

    // MARK: Private

    @State private var supplementalIDs: [String]
    @StateObject private var orientation = DeviceOrientation()
}

#if DEBUG

struct CharacterPhotoSpecimenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                Section {
                    AllCharacterPhotoSpecimenView(scroll: false) {
                        ["1218", "1221", "1224"]
                    }
                }
            }
        }
    }
}

#endif
