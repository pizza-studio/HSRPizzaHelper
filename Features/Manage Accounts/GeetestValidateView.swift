//
//  GeetestValidateView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/6/10.
//

import HBMihoyoAPI
import SwiftUI
import WebKit

struct GeetestValidateView: UIViewRepresentable {
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        // MARK: Lifecycle

        init(_ parent: GeetestValidateView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: GeetestValidateView

        // Receive message from website
        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            if message.name == "callbackHandler" {
                if let messageBody = message.body as? String {
                    print("validate: \(messageBody)")
                    parent.finishWithValidate(messageBody)
                }
            }
        }
    }

    let challenge: String
    // swiftlint:disable:next identifier_name
    let gt: String

    let webView = WKWebView()
    @State private var isValidationObtained = false // 标识是否已获取到 validate.value 的内容

    @State var completion: (String) -> Void

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.configuration.userContentController.removeAllScriptMessageHandlers()
        webView.configuration.userContentController.add(context.coordinator, name: "callbackHandler")
        webView.customUserAgent = """
        Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148
        """
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let url = URL(string: "https://gi.pizzastudio.org/geetest/")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "challenge", value: challenge),
            URLQueryItem(name: "gt", value: gt),
        ]
        guard let finalURL = components?.url else {
            return
        }

        var request = URLRequest(url: finalURL)
        request.allHTTPHeaderFields = [
            "Referer": "https://webstatic.mihoyo.com",
        ]

        uiView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func finishWithValidate(_ validate: String) {
        completion(validate)
    }
}
