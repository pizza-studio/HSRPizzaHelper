import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - URLSessionAsyncErrors

/// Defines the possible errors
public enum URLSessionAsyncErrors: Error {
    case invalidUrlResponse, missingResponseData
}

/// An extension that provides async support for fetching a URL
///
/// Needed because the Linux version of Swift does not support async URLSession yet.
extension URLSession {
    /// A reimplementation of `URLSession.shared.data(from: url)` required for Linux
    ///
    /// - Parameter url: The URL for which to load data.
    /// - Returns: Data and response.
    ///
    /// - Usage:
    ///
    ///     let (data, response) = try await URLSession.shared.asyncData(from: url)
    public func asyncData(from url: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: url) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let response = response as? HTTPURLResponse else {
                    continuation.resume(throwing: URLSessionAsyncErrors.invalidUrlResponse)
                    return
                }
                guard let data = data else {
                    continuation.resume(throwing: URLSessionAsyncErrors.missingResponseData)
                    return
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }
}

// MARK: - GitTag

struct GitTag: Codable {
    let name: String
}

func getLatestTag() async throws -> String? {
    let gitHubAPIURL = URL(string: "https://api.github.com/repos/pizza-studio/GachaMetaGenerator/tags")!
    let (data, _) = try await URLSession.shared.asyncData(from: gitHubAPIURL)
    let json = try JSONDecoder().decode([GitTag].self, from: data)
    return json.first?.name
}

func updateVersionInText(text: String) -> String {
    let lines = text.components(separatedBy: "\n")
    var updatedLines = [String]()

    for line in lines {
        if line.contains("GachaMetaGenerator") {
            let versionRegex = try! NSRegularExpression(pattern: "\\d+\\.\\d+\\.\\d+")
            let versionMatches = versionRegex.matches(in: line, range: NSRange(line.startIndex..., in: line))
            if let versionMatch = versionMatches.first {
                let versionRange = versionMatch.range
                let versionString = (line as NSString).substring(with: versionRange)
                let versionComponents = versionString.components(separatedBy: ".")
                if versionComponents.count == 3 {
                    let major = Int(versionComponents[0])!
                    let minor = Int(versionComponents[1])!
                    var patch = Int(versionComponents[2])!
                    patch += 1
                    let updatedVersionString = "\(major).\(minor).\(patch)"
                    let updatedLine = line.replacingOccurrences(of: versionString, with: updatedVersionString)
                    updatedLines.append(updatedLine)
                } else {
                    updatedLines.append(line)
                }
            } else {
                updatedLines.append(line)
            }
        } else {
            updatedLines.append(line)
        }
    }

    return updatedLines.joined(separator: "\n")
}

let targetFileDir = "./Packages/GachaKitHSR/Package.swift"

var strPkgMetaContent = ""

do {
    strPkgMetaContent += try String(contentsOfFile: targetFileDir, encoding: .utf8)
} catch {
    NSLog(" - Exception happened when reading raw data.")
    exit(1)
}

do {
    guard let newTag = try await getLatestTag() else { exit(0) }
    print("Latest Remote tag is: \(newTag).")
    var lines = strPkgMetaContent.components(separatedBy: .newlines)
    for i in 0 ..< lines.count {
        let currentLine = lines[i]
        guard currentLine.contains("GachaMetaGenerator"), currentLine.contains("from:") else { continue }
        let regex = try Regex("\\d+\\.\\d+\\.\\d+")
        lines[i] = currentLine.replacing(regex, with: newTag)
    }
    strPkgMetaContent = lines.joined(separator: "\n")

} catch {
    NSLog(error.localizedDescription)
    exit(1)
}

do {
    try strPkgMetaContent.write(to: URL(fileURLWithPath: targetFileDir), atomically: false, encoding: .utf8)
    NSLog(" - GachaMetaGenerator 版本資訊更新完成。")
} catch {
    NSLog(" -: Error on writing strings to file: \(error)")
}
