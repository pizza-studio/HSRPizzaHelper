//
//  RequestRelated.swift
//
//
//  Created by Bill Haku on 2023/3/25.
//

import Foundation

public typealias FetchResult = Result<UserData, FetchError>
public typealias BasicInfoFetchResult = Result<BasicInfos, FetchError>
public typealias CurrentEventsFetchResult = Result<CurrentEvent, FetchError>
public typealias LedgerDataFetchResult = Result<LedgerData, FetchError>
public typealias AllAvatarDetailFetchResult = Result<
    AllAvatarDetailModel,
    FetchError
>

#if !os(watchOS)
//    typealias PlayerDetailsFetchResult = Result<
//        PlayerDetailFetchModel,
//        RequestError
//    >
//    typealias PlayerDetailResult = Result<
//        PlayerDetail,
//        PlayerDetail.PlayerDetailError
//    >
public typealias SpiralAbyssDetailFetchResult = Result<
    SpiralAbyssDetail,
    FetchError
>
#endif

extension FetchResult {
    public static let defaultFetchResult: FetchResult = .success(
        UserData
            .defaultData
    )
}

// MARK: - RequestResult

public struct RequestResult: Codable {
    let data: FetchData?
    let message: String
    let retcode: Int
}

// MARK: - WidgetRequestResult

public struct WidgetRequestResult: Codable {
    let data: WidgetUserData?
    let message: String
    let retcode: Int
}

// MARK: - BasicInfoRequestResult

public struct BasicInfoRequestResult: Codable {
    let data: BasicInfos?
    let message: String
    let retcode: Int
}

// MARK: - LedgerDataRequestResult

public struct LedgerDataRequestResult: Codable {
    let data: LedgerData?
    let message: String
    let retcode: Int
}

// MARK: - AllAvatarDetailRequestDetail

public struct AllAvatarDetailRequestDetail: Codable {
    let data: AllAvatarDetailModel?
    let message: String
    let retcode: Int
}

#if !os(watchOS)
public struct SpiralAbyssDetailRequestResult: Codable {
    let data: SpiralAbyssDetail?
    let message: String
    let retcode: Int
}
#endif

// MARK: - RequestError

public enum RequestError: Error {
    case dataTaskError(String)
    case noResponseData
    case responseError
    case decodeError(String)
    case errorWithCode(Int)
}

// MARK: - ErrorCode

public struct ErrorCode: Codable {
    var code: Int
    var message: String?
}

// MARK: - FetchError

public enum FetchError: Error, Equatable {
    case noFetchInfo

    case cookieInvalid(Int, String) // 10001
    case unmachedAccountCookie(Int, String) // 10103, 10104
    case accountInvalid(Int, String) // 1008
    case dataNotFound(Int, String) // -1, 10102

    case notLoginError(Int, String) // -100

    case decodeError(String)

    case requestError(RequestError)

    case unknownError(Int, String)

    case defaultStatus

    case accountUnbound

    case errorWithCode(Int)

    case accountAbnormal(Int) // 1034

    case noStoken

    // MARK: Public

    public static func == (lhs: FetchError, rhs: FetchError) -> Bool {
        lhs.description == rhs.description && lhs.message == rhs.message
    }
}

// MARK: - PSAServerError

public enum PSAServerError: Error {
    case uploadError(String)
    case getDataError(String)
}

extension FetchError {
    public var description: String {
        switch self {
        case .defaultStatus:
            return "请先刷新以获取树脂状态".localized

        case .noFetchInfo:
            return "请长按小组件选择帐号".localized

        case let .cookieInvalid(retcode, _):
            return String(
                format: NSLocalizedString(
                    "错误码%lld：Cookie失效，请重新登录",
                    comment: "错误码%@：Cookie失效，请重新登录"
                ),
                retcode
            )
        case let .unmachedAccountCookie(retcode, _):
            return String(
                format: NSLocalizedString(
                    "错误码%lld：米游社帐号与UID不匹配，请手动输入UID",
                    comment: "错误码%@：米游社帐号与UID不匹配"
                ),
                retcode
            )
        case let .accountInvalid(retcode, _):
            return String(
                format: NSLocalizedString(
                    "错误码%lld：UID有误",
                    comment: "错误码%@：UID有误"
                ),
                retcode
            )
        case .dataNotFound:
            return "请前往米游社（或Hoyolab）打开旅行便笺功能".localized
        case .decodeError:
            return "解码错误：请检查网络环境".localized
        case .requestError:
            return "网络错误".localized
        case .notLoginError:
            return "未获取到登录信息，请重试".localized
        case let .unknownError(retcode, _):
            return String(
                format: NSLocalizedString("未知错误码：%lld", comment: "未知错误码：%lld"),
                retcode
            )
        case .accountAbnormal:
            return "（1034）帐号状态异常，建议降低小组件同步频率，或长按小组件开启简洁模式".localized
        case .noStoken:
            return "请重新登录本帐号以获取stoken".localized
        default:
            return ""
        }
    }

    public var message: String {
        switch self {
        case .defaultStatus:
            return ""

        case .noFetchInfo:
            return ""
        case let .notLoginError(retcode, message):
            return "(\(retcode))" + message
        case .cookieInvalid:
            return ""
        case let .unmachedAccountCookie(_, message):
            return message
        case let .accountInvalid(_, message):
            return message
        case let .dataNotFound(retcode, message):
            return "(\(retcode))" + message
        case let .decodeError(message):
            return message
        case let .requestError(requestError):
            switch requestError {
            case let .dataTaskError(message):
                return "\(message)"
            case .noResponseData:
                return "无返回数据".localized
            case .responseError:
                return "无响应".localized
            default:
                return "未知错误".localized
            }
        case .accountAbnormal:
            return "（1034）帐号状态异常，请前往「米游社」App-「我的」-「我的角色」进行验证".localized
        case let .unknownError(_, message):
            return message
        case .noStoken:
            return "请重新登录本帐号以获取stoken".localized
        default:
            return ""
        }
    }
}

// MARK: - MultiTokenResult

public struct MultiTokenResult: Codable {
    public let retcode: Int
    public let message: String
    public let data: MultiToken?
}

// MARK: - MultiToken

public struct MultiToken: Codable {
    public struct Item: Codable {
        public let name: String
        public let token: String
    }

    public var list: [Item]

    public var stoken: String {
        list.first { item in
            item.name == "stoken"
        }?.token ?? ""
    }

    public var ltoken: String {
        list.first { item in
            item.name == "ltoken"
        }?.token ?? ""
    }
}

// MARK: - RequestAccountListResult

public struct RequestAccountListResult: Codable {
    public let retcode: Int
    public let message: String
    public let data: AccountListData?
}

// MARK: - AccountListData

public struct AccountListData: Codable {
    public let list: [FetchedAccount]
}

// MARK: - FetchedAccount

public struct FetchedAccount: Codable, Hashable, Identifiable {
    public let region: String
    public let gameBiz: String
    public let nickname: String
    public let level: Int
    public let isOfficial: Bool
    public let regionName: String
    public let gameUid: String
    public let isChosen: Bool

    public var id: String { gameUid }
}
