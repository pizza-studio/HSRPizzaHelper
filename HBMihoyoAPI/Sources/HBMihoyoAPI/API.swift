//
//  File.swift
//  
//
//  Created by 戴藏龙 on 2023/5/2.
//

import Foundation

/// Abstract class for MiHoYoAPI. Add new features by `extension`ing it.
public enum MiHoYoAPI {}

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
    func generateRecordAPIRequest(
        httpMethod: HTTPMethod = .get,
        region: Region,
        path: String,
        queryItems: [URLQueryItem],
        body: Data? = nil,
        cookie: String? = nil
    ) throws -> URLRequest {
        try generateRequest(httpMethod: httpMethod, region: region, host: URLRequestHelperConfiguration.recordURLAPIHost(region: region), path: path, queryItems: queryItems, body: body, cookie: cookie)
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
    func generateAccountAPIRequest(
        httpMethod: HTTPMethod = .get,
        region: Region,
        path: String,
        queryItems: [URLQueryItem],
        body: Data? = nil,
        cookie: String? = nil
    ) throws -> URLRequest {
        try generateRequest(httpMethod: httpMethod, region: region, host: URLRequestHelperConfiguration.accountAPIURLHost(region: region), path: path, queryItems: queryItems, body: body, cookie: cookie)
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
    fileprivate func generateRequest(
        httpMethod: HTTPMethod = .get,
        region: Region,
        host: String,
        path: String,
        queryItems: [URLQueryItem],
        body: Data? = nil,
        cookie: String? = nil
    ) throws -> URLRequest {
        var components = URLComponents()

        components.scheme = "https"

        components.host = host

        components.queryItems = queryItems

        guard let url = components.url else {
            throw MiHoYoAPIError(retcode: -9999, message: "Unknown error. Please contact developer. ")
        }
        var request = URLRequest(url: url)

        request.httpMethod = httpMethod.rawValue

        request.allHTTPHeaderFields = URLRequestHelperConfiguration.defaultHeaders(region: region)

        if let cookie = cookie {
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
        }
        request.setValue(URLRequestHelper.getDS(region: region, queryItems: queryItems, body: body), forHTTPHeaderField: "DS")
        if let body = body {
            request.setValue(
                "\(body.count)",
                forHTTPHeaderField: "Content-Length"
            )
        }

        return request
    }

    enum HTTPMethod: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
    }
}
