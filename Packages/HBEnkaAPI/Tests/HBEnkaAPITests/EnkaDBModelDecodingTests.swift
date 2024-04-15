// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Foundation
@testable import HBEnkaAPI
import XCTest

// MARK: - Factory JSON Database Decoding Tests.

final class EnkaDBModelDecodingTests: XCTestCase {
    func testLocTableJSONParsing() throws {
        let testData = EnkaHSR.JSONTypes.locTable.bundledJSONData
        guard let testData = testData else {
            assertionFailure("!!! Cannot access bundled EnkaDB RawLocTables JSON data.")
            return
        }
        let decoder = JSONDecoder()
        var dataCount = 0
        do {
            let obj = try decoder.decode(EnkaHSR.DBModels.RawLocTables.self, from: testData)
            dataCount = obj.keys.count
        } catch {
            assertionFailure(error.localizedDescription)
        }
        XCTAssertGreaterThan(dataCount, 0)
    }

    func testProfileAvatarJSONParsing() throws {
        let testData = EnkaHSR.JSONTypes.profileAvatarIcons.bundledJSONData
        guard let testData = testData else {
            assertionFailure("!!! Cannot access bundled EnkaDB ProfileAvatar JSON data.")
            return
        }
        let decoder = JSONDecoder()
        var dataCount = 0
        do {
            let obj = try decoder.decode(EnkaHSR.DBModels.ProfileAvatarDict.self, from: testData)
            dataCount = obj.keys.count
        } catch {
            assertionFailure(error.localizedDescription)
        }
        XCTAssertGreaterThan(dataCount, 0)
    }

    func testCharacterJSONParsing() throws {
        let testData = EnkaHSR.JSONTypes.characters.bundledJSONData
        guard let testData = testData else {
            assertionFailure("!!! Cannot access bundled EnkaDB Character JSON data.")
            return
        }
        let decoder = JSONDecoder()
        var dataCount = 0
        do {
            let obj = try decoder.decode(EnkaHSR.DBModels.CharacterDict.self, from: testData)
            dataCount = obj.keys.count
        } catch {
            assertionFailure(error.localizedDescription)
        }
        XCTAssertGreaterThan(dataCount, 0)
    }

    func testMetaJSONParsing() throws {
        let testData = EnkaHSR.JSONTypes.metadata.bundledJSONData
        guard let testData = testData else {
            assertionFailure("!!! Cannot access bundled EnkaDB Meta JSON data.")
            return
        }
        let decoder = JSONDecoder()
        var dataCount = 0
        do {
            let obj = try decoder.decode(EnkaHSR.DBModels.Meta.self, from: testData)
            dataCount = obj.tree.keys.count
        } catch {
            assertionFailure(error.localizedDescription)
        }
        XCTAssertGreaterThan(dataCount, 0)
    }

    func testSkillRanksJSONParsing() throws {
        let testData = EnkaHSR.JSONTypes.skillRanks.bundledJSONData
        guard let testData = testData else {
            assertionFailure("!!! Cannot access bundled EnkaDB SkillRanks JSON data.")
            return
        }
        let decoder = JSONDecoder()
        var dataCount = 0
        do {
            let obj = try decoder.decode(EnkaHSR.DBModels.SkillRanksDict.self, from: testData)
            dataCount = obj.keys.count
        } catch {
            assertionFailure(error.localizedDescription)
        }
        XCTAssertGreaterThan(dataCount, 0)
    }

    func testArtifactsJSONParsing() throws {
        let testData = EnkaHSR.JSONTypes.artifacts.bundledJSONData
        guard let testData = testData else {
            assertionFailure("!!! Cannot access bundled EnkaDB Relics JSON data.")
            return
        }
        let decoder = JSONDecoder()
        var dataCount = 0
        do {
            let obj = try decoder.decode(EnkaHSR.DBModels.ArtifactsDict.self, from: testData)
            dataCount = obj.keys.count
        } catch {
            assertionFailure(error.localizedDescription)
        }
        XCTAssertGreaterThan(dataCount, 0)
    }

    func testSkillsJSONParsing() throws {
        let testData = EnkaHSR.JSONTypes.skills.bundledJSONData
        guard let testData = testData else {
            assertionFailure("!!! Cannot access bundled EnkaDB Skills JSON data.")
            return
        }
        let decoder = JSONDecoder()
        var dataCount = 0
        do {
            let obj = try decoder.decode(EnkaHSR.DBModels.SkillsDict.self, from: testData)
            dataCount = obj.keys.count
        } catch {
            assertionFailure(error.localizedDescription)
        }
        XCTAssertGreaterThan(dataCount, 0)
    }

    func testWeaponsJSONParsing() throws {
        let testData = EnkaHSR.JSONTypes.weapons.bundledJSONData
        guard let testData = testData else {
            assertionFailure("!!! Cannot access bundled EnkaDB Weapons JSON data.")
            return
        }
        let decoder = JSONDecoder()
        var dataCount = 0
        do {
            let obj = try decoder.decode(EnkaHSR.DBModels.WeaponsDict.self, from: testData)
            dataCount = obj.keys.count
        } catch {
            assertionFailure(error.localizedDescription)
        }
        XCTAssertGreaterThan(dataCount, 0)
    }
}
