// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import SwiftUI

// MARK: - NewsKitHSR.NewsElementView

extension NewsKitHSR {
    public struct NewsElementView: View {
        // MARK: Lifecycle

        public init(_ givenData: any NewsElement) {
            self.data = givenData
        }

        // MARK: Public

        public let data: any NewsElement

        public var body: some View {
            coreBody
                .fontWidth(.condensed)
        }

        @ViewBuilder public var coreBody: some View {
            Section {
                Text(verbatim: data.title).bold()
                Text(verbatim: data.description)
                    .font(.footnote)
                    .foregroundStyle(.primary.opacity(0.8))
            } footer: {
                HStack {
                    if let event = data as? NewsKitHSR.EventElement {
                        Text(verbatim: event.dateStartedStr)
                        Spacer()
                        Text(verbatim: "→")
                        Spacer()
                        Text(verbatim: event.dateEndedStr)
                    } else {
                        Text(verbatim: data.dateCreatedStr)
                        Spacer()
                    }
                }.frame(maxWidth: .infinity)
            }
            .compositingGroup()
        }
    }
}

// MARK: - View + View

#if hasFeature(RetroactiveAttribute)
extension [any NewsKitHSR.NewsElement]: @retroactive View {}
#else
extension [any NewsKitHSR.NewsElement]: View {}
#endif

extension [any NewsKitHSR.NewsElement] {
    public var body: some View {
        List {
            ForEach(self, id: \.id) { newsElement in
                NewsKitHSR.NewsElementView(newsElement)
            }
        }
    }
}

// MARK: - NewsKitHSR.NewsView

extension NewsKitHSR {
    public struct NewsView: View {
        // MARK: Lifecycle

        public init(_ aggregated: NewsKitHSR.AggregatedResult) {
            coordinator.data = aggregated
        }

        public init() {
            coordinator.updateData()
        }

        // MARK: Public

        public var data: NewsKitHSR.AggregatedResult { coordinator.data }

        // swiftlint:disable sf_safe_symbol
        public var body: some View {
            NavigationStack {
                currentTabContent
                    .toolbar {
                        #if os(OSX) || targetEnvironment(macCatalyst)
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("", systemImage: "arrow.clockwise") {
                                coordinator.updateData()
                            }
                        }
                        #endif
                        ToolbarItem(placement: .topBarTrailing) {
                            Picker("", selection: $currentTab) {
                                Label("news.Notices", systemImage: "info.circle")
                                    .tag(NewsKitHSR.NewsType.notices)
                                Label("news.Events", systemImage: "calendar.badge.clock")
                                    .tag(NewsKitHSR.NewsType.events)
                                Label("news.Intels", systemImage: "newspaper")
                                    .tag(NewsKitHSR.NewsType.intels)
                            }
                            .padding(4)
                            .pickerStyle(.segmented)
                        }
                    }
            }
            .navigationTitle(currentPageTitle)
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                coordinator.updateData()
            }
        }

        // swiftlint:enable sf_safe_symbol

        // MARK: Private

        private class Coordinator: ObservableObject {
            // MARK: Lifecycle

            public init(data: NewsKitHSR.AggregatedResult) {
                self.data = data
            }

            public init() {
                self.data = .init()
            }

            // MARK: Public

            public func updateData() {
                Task {
                    data = await (try? NewsKitHSR.fetchAndAggregate()) ?? .init()
                }
            }

            // MARK: Internal

            @Published var data: NewsKitHSR.AggregatedResult
        }

        @ObservedObject private var coordinator: Coordinator = .init()

        @State private var currentTab: NewsKitHSR.NewsType = .notices

        private var currentPageTitle: LocalizedStringKey {
            switch currentTab {
            case .events: "news.Events"
            case .intels: "news.Intels"
            case .notices: "news.Notices"
            }
        }

        private var currentTabContent: some View {
            switch currentTab {
            case .events: AnyView(data.events)
            case .intels: AnyView(data.intels)
            case .notices: AnyView(data.notices)
            }
        }
    }
}

#Preview {
    let sampleEventData = """
    [
      {
        "id": "28551245",
        "createdAt": 1715603528,
        "description": "参与分享必得2.2角色永久评论装扮×4，还有机会获得星琼奖励~",
        "endAt": 1717948799,
        "startAt": 1715529600,
        "title": "【星琼奖励】参与2.2版本讨论活动，赢取星琼和永久评论装扮奖励！",
        "url": "https://www.hoyolab.com/article/28551245"
      }
    ]
    """

    let sampleIntelData = """
    [
      {
        "id": "28846635",
        "createdAt": 1716177609,
        "description": "影业大亨「钟表匠」神秘失踪，克劳克影业群龙无首，
    激烈的市场竞争中屡屡受挫……钟表小子究竟何去何从？
    这次帕姆变身大影视家，参与《美梦往事》系列影片剪辑与拍摄，尝试梦境动画的制作技法！
    诚邀开拓者品鉴由大影视家帕姆参与制作拍摄的《美梦往事》系列动画！",
        "title": "大影视家帕姆｜美梦往事篇",
        "url": "https://www.hoyolab.com/article/28846635"
      }
    ]
    """
    let sampleNoticeData = """
    [
      {
        "id": "28802787",
        "createdAt": 1716096992,
        "description": "您好，开拓者： 列车组将于近期进行PC启动器版本升级，升级完成后，PC启动器将更新至2.33.7版本。
    ▌更新时间 2024/05/20 14:00（UTC+8) 开始
    ▌更新方式 收到启动器更新通知后，开拓者点击【更新】按钮即可进行更新操作。
    ▌设备要求
    ■PC端推荐配置如下：
    设备：i7/8G内存/独立显卡、GTX1060及以上配置
    系统：win10 64位或以上系统
    ■PC端支持配置如下：
    设备：i3/6G内存/独立显卡、GTX650及以上配置
    系统：win7 64位或以上系统",
        "title": "《崩坏：星穹铁道》PC启动器更新预告",
        "url": "https://www.hoyolab.com/article/28802787"
      }
    ]
    """
    // swiftlint:disable force_try
    let aggregated = NewsKitHSR.AggregatedResult(
        events: try! NewsKitHSR.EventElement.decodeArrayFrom(string: sampleEventData),
        intels: try! NewsKitHSR.IntelElement.decodeArrayFrom(string: sampleIntelData),
        notices: try! NewsKitHSR.NoticeElement.decodeArrayFrom(string: sampleNoticeData)
    )
    // swiftlint:enable force_try

    return NewsKitHSR.NewsView(aggregated)
}
