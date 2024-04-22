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

    func testParseGachaURL() throws {
        // swiftlint:disable line_length
        let urlString = """
        https://api-takumi.mihoyo.com/common/gacha_record/api/getGachaLog?authkey_ver=1&sign_type=2&auth_appid=webview_gacha&win_mode=fullscreen&gacha_id=37ebc087b75657573e19622da856f9c29524ae&timestamp=1689725278&region=prod_gf_cn&default_gacha_type=11&lang=zh-cn&authkey=J9D%2B94xa6RoHaedAIkSJg88HDPwH%2B7xJLT7cXFZ8NkhaecKnbLMmEYsO9P328ao8FK5ZgtYAyNdZxYggkhx%2BRDa8y5ObNFN5CxO%2ByM4nyFgbbKfxVRGO4U4nSTkefWRcGV7WwXq%2Frbg6t6msRuDn7ywmGoIN5%2B5TQrr%2FV8GTzor%2BeEpzFtn7%2FldBfnqSNeQqEQM97j8qfny44p1o%2BPUT8oVNOmHE1qLW%2FhbtWOMPD8J2MokYgV%2BM7DUTG7AmM6LQxLaONFJi%2BUmUodMKlP%2BI1w7ThNsfT3pMQlrfolmBBQAL4LOr5Ae2QSHwdq%2FVDsmT2UrjZBFS0fnebeLalR1B6ARjPIy7vIzDfJI6RsVVVHjI8pYuhX%2BWFt4dW%2BXKfjUorrnEYZaCGsR2VhwVD15aGevIUZCxWwQEnlOpG08LOpN90F9UFcBdMIDCTbeUB3MT%2FzyUVbR1uybkzLI73y640U%2BWLPmNbwLCP4c8jTSgXBf7MY%2F1yMWqMACepqfoZXHo52JLAwCDXl8MBYRQezr2%2Fl%2Bpf6Z8NbJn23ARIBTlGN8xmtbCKHSdBDoxBTRDlEG1fKjqbsW3NAsuBK35VeOVjO8goN6iKlyFuSuM1MsLOBM5h3nnaeaQmfE5Q2fHlkx8jg7Ljid%2FeLrXHhuZ7uGifbxkiFEk%2FjxIVW3rQB486GE%3D&game_biz=hkrpg_cn&os_system=iOS%2016.6&device_model=iPhone15%2C2&plat_type=ios&page=1&size=5&gacha_type=11&end_id=0
        """
        // swiftlint:enable line_length
        let basicParam = try parseGachaURL(by: urlString)
        print(basicParam)

        print(
            generateGachaRequest(basicParam: basicParam, page: 1, size: 5, gachaType: .characterEventWarp, endID: "0")
                .url!
        )
    }
}
