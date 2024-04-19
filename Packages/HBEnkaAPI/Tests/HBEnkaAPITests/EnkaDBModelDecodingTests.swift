// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
@testable import HBEnkaAPI
import XCTest

// MARK: - Factory JSON Database Decoding Tests.

final class EnkaDBModelDecodingTests: XCTestCase {
    func testEnkaDBConstructionWithBundledJSONs() throws {
        let x = EnkaHSR.EnkaDB(locTag: "en")
        guard let x = x else {
            assertionFailure("!!! Cannot construct EnkaDB from bundled JSON data.")
            return
        }
        print(x.locTable.count)
    }

    func testLocTableJSONParsing() throws {
        let testData = EnkaHSR.JSONTypes.locTable.bundledJSONData
        guard let obj = try? testData.parseAs(EnkaHSR.DBModels.RawLocTables.self) else {
            assertionFailure("!!! Cannot parse bundled EnkaDB RawLocTables JSON data.")
            return
        }
        let dataCount = obj.keys.count
        XCTAssertGreaterThan(dataCount, 0)
    }

    func testProfileAvatarJSONParsing() throws {
        let testData = EnkaHSR.JSONTypes.profileAvatarIcons.bundledJSONData
        guard let obj = try? testData.parseAs(EnkaHSR.DBModels.ProfileAvatarDict.self) else {
            assertionFailure("!!! Cannot access bundled EnkaDB ProfileAvatar JSON data.")
            return
        }
        let dataCount = obj.keys.count
        XCTAssertGreaterThan(dataCount, 0)
    }

    func testCharacterJSONParsing() throws {
        let testData = EnkaHSR.JSONTypes.characters.bundledJSONData
        guard let obj = try? testData.parseAs(EnkaHSR.DBModels.CharacterDict.self) else {
            assertionFailure("!!! Cannot access bundled EnkaDB Character JSON data.")
            return
        }
        let dataCount = obj.keys.count
        XCTAssertGreaterThan(dataCount, 0)
    }

    func testMetaJSONParsing() throws {
        let testData = EnkaHSR.JSONTypes.metadata.bundledJSONData
        guard let obj = try? testData.parseAs(EnkaHSR.DBModels.Meta.self) else {
            assertionFailure("!!! Cannot access bundled EnkaDB Meta JSON data.")
            return
        }
        let dataCount = obj.tree.keys.count
        XCTAssertGreaterThan(dataCount, 0)
    }

    func testSkillRanksJSONParsing() throws {
        let testData = EnkaHSR.JSONTypes.skillRanks.bundledJSONData
        guard let obj = try? testData.parseAs(EnkaHSR.DBModels.SkillRanksDict.self) else {
            assertionFailure("!!! Cannot access bundled EnkaDB SkillRanks JSON data.")
            return
        }
        let dataCount = obj.keys.count
        XCTAssertGreaterThan(dataCount, 0)
    }

    func testArtifactsJSONParsing() throws {
        let testData = EnkaHSR.JSONTypes.artifacts.bundledJSONData
        guard let obj = try? testData.parseAs(EnkaHSR.DBModels.ArtifactsDict.self) else {
            assertionFailure("!!! Cannot access bundled EnkaDB Relics JSON data.")
            return
        }
        let dataCount = obj.keys.count
        XCTAssertGreaterThan(dataCount, 0)
    }

    func testSkillsJSONParsing() throws {
        let testData = EnkaHSR.JSONTypes.skills.bundledJSONData
        guard let obj = try? testData.parseAs(EnkaHSR.DBModels.SkillsDict.self) else {
            assertionFailure("!!! Cannot access bundled EnkaDB Skills JSON data.")
            return
        }
        let dataCount = obj.keys.count
        XCTAssertGreaterThan(dataCount, 0)
    }

    func testSkillTreesJSONParsing() throws {
        let testData = EnkaHSR.JSONTypes.skillTrees.bundledJSONData
        guard let obj = try? testData.parseAs(EnkaHSR.DBModels.SkillTreesDict.self) else {
            assertionFailure("!!! Cannot access bundled EnkaDB SkillTrees JSON data.")
            return
        }
        let dataCount = obj.keys.count
        XCTAssertGreaterThan(dataCount, 0)
    }

    func testWeaponsJSONParsing() throws {
        let testData = EnkaHSR.JSONTypes.weapons.bundledJSONData
        guard let obj = try? testData.parseAs(EnkaHSR.DBModels.WeaponsDict.self) else {
            assertionFailure("!!! Cannot access bundled EnkaDB Weapons JSON data.")
            return
        }
        let dataCount = obj.keys.count
        XCTAssertGreaterThan(dataCount, 0)
    }
}
