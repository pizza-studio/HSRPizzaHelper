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
        if useGenshinStyleIcon,
           let idPhotoView = IDPhotoView(pid: charID.description, size, .asCard) {
            idPhotoView
        } else if useGenshinStyleIcon,
                  let idPhotoView = IDPhotoFallbackView(pid: charID.description, size, .asCard) {
            idPhotoView
        } else if let traditionalFallback = EnkaHSR.queryImageAssetSUI(for: proposedPhotoAssetName) {
            traditionalFallback
                .resizable()
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
        } else {
            blankQuestionedView
        }
    }

    @ViewBuilder var normalIcon: some View {
        if useGenshinStyleIcon,
           let idPhotoView = IDPhotoView(pid: charID.description, size, cutType) {
            idPhotoView
        } else if useGenshinStyleIcon,
                  let idPhotoView = IDPhotoFallbackView(pid: charID.description, size, cutType) {
            idPhotoView
        } else if let result = EnkaHSR.queryImageAssetSUI(for: proposedPhotoAssetName) {
            let resultNew = result
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(1.5, anchor: .top)
                .scaleEffect(1.4)
                .frame(maxWidth: size, maxHeight: size)
            // Draw.
            let bgColor = Color.black.opacity(0.165)
            Group {
                if circleClipped {
                    resultNew
                        .background { bgColor }
                        .clipShape(Circle())
                        .contentShape(Circle())
                } else {
                    resultNew
                        .background { bgColor }
                        .clipShape(Rectangle())
                        .contentShape(Rectangle())
                }
            }
            .compositingGroup()
        } else {
            blankQuestionedView
        }
    }

    // MARK: Private

    @Default(.useGenshinStyleCharacterPhotos) private var useGenshinStyleIcon: Bool

    private let isCard: Bool
    private let charID: String
    private let size: CGFloat
    private let circleClipped: Bool
    private let clipToHead: Bool

    private var cutType: IDPhotoView.IconType {
        clipToHead ? .cutHead : .cutShoulder
    }

    private var proposedPhotoAssetName: String {
        "characters_\(charID)"
    }

    @ViewBuilder private var blankQuestionedView: some View {
        Circle().background(.gray).overlay {
            Text(verbatim: "?").foregroundStyle(.white).fontWeight(.black)
        }.frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size / 10))
            .contentShape(RoundedRectangle(cornerRadius: size / 10))
            .compositingGroup()
    }
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
        guard let coordinator = Self.Coordinator(pid: pid) else { return nil }
        self.coordinator = coordinator
        let lifePath = EnkaHSR.Sputnik.sharedDB.characters[pid]?.avatarBaseType
        guard let lifePath = lifePath else { return nil }
        self.size = size
        self.iconType = type
        self.imageHandler = imageHandler ?? { $0 }
        self.lifePath = lifePath
        self.pathTotemVisible = type.pathTotemVisible
    }

    // MARK: Public

    public enum IconType: CGFloat {
        case asCard = 1.1
        case cutShoulder = 1.15
        case cutHead = 1.5
        case cutFace = 2
        case cutFaceRoundedRect = 3

        // MARK: Internal

        var pathTotemVisible: Bool {
            ![.cutHead, .cutFace, .cutFaceRoundedRect].contains(self)
        }

        func shiftedAmount(containerSize size: CGFloat) -> CGFloat {
            let fixedRawValue = min(2, max(1, rawValue))
            switch self {
            case .asCard: return size / (20 * fixedRawValue)
            case .cutShoulder: return size / (15 * fixedRawValue)
            default: return size / (4 * fixedRawValue)
            }
        }
    }

    public var body: some View {
        coreBody.compositingGroup()
    }

    // MARK: Internal

    @Environment(\.colorScheme) var colorScheme

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
        imageHandler(coordinator.charAvatarImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    @ViewBuilder var backgroundObj: some View {
        Group {
            coordinator.backgroundImage
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(2)
                .rotationEffect(.degrees(180))
                .blur(radius: 12)
        }
        .overlay {
            if pathTotemVisible {
                coordinator.lifePathImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(1)
                    .colorMultiply(elementColor)
                    .saturation(0.5)
                    .brightness(0.5)
                    .opacity(0.7)
            }
        }
        .background(baseWindowBGColor)
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

    var baseWindowBGColor: Color {
        switch colorScheme {
        case .dark:
            return .init(cgColor: .init(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.00))
        case .light:
            return .init(cgColor: .init(red: 0.80, green: 0.80, blue: 0.80, alpha: 1.00))
        @unknown default:
            return .gray
        }
    }

    // MARK: Private

    private class Coordinator: ObservableObject {
        // MARK: Lifecycle

        public init?(pid: String) {
            guard let cidObj = EnkaHSR.AvatarSummarized.CharacterID(id: pid) else { return nil }
            self.cid = cidObj
            let fallbackPID = EnkaHSR.CharacterName.convertPIDForProtagonist(pid)
            guard let charAvatarImage = EnkaHSR.queryImageAssetSUI(for: "idp\(pid)")
                ?? EnkaHSR.queryImageAssetSUI(for: "idp\(fallbackPID)")
            else { return nil }
            let lifePath = EnkaHSR.Sputnik.sharedDB.characters[pid]?.avatarBaseType
            guard let lifePath = lifePath else { return nil }
            let lifePathImage = EnkaHSR.queryImageAssetSUI(for: lifePath.iconAssetName)
            let backgroundImage = EnkaHSR.queryImageAssetSUI(for: cidObj.photoAssetName)
            guard let lifePathImage = lifePathImage else { return nil }
            guard let backgroundImage = backgroundImage else { return nil }
            self.lifePathImage = lifePathImage
            self.backgroundImage = backgroundImage
            self.charAvatarImage = charAvatarImage
        }

        // MARK: Internal

        let cid: EnkaHSR.AvatarSummarized.CharacterID
        var lifePathImage: Image
        var backgroundImage: Image
        var charAvatarImage: Image

        var pid: String { cid.id }
    }

    private let pid: String
    private let imageHandler: (Image) -> Image
    private let size: CGFloat
    private let iconType: IconType
    private let pathTotemVisible: Bool
    private let lifePath: EnkaHSR.DBModels.LifePath
    private let coordinator: Coordinator
}

// MARK: - IDPhotoFallbackView

/// 仅用于 EnkaDB 还没更新的场合。
struct IDPhotoFallbackView: View {
    // MARK: Lifecycle

    public init?(
        pid: String,
        _ size: CGFloat,
        _ type: IDPhotoView.IconType,
        imageHandler: ((Image) -> Image)? = nil
    ) {
        let coordinator = Self.Coordinator(pid: pid)
        guard let coordinator = coordinator else { return nil }
        self.pid = pid
        self.coordinator = coordinator
        self.size = size
        self.iconType = type
        self.imageHandler = imageHandler ?? { $0 }
    }

    // MARK: Public

    public var body: some View {
        coreBody.compositingGroup()
    }

    // MARK: Internal

    @Environment(\.colorScheme) var colorScheme

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
        imageHandler(coordinator.charAvatarImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }

    @ViewBuilder var backgroundObj: some View {
        Group {
            coordinator.backgroundImage
                .resizable()
                .aspectRatio(contentMode: .fill)
                .scaleEffect(2)
                .rotationEffect(.degrees(180))
                .blur(radius: 12)
        }
        .background(baseWindowBGColor)
    }

    var baseWindowBGColor: Color {
        switch colorScheme {
        case .dark:
            return .init(cgColor: .init(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.00))
        case .light:
            return .init(cgColor: .init(red: 0.80, green: 0.80, blue: 0.80, alpha: 1.00))
        @unknown default:
            return .gray
        }
    }

    // MARK: Private

    private class Coordinator: ObservableObject {
        // MARK: Lifecycle

        public init?(pid: String) {
            self.pid = pid
            let fallbackPID = EnkaHSR.CharacterName.convertPIDForProtagonist(pid)
            guard let charAvatarImage = EnkaHSR.queryImageAssetSUI(for: "idp\(pid)")
                ?? EnkaHSR.queryImageAssetSUI(for: "idp\(fallbackPID)")
            else { return nil }
            let backgroundImage = EnkaHSR.queryImageAssetSUI(for: "characters_\(pid)")
            guard let backgroundImage = backgroundImage else { return nil }
            self.backgroundImage = backgroundImage
            self.charAvatarImage = charAvatarImage
        }

        // MARK: Internal

        var backgroundImage: Image
        var charAvatarImage: Image
        var pid: String
    }

    private let pid: String
    private let imageHandler: (Image) -> Image
    private let size: CGFloat
    private let iconType: IDPhotoView.IconType
    private let coordinator: Coordinator
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

// MARK: - EachAvatarStatView_Previews

#if DEBUG
struct IDPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 14) {
            VStack {
                IDPhotoView(pid: "8004", 128, .cutShoulder)
                IDPhotoView(pid: "1218", 128, .cutShoulder) // Should be missing if asset is missing.
                IDPhotoView(pid: "1221", 128, .cutShoulder) // Should be missing if asset is missing.
                IDPhotoView(pid: "1224", 128, .cutShoulder) // Should be missing if asset is missing.
            }

            VStack {
                CharacterIconView(charID: "8004", size: 128, circleClipped: true, clipToHead: false)
                CharacterIconView(charID: "1218", size: 128, circleClipped: true, clipToHead: false)
                CharacterIconView(charID: "1221", size: 128, circleClipped: true, clipToHead: false)
                CharacterIconView(charID: "1224", size: 128, circleClipped: true, clipToHead: false)
            }

            VStack {
                IDPhotoFallbackView(pid: "8004", 128, .cutShoulder)
                IDPhotoFallbackView(pid: "1218", 128, .cutShoulder)
                IDPhotoFallbackView(pid: "1221", 128, .cutShoulder)
                IDPhotoFallbackView(pid: "1224", 128, .cutShoulder)
            }
        }
    }
}
#endif
