// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

@testable import EnkaKitHSR
import XCTest

private let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Tests" }).joined(
    separator: "/"
).dropFirst()

private let testDataPath: String = packageRootPath + "/Tests/TestData/"

// MARK: - Utility Functions

func getBundledCharTable() -> EnkaHSR.DBModels.CharacterDict? {
    let testData = EnkaHSR.JSONType.characters.bundledJSONData
    guard let testData = testData else { return nil }
    return try? JSONDecoder().decode(EnkaHSR.DBModels.CharacterDict.self, from: testData)
}

func getBundledLocTable() -> EnkaHSR.DBModels.RawLocTables? {
    let testData = EnkaHSR.JSONType.locTable.bundledJSONData
    guard let testData = testData else { return nil }
    return try? JSONDecoder().decode(EnkaHSR.DBModels.RawLocTables.self, from: testData)
}

// MARK: - EnkaKitHSRTests

final class EnkaKitHSRTests: XCTestCase {
    override func setUpWithError() throws {
        EnkaHSR.assetPathRoot = "\(packageRootPath)/../../Assets"
    }

    func testDecodingQueriedResults() throws {
        let filePath = testDataPath + "TestQueryResultEnka.json"
        let dataURL = URL(fileURLWithPath: filePath)
        guard let jsonData = try? Data(contentsOf: dataURL) else {
            assertionFailure("!!! Cannot access Enka Query Result JSON data.")
            return
        }
        var uid = "0"
        var profile: EnkaHSR.QueryRelated.QueriedProfile?
        do {
            let obj = try JSONDecoder().decode(EnkaHSR.QueryRelated.QueriedProfile.self, from: jsonData)
            uid = obj.uid ?? obj.detailInfo?.uid.description ?? 114514810.description
            profile = obj
        } catch {
            throw (error)
        }
        XCTAssertEqual(uid, "114514810")
        guard let profile = profile, let detailInfo = profile.detailInfo else { return }
        guard let enkaDatabase = EnkaHSR.EnkaDB(locTag: "zh-tw") else { return }
        let summarized = detailInfo.avatarDetailList.first?.summarize(theDB: enkaDatabase)?.artifactsRated()
        XCTAssertNotNil(summarized)
        XCTAssertNotNil(summarized?.artifactRatingResult)
        guard let summarized = summarized else { return }
        XCTAssertEqual(summarized.mainInfo.localizedName, "黃泉")
        XCTAssertEqual(summarized.mainInfo.constellation, 2)
        XCTAssertEqual(summarized.equippedWeapon?.enkaId, 23024)
        XCTAssertEqual(summarized.equippedWeapon?.basicProps[0].localizedTitle, "基礎生命值")
        XCTAssertEqual(summarized.artifacts[0].enkaId, 61171)
        XCTAssertTrue(EnkaHSR.queryImageAssetSUI(for: summarized.mainInfo.idExpressable.photoAssetName) != nil)
        // Check skill levels reinforced by constellations.
        let seijaku = detailInfo.avatarDetailList[4].summarize(theDB: enkaDatabase)
        XCTAssertNotNil(seijaku)
        guard let seijaku = seijaku else { return }
        XCTAssertNotNil(seijaku.mainInfo.baseSkills.elementalBurst.levelAddition)
        print("\n\(seijaku.asText)")
        print("\n\(seijaku.asMarkDown)")

        let char = detailInfo.avatarDetailList[4].summarize(theDB: enkaDatabase)
        char?.equippedWeapon?.specialProps.forEach { print($0) }
    }

    func testAllPropertyIconFileAccess() throws {
        EnkaHSR.PropertyType.allCases.filter(\.hasPropIcon).forEach { prop in
            XCTAssertNotNil(prop.iconAssetName)
            guard let assetName = prop.iconAssetName else { return }
            let exists = EnkaHSR.queryImageAssetSUI(for: assetName) != nil
            if !exists {
                print("\nPath: \(assetName)")
                XCTAssertTrue(exists)
                print("\n")
            }
        }
    }

    func testPrintAllCharacterNames() throws {
        guard let locTable = getBundledLocTable()?["zh-tw"], let charTable = getBundledCharTable() else { return }
        charTable.forEach { charID, character in
            guard let nameLocalized = locTable[character.avatarName.hash.description] else { return }
            print("\(nameLocalized) \(charID)")
        }
    }

    func testLifePathFileName() throws {
        XCTAssertEqual(EnkaHSR.LifePath.nihility.iconFileName, "Nihility.heic")
    }

    func testWallpapers() throws {
        Wallpaper.allCases.forEach { thisCase in
            print(thisCase.localizedTitle)
            XCTAssertNotNil(thisCase.image)
        }
    }
}
