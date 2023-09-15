import Foundation
import HBMihoyoAPI

@available(iOS 15, watchOS 7, *)
public enum PizzaHelperAPI {
    // MARK: Public

    public enum HTTPMethod: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
    }

    /// Get the newest App version
    /// - Parameters:
    ///     - isBeta: if is Beta version
    ///     - completion: data
    public static func fetchNewestVersion(
        isBeta: Bool,
        completion: @escaping (
            NewestVersion
        ) -> ()
    ) async throws {
        var url = URL(string: "https://hsr.pizzastudio.org")!

        var path: String
        if isBeta {
            path = "api/app/newest_version_beta.json"
        } else {
            path = "api/app/newest_version.json"
        }

        url.appendPathComponent(path)

        let request = URLRequest(url: url)

        let (data, _) = try await URLSession.shared.data(for: request)

        let res = try decodeFromJSONResult(data: data)
        completion(res)

//        HttpMethod<NewestVersion>
//            .homeRequest(
//                .get,
//                urlStr,
//                cachedPolicy: .reloadIgnoringLocalCacheData
//            ) { result in
//                switch result {
//                case let .success(requestResult):
//                    print("request succeed")
//                    completion(requestResult)
//
//                case .failure:
//                    print("request newest version fail")
//                }
//            }
    }

    // MARK: Fileprivate

    /// Generate request
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
        host: String,
        path: String,
        queryItems: [URLQueryItem],
        body: Data? = nil,
        cookie: String? = nil
    ) throws
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

        if let cookie = cookie {
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
        }
        if let body = body {
            request.setValue(
                "\(body.count)",
                forHTTPHeaderField: "Content-Length"
            )
        }

        return request
    }

    // MARK: Private

    private static func decodeFromJSONResult(data: Data) throws -> NewestVersion {
        let decoder = JSONDecoder()
        let result = try? decoder.decode(NewestVersion.self, from: data)
        guard let result = result else {
            throw MiHoYoAPIError(retcode: -1, message: "result error")
        }
        return result
    }
}
