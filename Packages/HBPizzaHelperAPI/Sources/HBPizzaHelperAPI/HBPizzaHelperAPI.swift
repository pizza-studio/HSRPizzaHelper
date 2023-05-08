import Foundation

@available(iOS 13, watchOS 7, *)
public enum PizzaHelperAPI {
    /// 获取最新系统版本
    /// - Parameters:
    ///     - isBeta: 是否是Beta
    ///     - completion: 数据
    public static func fetchNewestVersion(
        isBeta: Bool,
        completion: @escaping (
            NewestVersion
        ) -> ()
    ) {
        // 请求类别
        var urlStr: String
        if isBeta {
            urlStr = "api/app/newest_version_beta.json"
        } else {
            urlStr = "api/app/newest_version.json"
        }

        // 请求
        HttpMethod<NewestVersion>
            .homeRequest(
                .get,
                urlStr,
                cachedPolicy: .reloadIgnoringLocalCacheData
            ) { result in
                switch result {
                case let .success(requestResult):
                    print("request succeed")
                    completion(requestResult)

                case .failure:
                    print("request newest version fail")
                }
            }
    }

    /// 从EnkaNetwork获取角色ID对应详细信息
    /// - Parameters:
    ///     - completion: 数据
    public static func fetchENCharacterDetailDatas(
        completion: @escaping (
            ENCharacterMap
        ) -> ()
    ) {
        // 请求类别
        let urlStr = "api/players/characters.json"

        // 请求
        HttpMethod<ENCharacterMap>
            .homeRequest(
                .get,
                urlStr,
                cachedPolicy: .reloadIgnoringLocalCacheData
            ) { result in
                switch result {
                case let .success(requestResult):
                    print("request succeed")
                    completion(requestResult)

                case .failure:
                    print("fetch ENCharacterDetailDatas fail")
                }
            }
    }

    /// 从EnkaNetwork获取角色ID对应本地化信息
    /// - Parameters:
    ///     - completion: 数据
    public static func fetchENCharacterLocDatas(
        completion: @escaping (
            ENCharacterLoc
        ) -> ()
    ) {
        // 请求类别
        let urlStr = "api/players/loc.json"

        // 请求
        HttpMethod<ENCharacterLoc>
            .homeRequest(
                .get,
                urlStr,
                cachedPolicy: .reloadIgnoringLocalCacheData
            ) { result in
                switch result {
                case let .success(requestResult):
                    print("request succeed")
                    completion(requestResult)

                case .failure:
                    print("fetch ENCharacterLocDatas fail")
                }
            }
    }

    public static func getArtifactRatingScore(
        artifacts: ArtifactRatingRequest,
        completion: @escaping (
            ArtifactRatingScoreResult
        ) -> ()
    ) {
        var urlStr = "?"
        urlStr = urlStr.addPara("cid", String(artifacts.cid))

        urlStr = urlStr.addPara("fstar", String(artifacts.flower.star))
        urlStr = urlStr.addPara("flv", String(artifacts.flower.lv))
        urlStr = urlStr.addPara(
            "stat1atkpercent",
            String(artifacts.flower.atkPercent)
        )
        urlStr = urlStr.addPara(
            "stat1hppercent",
            String(artifacts.flower.hpPercent)
        )
        urlStr = urlStr.addPara(
            "stat1defpercent",
            String(artifacts.flower.defPercent)
        )
        urlStr = urlStr.addPara("stat1EM", String(artifacts.flower.em))
        urlStr = urlStr.addPara(
            "stat1ERpercent",
            String(artifacts.flower.erPercent)
        )
        urlStr = urlStr.addPara(
            "stat1CRpercent",
            String(artifacts.flower.crPercent)
        )
        urlStr = urlStr.addPara(
            "stat1CDpercent",
            String(artifacts.flower.cdPercent)
        )
        urlStr = urlStr.addPara("stat1atk", String(artifacts.flower.atk))
        urlStr = urlStr.addPara("stat1hp", String(artifacts.flower.hp))
        urlStr = urlStr.addPara("stat1def", String(artifacts.flower.def))

        urlStr = urlStr.addPara("pstar", String(artifacts.plume.star))
        urlStr = urlStr.addPara("plv", String(artifacts.plume.lv))
        urlStr = urlStr.addPara(
            "stat2atkpercent",
            String(artifacts.plume.atkPercent)
        )
        urlStr = urlStr.addPara(
            "stat2hppercent",
            String(artifacts.plume.hpPercent)
        )
        urlStr = urlStr.addPara(
            "stat2defpercent",
            String(artifacts.plume.defPercent)
        )
        urlStr = urlStr.addPara("stat2EM", String(artifacts.plume.em))
        urlStr = urlStr.addPara(
            "stat2ERpercent",
            String(artifacts.plume.erPercent)
        )
        urlStr = urlStr.addPara(
            "stat2CRpercent",
            String(artifacts.plume.crPercent)
        )
        urlStr = urlStr.addPara(
            "stat2CDpercent",
            String(artifacts.plume.cdPercent)
        )
        urlStr = urlStr.addPara("stat2atk", String(artifacts.plume.atk))
        urlStr = urlStr.addPara("stat2hp", String(artifacts.plume.hp))
        urlStr = urlStr.addPara("stat2def", String(artifacts.plume.def))

        urlStr = urlStr.addPara("sstar", String(artifacts.sands.star))
        urlStr = urlStr.addPara("slv", String(artifacts.sands.lv))
        if let mainProp = artifacts.sands.mainProp3 {
            urlStr = urlStr.addPara(
                "artifact3mainstatcat",
                String(mainProp.rawValue)
            )
            urlStr = urlStr.addPara(
                "stat3atkpercent",
                String(artifacts.sands.atkPercent)
            )
            urlStr = urlStr.addPara(
                "stat3hppercent",
                String(artifacts.sands.hpPercent)
            )
            urlStr = urlStr.addPara(
                "stat3defpercent",
                String(artifacts.sands.defPercent)
            )
            urlStr = urlStr.addPara("stat3EM", String(artifacts.sands.em))
            urlStr = urlStr.addPara(
                "stat3ERpercent",
                String(artifacts.sands.erPercent)
            )
            urlStr = urlStr.addPara(
                "stat3CRpercent",
                String(artifacts.sands.crPercent)
            )
            urlStr = urlStr.addPara(
                "stat3CDpercent",
                String(artifacts.sands.cdPercent)
            )
            urlStr = urlStr.addPara("stat3atk", String(artifacts.sands.atk))
            urlStr = urlStr.addPara("stat3hp", String(artifacts.sands.hp))
            urlStr = urlStr.addPara("stat3def", String(artifacts.sands.def))

            urlStr = urlStr.addPara("gstar", String(artifacts.goblet.star))
            urlStr = urlStr.addPara("glv", String(artifacts.goblet.lv))
        }
        if let mainProp = artifacts.goblet.mainProp4 {
            urlStr = urlStr.addPara(
                "artifact4mainstatcat",
                String(mainProp.rawValue)
            )
            urlStr = urlStr.addPara(
                "stat4atkpercent",
                String(artifacts.goblet.atkPercent)
            )
            urlStr = urlStr.addPara(
                "stat4hppercent",
                String(artifacts.goblet.hpPercent)
            )
            urlStr = urlStr.addPara(
                "stat4defpercent",
                String(artifacts.goblet.defPercent)
            )
            urlStr = urlStr.addPara("stat4EM", String(artifacts.goblet.em))
            urlStr = urlStr.addPara(
                "stat4ERpercent",
                String(artifacts.goblet.erPercent)
            )
            urlStr = urlStr.addPara(
                "stat4CRpercent",
                String(artifacts.goblet.crPercent)
            )
            urlStr = urlStr.addPara(
                "stat4CDpercent",
                String(artifacts.goblet.cdPercent)
            )
            urlStr = urlStr.addPara("stat4atk", String(artifacts.goblet.atk))
            urlStr = urlStr.addPara("stat4hp", String(artifacts.goblet.hp))
            urlStr = urlStr.addPara("stat4def", String(artifacts.goblet.def))

            urlStr = urlStr.addPara("cstar", String(artifacts.circlet.star))
            urlStr = urlStr.addPara("clv", String(artifacts.circlet.lv))
        }
        if let mainProp = artifacts.circlet.mainProp5 {
            urlStr = urlStr.addPara(
                "artifact5mainstatcat",
                String(mainProp.rawValue)
            )
            urlStr = urlStr.addPara(
                "stat5atkpercent",
                String(artifacts.circlet.atkPercent)
            )
            urlStr = urlStr.addPara(
                "stat5hppercent",
                String(artifacts.circlet.hpPercent)
            )
            urlStr = urlStr.addPara(
                "stat5defpercent",
                String(artifacts.circlet.defPercent)
            )
            urlStr = urlStr.addPara("stat5EM", String(artifacts.circlet.em))
            urlStr = urlStr.addPara(
                "stat5ERpercent",
                String(artifacts.circlet.erPercent)
            )
            urlStr = urlStr.addPara(
                "stat5CRpercent",
                String(artifacts.circlet.crPercent)
            )
            urlStr = urlStr.addPara(
                "stat5CDpercent",
                String(artifacts.circlet.cdPercent)
            )
            urlStr = urlStr.addPara("stat5atk", String(artifacts.circlet.atk))
            urlStr = urlStr.addPara("stat5hp", String(artifacts.circlet.hp))
            urlStr = urlStr.addPara("stat5def", String(artifacts.circlet.def))
        }

        // 请求
        HttpMethod<ArtifactRatingScoreResult>
            .homeRequest(
                .get,
                urlStr,
                cachedPolicy: .reloadIgnoringLocalCacheData,
                hostType: .artifactRatingHost
            ) { result in
                switch result {
                case let .success(requestResult):
                    print("request artifact rating succeed")
                    completion(requestResult)

                case .failure:
                    print("fetch Artifact Score fail")
                }
            }
    }
}
