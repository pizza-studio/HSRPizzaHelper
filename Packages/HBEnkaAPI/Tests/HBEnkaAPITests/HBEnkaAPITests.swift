// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

@testable import HBEnkaAPI
import XCTest

private let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Tests" }).joined(
    separator: "/"
).dropFirst()

private let testDataPath: String = packageRootPath + "/Tests/TestData/"

// MARK: - Utility Functions

func getBundledCharTable() -> EnkaHSR.DBModels.CharacterDict? {
    let testData = EnkaHSR.JSONTypes.characters.bundledJSONData
    guard let testData = testData else { return nil }
    return try? JSONDecoder().decode(EnkaHSR.DBModels.CharacterDict.self, from: testData)
}

func getBundledLocTable() -> EnkaHSR.DBModels.RawLocTables? {
    let testData = EnkaHSR.JSONTypes.locTable.bundledJSONData
    guard let testData = testData else { return nil }
    return try? JSONDecoder().decode(EnkaHSR.DBModels.RawLocTables.self, from: testData)
}

// MARK: - HBEnkaAPITests

final class HBEnkaAPITests: XCTestCase {
    func testDecodingQueriedResults() throws {
        let filePath = testDataPath + "TestQueryResult.json"
        let dataURL = URL(fileURLWithPath: filePath)
        guard let jsonData = try? Data(contentsOf: dataURL) else {
            assertionFailure("!!! Cannot access Enka Query Result JSON data.")
            return
        }
        var uid = "0"
        do {
            let obj = try JSONDecoder().decode(EnkaHSR.QueryRelated.QueriedProfile.self, from: jsonData)
            uid = obj.uid
        } catch {
            assertionFailure(error.localizedDescription)
        }
        XCTAssertEqual(uid, "114514810")
    }

    func testPrintAllCharacterNames() throws {
        guard let locTable = getBundledLocTable()?["zh-tw"], let charTable = getBundledCharTable() else { return }
        charTable.forEach { charId, character in
            guard let nameLocalized = locTable[character.avatarName.hash.description] else { return }
            print("\(nameLocalized) \(charId)")
        }
    }
}
