//
//  GetCookieWebView.swift
//  GenshinPizzaHepler
//
//  Created by 戴藏龙 on 2022/8/16.
//  获取Cookie的网页View

import HBMihoyoAPI
import SafariServices
import SwiftUI
import WebKit

// MARK: - GetCookieWebView

struct GetCookieWebView: View {
    @Binding var isShown: Bool

    @Binding var cookie: String!

    let region: Region

    var dataStore: WKWebsiteDataStore = .default()

    var body: some View {
        NavigationStack {
            CookieGetterWebView(
                url: getURL(region: region),
                dataStore: dataStore,
                httpHeaderFields: getHTTPHeaderFields(region: region)
            )
            .navigationTitle("account.login.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("sys.done") {
                        Task(priority: .userInitiated) {
                            await getCookieFromDataStore()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("sys.cancel") {
                        isShown.toggle()
                    }
                }
            }
        }
    }

    @MainActor
    func getCookieFromDataStore() async {
        defer { isShown.toggle() }
        cookie = ""
        let cookies = await dataStore.httpCookieStore.allCookies()

        func getFromCookies(_ fieldName: String) -> String? {
            cookies.first(where: { $0.name == fieldName })?.value
        }

        switch region {
        case .mainlandChina:
            let loginTicket = getFromCookies("login_ticket") ?? ""
            let loginUid = getFromCookies("login_uid") ?? ""
            let multiToken = try? await MiHoYoAPI.getMultiTokenByLoginTicket(
                loginTicket: loginTicket,
                loginUid: loginUid
            )
            if let multiToken = multiToken {
                cookie += "stuid=" + loginUid + "; "
                cookie += "stoken=" + multiToken.stoken + "; "
                cookie += "ltuid=" + loginUid + "; "
                cookie += "ltoken=" + multiToken.ltoken + "; "
            }
        case .global:
            cookies.forEach {
                cookie += "\($0.name)=\($0.value); "
            }
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
            didFinish _: WKNavigation!
        ) {
            let jsonScript = """
            let timer = setInterval(() => {
            var m = document.getElementById("driver-page-overlay");
            m.parentNode.removeChild(m);
            }, 300);
            setTimeout(() => {clearInterval(timer);timer = null}, 10000);
            """
            webView.evaluateJavaScript(jsonScript)
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
        let timeoutInterval: TimeInterval = 10
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: timeoutInterval
        )
        request.allHTTPHeaderFields = httpHeaderFields
        let webview = WKWebView()
        webview.configuration.websiteDataStore = dataStore
        webview.navigationDelegate = context.coordinator
        webview.load(request)
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context _: Context) {
        if let url = URL(string: url) {
            let timeoutInterval: TimeInterval = 10
            var request = URLRequest(
                url: url,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                timeoutInterval: timeoutInterval
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

private func getURL(region: Region) -> String {
    switch region {
    case .mainlandChina:
        return "https://user.mihoyo.com/#/login/captcha"
    case .global:
        return "https://www.hoyolab.com/"
    }
}

private func getHTTPHeaderFields(region: Region) -> [String: String] {
    switch region {
    case .mainlandChina:
        return [
            "Accept": """
            text/html,application/xhtml+xml,application/xml;q=0.9,\
            image/webp,image/apng,*/*;q=0.8,\
            application/signed-exchange;v=b3;q=0.9
            """,
            "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
            "Connection": "keep-alive",
            "Accept-Encoding": "gzip, deflate, br",
            "User-Agent": """
            Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) \
            AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 \
            Safari/604.1
            """,
            "cache-control": "max-age=0",
        ]
    case .global:
        return [
            "accept": """
            text/html,application/xhtml+xml,\
            application/xml;q=0.9,\
            image/webp,image/apng,*/*;q=0.8,\
            application/signed-exchange;v=b3;q=0.9
            """,
            "accept-language": "zh-CN,zh-Hans;q=0.9",
            "accept-encoding": "gzip, deflate, br",
            "user-agent": """
            Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) \
            AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 \
            Safari/604.1
            """,
            "cache-control": "max-age=0",
        ]
    }
}

// MARK: - QRCodeGetCookieView

struct QRCodeGetCookieView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject var viewModel = QRCodeGetCookieViewModel.shared

    @Binding var cookie: String!

    @State private var isNotScannedAlertShow: Bool = false

    @State private var isCheckingScanning = false

    private var qrWidth: CGFloat {
        #if os(OSX) || targetEnvironment(macCatalyst)
        340
        #else
        280
        #endif
    }

    private var qrImage: Image? {
        guard let qrCodeAndTicket = viewModel.qrCodeAndTicket else { return nil }
        let img = Image(decorative: qrCodeAndTicket.qrCode, scale: 1)
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .frame(width: qrWidth, height: qrWidth)
            .padding()
        let renderer = ImageRenderer(content: img)
        renderer.proposedSize = .init(width: qrWidth, height: qrWidth)
        renderer.scale = 2
        guard let newImg = renderer.cgImage else { return nil }
        return Image(decorative: newImg, scale: 1)
    }

    private static var isMiyousheInstalled: Bool {
        UIApplication.shared.canOpenURL(URL(string: miyousheHeader)!)
    }

    private static var miyousheHeader: String { "mihoyobbs://" }

    private static var miyousheStorePage: String {
        "https://apps.apple.com/cn/app/id1470182559"
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if let error = viewModel.error {
                        Label {
                            Text(error.localizedDescription)
                        } icon: {
                            Image(systemSymbol: .exclamationmarkCircle)
                                .foregroundStyle(.red)
                        }
                        Button("sys.retry") {
                            viewModel.reCreateQRCode()
                        }
                    } else if let qrCodeAndTicket = viewModel.qrCodeAndTicket, let qrImage = qrImage {
                        HStack(alignment: .center) {
                            Spacer()
                            ShareLink(
                                item: qrImage,
                                preview: SharePreview("account.qr_code_login.shared_qr_code_title", image: qrImage)
                            ) {
                                qrImage
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: qrWidth, height: qrWidth)
                                    .padding()
                            }
                            Spacer()
                        }
                        .overlay(alignment: .bottom) {
                            Text("account.qr_code_login.click_qr_to_save").font(.footnote)
                                .padding(4)
                                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.primary.opacity(0.05)))
                        }
                        if isCheckingScanning {
                            ProgressView()
                        } else {
                            Button("account.qr_code_login.check_scanned") {
                                Task {
                                    isCheckingScanning = true
                                    do {
                                        let status = try await MiHoYoAPI.queryQRCodeStatus(
                                            deviceId: viewModel.taskId,
                                            ticket: qrCodeAndTicket.ticket
                                        )

                                        if case let .confirmed(accountId: accountId, token: gameToken) = status {
                                            let stokenResult = try await MiHoYoAPI.gameToken2StokenV2(
                                                accountId: accountId,
                                                gameToken: gameToken
                                            )
                                            let stoken = stokenResult.stoken
                                            let mid = stokenResult.mid

                                            let ltoken = try await MiHoYoAPI.stoken2LTokenV1(
                                                mid: mid,
                                                stoken: stoken
                                            ).ltoken

                                            var cookie = ""
                                            cookie += "stuid=" + accountId + "; "
                                            cookie += "stoken=" + stoken + "; "
                                            cookie += "ltuid=" + accountId + "; "
                                            cookie += "ltoken=" + ltoken + "; "
                                            cookie += "mid=" + mid + "; "
                                            self.cookie = cookie

                                            dismiss()
                                        } else {
                                            isNotScannedAlertShow = true
                                        }
                                    } catch {
                                        viewModel.error = error
                                    }
                                    isCheckingScanning = false
                                }
                            }
                        }

                        if Self.isMiyousheInstalled {
                            Link(
                                destination: URL(
                                    string: Self.miyousheHeader
                                )!
                            ) {
                                Text("account.qr_code_login.open_miyoushe")
                            }
                        } else {
                            Link(
                                destination: URL(
                                    string: Self.miyousheStorePage
                                )!
                            ) {
                                Text("account.qr_code_login.open_miyoushe_mas_page")
                            }
                        }

                        Button("account.qr_code_login.regenerate_qrcode") {
                            viewModel.reCreateQRCode()
                        }
                    } else {
                        ProgressView()
                    }
                } footer: {
                    Text("account.qr_code_login.footer")
                }
            }
            .alert("account.qr_code_login.not_scanned_alert", isPresented: $isNotScannedAlertShow, actions: {
                Button("sys.done") {
                    isNotScannedAlertShow.toggle()
                }
            })
            .navigationTitle("account.qr_code_login.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("sys.cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - QRCodeGetCookieViewModel

// Credit: Bill Haku for the fix in commit bef5d1a.
class QRCodeGetCookieViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        self.taskId = .init()
        Task {
            do {
                self.qrCodeAndTicket = nil
                self.qrCodeAndTicket = try await MiHoYoAPI.generateLoginQRCode(deviceId: taskId)
            } catch {
                self.error = error
            }
        }
    }

    // MARK: Public

    public func reCreateQRCode() {
        taskId = .init()
        Task {
            do {
                self.qrCodeAndTicket = nil
                self.qrCodeAndTicket = try await MiHoYoAPI.generateLoginQRCode(deviceId: taskId)
            } catch {
                self.error = error
            }
        }
    }

    // MARK: Internal

    static var shared: QRCodeGetCookieViewModel = .init()

    @Published var qrCodeAndTicket: (qrCode: CGImage, ticket: String)?
    @Published var taskId: UUID
    @Published var error: Error?
}
