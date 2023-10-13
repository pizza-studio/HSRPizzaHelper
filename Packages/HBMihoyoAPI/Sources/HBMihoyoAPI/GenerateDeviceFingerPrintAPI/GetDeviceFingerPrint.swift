//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/6/11.
//

import Foundation
import UIKit

@available(iOS 15.0, *)
extension MiHoYoAPI {
    public static func getDeviceFingerPrint(region: Region) async throws -> String {
        let userDefaults = UserDefaults(suiteName: "group.Canglong.HSRPizzaHelper")!
        if let fingerPrint = userDefaults.string(forKey: "device_finger_print"), fingerPrint != "" {
            return fingerPrint
        }
        func generateSeed() -> String {
            let characters = "0123456789abcdef"
            var result = ""
            for _ in 0 ..< 16 {
                let randomIndex = Int.random(in: 0 ..< characters.count)
                let character = characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
                result.append(character)
            }
            return result
        }

        struct DeviceFingerPrintResult: DecodableFromMiHoYoAPIJSONResult {
            let msg: String
            // swiftlint:disable:next identifier_name
            let device_fp: String
            let code: Int
        }

        let url = URL(string: "https://public-data-api.mihoyo.com/device-fp/api/getFp")!
        #if !os(watchOS)
        let deviceId = await (UIDevice.current.identifierForVendor ?? UUID()).uuidString
        #else
        let deviceId = UUID().uuidString
        #endif
        let body: [String: String] = [
            "seed_id": generateSeed(),
            "device_id": deviceId,
            "platform": "5",
            "seed_time": "\(Int(Date().timeIntervalSince1970) * 1000)",
            // swiftlint:disable line_length
            "ext_fields": """
            {"userAgent":"Mozilla/5.0 (iPhone; CPU iPhone OS 16_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.50.1","browserScreenSize":281520,"maxTouchPoints":5,"isTouchSupported":true,"browserLanguage":"zh-CN","browserPlat":"iPhone","browserTimeZone":"Asia/Shanghai","webGlRender":"Apple GPU","webGlVendor":"Apple Inc.","numOfPlugins":0,"listOfPlugins":"unknown","screenRatio":3,"deviceMemory":"unknown","hardwareConcurrency":"4","cpuClass":"unknown","ifNotTrack":"unknown","ifAdBlock":0,"hasLiedResolution":1,"hasLiedOs":0,"hasLiedBrowser":0}
            """,
            // swiftlint:enable line_length
            "app_name": "account_cn",
            "device_fp": "38d7ee834d1e9",
        ]
        var request = URLRequest(url: url)
        request.httpBody = try JSONEncoder().encode(body)
        request.httpMethod = "POST"
        let (data, _) = try await URLSession.shared.data(for: request)
        let fingerPrint = try DeviceFingerPrintResult.decodeFromMiHoYoAPIJSONResult(data: data)
            .device_fp
        return fingerPrint
    }
}
