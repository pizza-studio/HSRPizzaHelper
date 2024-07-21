// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Combine

// MARK: - EnkaHSR.ProfileSummarized

extension EnkaHSR {
    public class ProfileSummarized: ObservableObject {
        // MARK: Lifecycle

        public init(theDB: EnkaDB, rawInfo: QueryRelated.DetailInfo) {
            self.theDB = theDB
            self.rawInfo = rawInfo
            self.summarizedAvatars = rawInfo.summarizeAllAvatars(theDB: theDB)
            cancellables.append(
                theDB.objectWillChange.sink {
                    self.update(newRawInfo: self.rawInfo)
                }
            )
        }

        // MARK: Public

        public private(set) var theDB: EnkaDB
        @Published public private(set) var rawInfo: QueryRelated.DetailInfo
        @Published public private(set) var summarizedAvatars: [EnkaHSR.AvatarSummarized]

        // MARK: Private

        private var cancellables: [AnyCancellable] = []
    }
}

extension EnkaHSR.ProfileSummarized {
    public func update(
        newRawInfo: EnkaHSR.QueryRelated.DetailInfo, dropExistingData: Bool = false
    ) {
        rawInfo = dropExistingData ? newRawInfo : rawInfo.merge(new: newRawInfo)
        summarizedAvatars = rawInfo.summarizeAllAvatars(theDB: theDB)
    }
}
