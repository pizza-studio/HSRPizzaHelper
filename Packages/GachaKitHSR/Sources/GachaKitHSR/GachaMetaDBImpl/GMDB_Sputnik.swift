// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Combine
import Defaults
import Foundation
import GachaMetaDB
import GachaMetaGeneratorModule
import HBMihoyoAPI

#if !os(watchOS)

// 特别备注：穹披助手使用 GachaMetaDB 时不需要反向查询。

// MARK: - GachaMeta.Sputnik

extension GachaMeta {
    public enum Sputnik {}
}

extension GachaMeta {
    public static let sharedDB = DBSet()

    public class DBSet: ObservableObject {
        // MARK: Lifecycle

        public init() {
            cancellables.append(
                Defaults.publisher(.localGachaMetaDB).sink { _ in
                    Task.detached { @MainActor in
                        self.mainDB = Defaults[.localGachaMetaDB]
                    }
                }
            )
        }

        // MARK: Public

        @Published public var mainDB = Defaults[.localGachaMetaDB]

        // MARK: Private

        private var cancellables: [AnyCancellable] = []
    }
}

extension GachaMeta.Sputnik {
    @MainActor
    public static func updateLocalGachaMetaDB() async throws {
        do {
            let newDB = try await fetchPreCompiledData()
            Defaults[.localGachaMetaDB] = newDB
        } catch {
            throw GachaMeta.GMDBError.resultFetchFailure(subError: error)
        }
    }

    static func fetchPreCompiledData(
        from serverType: Region = .mainlandChina
    ) async throws
        -> GachaMeta.MetaDB {
        var dataToParse = Data([])
        do {
            let (data, _) = try await URLSession.shared.data(
                for: URLRequest(url: serverType.gachaMetaDBRemoteURL)
            )
            dataToParse = data
        } catch {
            print(error.localizedDescription)
            print("// [GachaMeta.MetaDB.fetchPreCompiledData] Attempt using alternative JSON server source.")
            do {
                let (data, _) = try await URLSession.shared.data(
                    for: URLRequest(url: serverType.gmdbServerViceVersa.gachaMetaDBRemoteURL)
                )
                dataToParse = data
                // 如果这次成功的话，就自动修改偏好设定、今后就用这个资料源。
                let successMsg = "// [GachaMeta.MetaDB.fetchPreCompiledData] 2nd attempt succeeded."
                print(successMsg)
            } catch {
                print("// [GachaMeta.MetaDB.fetchPreCompiledData] Final attempt failed:")
                print(error.localizedDescription)
                throw error
            }
        }
        let requestResult = try JSONDecoder().decode(GachaMeta.MetaDB.self, from: dataToParse)
        return requestResult
    }
}

// MARK: - GachaMeta.GMDBError

extension GachaMeta {
    public enum GMDBError: Error, LocalizedError {
        case emptyFetchResult
        case resultFetchFailure(subError: Error)
        case databaseExpired

        // MARK: Public

        public var errorDescription: String? {
            switch self {
            case .emptyFetchResult:
                return NSLocalizedString("GachaMetaDBError.EmptyFetchResult", comment: "")
            case let .resultFetchFailure(subError):
                return NSLocalizedString("GachaMetaDBError.ResultFetchFailed", comment: "") +
                    ": \(subError.localizedDescription)"
            case .databaseExpired:
                return NSLocalizedString("GachaMetaDBError.DatabaseExpired", comment: "")
            }
        }
    }
}

extension Region {
    fileprivate var gmdbServerViceVersa: Self {
        switch self {
        case .mainlandChina: return .global
        case .global: return .mainlandChina
        }
    }

    public var gachaMetaDBRemoteURL: URL {
        var urlStr = ""
        switch self {
        case .mainlandChina:
            urlStr += #"https://gitlink.org.cn/attachments/entries/get_file?download_url="#
            urlStr += #"https://www.gitlink.org.cn/api/ShikiSuen/GachaMetaGenerator/raw/"#
            urlStr += #"Sources%2FGachaMetaDB%2FResources%2FOUTPUT-GI.json?ref=main"#
        case .global:
            urlStr += #"https://raw.githubusercontent.com/pizza-studio/"#
            urlStr += #"GachaMetaGenerator/main/Sources/GachaMetaDB/Resources/OUTPUT-GI.json"#
        }
        return URL(string: urlStr)!
    }
}
#endif
