// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import EnkaKitHSR
import Foundation
import SwiftUI

// MARK: - CharSpecimen

public struct CharSpecimen: Identifiable, Hashable {
    public static var allSpecimens: [Self] {
        EnkaHSR.Sputnik.sharedDB.characters.keys.sorted().map { Self(id: $0) }
    }

    public let id: String

    public static func putAllSecimensAsMatrix(lineCapacity: Int) -> [[Self]] {
        let lineCapacity = Swift.max(1, lineCapacity)
        guard lineCapacity > 1 else { return [allSpecimens] }
        var outerContainer = [[Self]]()
        var innerContainer = [Self]()
        allSpecimens.forEach { specimen in
            defer {
                if innerContainer.count >= lineCapacity {
                    outerContainer.append(innerContainer)
                    innerContainer.removeAll()
                }
            }
            innerContainer.append(specimen)
        }
        return outerContainer
    }

    @ViewBuilder
    public static func renderAllSpecimen(
        scroll: Bool,
        columns: Int,
        size: Double,
        cutType: IDPhotoView.IconType = .cutShoulder
    )
        -> some View {
        let inner = StaggeredGrid(
            columns: columns, outerPadding: false, scroll: scroll, list: Self.allSpecimens
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

    public func render(size: Double, cutType: IDPhotoView.IconType = .cutShoulder) -> some View {
        IDPhotoView(pid: id, size, cutType, forceRender: true)
    }
}

// MARK: - AllCharacterPhotoSpecimenView

public struct AllCharacterPhotoSpecimenView: View {
    // MARK: Lifecycle

    public init(columns: Int = 4, scroll: Bool = true) {
        self.columns = Swift.max(1, columns)
        self.scroll = scroll
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
        )
        .animation(.easeInOut, value: columns)
        .environmentObject(orientation)
    }

    // MARK: Private

    @StateObject private var orientation = DeviceOrientation()
}

#if DEBUG

struct CharacterPhotoSpecimenView_Previews: PreviewProvider {
    static let frameSize: CGSize = {
        let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
            separator: "/"
        ).dropFirst()
        EnkaHSR.assetPathRoot = "\(packageRootPath)/../../Assets"
        return .init(width: 320, height: 720)
    }()

    static var previews: some View {
        let size = frameSize
        NavigationStack {
            List {
                Section {
                    AllCharacterPhotoSpecimenView(scroll: false)
                        .overlay {
                            Text(size.width.description).foregroundStyle(.clear)
                        }
                }
            }
        }
    }
}

#endif
