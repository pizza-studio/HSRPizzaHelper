//
//  WebBrowserView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//

import SwiftUI
import WebKit

struct WebBroswerView: UIViewRepresentable {
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
