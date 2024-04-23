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

// MARK: - WebBrowserView

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

// MARK: - OPWebView

public class OPWebView: WKWebView {
    // MARK: Lifecycle

    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: Self.makeMobileConfig())
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Internal

    static let jsForDarkmodeAwareness: String = {
        let cssString = """
        @media (prefers-color-scheme: dark) {
          body {
            background: #333; color: white;
          }
          :root {
              --active-file-bg-color: #fff3f0;
              --active-file-border-color: #f22f27;
              --active-file-text-color: #d0ccc6;
              --control-text-color: #777777;
              --primary-color: #f22f27;
              --select-text-bg-color: #faa295;
              --side-bar-bg-color: #ffffff;
              --mid-1: #e8e6e3;
              --mid-2: #fafafa;
              --mid-3: #f5f5f5;
              --mid-4: #f0f0f0;
              --mid-5: #d9d9d9;
              --mid-6: #bfbfbf;
              --mid-7: #9f978b;
              --mid-8: #b0a99f;
              --mid-9: #beb8b0;
              --mid-10: #d0ccc6;
              --mid-11: #1f1f1f;
              --mid-12: #141414;
              --mid-13: #000000;
              --main-1: #fff3f0;
              --main-2: #ffd4cc;
              --main-3: #ffafa3;
              --main-4: #ff7e6f;
              --main-5: #ff5e53;
              --main-6: #f33f38;
              --main-7: #eb4242;
              --main-8: #a60a0f;
              --main-9: #80010a;
              --main-10: #590009;
              --main-11: #fff143;
          }
        }
        """
        let cssStringCleaned = cssString.replacingOccurrences(of: "\n", with: "")
        var jsString = "var style = document.createElement('style');"
        jsString.append(" style.innerHTML = '\(cssStringCleaned)';")
        jsString.append(" document.head.appendChild(style);")
        return jsString
    }()

    static func makeMobileConfig() -> WKWebViewConfiguration {
        let userScript = WKUserScript(
            source: OPWebView.jsForDarkmodeAwareness,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)

        let result = WKWebViewConfiguration()
        let pagePref = WKWebpagePreferences()
        let viewPref = WKPreferences()
        viewPref.isTextInteractionEnabled = true
        pagePref.preferredContentMode = .mobile
        result.defaultWebpagePreferences = pagePref
        result.preferences = viewPref
        result.userContentController = userContentController
        return result
    }
}
