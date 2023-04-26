//
//  HTTPMethod.swift
//
//
//  Created by Bill Haku on 2023/3/25.
//  HTTP请求方法

import Foundation

// MARK: - Method

enum Method {
    case post
    case get
    case put
}

// MARK: - HttpMethod

@available(iOS 13, watchOS 6, *)
struct HttpMethod<T: Codable> {
    /// 综合的http 各种方法接口
    /// - Parameters:
    ///   - method:Method, http方法的类型
    ///   - urlStr:String，url的字符串后缀，即request的类型
    ///   - region:Region，请求的服务器地区类型
    ///   - serverID: String，服务器ID
    ///   - uid: String, UID
    ///   - cookie: String， 用户Cookie
    ///   - completion:异步返回处理好的data以及报错的类型
    static func commonRequest(
        _ method: Method,
        _ urlStr: String,
        _ region: Region,
        _ serverID: String,
        _ uid: String,
        _ cookie: String,
        completion: @escaping (
            (Result<T, RequestError>) -> ()
        )
    ) {
        let networkReachability = NetworkReachability()

        func getSessionConfiguration() -> URLSessionConfiguration {
            let sessionConfiguration = URLSessionConfiguration.default

            let sessionUseProxy =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .bool(forKey: "useProxy")
            let sessionProxyHost =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyHost")
            let sessionProxyPort =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyPort")
            let sessionProxyUserName =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyUserName")
            let sessionProxyPassword =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyUserPassword")
            if sessionUseProxy {
                guard let sessionProxyHost = sessionProxyHost else {
                    print("Proxy host error")
                    return sessionConfiguration
                }
                guard let sessionProxyPort = Int(sessionProxyPort ?? "0") else {
                    print("Proxy port error")
                    return sessionConfiguration
                }

                if sessionProxyUserName != nil, sessionProxyUserName != "",
                   sessionProxyPassword != nil, sessionProxyPassword != "" {
                    print("Proxy add authorization")
                    let userPasswordString =
                        "\(String(describing: sessionProxyUserName)):\(String(describing: sessionProxyPassword))"
                    let userPasswordData = userPasswordString
                        .data(using: String.Encoding.utf8)
                    let base64EncodedCredential = userPasswordData!
                        .base64EncodedString(
                            options: Data
                                .Base64EncodingOptions(rawValue: 0)
                        )
                    let authString = "Basic \(base64EncodedCredential)"
                    sessionConfiguration
                        .httpAdditionalHeaders =
                        ["Proxy-Authorization": authString]
                    sessionConfiguration
                        .httpAdditionalHeaders = ["Authorization": authString]
                }

                print("Use Proxy \(sessionProxyHost):\(sessionProxyPort)")

                #if !os(watchOS)
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPEnable as String
                    ] =
                    true
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPProxy as String
                    ] =
                    sessionProxyHost
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPPort as String
                    ] =
                    sessionProxyPort
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFProxyTypeHTTP as String
                    ] =
                    "\(sessionProxyHost):\(sessionProxyPort)"
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFProxyTypeHTTPS as String
                    ] =
                    "\(sessionProxyHost):\(sessionProxyPort)"
                #endif
            } else {
                print("No Proxy")
            }
            return sessionConfiguration
        }

        func get_ds_token(uid: String, server_id: String) -> String {
            let s: String
            switch region {
            case .cn:
                s = "xV8v4Qu54lUKrEYFZkJhB8cuOh9Asafs"
            case .global:
                s = "okr4obncj8bw5a65hbnn5oo6ixjc3l9w"
            }
            let t = String(Int(Date().timeIntervalSince1970))
            let r = String(Int.random(in: 100000 ..< 200000))
            let q = "role_id=\(uid)&server=\(server_id)"
            let c = "salt=\(s)&t=\(t)&r=\(r)&b=&q=\(q)".md5
            return t + "," + r + "," + c
        }

        if networkReachability.reachable {
            DispatchQueue.global(qos: .userInteractive).async {
                // 请求url前缀，后跟request的类型
                let baseStr: String
                let appVersion: String
                let userAgent: String
                let clientType: String
                switch region {
                case .cn:
                    baseStr = "https://api-takumi-record.mihoyo.com/"
                    appVersion = "2.40.1"
                    userAgent =
                        "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.40.1"
                    clientType = "5"
                case .global:
                    baseStr = "https://bbs-api-os.hoyolab.com/"
                    appVersion = "2.9.1"
                    userAgent =
                        "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.9.1"
                    clientType = "2"
                }
                // 由前缀和后缀共同组成的url
                var url = URLComponents(string: baseStr + urlStr)!
                url.queryItems = [
                    URLQueryItem(name: "server", value: serverID),
                    URLQueryItem(name: "role_id", value: uid),
                ]
                // 初始化请求
                var request = URLRequest(url: url.url!)
                // 设置请求头
                request.allHTTPHeaderFields = [
                    "DS": get_ds_token(uid: uid, server_id: serverID),
                    "x-rpc-app_version": appVersion,
                    "User-Agent": userAgent,
                    "x-rpc-client_type": clientType,
                    "Referer": "https://webstatic.mihoyo.com/",
                    "Cookie": cookie,
                ]
                // http方法
                switch method {
                case .post:
                    request.httpMethod = "POST"
                case .get:
                    request.httpMethod = "GET"
                case .put:
                    request.httpMethod = "PUT"
                }
                // 开始请求
                let session =
                    URLSession(configuration: getSessionConfiguration())
                session.dataTask(
                    with: request
                ) { data, response, error in
                    // 判断有没有错误（这里无论如何都不会抛因为是自己手动返回错误信息的）
                    print(error ?? "ErrorInfo nil")
                    if let error = error {
                        completion(.failure(.dataTaskError(
                            error
                                .localizedDescription
                        )))
                        print(
                            "DataTask error in General HttpMethod: " +
                                error.localizedDescription + "\n"
                        )
                    } else {
                        guard let data = data else {
                            completion(.failure(.noResponseData))
                            print("found response data nil")
                            return
                        }
                        guard response is HTTPURLResponse else {
                            completion(.failure(.responseError))
                            print("response error")
                            return
                        }
                        DispatchQueue.main.async {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase

//                            let dictionary = try? JSONSerialization.jsonObject(with: data)
//                            print(dictionary ?? "None")

                            do {
                                let requestResult = try decoder.decode(
                                    T.self,
                                    from: data
                                )
                                completion(.success(requestResult))
                            } catch {
                                print(error)
                                completion(.failure(.decodeError(
                                    error
                                        .localizedDescription
                                )))
                            }
                        }
                    }
                }.resume()
            }
        }
    }

    /// 综合的http 各种方法接口
    /// - Parameters:
    ///   - method:Method, http方法的类型
    ///   - urlStr:String，url的字符串后缀，即request的类型
    ///   - region:Region，请求的服务器地区类型
    ///   - serverID: String，服务器ID
    ///   - uid: String, UID
    ///   - cookie: String， 用户Cookie
    ///   - completion:异步返回处理好的data以及报错的类型
    static func commonWidgetRequest(
        _ method: Method,
        _ urlStr: String,
        _ cookie: String,
        completion: @escaping (
            (Result<T, RequestError>) -> ()
        )
    ) {
        let networkReachability = NetworkReachability()

        func getSessionConfiguration() -> URLSessionConfiguration {
            let sessionConfiguration = URLSessionConfiguration.default

            let sessionUseProxy =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .bool(forKey: "useProxy")
            let sessionProxyHost =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyHost")
            let sessionProxyPort =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyPort")
            let sessionProxyUserName =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyUserName")
            let sessionProxyPassword =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyUserPassword")
            if sessionUseProxy {
                guard let sessionProxyHost = sessionProxyHost else {
                    print("Proxy host error")
                    return sessionConfiguration
                }
                guard let sessionProxyPort = Int(sessionProxyPort ?? "0") else {
                    print("Proxy port error")
                    return sessionConfiguration
                }

                if sessionProxyUserName != nil, sessionProxyUserName != "",
                   sessionProxyPassword != nil, sessionProxyPassword != "" {
                    print("Proxy add authorization")
                    let userPasswordString =
                        "\(String(describing: sessionProxyUserName)):\(String(describing: sessionProxyPassword))"
                    let userPasswordData = userPasswordString
                        .data(using: String.Encoding.utf8)
                    let base64EncodedCredential = userPasswordData!
                        .base64EncodedString(
                            options: Data
                                .Base64EncodingOptions(rawValue: 0)
                        )
                    let authString = "Basic \(base64EncodedCredential)"
                    sessionConfiguration
                        .httpAdditionalHeaders =
                        ["Proxy-Authorization": authString]
                    sessionConfiguration
                        .httpAdditionalHeaders = ["Authorization": authString]
                }

                print("Use Proxy \(sessionProxyHost):\(sessionProxyPort)")

                #if !os(watchOS)
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPEnable as String
                    ] =
                    true
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPProxy as String
                    ] =
                    sessionProxyHost
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPPort as String
                    ] =
                    sessionProxyPort
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFProxyTypeHTTP as String
                    ] =
                    "\(sessionProxyHost):\(sessionProxyPort)"
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFProxyTypeHTTPS as String
                    ] =
                    "\(sessionProxyHost):\(sessionProxyPort)"
                #endif
            } else {
                print("No Proxy")
            }
            return sessionConfiguration
        }

        func get_ds_token() -> String {
            let s = "t0qEgfub6cvueAPgR5m9aQWWVciEer7v"
            let t = String(Int(Date().timeIntervalSince1970))
            let r = String(Int.random(in: 100000 ..< 200000))
            let q = "game_id=2"
            let c = "salt=\(s)&t=\(t)&r=\(r)&b=&q=\(q)".md5
            return t + "," + r + "," + c
        }

        if networkReachability.reachable {
            DispatchQueue.global(qos: .userInteractive).async {
                // 请求url前缀，后跟request的类型
                let baseStr: String = "https://api-takumi-record.mihoyo.com/"
                let appVersion: String = "2.34.1"
                let userAgent: String =
                    "WidgetExtension/264 CFNetwork/1399 Darwin/22.1.0"
                let clientType: String = "2"
//                switch region {
//                case .cn:
//                    baseStr = "https://api-takumi-record.mihoyo.com/"
//                    appVersion = "2.34.1"
//                    userAgent = "WidgetExtension/264 CFNetwork/1399 Darwin/22.1.0"
//                    clientType = "2"
//                case .global:
//                    baseStr = "https://bbs-api-os.hoyolab.com/"
//                    appVersion = "2.9.1"
//                    userAgent = "WidgetExtension/264 CFNetwork/1399 Darwin/22.1.0"
//                    clientType = "2"
//                }
                // 由前缀和后缀共同组成的url
                var url = URLComponents(string: baseStr + urlStr)!
                url.queryItems = [
                    URLQueryItem(name: "game_id", value: "2"),
                ]
                // 初始化请求
                var request = URLRequest(url: url.url!)
                // 设置请求头
                request.allHTTPHeaderFields = [
                    "DS": get_ds_token(),
                    "x-rpc-app_version": appVersion,
                    "User-Agent": userAgent,
                    "x-rpc-client_type": clientType,
                    "Referer": "https://app.mihoyo.com/",
                    "Cookie": cookie,
                    "x-rpc-device_id": "",
                    "x-rpc-channel": "appstore",
                ]
                // http方法
                switch method {
                case .post:
                    request.httpMethod = "POST"
                case .get:
                    request.httpMethod = "GET"
                case .put:
                    request.httpMethod = "PUT"
                }
                // 开始请求
                let session =
                    URLSession(configuration: getSessionConfiguration())
                session.dataTask(
                    with: request
                ) { data, response, error in
                    // 判断有没有错误（这里无论如何都不会抛因为是自己手动返回错误信息的）
                    print(error ?? "ErrorInfo nil")
                    if let error = error {
                        completion(.failure(.dataTaskError(
                            error
                                .localizedDescription
                        )))
                        print(
                            "DataTask error in General HttpMethod: " +
                                error.localizedDescription + "\n"
                        )
                    } else {
                        guard let data = data else {
                            completion(.failure(.noResponseData))
                            print("found response data nil")
                            return
                        }
                        guard response is HTTPURLResponse else {
                            completion(.failure(.responseError))
                            print("response error")
                            return
                        }
                        DispatchQueue.main.async {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase

                            let dictionary = try? JSONSerialization
                                .jsonObject(with: data)
                            print(dictionary ?? "None")

                            do {
                                let requestResult = try decoder.decode(
                                    T.self,
                                    from: data
                                )
                                completion(.success(requestResult))
                            } catch {
                                print(error)
                                completion(.failure(.decodeError(
                                    error
                                        .localizedDescription
                                )))
                            }
                        }
                    }
                }.resume()
            }
        }
    }

    /// 返回ltoken和stoken
    /// - Parameters:
    ///   - login
    ///   - completion:异步返回处理好的data以及报错的类型
    static func commonGetToken(
        _ method: Method,
        urlStr: String,
        loginTicket: String,
        loginUid: String,
        completion: @escaping (
            (Result<T, RequestError>) -> ()
        )
    ) {
        let networkReachability = NetworkReachability()

        func getSessionConfiguration() -> URLSessionConfiguration {
            let sessionConfiguration = URLSessionConfiguration.default

            let sessionUseProxy =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .bool(forKey: "useProxy")
            let sessionProxyHost =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyHost")
            let sessionProxyPort =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyPort")
            let sessionProxyUserName =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyUserName")
            let sessionProxyPassword =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyUserPassword")
            if sessionUseProxy {
                guard let sessionProxyHost = sessionProxyHost else {
                    print("Proxy host error")
                    return sessionConfiguration
                }
                guard let sessionProxyPort = Int(sessionProxyPort ?? "0") else {
                    print("Proxy port error")
                    return sessionConfiguration
                }

                if sessionProxyUserName != nil, sessionProxyUserName != "",
                   sessionProxyPassword != nil, sessionProxyPassword != "" {
                    print("Proxy add authorization")
                    let userPasswordString =
                        "\(String(describing: sessionProxyUserName)):\(String(describing: sessionProxyPassword))"
                    let userPasswordData = userPasswordString
                        .data(using: String.Encoding.utf8)
                    let base64EncodedCredential = userPasswordData!
                        .base64EncodedString(
                            options: Data
                                .Base64EncodingOptions(rawValue: 0)
                        )
                    let authString = "Basic \(base64EncodedCredential)"
                    sessionConfiguration
                        .httpAdditionalHeaders =
                        ["Proxy-Authorization": authString]
                    sessionConfiguration
                        .httpAdditionalHeaders = ["Authorization": authString]
                }

                print("Use Proxy \(sessionProxyHost):\(sessionProxyPort)")

                #if !os(watchOS)
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPEnable as String
                    ] =
                    true
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPProxy as String
                    ] =
                    sessionProxyHost
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPPort as String
                    ] =
                    sessionProxyPort
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFProxyTypeHTTP as String
                    ] =
                    "\(sessionProxyHost):\(sessionProxyPort)"
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFProxyTypeHTTPS as String
                    ] =
                    "\(sessionProxyHost):\(sessionProxyPort)"
                #endif
            } else {
                print("No Proxy")
            }
            return sessionConfiguration
        }

        if networkReachability.reachable {
            DispatchQueue.global(qos: .userInteractive).async {
                // 请求url前缀，后跟request的类型
                let baseStr: String = "https://api-takumi.mihoyo.com/"
//                switch region {
//                case .cn:
//                    baseStr = "https://api-takumi-record.mihoyo.com/"
//                    appVersion = "2.34.1"
//                    userAgent = "WidgetExtension/264 CFNetwork/1399 Darwin/22.1.0"
//                    clientType = "2"
//                case .global:
//                    baseStr = "https://bbs-api-os.hoyolab.com/"
//                    appVersion = "2.9.1"
//                    userAgent = "WidgetExtension/264 CFNetwork/1399 Darwin/22.1.0"
//                    clientType = "2"
//                }
                // 由前缀和后缀共同组成的url
                var url = URLComponents(string: baseStr + urlStr)!
                url.queryItems = [
                    URLQueryItem(name: "login_ticket", value: loginTicket),
                    URLQueryItem(name: "token_types", value: "3"),
                    URLQueryItem(name: "uid", value: loginUid),
                ]
                var request = URLRequest(url: url.url!)
                // http方法
                switch method {
                case .post:
                    request.httpMethod = "POST"
                case .get:
                    request.httpMethod = "GET"
                case .put:
                    request.httpMethod = "PUT"
                }
                // 开始请求
                let session =
                    URLSession(configuration: getSessionConfiguration())
                session.dataTask(
                    with: request
                ) { data, response, error in
                    // 判断有没有错误（这里无论如何都不会抛因为是自己手动返回错误信息的）
                    print(error ?? "ErrorInfo nil")
                    if let error = error {
                        completion(.failure(.dataTaskError(
                            error
                                .localizedDescription
                        )))
                        print(
                            "DataTask error in General HttpMethod: " +
                                error.localizedDescription + "\n"
                        )
                    } else {
                        guard let data = data else {
                            completion(.failure(.noResponseData))
                            print("found response data nil")
                            return
                        }
                        guard response is HTTPURLResponse else {
                            completion(.failure(.responseError))
                            print("response error")
                            return
                        }
                        DispatchQueue.main.async {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase

                            let dictionary = try? JSONSerialization
                                .jsonObject(with: data)
                            print(dictionary ?? "None")

                            do {
                                let requestResult = try decoder.decode(
                                    T.self,
                                    from: data
                                )
                                completion(.success(requestResult))
                            } catch {
                                print(error)
                                completion(.failure(.decodeError(
                                    error
                                        .localizedDescription
                                )))
                            }
                        }
                    }
                }.resume()
            }
        }
    }

    /// 综合的http 各种方法接口
    /// - Parameters:
    ///   - method:Method, http方法的类型
    ///   - urlStr:String，url的字符串后缀，即request的类型
    ///   - region:Region，请求的服务器地区类型
    ///   - serverID: String，服务器ID
    ///   - uid: String, UID
    ///   - cookie: String， 用户Cookie
    ///   - completion:异步返回处理好的data以及报错的类型
    static func spiralAbyssRequest(
        _ method: Method,
        _ urlStr: String,
        _ region: Region,
        _ serverID: String,
        _ uid: String,
        _ cookie: String,
        _ scheduleType: String,
        completion: @escaping (
            (Result<T, RequestError>) -> ()
        )
    ) {
        let networkReachability = NetworkReachability()

        func getSessionConfiguration() -> URLSessionConfiguration {
            let sessionConfiguration = URLSessionConfiguration.default

            let sessionUseProxy =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .bool(forKey: "useProxy")
            let sessionProxyHost =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyHost")
            let sessionProxyPort =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyPort")
            let sessionProxyUserName =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyUserName")
            let sessionProxyPassword =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyUserPassword")
            if sessionUseProxy {
                guard let sessionProxyHost = sessionProxyHost else {
                    print("Proxy host error")
                    return sessionConfiguration
                }
                guard let sessionProxyPort = Int(sessionProxyPort ?? "0") else {
                    print("Proxy port error")
                    return sessionConfiguration
                }

                if sessionProxyUserName != nil, sessionProxyUserName != "",
                   sessionProxyPassword != nil, sessionProxyPassword != "" {
                    print("Proxy add authorization")
                    let userPasswordString =
                        "\(String(describing: sessionProxyUserName)):\(String(describing: sessionProxyPassword))"
                    let userPasswordData = userPasswordString
                        .data(using: String.Encoding.utf8)
                    let base64EncodedCredential = userPasswordData!
                        .base64EncodedString(
                            options: Data
                                .Base64EncodingOptions(rawValue: 0)
                        )
                    let authString = "Basic \(base64EncodedCredential)"
                    sessionConfiguration
                        .httpAdditionalHeaders =
                        ["Proxy-Authorization": authString]
                    sessionConfiguration
                        .httpAdditionalHeaders = ["Authorization": authString]
                }

                print("Use Proxy \(sessionProxyHost):\(sessionProxyPort)")

                #if !os(watchOS)
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPEnable as String
                    ] =
                    true
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPProxy as String
                    ] =
                    sessionProxyHost
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPPort as String
                    ] =
                    sessionProxyPort
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFProxyTypeHTTP as String
                    ] =
                    "\(sessionProxyHost):\(sessionProxyPort)"
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFProxyTypeHTTPS as String
                    ] =
                    "\(sessionProxyHost):\(sessionProxyPort)"
                #endif
            } else {
                print("No Proxy")
            }
            return sessionConfiguration
        }

        func get_ds_token(
            scheduleType: String,
            uid: String,
            server_id: String
        )
            -> String {
            let s: String
            switch region {
            case .cn:
                s = "xV8v4Qu54lUKrEYFZkJhB8cuOh9Asafs"
            case .global:
                s = "okr4obncj8bw5a65hbnn5oo6ixjc3l9w"
            }
            let t = String(Int(Date().timeIntervalSince1970))
            let r = String(Int.random(in: 100000 ..< 200000))
            let q =
                "role_id=\(uid)&schedule_type=\(scheduleType)&server=\(server_id)"
            let c = "salt=\(s)&t=\(t)&r=\(r)&b=&q=\(q)".md5
            return t + "," + r + "," + c
        }

        if networkReachability.reachable {
            DispatchQueue.global(qos: .userInteractive).async {
                // 请求url前缀，后跟request的类型
                let baseStr: String
                let appVersion: String
                let userAgent: String
                let clientType: String
                switch region {
                case .cn:
                    baseStr = "https://api-takumi-record.mihoyo.com/"
                    appVersion = "2.36.1"
                    userAgent =
                        "Mozilla/5.0 (iPhone; CPU iPhone OS 15_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.36.1"
                    clientType = "5"
                case .global:
                    baseStr = "https://bbs-api-os.hoyolab.com/"
                    appVersion = "2.9.1"
                    userAgent =
                        "Mozilla/5.0 (iPhone; CPU iPhone OS 15_6_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.9.1"
                    clientType = "2"
                }
                // 由前缀和后缀共同组成的url
                var url = URLComponents(string: baseStr + urlStr)!
                url.queryItems = [
                    URLQueryItem(name: "schedule_type", value: scheduleType),
                    URLQueryItem(name: "server", value: serverID),
                    URLQueryItem(name: "role_id", value: uid),
                ]
                // 初始化请求
                var request = URLRequest(url: url.url!)
                print(url.url!)
                print(cookie)
                let dsToken = get_ds_token(
                    scheduleType: scheduleType,
                    uid: uid,
                    server_id: serverID
                )
                print(dsToken)
                // 设置请求头
                request.allHTTPHeaderFields = [
                    "DS": dsToken,
                    "x-rpc-app_version": appVersion,
                    "User-Agent": userAgent,
                    "x-rpc-client_type": clientType,
                    "Referer": "https://webstatic.mihoyo.com/",
                    "Cookie": cookie,
                ]
                // http方法
                switch method {
                case .post:
                    request.httpMethod = "POST"
                case .get:
                    request.httpMethod = "GET"
                case .put:
                    request.httpMethod = "PUT"
                }
                // 开始请求
                let session =
                    URLSession(configuration: getSessionConfiguration())
                session.dataTask(
                    with: request
                ) { data, response, error in
                    // 判断有没有错误（这里无论如何都不会抛因为是自己手动返回错误信息的）
                    print(error ?? "ErrorInfo nil")
                    if let error = error {
                        completion(.failure(.dataTaskError(
                            error
                                .localizedDescription
                        )))
                        print(
                            "DataTask error in General HttpMethod: " +
                                error.localizedDescription + "\n"
                        )
                    } else {
                        guard let data = data else {
                            completion(.failure(.noResponseData))
                            print("found response data nil")
                            return
                        }
                        guard response is HTTPURLResponse else {
                            completion(.failure(.responseError))
                            print("response error")
                            return
                        }
                        DispatchQueue.main.async {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase

//                            let dictionary = try? JSONSerialization.jsonObject(with: data)
//                            print(dictionary ?? "None")

                            do {
                                let requestResult = try decoder.decode(
                                    T.self,
                                    from: data
                                )
                                completion(.success(requestResult))
                            } catch {
                                print(error)
                                completion(.failure(.decodeError(
                                    error
                                        .localizedDescription
                                )))
                            }
                        }
                    }
                }.resume()
            }
        }
    }

    /// 返回游戏帐号基本信息
    /// - Parameters:
    ///   - method:Method, http方法的类型
    ///   - urlStr:String，url的字符串后缀，即request的类型
    ///   - region:Region，请求的服务器地区类型
    ///   - serverID: String，服务器ID
    ///   - uid: String, UID
    ///   - cookie: String， 用户Cookie
    ///   - completion:异步返回处理好的data以及报错的类型
    static func basicInfoRequest(
        _ method: Method,
        _ urlStr: String,
        _ region: Region,
        _ serverID: String,
        _ uid: String,
        _ cookie: String,
        completion: @escaping (
            (Result<T, RequestError>) -> ()
        )
    ) {
        let networkReachability = NetworkReachability()

        func getSessionConfiguration() -> URLSessionConfiguration {
            let sessionConfiguration = URLSessionConfiguration.default

            let sessionUseProxy =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .bool(forKey: "useProxy")
            let sessionProxyHost =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyHost")
            let sessionProxyPort =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyPort")
            let sessionProxyUserName =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyUserName")
            let sessionProxyPassword =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyUserPassword")
            if sessionUseProxy {
                guard let sessionProxyHost = sessionProxyHost else {
                    print("Proxy host error")
                    return sessionConfiguration
                }
                guard let sessionProxyPort = Int(sessionProxyPort ?? "0") else {
                    print("Proxy port error")
                    return sessionConfiguration
                }

                if sessionProxyUserName != nil, sessionProxyUserName != "",
                   sessionProxyPassword != nil, sessionProxyPassword != "" {
                    print("Proxy add authorization")
                    let userPasswordString =
                        "\(String(describing: sessionProxyUserName)):\(String(describing: sessionProxyPassword))"
                    let userPasswordData = userPasswordString
                        .data(using: String.Encoding.utf8)
                    let base64EncodedCredential = userPasswordData!
                        .base64EncodedString(
                            options: Data
                                .Base64EncodingOptions(rawValue: 0)
                        )
                    let authString = "Basic \(base64EncodedCredential)"
                    sessionConfiguration
                        .httpAdditionalHeaders =
                        ["Proxy-Authorization": authString]
                    sessionConfiguration
                        .httpAdditionalHeaders = ["Authorization": authString]
                }

                print("Use Proxy \(sessionProxyHost):\(sessionProxyPort)")

                #if !os(watchOS)
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPEnable as String
                    ] =
                    true
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPProxy as String
                    ] =
                    sessionProxyHost
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPPort as String
                    ] =
                    sessionProxyPort
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFProxyTypeHTTP as String
                    ] =
                    "\(sessionProxyHost):\(sessionProxyPort)"
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFProxyTypeHTTPS as String
                    ] =
                    "\(sessionProxyHost):\(sessionProxyPort)"
                #endif
            } else {
                print("No Proxy")
            }
            return sessionConfiguration
        }

        func get_ds_token(uid: String, server_id: String) -> String {
            let s: String
            switch region {
            case .cn:
                s = "xV8v4Qu54lUKrEYFZkJhB8cuOh9Asafs"
            case .global:
                s = "okr4obncj8bw5a65hbnn5oo6ixjc3l9w"
            }
            let t = String(Int(Date().timeIntervalSince1970))
            let r = String(Int.random(in: 100000 ..< 200000))
            let q = "role_id=\(uid)&server=\(server_id)"
            let c = "salt=\(s)&t=\(t)&r=\(r)&b=&q=\(q)".md5
            return t + "," + r + "," + c
        }

        if networkReachability.reachable {
            DispatchQueue.global(qos: .userInteractive).async {
                // 请求url前缀，后跟request的类型
                let baseStr: String
                let appVersion: String
                let userAgent: String
                let clientType: String
                switch region {
                case .cn:
                    baseStr =
                        "https://api-takumi-record.mihoyo.com/game_record/app/"
                    appVersion = "2.11.1"
                    userAgent =
                        "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.11."
                    clientType = "5"
                case .global:
                    baseStr =
                        "https://bbs-api-os.hoyoverse.com/game_record/app/"
                    appVersion = "2.9.1"
                    userAgent =
                        "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.11."
                    clientType = "2"
                }
                // 由前缀和后缀共同组成的url
                var url = URLComponents(string: baseStr + urlStr)!
                url.queryItems = [
                    URLQueryItem(name: "server", value: serverID),
                    URLQueryItem(name: "role_id", value: uid),
                ]
                // 初始化请求
                var request = URLRequest(url: url.url!)
                // 设置请求头
                request.allHTTPHeaderFields = [
                    "Accept": "application/json, text/plain, */*",
                    "DS": get_ds_token(uid: uid, server_id: serverID),
                    "x-rpc-app_version": appVersion,
                    "User-Agent": userAgent,
                    "x-rpc-client_type": clientType,
                    "x-rpc-language": Locale.langCodeForAPI,
                    "Referer": "https://webstatic.mihoyo.com/app/community-game-records/index.html?v=6",
                    "X-Requested-With": "com.mihoyo.hyperion",
                    "Origin": "https://webstatic.mihoyo.com",
                    "Accept-Encoding": "gzip, deflate",
                    "Cookie": cookie,
                ]
                // http方法
                switch method {
                case .post:
                    request.httpMethod = "POST"
                case .get:
                    request.httpMethod = "GET"
                case .put:
                    request.httpMethod = "PUT"
                }
                // 开始请求
                let session =
                    URLSession(configuration: getSessionConfiguration())
                session.dataTask(
                    with: request
                ) { data, response, error in
                    // 判断有没有错误（这里无论如何都不会抛因为是自己手动返回错误信息的）
                    print(error ?? "ErrorInfo nil")
                    if let error = error {
                        completion(.failure(.dataTaskError(
                            error
                                .localizedDescription
                        )))
                        print(
                            "DataTask error in General HttpMethod: " +
                                error.localizedDescription + "\n"
                        )
                    } else {
                        guard let data = data else {
                            completion(.failure(.noResponseData))
                            print("found response data nil")
                            return
                        }
                        guard response is HTTPURLResponse else {
                            completion(.failure(.responseError))
                            print("response error")
                            return
                        }
                        DispatchQueue.main.async {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase

//                            let dictionary = try? JSONSerialization.jsonObject(with: data)
//                            print(dictionary ?? "None")

                            do {
                                let requestResult = try decoder.decode(
                                    T.self,
                                    from: data
                                )
                                completion(.success(requestResult))
                            } catch {
                                print(error)
                                completion(.failure(.decodeError(
                                    error
                                        .localizedDescription
                                )))
                            }
                        }
                    }
                }.resume()
            }
        }
    }

    /// 返回游戏内帐号信息的请求方法接口
    /// - Parameters:
    ///   - method:Method, http方法的类型
    ///   - urlStr:String，url的字符串后缀，即request的类型
    ///   - region:Region，请求的服务器地区类型
    ///   - cookie: String， 用户Cookie
    ///   - serverID: String，服务器ID
    ///   - completion:异步返回处理好的data以及报错的类型
    static func gameAccountRequest(
        _ method: Method,
        _ urlStr: String,
        _ region: Region,
        _ cookie: String,
        _ serverId: String?,
        completion: @escaping (
            (Result<T, RequestError>) -> ()
        )
    ) {
        let networkReachability = NetworkReachability()

        if networkReachability.reachable {
            DispatchQueue.global(qos: .userInteractive).async {
                // 请求url前缀，后跟request的类型
                let baseStr: String
                let appVersion: String
                let userAgent: String
                switch region {
                case .cn:
                    baseStr = "https://api-takumi.mihoyo.com/"
                    appVersion = "2.11.1"
                    userAgent =
                        "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.11.1"
                case .global:
                    baseStr = "https://api-account-os.hoyolab.com/"
                    appVersion = "2.9.1"
                    userAgent =
                        "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.9.1"
                }
                // 由前缀和后缀共同组成的url
                var url = URLComponents(string: baseStr + urlStr)!
                switch region {
                case .cn:
                    url
                        .queryItems =
                        [URLQueryItem(name: "game_biz", value: "hk4e_cn")]
                case .global:
                    url.queryItems = [
                        URLQueryItem(name: "game_biz", value: "hk4e_global"),
                        URLQueryItem(name: "region", value: serverId),
                    ]
                }
                // 初始化请求
                var request = URLRequest(url: url.url!)
                // 设置请求头
                request.allHTTPHeaderFields = [
                    "Accept-Encoding": "gzip, deflate, br",
                    "Accept-Language": "zh-CN,zh-Hans;q=0.9",
                    "Accept": "application/json, text/plain, */*",
                    "Origin": "https://webstatic.mihoyo.com",
                    "User-Agent": userAgent,
                    "Connection": "keep-alive",
                    "x-rpc-app_version": appVersion,
                    "Referer": "https://webstatic.mihoyo.com/",
                ]
                // http方法
                switch method {
                case .post:
                    request.httpMethod = "POST"
                case .get:
                    request.httpMethod = "GET"
                case .put:
                    request.httpMethod = "PUT"
                }
                // 开始请求
                URLSession.shared.dataTask(
                    with: request
                ) { data, response, error in
                    // 判断有没有错误（这里无论如何都不会抛因为是自己手动返回错误信息的）
                    print(error ?? "ErrorInfo nil")
                    if let error = error {
                        completion(.failure(.dataTaskError(
                            error
                                .localizedDescription
                        )))
                        print(
                            "DataTask error in General HttpMethod: " +
                                error.localizedDescription + "\n"
                        )
                    } else {
                        guard let data = data else {
                            completion(.failure(.noResponseData))
                            print("found response data nil")
                            return
                        }
                        guard response is HTTPURLResponse else {
                            completion(.failure(.responseError))
                            print("response error")
                            return
                        }
                        DispatchQueue.main.async {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase

//                            let dictionary = try? JSONSerialization.jsonObject(with: data)
//                            print(dictionary ?? "None")

                            do {
                                let requestResult = try decoder.decode(
                                    T.self,
                                    from: data
                                )
                                completion(.success(requestResult))
                            } catch {
                                print(error)
                                completion(.failure(.decodeError(
                                    error
                                        .localizedDescription
                                )))
                            }
                        }
                    }
                }.resume()
            }
        }
    }

    /// 返回Open API结果接口
    /// - Parameters:
    ///   - method:Method, http方法的类型
    ///   - url:URL类型的URL
    ///   - completion:异步返回处理好的data以及报错的类型
    ///
    ///  需要自己传URL类型的url过来
    static func openRequest(
        _ method: Method,
        _ url: URL,
        cachedPolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        completion: @escaping (
            (Result<T, RequestError>) -> ()
        )
    ) {
        let networkReachability = NetworkReachability()

        if networkReachability.reachable {
            DispatchQueue.global(qos: .userInteractive).async {
                // 初始化请求
                var request = URLRequest(url: url)
                request.cachePolicy = cachedPolicy
                // 设置请求头
                request.allHTTPHeaderFields = [
                    "Accept-Encoding": "gzip, deflate, br",
                    "Accept-Language": "zh-CN,zh-Hans;q=0.9",
                    "Accept": "application/json, text/plain, */*",
                    "User-Agent": "Genshin-Pizza-Helper/2.0",
                    "Connection": "keep-alive",
                ]
                // http方法
                switch method {
                case .post:
                    request.httpMethod = "POST"
                case .get:
                    request.httpMethod = "GET"
                case .put:
                    request.httpMethod = "PUT"
                }
                // 开始请求
                URLSession.shared.dataTask(
                    with: request
                ) { data, response, error in
                    // 判断有没有错误（这里无论如何都不会抛因为是自己手动返回错误信息的）
                    print(error ?? "ErrorInfo nil")
                    print(
                        "STATUSCODE: \((response as? HTTPURLResponse)?.statusCode ?? -999)"
                    )
                    if let statusCode = (response as? HTTPURLResponse)?
                        .statusCode, statusCode != 200 {
                        completion(.failure(.errorWithCode(statusCode)))
                    }
                    if let error = error {
                        completion(.failure(.dataTaskError(
                            error
                                .localizedDescription
                        )))
                        print(
                            "DataTask error in General HttpMethod: " +
                                error.localizedDescription + "\n"
                        )
                    } else {
                        guard let data = data else {
                            completion(.failure(.noResponseData))
                            print("found response data nil")
                            return
                        }
                        guard response is HTTPURLResponse else {
                            completion(.failure(.responseError))
                            print("response error")
                            return
                        }
                        DispatchQueue.main.async {
                            let decoder = JSONDecoder()
//                            decoder.keyDecodingStrategy = .convertFromSnakeCase

//                            let dictionary = try? JSONSerialization.jsonObject(with: data)
//                            print(dictionary ?? "None")

                            do {
                                let requestResult = try decoder.decode(
                                    T.self,
                                    from: data
                                )
//                                let requestResult = try decoder.decode(T.self, from: Data(contentsOf: <#T##URL#>))
                                completion(.success(requestResult))
                            } catch {
                                print(error)
                                completion(.failure(.decodeError(
                                    error
                                        .localizedDescription
                                )))
                            }
                        }
                    }
                }.resume()
            }
        }
    }

    /// 返回旅行者札记信息
    /// - Parameters:
    ///   - method:Method, http方法的类型
    ///   - urlStr:String，url的字符串后缀，即request的类型
    ///   - month: 月份 0或者具体的月份
    ///   - uid: String, UID
    ///   - serverID: String，服务器ID
    ///   - region:Region，请求的服务器地区类型
    ///   - cookie: String， 用户Cookie
    ///   - completion:异步返回处理好的data以及报错的类型
    static func ledgerDataRequest(
        _ method: Method,
        _ urlStr: String,
        _ month: Int,
        _ uid: String,
        _ serverID: String,
        _ region: Region,
        _ cookie: String,
        completion: @escaping (
            (Result<T, RequestError>) -> ()
        )
    ) {
        let networkReachability = NetworkReachability()

        func getSessionConfiguration() -> URLSessionConfiguration {
            let sessionConfiguration = URLSessionConfiguration.default

            let sessionUseProxy =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .bool(forKey: "useProxy")
            let sessionProxyHost =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyHost")
            let sessionProxyPort =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyPort")
            let sessionProxyUserName =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyUserName")
            let sessionProxyPassword =
                UserDefaults(suiteName: "group.GenshinPizzaHelper")!
                    .string(forKey: "proxyUserPassword")
            if sessionUseProxy {
                guard let sessionProxyHost = sessionProxyHost else {
                    print("Proxy host error")
                    return sessionConfiguration
                }
                guard let sessionProxyPort = Int(sessionProxyPort ?? "0") else {
                    print("Proxy port error")
                    return sessionConfiguration
                }

                if sessionProxyUserName != nil, sessionProxyUserName != "",
                   sessionProxyPassword != nil, sessionProxyPassword != "" {
                    print("Proxy add authorization")
                    let userPasswordString =
                        "\(String(describing: sessionProxyUserName)):\(String(describing: sessionProxyPassword))"
                    let userPasswordData = userPasswordString
                        .data(using: String.Encoding.utf8)
                    let base64EncodedCredential = userPasswordData!
                        .base64EncodedString(
                            options: Data
                                .Base64EncodingOptions(rawValue: 0)
                        )
                    let authString = "Basic \(base64EncodedCredential)"
                    sessionConfiguration
                        .httpAdditionalHeaders =
                        ["Proxy-Authorization": authString]
                    sessionConfiguration
                        .httpAdditionalHeaders = ["Authorization": authString]
                }

                print("Use Proxy \(sessionProxyHost):\(sessionProxyPort)")

                #if !os(watchOS)
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPEnable as String
                    ] =
                    true
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPProxy as String
                    ] =
                    sessionProxyHost
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFNetworkProxiesHTTPPort as String
                    ] =
                    sessionProxyPort
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFProxyTypeHTTP as String
                    ] =
                    "\(sessionProxyHost):\(sessionProxyPort)"
                sessionConfiguration
                    .connectionProxyDictionary?[
                        kCFProxyTypeHTTPS as String
                    ] =
                    "\(sessionProxyHost):\(sessionProxyPort)"
                #endif
            } else {
                print("No Proxy")
            }
            return sessionConfiguration
        }

        func get_ds_token(uid: String, server_id: String) -> String {
            let s: String
            switch region {
            case .cn:
                s = "xV8v4Qu54lUKrEYFZkJhB8cuOh9Asafs"
            case .global:
                s = "okr4obncj8bw5a65hbnn5oo6ixjc3l9w"
            }
            let t = String(Int(Date().timeIntervalSince1970))
            let r = String(Int.random(in: 100000 ..< 200000))
            let q = "role_id=\(uid)&server=\(server_id)"
            let c = "salt=\(s)&t=\(t)&r=\(r)&b=&q=\(q)".md5
            return t + "," + r + "," + c
        }

        if networkReachability.reachable {
            DispatchQueue.global(qos: .userInteractive).async {
                // 请求url前缀，后跟request的类型
                let baseStr: String
                let appVersion: String
                let userAgent: String
                let clientType: String
                let referer: String
                let origin: String
                switch region {
                case .cn:
                    baseStr = "https://hk4e-api.mihoyo.com/"
                    appVersion = "2.11.1"
                    userAgent =
                        "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.11.1"
                    clientType = "5"
                    referer = "https://webstatic.mihoyo.com"
                    origin = "https://webstatic.mihoyo.com"
                case .global:
                    baseStr = "https://sg-hk4e-api.hoyolab.com/"
                    appVersion = "2.9.1"
                    userAgent =
                        "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBSOversea/2.20.0"
                    clientType = "2"
                    referer = "https://act.hoyolab.com"
                    origin = "https://act.hoyolab.com"
                }
                // 由前缀和后缀共同组成的url
                var url = URLComponents(string: baseStr + urlStr)!
                switch region {
                case .cn:
                    url.queryItems = [
                        URLQueryItem(name: "month", value: String(month)),
                        URLQueryItem(name: "bind_uid", value: String(uid)),
                        URLQueryItem(name: "bind_region", value: serverID),
                        URLQueryItem(
                            name: "bbs_presentation_style",
                            value: "fullscreen"
                        ),
                        URLQueryItem(name: "bbs_auth_required", value: "true"),
                        URLQueryItem(name: "utm_source", value: "bbs"),
                        URLQueryItem(name: "utm_medium", value: "mys"),
                        URLQueryItem(name: "utm_compaign", value: "icon"),
                    ]
                case .global:
                    url.queryItems = [
                        URLQueryItem(name: "month", value: String(month)),
                        URLQueryItem(name: "region", value: serverID),
                        URLQueryItem(name: "uid", value: String(uid)),
                        URLQueryItem(name: "lang", value: Locale.langCodeForAPI),
                    ]
                }
                // 初始化请求
                var request = URLRequest(url: url.url!)
                // 设置请求头
                request.allHTTPHeaderFields = [
                    "Accept": "application/json, text/plain, */*",
//                    "DS": get_ds_token(uid: uid, server_id: serverID),
                    "x-rpc-app_version": appVersion,
                    "User-Agent": userAgent,
                    "x-rpc-client_type": clientType,
                    "x-rpc-language": Locale.langCodeForAPI,
                    "X-Requested-With": "com.mihoyo.hyperion",
                    "Origin": origin,
                    "Accept-Encoding": "gzip, deflate",
                    "Referer": referer,
                    "Cookie": cookie,
                ]
                // http方法
                switch method {
                case .post:
                    request.httpMethod = "POST"
                case .get:
                    request.httpMethod = "GET"
                case .put:
                    request.httpMethod = "PUT"
                }
                // 开始请求
                let session =
                    URLSession(configuration: getSessionConfiguration())
                session.dataTask(
                    with: request
                ) { data, response, error in
                    // 判断有没有错误（这里无论如何都不会抛因为是自己手动返回错误信息的）
                    print(error ?? "ErrorInfo nil")
                    if let error = error {
                        completion(.failure(.dataTaskError(
                            error
                                .localizedDescription
                        )))
                        print(
                            "DataTask error in General HttpMethod: " +
                                error.localizedDescription + "\n"
                        )
                    } else {
                        guard let data = data else {
                            completion(.failure(.noResponseData))
                            print("found response data nil")
                            return
                        }
                        guard response is HTTPURLResponse else {
                            completion(.failure(.responseError))
                            print("response error")
                            return
                        }
                        DispatchQueue.main.async {
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .convertFromSnakeCase

                            let dictionary = try? JSONSerialization
                                .jsonObject(with: data)
                            print(dictionary ?? "None")

                            do {
                                let requestResult = try decoder.decode(
                                    T.self,
                                    from: data
                                )
                                completion(.success(requestResult))
                            } catch {
                                print(error)
                                completion(.failure(.decodeError(
                                    error
                                        .localizedDescription
                                )))
                            }
                        }
                    }
                }.resume()
            }
        }
    }

    /// 返回自己的后台的结果接口
    /// - Parameters:
    ///   - method:Method, http方法的类型
    ///   - url:String，请求的路径
    ///   - completion:异步返回处理好的data以及报错的类型
    ///
    ///  需要自己传URL类型的url过来
    static func homeRequest(
        _ method: Method,
        _ urlStr: String,
        cachedPolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
        completion: @escaping (
            (Result<T, RequestError>) -> ()
        )
    ) {
        let networkReachability = NetworkReachability()

        if networkReachability.reachable {
            DispatchQueue.global(qos: .userInteractive).async {
                // 请求url前缀，后跟request的类型
                let baseStr: String = "https://ophelper.top/"
                // 由前缀和后缀共同组成的url
                let url = URLComponents(string: baseStr + urlStr)!
                // 初始化请求
                var request = URLRequest(url: url.url!)
                request.cachePolicy = cachedPolicy
                // 设置请求头
                request.allHTTPHeaderFields = [
                    "Accept-Encoding": "gzip, deflate, br",
                    "Accept-Language": "zh-CN,zh-Hans;q=0.9",
                    "Accept": "application/json, text/plain, */*",
                    "Connection": "keep-alive",
                ]
                // http方法
                switch method {
                case .post:
                    request.httpMethod = "POST"
                case .get:
                    request.httpMethod = "GET"
                case .put:
                    request.httpMethod = "PUT"
                }
                // 开始请求
                URLSession.shared.dataTask(
                    with: request
                ) { data, response, error in
                    // 判断有没有错误（这里无论如何都不会抛因为是自己手动返回错误信息的）
                    print(error ?? "ErrorInfo nil")
                    if let error = error {
                        completion(.failure(.dataTaskError(
                            error
                                .localizedDescription
                        )))
                        print(
                            "DataTask error in General HttpMethod: " +
                                error.localizedDescription + "\n"
                        )
                    } else {
                        guard let data = data else {
                            completion(.failure(.noResponseData))
                            print("found response data nil")
                            return
                        }
                        guard response is HTTPURLResponse else {
                            completion(.failure(.responseError))
                            print("response error")
                            return
                        }
                        DispatchQueue.main.async {
                            let decoder = JSONDecoder()
//                            decoder.keyDecodingStrategy = .convertFromSnakeCase

//                            let dictionary = try? JSONSerialization.jsonObject(with: data)
//                            print(dictionary ?? "None")

                            do {
                                let requestResult = try decoder.decode(
                                    T.self,
                                    from: data
                                )
                                completion(.success(requestResult))
                            } catch {
                                print(error)
                                completion(.failure(.decodeError(
                                    error
                                        .localizedDescription
                                )))
                            }
                        }
                    }
                }.resume()
            }
        }
    }

    /// 返回需要POST的结果接口
    /// - Parameters:
    ///   - method:Method, http方法的类型
    ///   - url:String，请求的路径
    ///   - completion:异步返回处理好的data以及报错的类型
    ///
    ///  需要自己传URL类型的url过来
    static func postRequest(
        _ method: Method,
        baseHost: String = "http://81.70.76.222/",
        urlStr: String,
        body: Data,
        region: Region? = nil,
        cookie: String? = nil,
        dseed: String? = nil,
        ds: String? = nil,
        completion: @escaping (
            (Result<T, RequestError>) -> ()
        )
    ) {
        let networkReachability = NetworkReachability()

        if networkReachability.reachable {
            DispatchQueue.global(qos: .userInteractive).async {
                // 请求url前缀，后跟request的类型
                let baseStr: String = baseHost
                // 由前缀和后缀共同组成的url
                let url = URLComponents(string: baseStr + urlStr)!
                // 初始化请求
                var request = URLRequest(url: url.url!)
                // 设置请求头
                request.allHTTPHeaderFields = [
                    "Accept-Encoding": "gzip, deflate, br",
                    "Accept-Language": "zh-CN,zh-Hans;q=0.9",
                    "Accept": "application/json, text/plain, */*",
                    "Connection": "keep-alive",
                ]
                if let cookie = cookie {
                    request.setValue(cookie, forHTTPHeaderField: "Cookie")
                }

                if let region = region {
                    switch region {
                    case .cn:
                        request.setValue(
                            "5",
                            forHTTPHeaderField: "x-rpc-client_type"
                        )
                        request.setValue(
                            "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBS/2.36.1",
                            forHTTPHeaderField: "User-Agent"
                        )
                        request.setValue(
                            "2.36.1",
                            forHTTPHeaderField: "x-rpc-app_version"
                        )
                        request.setValue(
                            "https://webstatic.mihoyo.com",
                            forHTTPHeaderField: "Origin"
                        )
                        request.setValue(
                            "https://webstatic.mihoyo.com",
                            forHTTPHeaderField: "Referer"
                        )
                        request.setValue(
                            Locale.langCodeForAPI,
                            forHTTPHeaderField: "x-rpc-language"
                        )
                    case .global:
                        request.setValue(
                            "2",
                            forHTTPHeaderField: "x-rpc-client_type"
                        )
                        request.setValue(
                            "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) miHoYoBBSOversea/2.20.0",
                            forHTTPHeaderField: "User-Agent"
                        )
                        request.setValue(
                            "2.9.1",
                            forHTTPHeaderField: "x-rpc-app_version"
                        )
                        request.setValue(
                            "https://act.hoyolab.com",
                            forHTTPHeaderField: "Origin"
                        )
                        request.setValue(
                            "https://act.hoyolab.com",
                            forHTTPHeaderField: "Referer"
                        )
                        request.setValue(
                            Locale.langCodeForAPI,
                            forHTTPHeaderField: "x-rpc-language"
                        )
                    }
                }
                if let dseed = dseed {
                    request.setValue(dseed, forHTTPHeaderField: "dseed")
                }
                if let ds = ds {
                    if region != nil {
                        request.setValue(ds, forHTTPHeaderField: "DS")
                    } else {
                        request.setValue(ds, forHTTPHeaderField: "ds")
                    }
                }
                // http方法
                switch method {
                case .post:
                    request.httpMethod = "POST"
                case .get:
                    request.httpMethod = "GET"
                case .put:
                    request.httpMethod = "PUT"
                }
                // request body
                request.httpBody = body
                request.setValue(
                    "\(body.count)",
                    forHTTPHeaderField: "Content-Length"
                )
                print(body.count)
                print(request.allHTTPHeaderFields!)
                print(request)
                print(String(data: request.httpBody!, encoding: .utf8)!)
                // 开始请求
                URLSession.shared.dataTask(
                    with: request
                ) { data, response, error in
                    // 判断有没有错误（这里无论如何都不会抛因为是自己手动返回错误信息的）
                    print(error ?? "ErrorInfo nil")
                    if let error = error {
                        completion(.failure(.dataTaskError(
                            error
                                .localizedDescription
                        )))
                        print(
                            "DataTask error in General HttpMethod: " +
                                error.localizedDescription + "\n"
                        )
                    } else {
                        guard let data = data else {
                            completion(.failure(.noResponseData))
                            print("found response data nil")
                            return
                        }
                        guard response is HTTPURLResponse else {
                            completion(.failure(.responseError))
                            print("response error")
                            return
                        }
                        DispatchQueue.main.async {
                            let decoder = JSONDecoder()
                            if baseHost != "http://81.70.76.222/" {
                                decoder
                                    .keyDecodingStrategy = .convertFromSnakeCase
                            }

//                            let dictionary = try? JSONSerialization.jsonObject(with: data)
//                            print(dictionary ?? "None")

                            do {
                                let requestResult = try decoder.decode(
                                    T.self,
                                    from: data
                                )
                                completion(.success(requestResult))
                            } catch {
                                print(error)
                                completion(.failure(.decodeError(
                                    error
                                        .localizedDescription
                                )))
                            }
                        }
                    }
                }.resume()
            }
        }
    }

    /// 返回OPServer的请求的结果接口
    /// - Parameters:
    ///   - method:Method, http方法的类型
    ///   - url:String，请求的路径
    ///   - completion:异步返回处理好的data以及报错的类型
    ///
    ///  需要自己传URL类型的url过来
    static func homeServerRequest(
        _ method: Method,
        baseHost: String = "http://81.70.76.222",
        urlStr: String,
        body: Data? = nil,
        headersDict: [String: String] = [:],
        parasDict: [String: String] = [:],
        completion: @escaping (
            (Result<T, RequestError>) -> ()
        )
    ) {
        let networkReachability = NetworkReachability()

        if networkReachability.reachable {
            DispatchQueue.global(qos: .userInteractive).async {
                // 请求url前缀，后跟request的类型
                let baseStr: String = baseHost
                // 由前缀和后缀共同组成的url
                var url = URLComponents(string: baseStr + urlStr)!
                var urlQueryItems: [URLQueryItem] = url.queryItems ?? []
                for para in parasDict {
                    urlQueryItems
                        .append(URLQueryItem(name: para.key, value: para.value))
                }
                url.queryItems = urlQueryItems

                // 初始化请求
                var request = URLRequest(url: url.url!)
                // 设置请求头
                request.allHTTPHeaderFields = [
                    "Accept-Encoding": "gzip, deflate, br",
                    "Accept-Language": "zh-CN,zh-Hans;q=0.9",
                    "Accept": "*/*",
                    "Connection": "keep-alive",
                    "Content-Type": "application/json",
                ]

                request.setValue(
                    "Genshin-Pizza-Helper/2.0",
                    forHTTPHeaderField: "User-Agent"
                )
                for header in headersDict {
                    request.setValue(
                        header.value,
                        forHTTPHeaderField: header.key
                    )
                }
                // http方法
                switch method {
                case .post:
                    request.httpMethod = "POST"
                case .get:
                    request.httpMethod = "GET"
                case .put:
                    request.httpMethod = "PUT"
                }
                // request body
                if let body = body {
                    request.httpBody = body
                    request.setValue(
                        "\(body.count)",
                        forHTTPHeaderField: "Content-Length"
                    )
                }
//                print(request)
//                print(request.allHTTPHeaderFields!)
//                print(String(data: request.httpBody!, encoding: .utf8)!)
                // 开始请求
                URLSession.shared.dataTask(
                    with: request
                ) { data, response, error in
                    // 判断有没有错误（这里无论如何都不会抛因为是自己手动返回错误信息的）
                    print(error ?? "ErrorInfo nil")
                    if let error = error {
                        completion(.failure(.dataTaskError(
                            error
                                .localizedDescription
                        )))
                        print(
                            "DataTask error in General HttpMethod: " +
                                error.localizedDescription + "\n"
                        )
                    } else {
                        guard let data = data else {
                            completion(.failure(.noResponseData))
                            print("found response data nil")
                            return
                        }
                        guard response is HTTPURLResponse else {
                            completion(.failure(.responseError))
                            print("response error")
                            return
                        }
                        DispatchQueue.main.async {
                            guard let stringData = String(
                                data: data,
                                encoding: .utf8
                            ) else {
                                completion(
                                    .failure(
                                        .decodeError(
                                            "fail convert data to .utf8 string"
                                        )
                                    )
                                ); return
                            }
                            print(stringData)
                            let data = stringData.replacingOccurrences(
                                of: "\"NaN\"",
                                with: "0"
                            ).data(using: .utf8)!
                            let decoder = JSONDecoder()
                            if baseHost != "http://81.70.76.222" {
                                decoder
                                    .keyDecodingStrategy = .convertFromSnakeCase
                            }
                            guard let response = response as? HTTPURLResponse
                            else {
                                completion(.failure(.responseError))
                                return
                            }
                            print(response.statusCode)

                            do {
                                let requestResult = try decoder.decode(
                                    T.self,
                                    from: data
                                )
                                completion(.success(requestResult))
                            } catch {
                                print(error)
                                completion(.failure(.decodeError(
                                    error
                                        .localizedDescription
                                )))
                            }
                        }
                    }
                }.resume()
            }
        } else {
            completion(.failure(.responseError))
        }
    }
}

// MARK: - API

public class API {
    // API方法类，在这里只是一个空壳，以extension的方法扩展
}

// String的扩展，让其具有直接加键值对的功能
extension String {
    func addPara(_ key: String, _ value: String) -> String {
        var str = self
        if str != "" {
            str += "&"
        }
        str += "\(key)=\(value)"
        return str
    }
}
