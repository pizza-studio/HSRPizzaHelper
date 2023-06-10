//
//  GeetestValidateView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/6/10.
//

import SwiftUI
import WebKit

struct GeetestValidateView: UIViewRepresentable {
    class Coordinator: NSObject, WKNavigationDelegate {
        // MARK: Lifecycle

        init(_ parent: GeetestValidateView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: GeetestValidateView

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // 检查标识，确保只获取一次 validate.value 的内容
            guard !parent.isValidationObtained else {
                return
            }

            // 执行 JavaScript 代码获取 validate.value 的内容
            var shouldBreak = false

            // 创建一个 Timer，每隔 1 秒执行一次代码
            let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                // 在这里编写你要执行的代码
                webView.evaluateJavaScript("document.getElementById('validate').value") { result, _ in
                    if let validate = result as? String, !validate.isEmpty {
                        // 在这里处理获取到的 validate.value 内容
                        print("validate: " + validate)
                        self.parent.validate = validate
                        self.parent.isValidationObtained = true // 设置标识为已获取
                        shouldBreak = true
                    }
                }

                // 检查特定条件，满足条件时设置 shouldBreak 为 true，退出循环
                if shouldBreak {
                    timer.invalidate() // 停止 Timer
                }
            }

            // 将 Timer 添加到当前运行循环中
            RunLoop.current.add(timer, forMode: .common)

            // 进入循环，直到 Timer 停止或满足特定条件时退出
            while timer.isValid, !shouldBreak {
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
            }
        }
    }

    let webView = WKWebView()
    var isValidationObtained = false // 标识是否已获取到 validate.value 的内容
    @Binding var validate: String

    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let urlStr =
            "http://127.0.0.1:4000/geetest/?challenge=e95c1a43471095ffb08126df7ca0de2b&gt=729c3ab3d3b312bbda50e5f2ad7b6c7e"
        let url = URL(string: urlStr)
        let request = URLRequest(url: url!)
        uiView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
