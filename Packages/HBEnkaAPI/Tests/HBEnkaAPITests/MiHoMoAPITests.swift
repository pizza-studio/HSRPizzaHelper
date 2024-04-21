// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
@testable import HBEnkaAPI
import XCTest

// MARK: - MiHoMoAPITests

final class MiHoMoAPITests: XCTestCase {
    func testFetchingMiHoMoProfile() async throws {
        do {
            let dbObj = try await MiHoMo.QueriedProfile.fetch(uid: "114514810")
            print(dbObj.player.uid)
        } catch {
            throw (error)
        }
    }

    func testFetchingEnkaProfile() async throws {
        do {
            let dbObj = try await MiHoMo.QueriedProfile.fetchEnka(uid: "114514810")
            print(dbObj.detailInfo?.uid ?? 114_514)
        } catch {
            throw (error)
        }
    }
}
