// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import Foundation

// MARK: - Enka Sputnik

#if !os(watchOS)
extension EnkaHSR {
    public enum Sputnik {
        public static func getEnkaProfile(
            for uid: String,
            dateWhenNextRefreshable nextAvailableDate: Date? = nil
        ) async throws
            -> EnkaHSR.QueryRelated.DetailInfo {
            let existingData = Defaults[.queriedEnkaProfiles][uid]
            do {
                let newData = try await Self.fetchEnkaProfileRAW(uid, dateWhenNextRefreshable: nextAvailableDate)
                guard let detailInfo = newData.detailInfo else {
                    let errMsgCore = newData.message ?? "No Error Message is Given."
                    throw EnkaHSR.QueryRelated.Exception.enkaProfileQueryFailure(message: "EnkaMsg: \(errMsgCore)")
                }
                return detailInfo.merge(old: existingData)
            } catch {
                print(error.localizedDescription)
                throw EnkaHSR.QueryRelated.Exception.enkaProfileQueryFailure(message: error.localizedDescription)
            }
        }

        public static func getEnkaDB() async throws -> EnkaHSR.EnkaDB {
            // Read charloc and charmap from UserDefault
            let storedDB = Defaults[.enkaDBData]

            var enkaDataExpired = Calendar.current.date(
                byAdding: .hour,
                value: 2,
                to: Defaults[.lastEnkaDBDataCheckDate]
            )! < Date()

            if Locale.langCodeForEnkaAPI != storedDB.langTag {
                enkaDataExpired = true
            }

            let needUpdate = enkaDataExpired

            if !needUpdate {
                return storedDB
            } else {
                let host = Defaults[.defaultDBQueryHost]
                async let newDB = try EnkaHSR.EnkaDB(
                    locTag: Locale.langCodeForEnkaAPI,
                    locTables: Self.fetchEnkaDBData(
                        from: host, type: .locTable,
                        decodingTo: EnkaHSR.DBModels.RawLocTables.self
                    ),
                    profileAvatars: Self.fetchEnkaDBData(
                        from: host, type: .profileAvatarIcons,
                        decodingTo: EnkaHSR.DBModels.ProfileAvatarDict.self
                    ),
                    characters: Self.fetchEnkaDBData(
                        from: host, type: .characters,
                        decodingTo: EnkaHSR.DBModels.CharacterDict.self
                    ),
                    meta: Self.fetchEnkaDBData(
                        from: host, type: .metadata,
                        decodingTo: EnkaHSR.DBModels.Meta.self
                    ),
                    skillRanks: Self.fetchEnkaDBData(
                        from: host, type: .skillRanks,
                        decodingTo: EnkaHSR.DBModels.SkillRanksDict.self
                    ),
                    artifacts: Self.fetchEnkaDBData(
                        from: host, type: .artifacts,
                        decodingTo: EnkaHSR.DBModels.ArtifactsDict.self
                    ),
                    skills: Self.fetchEnkaDBData(
                        from: host, type: .skills,
                        decodingTo: EnkaHSR.DBModels.SkillsDict.self
                    ),
                    skillTrees: Self.fetchEnkaDBData(
                        from: host, type: .skillTrees,
                        decodingTo: EnkaHSR.DBModels.SkillTreesDict.self
                    ),
                    weapons: Self.fetchEnkaDBData(
                        from: host, type: .weapons,
                        decodingTo: EnkaHSR.DBModels.WeaponsDict.self
                    )
                )
                guard let newDB = try await newDB else {
                    throw EnkaHSR.QueryRelated.Exception
                        .enkaDBOnlineFetchFailure(details: "Language Tag Matching Error.")
                }

                Defaults[.enkaDBData] = newDB

                Defaults[.lastEnkaDBDataCheckDate] = Date()

                return newDB
            }
        }
    }
}

// MARK: - Fetch Errors

extension EnkaHSR.Sputnik {
    public enum DataFetchError: Error {
        case charMapInvalid
        case charLocInvalid
    }
}

extension EnkaHSR.Sputnik {
    /// 从 Enka Networks 获取游戏内玩家展柜资讯。
    /// - Parameters:
    ///     - uid: 用户UID
    ///     - completion: 资料
    public static func fetchEnkaProfileRAW(
        _ uid: String,
        dateWhenNextRefreshable: Date? = nil
    ) async throws
        -> EnkaHSR.QueryRelated.QueriedProfile {
        if let date = dateWhenNextRefreshable, date > Date() {
            let delta = date.timeIntervalSinceReferenceDate - Date().timeIntervalSinceReferenceDate
            print(
                "PLAYER DETAIL FETCH 刷新太快了，请在\(delta)秒后刷新"
            )
            throw EnkaHSR.QueryRelated.Exception.refreshTooFast(dateWhenRefreshable: date)
        } else {
            let enkaOfficial = EnkaHSR.HostType.profileQueryURLHeader + uid
            // swiftlint:disable force_unwrapping
            let url = URL(string: enkaOfficial)!
            // swiftlint:enable force_unwrapping
            let (data, _) = try await URLSession.shared.data(for: URLRequest(url: url))
            let requestResult = try JSONDecoder().decode(
                EnkaHSR.QueryRelated.QueriedProfile.self,
                from: data
            )
            return requestResult
        }
    }

    /// 从 EnkaNetwork 获取具体单笔 EnkaDB 子类型资料
    /// - Parameters:
    ///     - completion: 资料
    static func fetchEnkaDBData<T: Codable>(
        from serverType: EnkaHSR.HostType = .enkaGlobal,
        type dataType: EnkaHSR.JSONType,
        decodingTo: T.Type
    ) async throws
        -> T {
        var dataToParse = Data([])
        do {
            let (data, _) = try await URLSession.shared.data(
                for: URLRequest(url: serverType.enkaDBSourceURL(type: dataType))
            )
            dataToParse = data
        } catch {
            print(error.localizedDescription)
            print("// [Enka.Sputnik.fetchEnkaDBData] Attempt using alternative JSON server source.")
            do {
                let (data, _) = try await URLSession.shared.data(
                    for: URLRequest(url: serverType.viceVersa().enkaDBSourceURL(type: dataType))
                )
                dataToParse = data
            } catch {
                print("// [Enka.Sputnik.fetchEnkaDBData] Final attempt failed:")
                print(error.localizedDescription)
                throw error
            }
        }
        do {
            let requestResult = try JSONDecoder().decode(T.self, from: dataToParse)
            return requestResult
        } catch {
            if dataToParse.isEmpty {
                print("// DEBUG: Data Fetch Failed: \(dataType.rawValue).json")
            } else {
                print("// DEBUG: Data Parse Failed: \(dataType.rawValue).json")
            }
            print(error.localizedDescription)
            throw error
        }
    }
}

#endif
