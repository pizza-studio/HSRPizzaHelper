// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

@testable import EnkaKitHSR
import XCTest

private let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Tests" }).joined(
    separator: "/"
).dropFirst()

private let testDataPath: String = packageRootPath + "/Tests/TestData/"

// MARK: - ArtifactAppraiserBetaTests

final class ArtifactAppraiserBetaTests: XCTestCase {
    // MARK: Internal

    override func setUpWithError() throws {
        EnkaHSR.assetPathRoot = "\(packageRootPath)/../../Assets"
    }

    func testPrintAllArtifactSubAffixes() throws {
        guard let theDB = EnkaHSR.EnkaDB(locTag: "zh-tw") else { return }
        var allDicts: [EnkaHSR.DBModels.Artifact.ArtifactType: [IdPairedProperty]] = [:]
        theDB.artifacts.forEach { _, artifact in
            let artifactType = artifact.type
            // let mainAffixes = theDB.meta.relic.mainAffix[artifact.mainAffixGroup.description]
            let subAffixes = theDB.meta.relic.subAffix[artifact.subAffixGroup.description]
            subAffixes?.forEach { affixId, affix in
                let newPair = IdPairedProperty(id: affixId, prop: affix.property)
                if !allDicts[artifactType, default: []].contains(newPair) {
                    allDicts[artifactType, default: []].append(newPair)
                }
            }
        }
        allDicts.forEach { artifactType, pairs in
            print("public enum \(artifactType.rawValue)_AFFIXES: String, Codable {")
            defer { print("}") }
            pairs.sorted { (Int($0.id) ?? 0) < (Int($1.id) ?? 0) }.forEach { paired in
                print("    case \(paired.prop.rawValue) = \(paired.id)")
            }
        }
    }

    func testPrintAllArtifactMainAffixes() throws {
        guard let theDB = EnkaHSR.EnkaDB(locTag: "zh-tw") else { return }
        var allDicts: [EnkaHSR.DBModels.Artifact.ArtifactType: [IdPairedProperty]] = [:]
        theDB.artifacts.forEach { _, artifact in
            let artifactType = artifact.type
            let mainAffixes = theDB.meta.relic.mainAffix[artifact.mainAffixGroup.description]
            // let subAffixes = theDB.meta.relic.subAffix[artifact.subAffixGroup.description]
            mainAffixes?.forEach { affixId, affix in
                let newPair = IdPairedProperty(id: affixId, prop: affix.property)
                if !allDicts[artifactType, default: []].contains(newPair) {
                    allDicts[artifactType, default: []].append(newPair)
                }
            }
        }
        allDicts.forEach { artifactType, pairs in
            print("public enum \(artifactType.rawValue)_AFFIXES: String, Codable {")
            defer { print("}") }
            pairs.sorted { (Int($0.id) ?? 0) < (Int($1.id) ?? 0) }.forEach { paired in
                print("    case \(paired.prop.rawValue) = \(paired.id)")
            }
        }
    }

    // MARK: Private

    private struct IdPairedProperty: Hashable {
        let id: String
        let prop: EnkaHSR.PropertyType
    }
}

// MARK: - ArtifactAppraiserTests

final class ArtifactAppraiserTests: XCTestCase {
    override func setUpWithError() throws {
        EnkaHSR.assetPathRoot = "\(packageRootPath)/../../Assets"
    }

    func testPrintAllScoreModels() throws {
        let scoreDB = ArtifactRating.StatScoreModelOptimized.Dict.construct()
        print(scoreDB)
        XCTAssertTrue(!scoreDB.isEmpty)
    }

    func testScoreModelValidity() throws {
        print("----------------------------------")
        let scoreDB = ArtifactRating.StatScoreModelOptimized.Dict.construct()
        var invalidIDs = [String]()
        scoreDB.forEach { theID, theModel in
            if ![theModel].areAllContentsValid {
                invalidIDs.append(theID)
            }
        }
        print("Artifact Rating Model Invalid for character id: \(invalidIDs.joined(separator: ", ")).")
        print("----------------------------------")
    }
}
