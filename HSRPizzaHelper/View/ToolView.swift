//
//  ToolView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/7/30.
//

import Foundation
import HBMihoyoAPI
import SwiftUI
import WebKit

// MARK: - ToolView

struct ToolView: View {
    enum Navigation: Hashable {
        case gacha
        case dictionary
        case map(Region)
    }

    @State var navigation: Navigation?

    var body: some View {
        NavigationSplitView {
            List(selection: $navigation) {
                Section {
                    NavigationLink(value: Navigation.gacha) {
                        Text("app.tool.warp_analysis")
                    }
                    NavigationLink(value: Navigation.dictionary) {
                        Text("app.tool.dictionary")
                    }
                }
                ThirdPartyToolsView()
            }
            .listStyle(.insetGrouped)
            .navigationTitle("app.tool.title")
        } detail: {
            NavigationStack {
                switch navigation {
                case .gacha:
                    GachaView()
                case .dictionary:
                    HSRDictionaryView()
                case let .map(region):
                    HSRMapWebView(region: region)
                case nil:
                    GachaView()
                }
            }
        }
    }
}

// MARK: - ThirdPartyToolsView

public struct ThirdPartyToolsView: View {
    // MARK: Public

    public var body: some View {
        Section {
            mapNavigationLink()
        }
    }

    // MARK: Internal

    @FetchRequest(sortDescriptors: [
        .init(
            keyPath: \Account.priority,
            ascending: true
        ),
    ]) var accounts: FetchedResults<Account>

    var availableRegions: [Region] {
        [Region](Set<Region>(accounts.compactMap { $0.server.region }))
    }

    /// 检测当前登入的账号数量，做综合统计。
    /// 如果发现同时有登入国服与国际服的话，则同时显示两个不同区服的互动地图的入口。
    /// 如果只有一个的话，会按需显示对应的那一个、且不会显示用以区分两者的 Emoji。
    /// - Returns: View()
    @ViewBuilder
    func mapNavigationLink() -> some View {
        let regions = availableRegions.isEmpty ? Region.allCases : availableRegions
        ForEach(regions, id: \.self) { region in
            let emoji = region == .mainlandChina ? " 🇨🇳" : " 🌏"
            let additionalFlag = regions.count > 1 ? emoji : ""
            #if os(OSX) || targetEnvironment(macCatalyst)
            if let url = region.hsrInteractiveMapURL {
                Link(destination: url) {
                    Text("tools.hsrInteractiveMap".localized() + additionalFlag)
                }
            } else {
                NavigationLink(value: ToolView.Navigation.map(region)) {
                    Text("tools.hsrInteractiveMap".localized() + additionalFlag)
                }
            }
            #else
            NavigationLink(value: ToolView.Navigation.map(region)) {
                Text("tools.hsrInteractiveMap".localized() + additionalFlag)
            }
            #endif
        }
    }
}

// MARK: - Region

extension Region {
    // MARK: Public

    public var hsrInteractiveMapURL: URL? {
        switch self {
        case .mainlandChina:
            URL(string: "https://webstatic.mihoyo.com/sr/app/interactive-map/index.html")
        case .global:
            URL(string: "https://act.hoyolab.com/sr/app/interactive-map/index.html")
        }
    }
}

// MARK: - HSRMapWebView

struct HSRMapWebView: UIViewRepresentable {
    class Coordinator: NSObject, WKNavigationDelegate {
        // MARK: Lifecycle

        init(_ parent: HSRMapWebView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: HSRMapWebView

        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            var jsStr = ""
            jsStr.append("let timer = setInterval(() => {")
            jsStr
                .append(
                    "const bar = document.getElementsByClassName('mhy-bbs-app-header')[0];"
                )
            jsStr
                .append(
                    "const hoyolabBar = document.getElementsByClassName('mhy-hoyolab-app-header')[0];"
                )
            jsStr.append("bar?.parentNode.removeChild(bar);")
            jsStr.append("hoyolabBar?.parentNode.removeChild(hoyolabBar);")
            jsStr.append("}, 300);")
            jsStr
                .append(
                    "setTimeout(() => {clearInterval(timer);timer = null}, 10000);"
                )
            webView.evaluateJavaScript(jsStr)
        }
    }

    var region: Region

    func makeUIView(context: Context) -> OPWebView {
        guard let url = region.hsrInteractiveMapURL
        else {
            return OPWebView()
        }
        let request = URLRequest(url: url)

        let webView = OPWebView()
        webView.configuration.userContentController.removeAllUserScripts() // 对提瓦特地图禁用自动 dark mode 支持。
        webView.navigationDelegate = context.coordinator
        webView.load(request)
        return webView
    }

    func updateUIView(_ uiView: OPWebView, context: Context) {
        if let url = region.hsrInteractiveMapURL {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
