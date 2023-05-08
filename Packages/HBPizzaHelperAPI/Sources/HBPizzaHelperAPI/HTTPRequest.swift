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
                let baseStr: String = hostType.hostBase
                let url = URLComponents(string: baseStr + urlStr)!
                var request = URLRequest(url: url.url!)
                request.cachePolicy = cachedPolicy
                request.allHTTPHeaderFields = [
                    "Accept-Encoding": "gzip, deflate, br",
                    "Accept-Language": "zh-CN,zh-Hans;q=0.9",
                    "Accept": "application/json, text/plain, */*",
                    "Connection": "keep-alive",
                ]
                switch method {
                case .post:
                    request.httpMethod = "POST"
                case .get:
                    request.httpMethod = "GET"
                case .put:
                    request.httpMethod = "PUT"
                }
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
