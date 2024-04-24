// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

@testable import HBEnkaAPI
import XCTest

private let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Tests" }).joined(
    separator: "/"
).dropFirst()

private let testDataPath: String = packageRootPath + "/Tests/TestData/"

// MARK: - AssetAvaiabilityTests

final class AssetAvaiabilityTests: XCTestCase {
    override func setUpWithError() throws {
        EnkaHSR.assetPathRoot = "\(packageRootPath)/../../Assets"
    }

    func testPropIconAccessibility() throws {
        guard let theDB = EnkaHSR.EnkaDB(locTag: "zh-tw") else { return }
        var rawAffixes = [EnkaHSR.DBModels.PropertyType]()
        // Subprops from Weapons.
        theDB.meta.equipmentSkill.keys.forEach { idStr in
            for i in 1 ... 5 {
                rawAffixes.append(contentsOf: theDB.meta.equipmentSkill.query(id: idStr, stage: i).keys)
            }
        }
        // Props from Artifacts.
        rawAffixes += theDB.meta.relic.mainAffix.values.map { $0.values.map(\.property) }.reduce([], +)
        rawAffixes += theDB.meta.relic.subAffix.values.map { $0.values.map(\.property) }.reduce([], +)
        // Deduplicate.
        var affixes = [EnkaHSR.DBModels.PropertyType]()
        rawAffixes.forEach {
            guard !affixes.contains($0) else { return }
            affixes.append($0)
        }
        // 先测试「hasPropIcon」。
        XCTAssertEqual(affixes.filter { !$0.hasPropIcon }.count, 0)
        // 再测试「proposedIconFileName accessibility」。
        let fileMgr = FileManager.default
        var counter = 0
        affixes.forEach { affix in
            let path = affix.proposedIconFilePath
            if !fileMgr.fileExists(atPath: path) {
                print(path)
                counter += 1
            }
        }
        XCTAssertEqual(counter, 0)
    }
}
