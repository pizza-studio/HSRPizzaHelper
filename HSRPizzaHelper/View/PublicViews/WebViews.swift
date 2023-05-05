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

// MARK: - UserPolicyView

struct UserPolicyView: View {
//    @Binding
//    var sheet: ContentViewSheetType?

    var body: some View {
        NavigationView {
            // TODO: replace with HSR version policy
            WebBrowserView(url: "https://ophelper.top/static/policy.html")
                .ignoresSafeArea()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        // TODO: use localized key
                        Button("拒绝") {
                            exit(1)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        // TODO: use localized key
                        Button("同意") {
                            Defaults[\.isPolicyShown] = true
                        }
                    }
                }
                // TODO: use localized key
                .navigationTitle("用户协议")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
