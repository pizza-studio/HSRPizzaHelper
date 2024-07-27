// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.QueryRelated.DetailInfo {
    public func summarizeAllAvatars(theDB: EnkaHSR.EnkaDB) -> [EnkaHSR.AvatarSummarized] {
        avatarDetailList.compactMap { $0.summarize(theDB: theDB) }
    }

    public func summarize(theDB: EnkaHSR.EnkaDB) -> EnkaHSR.ProfileSummarized {
        .init(theDB: theDB, rawInfo: self)
    }

    public func accountPhotoFileNameStem(theDB: EnkaHSR.EnkaDB) -> String {
        let str = theDB.profileAvatars[headIcon.description]?
            .icon.split(separator: "/").last?.description ?? "114514.png"
        return "avatar_\(str)".replacingOccurrences(of: ".png", with: "")
    }

    public static var nullPhotoAssetName: String {
        "avatar_Anonymous"
    }
}
