//
//  GetCookieWebView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//  获取Cookie的网页View

import AlertToast
import HBMihoyoAPI
import SafariServices
import SwiftUI
import WebKit

// MARK: - GetCookieWebView

struct GetCookieWebView: View {
    @State
    var isAlertShow: Bool = false
    @Binding
    var isShown: Bool
    @Binding
    var cookie: String
    let region: Region
    var dataStore: WKWebsiteDataStore = .default()

    let cookieKeysToSave: [String] = ["ltoken", "ltuid"]

    var url: String {
        switch region {
        case .cn:
            return "https://user.mihoyo.com/#/login/captcha"
        case .global:
            return "https://www.hoyolab.com/"
        }
    }

    var httpHeaderFields: [String: String] {
        switch region {
        case .cn:
            return [
                "Host": "user.mihoyo.com",
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
                "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
                "Connection": "keep-alive",
                "Accept-Encoding": "gzip, deflate, br",
                "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 Safari/604.1",
                "cache-control": "max-age=0",
            ]
        case .global:
            return [
                //                "Host": "m.hoyolab.com",
                "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
                "accept-language": "zh-CN,zh-Hans;q=0.9",
                "accept-encoding": "gzip, deflate, br",
                "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36 Edg/107.0.1418.52",
                "cache-control": "max-age=0",
            ]
        }
    }

    var body: some View {
        NavigationView {
            CookieGetterWebView(
                url: url,
                dataStore: dataStore,
                httpHeaderFields: httpHeaderFields
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        cookie = ""

                        switch region {
                        case .cn:
                            DispatchQueue.main.async {
                                dataStore.httpCookieStore
                                    .getAllCookies { cookies in
                                        let loginTicket: String = cookies
                                            .first(where: { cookie in
                                                cookie.name == "login_ticket"
                                            })?.value ?? ""
//                                        let MHYUUID: String = cookies
//                                            .first(where: { cookie in
//                                                cookie.name == "_MHYUUID"
//                                            })?.value ?? ""
//                                        cookie += "_MHYUUID=\(MHYUUID); "
//                                        print("MHYUUID: \(MHYUUID)")
                                        print("loginTicket: \(loginTicket)")
                                        let loginUid: String = cookies
                                            .first(where: { cookie in
                                                cookie.name == "login_uid"
                                            })?.value ?? ""
                                        MihoyoAPI.getMultiTokenByLoginTicket(
                                            loginTicket: loginTicket,
                                            loginUid: loginUid
                                        ) { result in
                                            cookie += "stuid=" + loginUid + "; "
                                            cookie += "stoken=" +
                                                (
                                                    (
                                                        try? result.get().stoken
                                                    ) ??
                                                        ""
                                                ) + "; "
                                            cookie += "ltuid=" + loginUid + "; "
                                            cookie += "ltoken=" +
                                                (
                                                    (
                                                        try? result.get().ltoken
                                                    ) ??
                                                        ""
                                                ) + "; "
                                            isShown.toggle()
                                        }
                                    }
                            }
                        case .global:
                            DispatchQueue.main.async {
                                dataStore.httpCookieStore
                                    .getAllCookies { cookies in
                                        cookies.forEach {
                                            print($0.name, $0.value)
                                            cookie = cookie + $0.name + "=" + $0
                                                .value + "; "
                                        }
                                    }
                                isShown.toggle()
                            }
                        }
                    }
                }
            }
            .navigationTitle("请完成登录")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(isPresented: $isAlertShow) {
            Alert(
                title: Text("提示"),
                message: Text(
                    "请在打开的网页完成登录米游社操作后点击「完成」。\n通过Google，Facebook或Twitter登录HoYoLAB不可使用，请使用帐号密码登录。\n我们承诺：您的登录信息只会保存在您的本地设备和私人iCloud中，仅用于向米游社请求您的原神状态。"
                ),
                dismissButton: .default(Text("好"))
            )
        }
        .onAppear {
            isAlertShow.toggle()
        }
    }
}

// MARK: - CookieGetterWebView

struct CookieGetterWebView: UIViewRepresentable {
    class Coordinator: NSObject, WKNavigationDelegate {
        // MARK: Lifecycle

        init(_ parent: CookieGetterWebView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: CookieGetterWebView

        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            let js = """
            let timer = setInterval(() => {
            var m = document.getElementById("driver-page-overlay");
            m.parentNode.removeChild(m);
            }, 300);
            setTimeout(() => {clearInterval(timer);timer = null}, 10000);
            """
            webView.evaluateJavaScript(js)
        }
    }

    var url: String = ""
    let dataStore: WKWebsiteDataStore
    let httpHeaderFields: [String: String]

    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: url)
        else {
            return WKWebView()
        }
        dataStore
            .fetchDataRecords(
                ofTypes: WKWebsiteDataStore
                    .allWebsiteDataTypes()
            ) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default()
                        .removeData(
                            ofTypes: record.dataTypes,
                            for: [record],
                            completionHandler: {}
                        )
                    #if DEBUG
                    print("WKWebsiteDataStore record deleted:", record)
                    #endif
                }
            }
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 10
        )
        request.allHTTPHeaderFields = httpHeaderFields
        let webview = WKWebView()
        webview.configuration.websiteDataStore = dataStore
//        webview.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.1 Safari/605.1.15"
        webview.navigationDelegate = context.coordinator
        webview.load(request)
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: url) {
            var request = URLRequest(
                url: url,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                timeoutInterval: 10
            )
            request.httpShouldHandleCookies = false
            request.allHTTPHeaderFields = httpHeaderFields
            print(request.description)
            uiView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// MARK: - GetLedgerCookieWebView

struct GetLedgerCookieWebView<V>: View {
    @EnvironmentObject
    var viewModel: ViewModel
    let title: String

    @State
    var isAlertShow: Bool = false
    @Binding
    var sheetType: V?
    @Binding
    var cookie: String
    let region: Region
    var dataStore: WKWebsiteDataStore = .default()

    let cookieKeysToSave: [String] = ["ltoken", "ltuid"]

    var url: String {
        switch region {
        case .cn:
            return "https://m.miyoushe.com/ys/#/home/0"
        case .global:
            return "https://m.hoyolab.com/"
        }
    }

    var httpHeaderFields: [String: String] {
        switch region {
        case .cn:
            return [
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                "Accept-Language": "zh-CN,zh-Hans;q=0.9",
                "Connection": "keep-alive",
                "Accept-Encoding": "gzip, deflate, br",
                "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 Safari/604.1",
                "Cookie": "",
            ]
        case .global:
            return [
                "Host": "m.hoyolab.com",
                "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                "accept-language": "zh-CN,zh-Hans;q=0.9",
                "accept-encoding": "gzip, deflate, br",
                "user-agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 Safari/604.1",
            ]
        }
    }

    var body: some View {
        NavigationView {
            CookieGetterWebView(
                url: url,
                dataStore: dataStore,
                httpHeaderFields: httpHeaderFields
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        switch region {
                        case .cn:
                            DispatchQueue.main.async {
                                var cookieDict: [String: String] = .init()
                                cookie.components(separatedBy: "; ")
                                    .forEach { subString in
                                        if let key = subString
                                            .components(separatedBy: "=").first,
                                            let value = subString
                                            .components(separatedBy: "=").last {
                                            cookieDict[key] = value
                                        }
                                    }
                                dataStore.httpCookieStore
                                    .getAllCookies { cookies in
                                        cookies.forEach {
                                            print($0.name, $0.value)
                                            cookieDict[$0.name] = $0.value
                                        }
                                        cookie = cookieDict.map { key, value in
                                            "\(key)=\(value); "
                                        }.joined()
                                        viewModel.saveAccount()
                                    }
                                sheetType = nil
                            }
                        case .global:
                            cookie = ""
                            DispatchQueue.main.async {
                                dataStore.httpCookieStore
                                    .getAllCookies { cookies in
                                        cookies.forEach {
                                            print($0.name, $0.value)
                                            cookie = cookie + $0.name + "=" + $0
                                                .value + "; "
                                        }
                                    }
                                viewModel.saveAccount()
                                sheetType = nil
                            }
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(isPresented: $isAlertShow) {
            Alert(
                title: Text("提示"),
                message: Text(
                    "请在打开的网页完成登录米游社操作后点击「完成」。\n通过Google，Facebook或Twitter登录HoYoLAB不可使用，请使用帐号密码登录。\n我们承诺：您的登录信息只会保存在您的本地设备和私人iCloud中，仅用于向米游社请求您的原神状态。"
                ),
                dismissButton: .default(Text("好"))
            )
        }
        .onAppear {
            isAlertShow.toggle()
        }
    }
}
