//
//  WebViews.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/5/5.
//  封装了使用WKWebView的各种网页

import SafariServices
import SwiftUI
import WebKit

// MARK: - SFSafariViewWrapper

struct SFSafariViewWrapper: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<Self>
    )
        -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<SFSafariViewWrapper>
    ) {}
}

// MARK: - WebBroswerView

struct WebBrowserView: UIViewRepresentable {
    var url: String = ""

    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: url)
        else {
            return WKWebView()
        }
        let request = URLRequest(url: url)
        let webview = WKWebView()
        webview.load(request)
        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}

// MARK: - EventDetailWebView

struct EventDetailWebView: UIViewRepresentable {
    // MARK: Lifecycle

    init(banner: String, nameFull: String, content: String) {
        self.banner = banner
        self.nameFull = nameFull
        self.content = content
    }

    // MARK: Internal

    class Coordinator: NSObject, WKScriptMessageHandler, WKUIDelegate {
        // MARK: Lifecycle

        init(_ parent: EventDetailWebView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: EventDetailWebView

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            print("message: \(message.name)")
            switch message.name {
            case "getArticleInfoBeforeLoaded":
                if let articleData = try? JSONSerialization.data(
                    withJSONObject: parent.getArticleDic(),
                    options: JSONSerialization.WritingOptions.prettyPrinted
                ) {
                    let articleInfo = String(
                        data: articleData,
                        encoding: String.Encoding.utf8
                    )

                    let inputJS = "updateArticleInfo(\(articleInfo ?? ""))"
                    print(inputJS)
                    parent.webView.evaluateJavaScript(inputJS)
                }
            default:
                break
            }
        }
    }

    @Environment(\.colorScheme)
    var colorScheme
    let webView = WKWebView()
//    let htmlContent: String
    let banner: String
    let nameFull: String
    let content: String
    var articleDic = [
        // 主题颜色：亮色：""，暗色："bg-amberDark-500 text-amberHalfWhite"
        "themeClass": "",
        "banner": "",
        "nameFull": "",
        "description": "",
    ]

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.configuration.userContentController
            .removeScriptMessageHandler(forName: "getArticleInfoBeforeLoaded")
    }

    func makeUIView(context: Context) -> WKWebView {
        webView.configuration.userContentController.add(
            makeCoordinator(),
            name: "getArticleInfoBeforeLoaded"
        )
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.uiDelegate = context.coordinator
        if let startPageURL = Bundle.main.url(
            forResource: "article",
            withExtension: "html"
        ) {
            uiView.loadFileURL(
                startPageURL,
                allowingReadAccessTo: Bundle.main.bundleURL
            )
        }
    }

    func getArticleDic() -> [String: String] {
        if colorScheme == .dark {
            let articleDic = [
                "themeClass": "bg-amberDark-800 text-amberHalfWhite", // 主题颜色
                "banner": banner,
                "nameFull": nameFull,
                "description": content,
            ]
            return articleDic
        } else {
            let articleDic = [
                "themeClass": "", // 主题颜色
                "banner": banner,
                "nameFull": nameFull,
                "description": content,
            ]
            return articleDic
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// MARK: - UserPolicyView

struct UserPolicyView: View {
//    @Binding
//    var sheet: ContentViewSheetType?

    var body: some View {
        NavigationView {
            WebBrowserView(url: "https://ophelper.top/static/policy.html")
                .ignoresSafeArea()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("拒绝") {
                            exit(1)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("同意") {
                            UserDefaults.standard.setValue(
                                true,
                                forKey: "isPolicyShown"
                            )
                            UserDefaults.standard.synchronize()
//                            sheet = nil
                        }
                    }
                }
                .navigationTitle("用户协议")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
