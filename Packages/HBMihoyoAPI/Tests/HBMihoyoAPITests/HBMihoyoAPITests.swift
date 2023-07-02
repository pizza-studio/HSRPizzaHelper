@testable import HBMihoyoAPI
import XCTest

final class HBMihoyoAPITests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
    }

    func dailyNoteDecodeTest() throws {
        let exampleURL = Bundle.module.url(forResource: "daily_note_example", withExtension: "json")!
        let exampleData = try Data(contentsOf: exampleURL)
        _ = try GeneralDailyNote.decodeFromMiHoYoAPIJSONResult(data: exampleData)
    }
}
