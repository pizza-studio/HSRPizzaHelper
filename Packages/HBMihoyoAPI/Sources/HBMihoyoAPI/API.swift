//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

// MARK: - MiHoYoAPI

/// Abstract class for MiHoYoAPI. Add new features by `extension`ing it.
@available(iOS 15.0, *)
public enum MiHoYoAPI {}

@available(iOS 15.0, *)
extension MiHoYoAPI {
    /// Generate `api-takumi-record.mihoyo.com` / `bbs-api-os.mihoyo.com` request for miHoYo API
    /// - Parameters:
    ///   - httpMethod: http method of request. Default `GET`.
    ///   - region: region of account
    ///   - path: path of api.
    ///   - queryItems: an array of `QueryItem` of request
    ///   - body: `Body` of request.
    ///   - cookie: cookie of request.
    /// - Returns: `URLRequest`
    public static func generateRecordAPIRequest(
        httpMethod: HTTPMethod = .get,
        region: Region,
        path: String,
        queryItems: [URLQueryItem],
        body: Data? = nil,
        cookie: String? = nil,
        additionalHeaders: [String: String]? = nil
    ) async throws
        -> URLRequest {
        try await generateRequest(
            httpMethod: httpMethod,
            region: region,
            host: URLRequestHelperConfiguration.recordURLAPIHost(region: region),
            path: path,
            queryItems: queryItems,
            body: body,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )
    }

    /// Generate `api-takumi.mihoyo.com` / `api-account-os.hoyolab.com` request for miHoYo API
    /// - Parameters:
    ///   - httpMethod: http method of request. Default `GET`.
    ///   - region: region of account
    ///   - path: path of api.
    ///   - queryItems: an array of `QueryItem` of request
    ///   - body: `Body` of request.
    ///   - cookie: cookie of request.
    /// - Returns: `URLRequest`
    public static func generateAccountAPIRequest(
        httpMethod: HTTPMethod = .get,
        region: Region,
        path: String,
        queryItems: [URLQueryItem],
        body: Data? = nil,
        cookie: String? = nil,
        additionalHeaders: [String: String]? = nil
    ) async throws
        -> URLRequest {
        try await generateRequest(
            httpMethod: httpMethod,
            region: region,
            host: URLRequestHelperConfiguration.accountAPIURLHost(region: region),
            path: path,
            queryItems: queryItems,
            body: body,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )
    }

    /// Generate request for miHoYo API
    /// - Parameters:
    ///   - httpMethod: http method of request. Default `GET`.
    ///   - region: region of account
    ///   - host: host of api. If nil, default host will apply.
    ///   - path: path of api.
    ///   - queryItems: an array of `QueryItem` of request
    ///   - body: `Body` of request.
    ///   - cookie: cookie of request.
    /// - Returns: `URLRequest`
    fileprivate static func generateRequest(
        httpMethod: HTTPMethod = .get,
        region: Region,
        host: String,
        path: String,
        queryItems: [URLQueryItem],
        body: Data? = nil,
        cookie: String? = nil,
        additionalHeaders: [String: String]?
    ) async throws
        -> URLRequest {
        var components = URLComponents()

        components.scheme = "https"

        components.host = host

        components.path = path

        components.queryItems = queryItems

        guard let url = components.url else {
            let unknownErrorRetcode = -9999
            throw MiHoYoAPIError(retcode: unknownErrorRetcode, message: "Unknown error. Please contact developer. ")
        }

        var request = URLRequest(url: url)

        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        request.httpMethod = httpMethod.rawValue

        request.allHTTPHeaderFields = try await URLRequestHelperConfiguration.defaultHeaders(
            region: region,
            additionalHeaders: additionalHeaders
        )

        if let cookie = cookie {
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
        }
        request.setValue(
            URLRequestHelper.getDS(region: region, query: url.query ?? "", body: body),
            forHTTPHeaderField: "DS"
        )
        if let body = body {
            request.setValue(
                "\(body.count)",
                forHTTPHeaderField: "Content-Length"
            )
        }

        return request
    }

    public enum HTTPMethod: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
    }
}
