//
//  HTTPMethod.swift
//
//
//  Created by Bill Haku on 2023/3/27.
//  HTTP请求方法

import Foundation
import HBMihoyoAPI

// MARK: - Method

enum Method {
    case post
    case get
    case put
}

// MARK: - HttpMethod

@available(iOS 13, watchOS 6, *)
struct HttpMethod<T: Codable> {
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
        hostType: HostType = .generalHost,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        completion: @escaping (
            (Result<T, RequestError>) -> ()
        )
    ) {
        let networkReachability = NetworkReachability()

        if networkReachability.reachable {
            DispatchQueue.global(qos: .userInteractive).async {
                // 请求url前缀，后跟request的类型
                let baseStr: String = hostType.hostBase
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
                    if let statusCode = (response as? HTTPURLResponse)?
                        .statusCode, statusCode != 200 {
                        completion(.failure(.errorWithCode(statusCode)))
                    }
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
                            decoder.keyDecodingStrategy = keyDecodingStrategy

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
                    case .china:
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

// String的扩展，让其具有直接加键值对的功能
extension String {
    func addPara(_ key: String, _ value: String) -> String {
        var str = self
        if str != "", str.last != "?" {
            str += "&"
        }
        str += "\(key)=\(value)"
        return str
    }
}

// MARK: - HostType

enum HostType {
    case generalHost
    case artifactRatingHost
    case abyssHost

    // MARK: Internal

    var hostBase: String {
        switch self {
        case .generalHost:
            return "https://hsr.ophelper.top/"
        case .artifactRatingHost:
            return "https://artifact-rating.ophelper.top/"
        case .abyssHost:
            return "http://81.70.76.222/"
        }
    }
}
