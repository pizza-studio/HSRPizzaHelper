// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

@testable import GachaKit
import HBMihoyoAPI
import XCTest

private let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Tests" }).joined(
    separator: "/"
).dropFirst()

private let testDataPath: String = packageRootPath + "/Tests/TestData/"

// MARK: - GachaKitTests

final class GachaKitTests: XCTestCase {
    func testDecodingSRGF() throws {
        let filePath: String = testDataPath + "SRGFv1_Sample.json"
        let url = URL(fileURLWithPath: filePath)
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(SRGFv1.self, from: data)
        XCTAssertEqual(decoded.info.exportApp, "YJSNPI")
        let x = decoded.list.filter {
            $0.gachaType == .characterEventWarp
                && $0.rankType == "5"
                && GachaItem.ItemType(itemID: $0.itemID) == .characters
        }
        XCTAssertEqual(x.count, 20)
        print(x.compactMap(\.name).joined(separator: "\n"))
        let y = decoded.list.filter {
            $0.gachaType == .lightConeEventWarp
                && $0.rankType == "5"
                && GachaItem.ItemType(itemID: $0.itemID) == .lightCones
        }
        XCTAssertEqual(y.count, 1)
        print(y.compactMap(\.name).joined(separator: "\n"))
    }

    func testConsistencySRGF() throws {
        let filePath: String = testDataPath + "SRGFv1_Sample.json"
        let url = URL(fileURLWithPath: filePath)
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(SRGFv1.self, from: data)
        let gachaLang = decoded.info.lang
        let rawList = decoded.list.sorted { $0.id < $1.id }.map { oldValue in
            var newValue = oldValue
            let newType = GachaItem.ItemType(itemID: oldValue.itemID)
            newValue.itemType = newType.translatedRaw(for: gachaLang)
            return newValue
        }
        let gachaEntries = rawList.map { $0.toGachaEntry(uid: "114514810", lang: gachaLang) }
        let newList = gachaEntries.map { $0.toSRGFEntry(langOverride: gachaLang) }.sorted { $0.id < $1.id }
        XCTAssertEqual(rawList, newList)
    }
}
