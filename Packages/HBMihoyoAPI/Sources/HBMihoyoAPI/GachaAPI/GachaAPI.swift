//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/8/8.
//

import Foundation

@available(iOS 15.0, *)
extension MiHoYoAPI {
    func getGachaLog() {}
}

private func generateGachaRequest(
    basicParam: GachaRequestBasicParameter,
    page: Int,
    size: Int,
    gachaType: GachaType,
    endID: Int
) throws
    -> URLRequest {
    var components = URLComponents()

    components.scheme = "https"

    switch basicParam.server.region {
    case .china:
        components.host = "api-takumi.mihoyo.com"
    case .global:
        components.host = "api-account-os.hoyolab.com"
    }

    components.path = "common/gacha_record/api/getGachaLog"

    components.queryItems = [
        .init(name: "authkey_ver", value: basicParam.authenticationKeyVersion),
        .init(name: "sign_type", value: basicParam.signType),
        .init(name: "auth_appid", value: "webview_gacha"),
        .init(name: "win_mode", value: "fullscreen"),
        .init(name: "gacha_id", value: "37ebc087b75657573e19622da856f9c29524ae"),
        .init(name: "timestamp", value: "\(Int(Date().timeIntervalSince1970))"),
        .init(name: "region", value: basicParam.server.rawValue),
        .init(name: "default_gacha_type", value: "11"),
        .init(name: "lang", value: "zh-cn"),
        .init(name: "authkey", value: basicParam.authenticationKey),
        .init(name: "game_biz", value: basicParam.server.region.rawValue),
        .init(name: "os_system", value: "iOS 16.6"),
        .init(name: "device_model", value: "iPhone15.2"),
        .init(name: "plat_type", value: "ios"),
        .init(name: "page", value: "\(page)"),
        .init(name: "size", value: "\(size)"),
        .init(name: "gacha_type", value: "\(gachaType.rawValue)"),
        .init(name: "end_id", value: "\(endID)"),
    ]

    return URLRequest(url: URL(string: "")!)
}

private func parseGachaURL(by gachaURLString: String) throws -> GachaRequestBasicParameter {
    guard let url = URL(string: gachaURLString),
          let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
    else { throw ParseGachaURLError.invalidURL }

    let queryItems = components.queryItems
    guard let authenticationKey = queryItems?.first(where: { $0.name == "authkey" })?.value
    else { throw ParseGachaURLError.noAuthenticationKey }
    guard let authenticationKeyVersion = queryItems?.first(where: { $0.name == "authkey_ver" })?.value
    else { throw ParseGachaURLError.noAuthenticationKeyVersion }
    guard let serverRawValue = queryItems?.first(where: { $0.name == "region" })?.value
    else { throw ParseGachaURLError.noServer }
    guard let server = Server(rawValue: serverRawValue) else { throw ParseGachaURLError.invalidServer }
    guard let signType = queryItems?.first(where: { $0.name == "sign_type" })?.value
    else { throw ParseGachaURLError.noSignType }

    return GachaRequestBasicParameter(
        authenticationKey: authenticationKey,
        authenticationKeyVersion: authenticationKeyVersion,
        signType: signType,
        server: server
    )
}

// MARK: - GachaRequestBasicParameter

struct GachaRequestBasicParameter {
    let authenticationKey: String
    let authenticationKeyVersion: String
    let signType: String
    let server: Server
}

// MARK: - GachaError

enum GachaError: Error {
    case parseURLError(ParseGachaURLError)
}

// MARK: - ParseGachaURLError

enum ParseGachaURLError: Error {
    case invalidURL
    case noAuthenticationKey
    case noAuthenticationKeyVersion
    case noServer
    case invalidServer
    case noSignType
}

// MARK: - GachaType

enum GachaType: Int {
    case standard = 11
}
