#!/usr/bin/env swift

import Foundation

let workSpaceDirPath = "./Packages/EnkaKitHSR/Sources/EnkaKitHSR/Resources/Assets.xcassets/MetaAssets"

// MARK: JSON 档案范本内容。

let folderJSONContents = #"""
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}

"""#

let sampleJSONForFile = #"""
{
  "images" : [
    {
      "filename" : "FILENAMEPLACEHOLDER",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}

"""#

func generateJSON(fileName: String? = nil) -> String {
    guard let fileName = fileName, !fileName.isEmpty else {
        return folderJSONContents
    }
    return sampleJSONForFile.replacingOccurrences(of: "FILENAMEPLACEHOLDER", with: fileName)
}

// swiftlint:disable:next large_tuple
func generateNewPath(newFileName: String) -> (filePath: String, jsonPath: String, setPath: String) {
    let newFileNameStem = newFileName.split(separator: ".").dropLast().joined(separator: ".")
    let setPath = "\(workSpaceDirPath)/\(newFileNameStem).imageset"
    let filePath = "\(setPath)/\(newFileName)"
    let jsonPath = "\(setPath)/Contents.json"
    return (filePath, jsonPath, setPath)
}

// MARK: - AssetFile

struct AssetFile: Codable, CustomStringConvertible {
    // MARK: Lifecycle

    public init(oldPath: String) {
        self.oldPath = oldPath
        let oldPathCells = oldPath.split(separator: "/").split(separator: #"\"#).reduce([], +).map(\.description)
        let newFileName = oldPathCells.suffix(1).joined(separator: "_")
        self.fileName = newFileName
        let newPaths = generateNewPath(newFileName: newFileName)
        self.newPath = newPaths.filePath
        self.setPath = newPaths.setPath
        self.jsonPath = newPaths.jsonPath
        self.jsonText = generateJSON(fileName: fileName)
        print(description)
    }

    // MARK: Internal

    let oldPath: String
    let newPath: String
    let fileName: String
    let jsonText: String
    let jsonPath: String
    let setPath: String

    var description: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
        // swiftlint:disable:next force_try
        let data = try! encoder.encode(self)
        return String(data: data, encoding: .utf8)!
    }

    func deploy() throws {
        try FileManager.default.createDirectory(atPath: setPath, withIntermediateDirectories: true)
        try FileManager.default.moveItem(atPath: oldPath, toPath: newPath)
        try jsonText.write(to: URL(fileURLWithPath: jsonPath), atomically: true, encoding: .utf8)
    }
}

// MARK: - 初始化新的工作资料夹。

func initNewWorkspace() {
    do {
        try? FileManager.default.removeItem(atPath: workSpaceDirPath)
        try FileManager.default.createDirectory(
            atPath: workSpaceDirPath,
            withIntermediateDirectories: true,
            attributes: nil
        )
        let contentsJSONURL = URL(fileURLWithPath: workSpaceDirPath + "/Contents.json")
        try folderJSONContents.write(to: contentsJSONURL, atomically: true, encoding: .utf8)
    } catch {
        assertionFailure(error.localizedDescription)
    }
}

func cleanWorkspace() {
    do {
        try FileManager.default.removeItem(atPath: "./Assets/AssetTemp")
    } catch {
        assertionFailure(error.localizedDescription)
    }
}

// MARK: - 列出所有要弄的档案。

func handleAllFiles() {
    let fileMgr = FileManager.default
    let allPaths: [String] = (fileMgr.subpaths(atPath: "./Assets/") ?? []).filter {
        $0.contains("AssetTemp") && $0.suffix(5).lowercased() == ".heic"
    }
    let assets: [AssetFile] = allPaths.map { AssetFile(oldPath: "./Assets/" + $0) }
    assets.forEach {
        do {
            try $0.deploy()
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}

initNewWorkspace()
handleAllFiles()
cleanWorkspace()
