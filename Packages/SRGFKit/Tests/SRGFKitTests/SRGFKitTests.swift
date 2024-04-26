// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

@testable import SRGFKit
import XCTest

private let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Tests" }).joined(
    separator: "/"
).dropFirst()

private let testDataPath: String = packageRootPath + "/Tests/TestData/"

// MARK: - SRGFKitTests

final class SRGFKitTests: XCTestCase {
    func testDecoding() throws {
        let filePath: String = testDataPath + "SRGFv1_Sample.json"
        let url = URL(fileURLWithPath: filePath)
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(SRGFv1.self, from: data)
        XCTAssertEqual(decoded.info.exportApp, "YJSNPI")
        let x = decoded.list.filter {
            $0.gachaType == .characterEventWarp
                && $0.rankType == "5"
                && $0.itemType == .character
        }
        XCTAssertEqual(x.count, 20)
        print(x.compactMap(\.name).joined(separator: "\n"))
        let y = decoded.list.filter {
            $0.gachaType == .lightConeEventWarp
                && $0.rankType == "5"
                && $0.itemType == .lightCone
        }
        XCTAssertEqual(y.count, 1)
        print(y.compactMap(\.name).joined(separator: "\n"))
    }
}
