// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

extension EnkaHSR.QueryRelated.DetailInfo {
    public func merge(new: Self) -> Self {
        var newAvatars = new.avatarDetailList
        let existingCharIds = newAvatars.map(\.avatarId)
        avatarDetailList.forEach { currentOldChar in
            guard !existingCharIds.contains(currentOldChar.avatarId) else { return }
            newAvatars.append(currentOldChar)
        }
        return .init(
            uid: new.uid,
            nickname: new.nickname,
            level: new.level,
            friendCount: new.friendCount,
            signature: new.signature,
            recordInfo: new.recordInfo,
            headIcon: new.headIcon,
            worldLevel: new.worldLevel,
            isDisplayAvatar: new.isDisplayAvatar,
            platform: new.platform,
            avatarDetailList: newAvatars
        )
    }

    public func merge(old: Self?) -> Self {
        guard let old = old else { return self }
        var newAvatars = avatarDetailList
        let existingCharIds = newAvatars.map(\.avatarId)
        old.avatarDetailList.forEach { currentOldChar in
            guard !existingCharIds.contains(currentOldChar.avatarId) else { return }
            newAvatars.append(currentOldChar)
        }
        return .init(
            uid: uid,
            nickname: nickname,
            level: level,
            friendCount: friendCount,
            signature: signature,
            recordInfo: recordInfo,
            headIcon: headIcon,
            worldLevel: worldLevel,
            isDisplayAvatar: isDisplayAvatar,
            platform: platform,
            avatarDetailList: newAvatars
        )
    }
}
