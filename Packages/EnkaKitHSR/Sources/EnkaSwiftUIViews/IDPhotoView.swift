// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import EnkaKitHSR
import Foundation
import SwiftUI

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
        self.pid = pid
        let fallbackPID = EnkaHSR.CharacterName.convertPIDForProtagonist(pid)
        guard let ref = EnkaHSR.queryImageAsset(for: "idp\(fallbackPID)") else { return nil }
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
        case .hunt: opacity = 0.3
        default: break
        }
        return EnkaHSR.Sputnik.sharedDB.characters[pid]?.element.themeColor.suiColor.opacity(opacity) ?? .clear
    }

    var lifePathImage: CGImage? {
        let path = lifePath.iconFilePath
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
    private let lifePath: EnkaHSR.DBModels.LifePath
}

extension EnkaHSR.DBModels.Element {
    public var themeColor: CGColor {
        switch self {
        case .physico: return .init(red: 0.40, green: 0.40, blue: 0.40, alpha: 1.00)
        case .anemo: return .init(red: 0.00, green: 0.52, blue: 0.56, alpha: 1.00)
        case .electro: return .init(red: 0.54, green: 0.14, blue: 0.79, alpha: 1.00)
        case .fantastico: return .init(red: 0.35, green: 0.35, blue: 0.00, alpha: 1.00)
        case .posesto: return .init(red: 0.09, green: 0.00, blue: 0.63, alpha: 1.00)
        case .pyro: return .init(red: 0.83, green: 0.00, blue: 0.00, alpha: 1.00)
        case .cryo: return .init(red: 0.00, green: 0.38, blue: 0.63, alpha: 1.00)
        }
    }
}
