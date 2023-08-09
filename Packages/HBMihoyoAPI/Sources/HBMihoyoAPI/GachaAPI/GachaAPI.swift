//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/8/8.
//

import Combine
import Foundation

@available(iOS 15.0, *)
extension MiHoYoAPI {
    func getGachaLog() {}
}

// MARK: - GachaClient

public class GachaClient {
    // MARK: Lifecycle

    public init(gachaURLString: String) throws {
        self.authentication = try parseGachaURL(by: gachaURLString)
    }

    // MARK: Public

    public let publisher: PassthroughSubject<GachaResult, GachaError> = .init()

    public func start() {
        if task == nil {
            task = Task(priority: .high) {
                while case let .currentPagination(pagination) = status {
                    do {
                        let result = try await fetchData(pagination: pagination)
                        publisher.send(result)
                    } catch {
                        status = .finished
                        publisher.send(completion: .failure(GachaError.fetchDataError(
                            page: pagination.page,
                            size: pagination.size,
                            gachaType: pagination.gachaType,
                            error: error
                        )))
                    }
                }
            }
        }
    }

    public func cancel() {
        task?.cancel()
        status = .finished
        publisher.send(completion: .finished)
    }

    // MARK: Private

    private enum Status {
        case finished
        case currentPagination(Pagination)

        // MARK: Internal

        mutating func switchToNextPage(endID: String?) {
            guard case let .currentPagination(pagination) = self else {
                return
            }

            if let endID {
                self =
                    .currentPagination(.init(
                        page: pagination.page + 1,
                        size: pagination.size,
                        endID: endID,
                        gachaType: pagination.gachaType
                    ))
            } else {
                if let nextGachaType = pagination.gachaType.next() {
                    self = .currentPagination(.init(gachaType: nextGachaType))
                } else {
                    self = .finished
                }
            }
        }
    }

    private struct Pagination {
        // MARK: Lifecycle

        init() {
            self.page = 1
            self.size = 20
            self.endID = "0"
            self.gachaType = .allCases.first!
        }

        init(gachaType: GachaType) {
            self.page = 1
            self.size = 20
            self.endID = "0"
            self.gachaType = gachaType
        }

        init(page: Int, size: Int, endID: String, gachaType: GachaType) {
            self.page = page
            self.size = size
            self.endID = endID
            self.gachaType = gachaType
        }

        // MARK: Internal

        var page: Int
        var size: Int
        var endID: String
        var gachaType: GachaType
    }

    private let authentication: GachaRequestAuthentication
    private var status: Status = .currentPagination(.init())
    private var task: Task<(), Never>?

    private func fetchData(pagination: Pagination) async throws -> GachaResult {
        let request = generateGachaRequest(
            basicParam: authentication,
            page: pagination.page,
            size: pagination.size,
            gachaType: pagination.gachaType,
            endID: pagination.endID
        )

        let (data, _) = try await URLSession.shared.data(for: request)

        let result = try GachaResult.decodeFromMiHoYoAPIJSONResult(data: data)

        status.switchToNextPage(endID: result.list.last?.id)

        return result
    }
}

func generateGachaRequest(
    basicParam: GachaRequestAuthentication,
    page: Int,
    size: Int,
    gachaType: GachaType,
    endID: String
)
    -> URLRequest {
    var components = URLComponents()

    components.scheme = "https"

    switch basicParam.server.region {
    case .china:
        components.host = "api-takumi.mihoyo.com"
    case .global:
        components.host = "api-account-os.hoyolab.com"
    }

    components.path = "/common/gacha_record/api/getGachaLog"

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
        .init(name: "game_biz", value: basicParam.server.region.rawValue),
        .init(name: "os_system", value: "iOS 16.6"),
        .init(name: "device_model", value: "iPhone15.2"),
        .init(name: "plat_type", value: "ios"),
        .init(name: "page", value: "\(page)"),
        .init(name: "size", value: "\(size)"),
        .init(name: "gacha_type", value: gachaType.rawValue),
        .init(name: "end_id", value: endID),
    ]
    let urlString = components.url!
        .absoluteString +
        "&authkey=\(basicParam.authenticationKey.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)"
    return URLRequest(url: URL(string: urlString)!)
}

func parseGachaURL(by gachaURLString: String) throws -> GachaRequestAuthentication {
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

    return GachaRequestAuthentication(
        authenticationKey: authenticationKey,
        authenticationKeyVersion: authenticationKeyVersion,
        signType: signType,
        server: server
    )
}

// MARK: - GachaRequestAuthentication

struct GachaRequestAuthentication {
    let authenticationKey: String
    let authenticationKeyVersion: String
    let signType: String
    let server: Server
}

// MARK: - GachaError

public enum GachaError: Error {
    case parseURLError(ParseGachaURLError)
    case fetchDataError(page: Int, size: Int, gachaType: GachaType, error: Error)
}

// MARK: - ParseGachaURLError

public enum ParseGachaURLError: Error {
    case invalidURL
    case noAuthenticationKey
    case noAuthenticationKeyVersion
    case noServer
    case invalidServer
    case noSignType
}

// MARK: - GachaType

public enum GachaType: String, Codable, CaseIterable {
    case regularWarp = "1"
    case characterEventWarp = "11"
    case lightConeEventWarp = "12"

    // MARK: Public

    public func next() -> Self? {
        switch self {
        case .regularWarp:
            return .characterEventWarp
        case .characterEventWarp:
            return .lightConeEventWarp
        case .lightConeEventWarp:
            return nil
        }
    }
}

// MARK: - GachaResult

public struct GachaResult: DecodableFromMiHoYoAPIJSONResult {
    public let page: Int
    public let size: Int
    public let region: Server
    public let regionTimeZone: Int
    public let list: [GachaItem]
}

// MARK: - GachaItem

public struct GachaItem: Codable {
    public enum Rank: String, Codable {
        case three = "3"
        case four = "4"
        case five = "5"
    }

    public enum ItemType: String, Codable {
        case lightCones = "光锥"
        case characters = "角色"
    }

    public let uid: String
    public let time: Date
    public let gachaID: String
    public let gachaType: GachaType
    public let itemID: String
    public let count: Int
    public let name: String
    public let itemType: ItemType
    public let rankType: Rank
    public let id: String
    public let lang: String
}
