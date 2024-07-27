import Foundation

// MARK: - Extract Filename Stem

extension String {
    func extractFileNameStem() -> String {
        split(separator: "/").last?.split(separator: ".").dropLast().joined(separator: ".").description ?? self
    }
}

// MARK: - SubStructForDecoding

struct SubStructForDecoding: Codable {
    enum CodingKeys: String, CodingKey {
        case iconPath = "IconPath"
    }

    let iconPath: String?
}

// MARK: - StructForDecoding

struct StructForDecoding: Codable {
    enum CodingKeys: String, CodingKey {
        case icon
        case subDict
        case firstWordText = "FirstWordText"
    }

    let firstWordText: String?
    let icon: String?
    let subDict: [String: SubStructForDecoding]?
}

// MARK: - DataType

public enum DataType: String, CaseIterable {
    case profileAvatar
    case property
    case character
    case element
    case lightCone
    case lifePath
    case artifact
    case skillTree

    // MARK: Public

    public func generateLinkDataDict() async throws -> [String: String] {
        var dict = [String: String]()
        guard let sourceURL = sourceURL else { return [:] }
        let (data, _) = try await URLSession.shared.data(from: sourceURL)
        try? JSONDecoder().decode([String: [String: SubStructForDecoding]].self, from: data).forEach { id, obj in
            switch self {
            case .artifact:
                let pairs = Array(obj).sorted {
                    $0.key < $1.key
                }
                pairs.enumerated().forEach { enumNumber, subPair in
                    let subId = "\(id)_\(enumNumber)"
                    let sourceFileName = subPair.value.iconPath?.extractFileNameStem()
                    writeKeyValuePair(id: subId, dict: &dict, sourceFileName: sourceFileName)
                }
            default: return
            }
        }
        try? JSONDecoder().decode([String: StructForDecoding].self, from: data).forEach { id, obj in
            switch self {
            case .profileAvatar:
                guard id.count >= 4, id != "8000" else { return }
                guard let iconPath = obj.icon, !iconPath.isEmpty else { return }
                let sourceFileName = iconPath.extractFileNameStem()
                writeKeyValuePair(id: sourceFileName, dict: &dict, sourceFileName: sourceFileName)
            case .property:
                guard let iconPath = obj.icon, !iconPath.isEmpty else { return }
                writeKeyValuePair(id: id, dict: &dict, sourceFileName: iconPath.extractFileNameStem())
            case .skillTree:
                guard let iconPath = obj.icon, !iconPath.isEmpty else { return }
                let sourceFileName = iconPath.extractFileNameStem()
                guard sourceFileName.contains("_") else { return }
                writeKeyValuePair(id: id, dict: &dict, sourceFileName: sourceFileName)
            case .lifePath:
                guard id != "Unknown", let newID = obj.firstWordText?.split(separator: " ").last else { return }
                writeKeyValuePair(id: newID.description, dict: &dict, sourceFileName: id.lowercased())
            case .artifact: return
            default:
                writeKeyValuePair(id: id, dict: &dict, sourceFileName: String?.none)
            }
        }
        return dict
    }

    // MARK: Internal

    static let srdBasePath = "https://raw.githubusercontent.com/Dimbreath/StarRailData/master/ExcelOutput/"
    static let srsBasePath = "https://raw.githubusercontent.com/Mar-7th/StarRailRes/master/index_new/en/"
    static let hksResHeader = "https://api.hakush.in/hsr/UI/"
    static let srsResHeader = "https://raw.githubusercontent.com/Mar-7th/StarRailRes/master/"

    // MARK: Private

    private var jsonURLString: String {
        switch self {
        case .profileAvatar: return Self.srsBasePath + "avatars.json"
        case .property: return Self.srsBasePath + "properties.json"
        case .skillTree: return Self.srsBasePath + "character_skill_trees.json"
        case .character: return Self.srdBasePath + "AvatarConfig.json"
        case .element: return Self.srdBasePath + "DamageType.json"
        case .lightCone: return Self.srdBasePath + "EquipmentConfig.json"
        case .lifePath: return Self.srdBasePath + "AvatarBaseType.json"
        case .artifact: return Self.srdBasePath + "RelicDataInfo.json"
        }
    }

    private var sourceURL: URL? {
        URL(string: jsonURLString)
    }

    private func writeKeyValuePair(id: String, dict: inout [String: String], sourceFileName: String? = nil) {
        switch self {
        case .profileAvatar:
            let fileName = sourceFileName ?? "\(id)"
            dict["avatar_\(id).png"] = Self.srsResHeader + "icon/avatar/\(fileName).png"
        case .property:
            let fileName = sourceFileName ?? "\(id)"
            dict["property_\(fileName).png"] = Self.srsResHeader + "icon/property/\(fileName).png"
        case .skillTree:
            let fileName = sourceFileName ?? "\(id)"
            dict["skill_\(fileName).png"] = Self.srsResHeader + "icon/skill/\(fileName).png"
        case .character:
            dict["characters_\(id).webp"] = Self.hksResHeader + "avatarshopicon/\(id).webp"
        case .element:
            dict["element_\(id).webp"] = Self.hksResHeader + "element/\(id.lowercased()).webp"
        case .lightCone:
            dict["light_cone_\(id).webp"] = Self.hksResHeader + "lightconemediumicon/\(id).webp"
        case .lifePath:
            let fileName = sourceFileName ?? "\(id)"
            dict["path_\(id).webp"] = Self.hksResHeader + "pathicon/\(fileName).webp"
        case .artifact:
            let fileName = sourceFileName ?? "\(id)"
            dict["relic_\(id).webp"] = Self.hksResHeader + "relicfigures/\(fileName).webp"
        }
    }
}

// MARK: - Main

let urlDict = try await withThrowingTaskGroup(
    of: [String: String].self, returning: [String: String].self
) { taskGroup in
    DataType.allCases.forEach { currentType in
        taskGroup.addTask { try await currentType.generateLinkDataDict() }
    }

    var newDict = [String: String]()
    for try await result in taskGroup {
        result.forEach { key, value in
            newDict[key] = value
        }
    }
    return newDict
}

// let encoder = JSONEncoder()
// encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
// print(String(data: try! encoder.encode(urlDict), encoding: .utf8)!)

// MARK: - Image Data Download

let dataDict = try await withThrowingTaskGroup(
    of: (String, Data)?.self, returning: [String: Data].self
) { taskGroup in
    urlDict.forEach { fileNameStem, urlString in
        taskGroup.addTask {
            let (data, _) = try await URLSession.shared.data(from: URL(string: urlString)!)
            return (fileNameStem, data)
        }
    }

    var newDict = [String: Data]()
    for try await result in taskGroup {
        guard let result = result else { continue }
        newDict[result.0] = result.1
    }
    return newDict
}

// MARK: - Asset Compilation

let workSpaceDirPath = "./Assets/AssetTemp"

do {
    try? FileManager.default.removeItem(atPath: workSpaceDirPath)
    try FileManager.default.createDirectory(
        atPath: workSpaceDirPath,
        withIntermediateDirectories: true,
        attributes: nil
    )

    for (fileNameStem, rawData) in dataDict {
        try rawData.write(to: URL(fileURLWithPath: workSpaceDirPath + "/\(fileNameStem)"), options: .atomic)
    }

    print("\n// RAW Images Pulled Succesfully.\n")
} catch {
    assertionFailure(error.localizedDescription)
    exit(1)
}
