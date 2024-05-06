// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import EnkaKitHSR
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

// MARK: - IDPhotoView

public struct IDPhotoView: View {
    // MARK: Lifecycle

    public init?(
        pid: String,
        _ size: CGFloat,
        _ type: IconType,
        imageHandler: ((Image) -> Image)? = nil
    ) {
        guard Defaults[.useGenshinStyleCharacterPhotos] else { return nil }
        self.pid = Self.convertPIDForProtagonist(pid)
        guard let ref = EnkaHSR.queryImageAsset(for: "idp\(self.pid)") else { return nil }
        self.size = size
        self.cgImageRef = ref
        self.iconType = type
        self.imageHandler = imageHandler ?? { $0 }
    }

    // MARK: Public

    public enum IconType: CGFloat {
        case asCard = 1.1
        case cutShoulder = 1.15
        case cutHead = 1.5
        case cutFace = 2
        case cutFaceRoundedRect = 3

        // MARK: Internal

        func shiftedAmount(containerSize size: CGFloat) -> CGFloat {
            let fixedRawValue = min(2, max(1, rawValue))
            switch self {
            case .asCard: return size / (20 * fixedRawValue)
            case .cutShoulder: return size / (15 * fixedRawValue)
            default: return size / (4 * fixedRawValue)
            }
        }
    }

    public let cgImageRef: CGImage

    public var body: some View {
        coreBody
    }

    // MARK: Internal

    var coreBody: some View {
        switch iconType {
        case .asCard: return AnyView(cardView)
        default: return AnyView(circleIconView)
        }
    }

    @ViewBuilder var cardView: some View {
        imageObj
            .scaledToFill()
            .frame(width: size * iconType.rawValue, height: size * iconType.rawValue)
            .clipped()
            .scaledToFit()
            .offset(y: iconType.shiftedAmount(containerSize: size))
            .background {
                backgroundObj
            }
            .frame(width: size * 0.74, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size / 10))
            .contentShape(RoundedRectangle(cornerRadius: size / 10))
    }

    @ViewBuilder var circleIconView: some View {
        let ratio = 179.649 / 1024
        let cornerSize = CGSize(width: ratio * size, height: ratio * size)
        let roundCornerSize = CGSize(width: size / 2, height: size / 2)
        let roundRect = iconType == .cutFaceRoundedRect
        imageObj
            .scaledToFill()
            .frame(width: size * iconType.rawValue, height: size * iconType.rawValue)
            .clipped()
            .scaledToFit()
            .offset(y: iconType.shiftedAmount(containerSize: size))
            .background {
                backgroundObj
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerSize: roundRect ? cornerSize : roundCornerSize))
            .contentShape(RoundedRectangle(cornerSize: roundRect ? cornerSize : roundCornerSize))
    }

    var imageObj: some View {
        imageHandler(Image(decorative: cgImageRef, scale: 1))
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    @ViewBuilder var backgroundObj: some View {
        if let img = backgroundImage {
            Image(decorative: img, scale: 1)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(2)
                .rotationEffect(.degrees(180))
                .blur(radius: 12)
        } else {
            Color.black.opacity(0.165)
        }
    }

    var backgroundImage: CGImage? {
        let path = "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.character.rawValue)/\(pid).png"
        #if os(macOS)
        guard let image = NSImage(contentsOfFile: path) else { return nil }
        var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        return imageRef
        #elseif os(iOS)
        return UIImage(contentsOfFile: path)?.cgImage
        #else
        return nil
        #endif
    }

    // MARK: Private

    private let pid: String
    private let imageHandler: (Image) -> Image
    private let size: CGFloat
    private let iconType: IconType

    private static func convertPIDForProtagonist(_ pid: String) -> String {
        guard pid.count == 4, let first = pid.first, first == "8" else { return pid }
        guard let last = pid.last?.description, var lastDigi = Int(last) else { return pid }
        guard lastDigi >= 1 else { return pid }
        lastDigi = lastDigi % 2
        if lastDigi == 0 { lastDigi += 2 }
        return String(pid.dropLast()) + lastDigi.description
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
