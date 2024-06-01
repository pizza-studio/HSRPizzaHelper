// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import EnkaKitHSR
import Foundation
import SwiftUI

// MARK: - CharacterIconView

public struct CharacterIconView: View {
    // MARK: Lifecycle

    public init(
        charID: String,
        size: CGFloat,
        circleClipped: Bool = true,
        clipToHead: Bool = false
    ) {
        self.charID = charID
        self.size = size
        self.circleClipped = circleClipped
        self.clipToHead = clipToHead
        self.isCard = false
    }

    public init(
        charID: String,
        cardSize size: CGFloat
    ) {
        self.charID = charID
        self.size = size
        self.circleClipped = false
        self.clipToHead = false
        self.isCard = true
    }

    // MARK: Public

    public var body: some View {
        if isCard {
            cardIcon
        } else {
            normalIcon
        }
    }

    // MARK: Internal

    @ViewBuilder var cardIcon: some View {
        if let cidObj = EnkaHSR.AvatarSummarized.CharacterID(id: charID) {
            if useGenshinStyleIcon, let idPhotoView = IDPhotoView(pid: charID.description, size, .asCard) {
                idPhotoView
            } else {
                ResIcon(cidObj.photoFilePath) {
                    $0.resizable()
                } placeholder: {
                    AnyView(Color.clear)
                }
                .aspectRatio(contentMode: .fit)
                .scaleEffect(1.5, anchor: .top)
                .scaleEffect(1.4)
                .frame(width: size * 0.74, height: size)
                .background {
                    Color.black.opacity(0.165)
                }
                .clipShape(RoundedRectangle(cornerRadius: size / 10))
                .contentShape(RoundedRectangle(cornerRadius: size / 10))
                .compositingGroup()
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder var normalIcon: some View {
        if let cidObj = EnkaHSR.AvatarSummarized.CharacterID(id: charID) {
            let cutType: IDPhotoView.IconType = clipToHead ? .cutHead : .cutShoulder
            if useGenshinStyleIcon, let idPhotoView = IDPhotoView(pid: charID.description, size, cutType) {
                idPhotoView
            } else {
                let result = ResIcon(cidObj.photoFilePath) {
                    $0.resizable()
                } placeholder: {
                    AnyView(Color.clear)
                }
                .aspectRatio(contentMode: .fit)
                .scaleEffect(1.5, anchor: .top)
                .scaleEffect(1.4)
                .frame(maxWidth: size, maxHeight: size)
                // Draw.
                let bgColor = Color.black.opacity(0.165)
                Group {
                    if circleClipped {
                        result
                            .background { bgColor }
                            .clipShape(Circle())
                            .contentShape(Circle())
                    } else {
                        result
                            .background { bgColor }
                            .clipShape(Rectangle())
                            .contentShape(Rectangle())
                    }
                }
                .compositingGroup()
            }
        } else {
            EmptyView()
        }
    }

    // MARK: Private

    @Default(.useGenshinStyleCharacterPhotos) private var useGenshinStyleIcon: Bool

    private let isCard: Bool
    private let charID: String
    private let size: CGFloat
    private let circleClipped: Bool
    private let clipToHead: Bool
}

// MARK: - IDPhotoView

public struct IDPhotoView: View {
    // MARK: Lifecycle

    public init?(
        pid: String,
        _ size: CGFloat,
        _ type: IconType,
        forceRender: Bool = false,
        imageHandler: ((Image) -> Image)? = nil
    ) {
        guard Defaults[.useGenshinStyleCharacterPhotos] || forceRender else { return nil }
        self.pid = pid
        let fallbackPID = EnkaHSR.CharacterName.convertPIDForProtagonist(pid)
        guard let ref = EnkaHSR.queryImageAsset(for: "idp\(pid)")
            ?? EnkaHSR.queryImageAsset(for: "idp\(fallbackPID)")
        else { return nil }
        let lifePath = EnkaHSR.Sputnik.sharedDB.characters[pid]?.avatarBaseType
        guard let lifePath = lifePath else { return nil }
        self.size = size
        self.cgImageRef = ref
        self.iconType = type
        self.imageHandler = imageHandler ?? { $0 }
        self.lifePath = lifePath
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
        coreBody.compositingGroup()
    }

    // MARK: Internal

    var coreBody: some View {
        switch iconType {
        case .asCard: return AnyView(cardView)
        default: return AnyView(circleIconView)
        }
    }

    var proposedSize: CGSize {
        switch iconType {
        case .asCard: return .init(width: size * 0.74, height: size)
        default: return .init(width: size, height: size)
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
        Group {
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
        }.overlay {
            if let lifePathImg = lifePathImage {
                Image(decorative: lifePathImg, scale: 1)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(1)
                    .colorMultiply(elementColor)
                    .saturation(0.5)
                    .brightness(0.5)
                    .opacity(0.7)
                    .shadow(radius: size / 5)
            }
        }
    }

    var elementColor: Color {
        var opacity: Double = 1
        switch lifePath {
        case .abundance: opacity = 0.4
        case .hunt: opacity = 0.35
        default: break
        }
        return EnkaHSR.Sputnik.sharedDB.characters[pid]?.element.themeColor.suiColor.opacity(opacity) ?? .clear
    }

    var lifePathImage: CGImage? {
        let path = lifePath.iconFilePath
        let result = CGImage.instantiate(filePath: path)
        return result
    }

    var backgroundImage: CGImage? {
        let path = "\(EnkaHSR.assetPathRoot)/\(EnkaHSR.AssetPathComponents.character.rawValue)/\(pid).png"
        let result = CGImage.instantiate(filePath: path)
        return result
    }

    // MARK: Private

    private let pid: String
    private let imageHandler: (Image) -> Image
    private let size: CGFloat
    private let iconType: IconType
    private let lifePath: EnkaHSR.DBModels.LifePath
}

extension EnkaHSR.DBModels.Element {
    public var themeColor: CGColor {
        switch self {
        case .physico: return .init(red: 0.40, green: 0.40, blue: 0.40, alpha: 1.00)
        case .anemo: return .init(red: 0.00, green: 0.52, blue: 0.56, alpha: 1.00)
        case .electro: return .init(red: 0.54, green: 0.14, blue: 0.79, alpha: 1.00)
        case .fantastico: return .init(red: 1.00, green: 1.00, blue: 0.00, alpha: 1.00)
        case .posesto: return .init(red: 0.00, green: 0.13, blue: 1.00, alpha: 1.00)
        case .pyro: return .init(red: 0.83, green: 0.00, blue: 0.00, alpha: 1.00)
        case .cryo: return .init(red: 0.00, green: 0.38, blue: 0.63, alpha: 1.00)
        }
    }
}

extension CGImage {
    fileprivate static func instantiate(filePath path: String) -> CGImage? {
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

    fileprivate func zoomed(_ factor: CGFloat, quality: CGInterpolationQuality = .high) -> CGImage? {
        guard factor > 0 else { return nil }
        let size: CGSize = .init(width: CGFloat(width) * factor, height: CGFloat(height) * factor)
        return directResized(size: size, quality: quality)
    }

    fileprivate func directResized(size: CGSize, quality: CGInterpolationQuality = .high) -> CGImage? {
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

// MARK: - EachAvatarStatView_Previews

#if DEBUG
struct IDPhotoView_Previews: PreviewProvider {
    static let idp: IDPhotoView? = {
        // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
        let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
            separator: "/"
        ).dropFirst()
        EnkaHSR.assetPathRoot = "\(packageRootPath)/../../Assets"
        return IDPhotoView(pid: "8004", 128, .cutShoulder)
    }()

    static var previews: some View {
        // NOTE: The preview only works if the canvas is set to use macOS (either native or Catalyst).
        VStack {
            idp
        }
    }
}
#endif
