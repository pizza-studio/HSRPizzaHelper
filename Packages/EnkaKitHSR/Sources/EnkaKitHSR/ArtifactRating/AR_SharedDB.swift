// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Defaults
import DefaultsKeys
import Foundation

private typealias DecodableModelDict = ArtifactRating.StatScoreModelDecodable.Dict

extension ArtifactRating.StatScoreModelOptimized.Dict {
    public static func construct() -> Self {
        Defaults[.srsModelData].optimized
    }
}

extension ArtifactRating.StatScoreModelDecodable.Dict {
    public static func localConstruct() throws -> Self? {
        let url = Bundle.module.url(forResource: "StarRailScore", withExtension: "json", subdirectory: nil)
        guard let url = url else { return nil }
        let data = try Data(contentsOf: url)
        let rawDB = try JSONDecoder().decode(DecodableModelDict.self, from: data)
        return rawDB
    }

    public var optimized: ArtifactRating.StatScoreModelOptimized.Dict {
        var newDB = ArtifactRating.StatScoreModelOptimized.Dict()
        forEach { charID, rawModel in
            var newModel = ArtifactRating.StatScoreModelOptimized()
            newModel.max = rawModel.max
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
        return newDB
    }
}
