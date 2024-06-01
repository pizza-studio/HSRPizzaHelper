// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
import ImageIO
import SwiftUI

// MARK: - Image Constructor from path.

extension CGImage {
    public static func instantiate(filePath path: String) -> CGImage? {
        guard let imageSource = CGImageSourceCreateWithURL(
            URL(fileURLWithPath: path) as CFURL,
            nil
        ) else { return nil }
        return CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    }

    public func zoomed(_ factor: CGFloat, quality: CGInterpolationQuality = .high) -> CGImage? {
        guard factor > 0 else { return nil }
        let size: CGSize = .init(width: CGFloat(width) * factor, height: CGFloat(height) * factor)
        return directResized(size: size, quality: quality)
    }

    internal func directResized(size: CGSize, quality: CGInterpolationQuality = .high) -> CGImage? {
        // Ref: https://rockyshikoku.medium.com/resize-cgimage-baf23a0f58ab
        let width = Int(floor(size.width))
        let height = Int(floor(size.height))

        let bytesPerPixel = bitsPerPixel / bitsPerComponent
        let destBytesPerRow = width * bytesPerPixel

        guard let colorSpace = colorSpace else { return nil }
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: destBytesPerRow,
            space: colorSpace,
            bitmapInfo: alphaInfo.rawValue
        ) else { return nil }

        context.interpolationQuality = quality
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))

        return context.makeImage()
    }
}

extension Image {
    public static func from(path: String) -> Image? {
        guard let cgImage = CGImage.instantiate(filePath: path) else { return nil }
        return Image(decorative: cgImage, scale: 1)
    }
}

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
        self.rawImage = .from(path: path)
    }

    // MARK: Public

    public let path: String
    public let placeholder: () -> AnyView
    public let imageHandler: (Image) -> Image
    public let rawImage: Image?

    public var body: some View {
        Group {
            if let theImage = rawImage {
                imageHandler(theImage)
            } else {
                AsyncImage(url: .init(fileURLWithPath: path)) { image in
                    imageHandler(image)
                } placeholder: {
                    placeholder()
                }
            }
        }
        .compositingGroup()
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
