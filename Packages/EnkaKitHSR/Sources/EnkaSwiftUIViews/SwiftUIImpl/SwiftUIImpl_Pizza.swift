// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
import SwiftUI

// MARK: - ResIcon

public struct ResIcon: View {
    // MARK: Lifecycle

    public init(
        _ path: String,
        imageHandler: ((Image) -> Image)? = nil,
        placeholder: (() -> AnyView)? = nil
    ) {
        self.path = path
        self.imageHandler = imageHandler ?? { $0 }
        self.placeholder = placeholder ?? { .init(ProgressView()) }
    }

    // MARK: Public

    public let path: String
    public let placeholder: () -> AnyView
    public let imageHandler: (Image) -> Image

    public var body: some View {
        #if os(OSX)
        if let image = NSImage(contentsOfFile: path) {
            imageHandler(Image(nsImage: image))
        } else {
            AsyncImage(url: .init(fileURLWithPath: path)) { image in
                imageHandler(image)
            } placeholder: {
                placeholder()
            }
        }
        #else
        if let image = UIImage(contentsOfFile: path) {
            imageHandler(Image(uiImage: image))
        } else {
            AsyncImage(url: .init(fileURLWithPath: path)) { image in
                imageHandler(image)
            } placeholder: {
                placeholder()
            }
        }
        #endif
    }
}

// MARK: - HelpTextForScrollingOnDesktopComputer

public struct HelpTextForScrollingOnDesktopComputer: View {
    // MARK: Lifecycle

    public init(_ direction: Direction) {
        self.direction = direction
    }

    // MARK: Public

    public enum Direction {
        case horizontal, vertical
    }

    public var body: some View {
        if OS.type == .macOS {
            let mark: String = (direction == .horizontal) ? "⇆ " : "⇅ "
            (Text(mark) + Text("operation.scrolling.guide")).font(.footnote).opacity(0.7)
        } else {
            EmptyView()
        }
    }

    // MARK: Internal

    @State var direction: Direction
}

// MARK: - Trailing Text Label

extension View {
    public func corneredTag(
        _ stringKey: LocalizedStringKey,
        alignment: Alignment,
        textSize: CGFloat = 12,
        opacity: CGFloat = 1,
        enabled: Bool = true,
        padding: CGFloat = 0
    )
        -> some View {
        guard stringKey != "", enabled else { return AnyView(self) }
        return AnyView(
            ZStack(alignment: alignment) {
                self
                Text(stringKey)
                    .font(.system(size: textSize))
                    .fontWidth(.condensed)
                    .fontWeight(.medium)
                    .padding(.horizontal, 0.3 * textSize)
                    .adjustedBlurMaterialBackground().clipShape(Capsule())
                    .opacity(opacity)
                    .padding(padding)
                    .fixedSize()
            }
        )
    }

    public func corneredTag(
        verbatim stringVerbatim: String,
        alignment: Alignment,
        textSize: CGFloat = 12,
        opacity: CGFloat = 1,
        enabled: Bool = true,
        padding: CGFloat = 0
    )
        -> some View {
        guard stringVerbatim != "", enabled else { return AnyView(self) }
        return AnyView(
            ZStack(alignment: alignment) {
                self
                Text(stringVerbatim)
                    .font(.system(size: textSize))
                    .fontWidth(.condensed)
                    .fontWeight(.medium)
                    .padding(.horizontal, 0.3 * textSize)
                    .adjustedBlurMaterialBackground().clipShape(Capsule())
                    .opacity(opacity)
                    .padding(padding)
                    .fixedSize()
            }
        )
    }
}

// MARK: - Blur Background

extension View {
    func blurMaterialBackground() -> some View {
        modifier(BlurMaterialBackground())
    }

    func adjustedBlurMaterialBackground() -> some View {
        modifier(AdjustedBlurMaterialBackground())
    }
}

// MARK: - BlurMaterialBackground

struct BlurMaterialBackground: ViewModifier {
    func body(content: Content) -> some View {
        content.background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .contentShape(RoundedRectangle(
            cornerRadius: 20,
            style: .continuous
        ))
    }
}

// MARK: - AdjustedBlurMaterialBackground

struct AdjustedBlurMaterialBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    @ViewBuilder
    func body(content: Content) -> some View {
        Group {
            if colorScheme == .dark {
                content.background(
                    .thinMaterial,
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
            } else {
                content.background(
                    .regularMaterial,
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
            }
        }.contentShape(RoundedRectangle(
            cornerRadius: 20,
            style: .continuous
        ))
    }
}

// MARK: - OS

public enum OS: Int {
    case macOS = 0
    case iPhoneOS = 1
    case iPadOS = 2
    case watchOS = 3
    case tvOS = 4

    // MARK: Public

    public static let type: OS = {
        guard !ProcessInfo.processInfo.isiOSAppOnMac else { return .macOS }
        #if os(OSX)
        return .macOS
        #elseif os(watchOS)
        return .watchOS
        #elseif os(tvOS)
        return .tvOS
        #elseif os(iOS)
        #if targetEnvironment(simulator)
        return maybePad ? .iPadOS : .iPhoneOS
        #elseif targetEnvironment(macCatalyst)
        return .macOS
        #else
        return maybePad ? .iPadOS : .iPhoneOS
        #endif
        #endif
    }()

    public static let isCatalyst: Bool = {
        #if targetEnvironment(macCatalyst)
        return true
        #else
        return false
        #endif
    }()

    // MARK: Private

    private static let maybePad: Bool = {
        #if canImport(UIKit)
        return UIDevice.modelIdentifier.contains("iPad") || UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }()
}

#if canImport(UIKit)
extension UIDevice {
    public static let modelIdentifier: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children
            .reduce("") { identifier, element in
                guard let value = element.value as? Int8,
                      value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        return identifier
    }()
}
#endif

extension Font {
    public static let baseFontSize: CGFloat = {
        #if os(OSX)
        return NSFont.systemFontSize
        #elseif targetEnvironment(macCatalyst)
        return UIFont.systemFontSize / 0.77
        #else
        return UIFont.systemFontSize
        #endif
    }()
}

extension CGColor {
    public var suiColor: Color {
        .init(cgColor: self)
    }
}
