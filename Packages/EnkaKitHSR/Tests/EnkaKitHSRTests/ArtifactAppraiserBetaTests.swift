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
        let rawDB = try JSONDecoder().decode(
            ArtifactRating.StatScoreModelRAW.Dict.self,
            from: statScoreRawJSON.data(using: .utf8)!
        )
        var newDB = ArtifactRating.StatScoreModelOptimized.Dict()
        rawDB.forEach { charID, rawModel in
            var newModel = ArtifactRating.StatScoreModelOptimized()
            // 副词条
            rawModel.weight.forEach { rawPropID, propWeight in
                let newWeight = ArtifactRating.SubStatScoreLevel(march7thWeight: propWeight)
                guard let prop = EnkaHSR.PropertyType(rawValue: rawPropID), newWeight != .none else { return }
                guard let optimizedProp = prop.appraisableArtifactParam else { return }
                newModel.weight[optimizedProp] = newWeight
            }
            // 主词条
            rawModel.main.forEach { typeIDStr, paramList in
                guard let typeID = Int(typeIDStr),
                      let artifactType = EnkaHSR.DBModels.Artifact.ArtifactType(typeID: typeID)
                else { return }
                paramList.forEach { rawPropID, propWeight in
                    let newWeight = ArtifactRating.SubStatScoreLevel(march7thWeight: propWeight)
                    guard let prop = EnkaHSR.PropertyType(rawValue: rawPropID), newWeight != .none else { return }
                    guard let optimizedProp = prop.appraisableArtifactParam else { return }
                    newModel.main[artifactType, default: .init()][optimizedProp] = newWeight
                }
            }
            newDB[charID] = newModel
        }
        print(newDB)
        XCTAssertTrue(!newDB.isEmpty)
    }
}

// MARK: - ArtifactRating.StatScoreModelRAW

extension ArtifactRating {
    public struct StatScoreModelRAW: Codable, Hashable {
        // MARK: Public

        public typealias Dict = [String: Self]

        // MARK: Internal

        let main: [String: [String: Double]]
        let weight: [String: Double]
        let max: Double
    }
}

public let statScoreRawJSON: String = """
{
    "1001": {
        "main": {
            "1": {
                "HPDelta": 1
            },
            "2": {
                "AttackDelta": 1
            },
            "3": {
                "HPAddedRatio": 0.5,
                "AttackAddedRatio": 0,
                "DefenceAddedRatio": 1,
                "CriticalChanceBase": 0,
                "CriticalDamageBase": 0,
                "HealRatioBase": 0,
                "StatusProbabilityBase": 1
            },
            "4": {
                "HPAddedRatio": 0.5,
                "AttackAddedRatio": 0,
                "DefenceAddedRatio": 1,
                "SpeedDelta": 0.8
            },
            "5": {
                "HPAddedRatio": 0.5,
                "AttackAddedRatio": 0,
                "DefenceAddedRatio": 1,
                "PhysicalAddedRatio": 0,
                "FireAddedRatio": 0,
                "IceAddedRatio": 0,
                "ThunderAddedRatio": 0,
                "WindAddedRatio": 0,
                "QuantumAddedRatio": 0,
                "ImaginaryAddedRatio": 0
            },
            "6": {
                "BreakDamageAddedRatioBase": 0,
                "SPRatioBase": 1,
                "HPAddedRatio": 0.5,
                "AttackAddedRatio": 0,
                "DefenceAddedRatio": 1
            }
        },
        "weight": {
            "HPDelta": 0.2,
            "AttackDelta": 0,
            "DefenceDelta": 0.5,
            "HPAddedRatio": 0.5,
            "AttackAddedRatio": 0,
            "DefenceAddedRatio": 1,
            "SpeedDelta": 1,
            "CriticalChanceBase": 0,
            "CriticalDamageBase": 0,
            "StatusProbabilityBase": 0.5,
            "StatusResistanceBase": 0.5,
            "BreakDamageAddedRatioBase": 0
        },
        "max": 9.3
    }
}
"""
