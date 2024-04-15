// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

@testable import HBEnkaAPI
import XCTest

private let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Tests" }).joined(
    separator: "/"
).dropFirst()

private let testDataPath: String = packageRootPath + "/Tests/TestData/"

// MARK: - HBEnkaAPITests

final class HBEnkaAPITests: XCTestCase {
    func testDecodingQueriedResults() throws {
        let filePath = testDataPath + "TestQueryResult.json"
        let dataURL = URL(fileURLWithPath: filePath)
        guard let jsonData = try? Data(contentsOf: dataURL) else {
            assertionFailure("!!! Cannot access Enka Query Result JSON data.")
            return
        }
        var uid = "0"
        do {
            let obj = try JSONDecoder().decode(EnkaHSR.QueryRelated.QueriedProfile.self, from: jsonData)
            uid = obj.uid
        } catch {
            assertionFailure(error.localizedDescription)
        }
        XCTAssertEqual(uid, "114514810")
    }
}
