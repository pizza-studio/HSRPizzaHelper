// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

// This "Avatar" indicates the profile picture of a game account.

extension EnkaHSR.DBModels {
    public typealias ProfileAvatarDict = [String: ProfileAvatar]

    public struct ProfileAvatar: Codable {
        public let Icon: String
    }
}
