// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
@testable import HBEnkaAPI
import XCTest

// MARK: - HBEnkaAPITests

final class EnkaSputnikTests: XCTestCase {
    override func tearDownWithError() throws {
        Defaults.reset([.enkaDBData, .queriedEnkaProfiles])
    }

    func testFetchingLatestEnkaDB() async throws {
        let dbObj = try await EnkaHSR.Sputnik.getEnkaDB()
        print(dbObj.langTag)
    }

    func testFetchingEnkaProfile() async throws {
        do {
            let dbObj = try await EnkaHSR.Sputnik.fetchEnkaProfileRAW("114514810")
            print(dbObj.uid?.description ?? "FUCKED.")
        } catch {
            print(error.localizedDescription)
        }
    }
}
