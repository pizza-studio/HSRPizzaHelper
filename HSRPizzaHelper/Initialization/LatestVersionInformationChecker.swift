//
//  LatestVersionInformationChecker.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/8.
//

import Defaults
import DefaultsKeys
import Foundation
import HBPizzaHelperAPI
import SwiftUI

extension View {
    func checkAndPopLatestVersionSheet() -> some View {
        modifier(LatestVersionInformationChecker())
    }
}

// MARK: - LatestVersionInformationChecker

private struct LatestVersionInformationChecker: ViewModifier {
    // MARK: Internal

    let buildVersion = Int((Bundle.main.infoDictionary!["CFBundleVersion"] as? String) ?? "") ?? 0

    func body(content: Content) -> some View {
        content
            .onAppBecomeActive {
                Task {
                    await checkNewestVersion()
                }
            }
            .sheet(isPresented: $isSheetShow) {
                LatestVersionInfoView(
                    isShow: $isSheetShow,
                    newestVersionInfos: $newestVersionInfos,
                    isJustUpdated: $isJustUpdated
                )
                .allowAutoDismiss(false)
            }
    }

    func checkNewestVersion() async {
        guard Defaults[.isPolicyShown] == true else {
            return
        }
        let isBeta: Bool
        switch AppConfig.appConfiguration {
        case .appStore:
            isBeta = false
        case .debug, .testFlight:
            isBeta = true
        }
        do {
            try await PizzaHelperAPI.fetchNewestVersion(isBeta: isBeta) { result in
                newestVersionInfos = result
                guard let newestVersionInfos = newestVersionInfos else {
                    return
                }
                if buildVersion < newestVersionInfos.buildVersion,
                   !Defaults[.checkedUpdateVersions]
                   .contains(newestVersionInfos.buildVersion) {
                    isSheetShow.toggle()
                } else if Defaults[.checkedNewestVersion] < newestVersionInfos
                    .buildVersion {
                    isJustUpdated = true
                    isSheetShow.toggle()
                    Defaults[.checkedNewestVersion] = newestVersionInfos.buildVersion
                }
            }
        } catch {}
    }

    // MARK: Private

    @State private var newestVersionInfos: NewestVersion?
    @State private var isJustUpdated: Bool = false

    @State private var isSheetShow: Bool = false
}

// MARK: - LatestVersionInfoView

struct LatestVersionInfoView: View {
    // MARK: Internal

    @Binding var isShow: Bool
    @Binding var newestVersionInfos: NewestVersion?
    @Binding var isJustUpdated: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        versionView()
                        Spacer()
                        Image("AppIconHD")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                    }
                    Divider().padding(.bottom)
                    updateAnnouncementView()
                    if !isJustUpdated {
                        let pair = AppConfig.appConfiguration.urlTextPair
                        Link(destination: pair.url) {
                            Text(String(localized: .init(stringLiteral: pair.i18nKey)))
                        }
                        .padding(.top)
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationTitle(isJustUpdated ? "update.thank" : "update.found")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("update.read") {
                        updateDidRead()
                    }
                }
            }
        }
    }

    // MARK: Private

    @ViewBuilder
    private func versionView() -> some View {
        let shortVersion: String = newestVersionInfos?.shortVersion ?? "Error"
        let buildVersion = " (\(newestVersionInfos?.buildVersion ?? -1))"
        Text(shortVersion).font(.largeTitle).bold() + Text(buildVersion).font(.caption).foregroundColor(.secondary)
    }

    @ViewBuilder
    private func updateAnnouncementView() -> some View {
        if !getLocalizedNoticeInfos(meta: newestVersionInfos!).isEmpty {
            Text("update.announcement")
                .bold()
                .font(.title2)
                .padding(.vertical, 2)
            ForEach(getLocalizedNoticeInfos(meta: newestVersionInfos!), id: \.self) { item in
                Text(verbatim: "∙ ") + Text(item.toAttributedString())
            }
            Divider().padding(.vertical)
        }
        Text("update.content").bold().font(.title2).padding(.vertical, 2)
        if newestVersionInfos != nil {
            ForEach(
                getLocalizedUpdateInfos(meta: newestVersionInfos!),
                id: \.self
            ) { item in
                Text(verbatim: "∙ ") + Text(item.toAttributedString())
            }
        } else {
            Text("Error")
        }
    }

    private func getLocalizedUpdateInfos(meta: NewestVersion) -> [String] {
        let locale = Bundle.main.preferredLocalizations.first
        switch locale {
        case "zh-Hans":
            return meta.updates.zhcn
        case "zh-Hant", "zh-HK":
            return meta.updates.zhtw ?? meta.updates.zhcn
        case "en":
            return meta.updates.en
        case "ja":
            return meta.updates.ja
        default:
            return meta.updates.en
        }
    }

    private func getLocalizedNoticeInfos(meta: NewestVersion) -> [String] {
        let locale = Bundle.main.preferredLocalizations.first
        switch locale {
        case "zh-Hans":
            return meta.notice.zhcn
        case "zh-Hant", "zh-HK":
            return meta.notice.zhtw ?? meta.notice.zhcn
        case "en":
            return meta.notice.en
        case "ja":
            return meta.notice.ja
        default:
            return meta.notice.en
        }
    }

    private func updateDidRead() {
        var checkedUpdateVersions = Defaults[.checkedUpdateVersions]
        checkedUpdateVersions.append(newestVersionInfos!.buildVersion)
        Defaults[.checkedUpdateVersions] = checkedUpdateVersions
        if isJustUpdated {
            let showRate = Bool.random()
            if showRate {
                DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                    ReviewHandler.requestReview()
                }
            }
        }
        isShow.toggle()
    }
}

extension AppConfiguration {
    fileprivate var urlTextPair: (url: URL, i18nKey: String) {
        switch self {
        case .debug, .testFlight:
            return (URL(string: "itms-beta://beta.itunes.apple.com/v1/app/6448894222")!, "update.move.tf")
        case .appStore:
            return (URL(string: "itms-apps://apps.apple.com/us/app/id6448894222")!, "update.move.as")
        }
    }
}

// MARK: - HistoryVersionInfoView

struct HistoryVersionInfoView: View {
    // MARK: Internal

    let buildVersion = Int((Bundle.main.infoDictionary!["CFBundleVersion"] as? String) ?? "") ?? 0
    @State var newestVersionInfos: NewestVersion?
    @State var isJustUpdated: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    newestVersionMetaTexts()
                    Spacer()
                    Image("AppIconHD")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(10)
                }
                Divider().padding(.bottom)
                updateAnnouncementView()
                if !isJustUpdated {
                    let pair = AppConfig.appConfiguration.urlTextPair
                    Link(destination: pair.url) {
                        Text(String(localized: .init(stringLiteral: pair.i18nKey)))
                    }
                    .padding(.top)
                } else {
                    justUpdatedView()
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        .navigationTitle(isJustUpdated ? "update.thank" : "update.found")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Task {
                await checkNewestVersion()
            }
        }
    }

    func getLocalizedUpdateInfos(meta: NewestVersion) -> [String] {
        let locale = Bundle.main.preferredLocalizations.first
        switch locale {
        case "zh-Hans":
            return meta.updates.zhcn
        case "zh-Hant", "zh-HK":
            return meta.updates.zhtw ?? meta.updates.zhcn
        case "en":
            return meta.updates.en
        case "ja":
            return meta.updates.ja
        default:
            return meta.updates.en
        }
    }

    func getLocalizedNoticeInfos(meta: NewestVersion) -> [String] {
        let locale = Bundle.main.preferredLocalizations.first
        switch locale {
        case "zh-Hans":
            return meta.notice.zhcn
        case "zh-Hant", "zh-HK":
            return meta.notice.zhtw ?? meta.notice.zhcn
        case "en":
            return meta.notice.en
        case "ja":
            return meta.notice.ja
        default:
            return meta.notice.en
        }
    }

    func getLocalizedHistoryUpdateInfos(
        meta: NewestVersion
            .VersionHistory
    )
        -> [String] {
        let locale = Bundle.main.preferredLocalizations.first
        switch locale {
        case "zh-Hans":
            return meta.updates.zhcn
        case "zh-Hant", "zh-HK":
            return meta.updates.zhtw ?? meta.updates.zhcn
        case "en":
            return meta.updates.en
        case "ja":
            return meta.updates.ja
        default:
            return meta.updates.en
        }
    }

    func checkNewestVersion() async {
        let isBeta: Bool
        switch AppConfig.appConfiguration {
        case .appStore:
            isBeta = false
        case .debug, .testFlight:
            isBeta = true
        }
        do {
            try await PizzaHelperAPI.fetchNewestVersion(isBeta: isBeta) { result in
                newestVersionInfos = result
                guard let newestVersionInfos = newestVersionInfos else {
                    return
                }
                if buildVersion >= newestVersionInfos.buildVersion {
                    isJustUpdated = true
                }
            }
        } catch {}
    }

    // MARK: Private

    @ViewBuilder
    private func newestVersionMetaTexts() -> some View {
        let shortVersion = newestVersionInfos?.shortVersion ?? "Error"
        let buildVersion = " (\(newestVersionInfos?.buildVersion ?? -1))"
        Text(shortVersion).font(.largeTitle).bold() + Text(buildVersion).font(.caption).foregroundColor(.secondary)
    }

    @ViewBuilder
    private func updateAnnouncementView() -> some View {
        if let newestVersionInfos = newestVersionInfos {
            if !getLocalizedNoticeInfos(meta: newestVersionInfos)
                .isEmpty {
                Text("update.announcement")
                    .bold()
                    .font(.title2)
                    .padding(.vertical, 2)
                ForEach(
                    getLocalizedNoticeInfos(meta: newestVersionInfos),
                    id: \.self
                ) { item in
                    Text("∙ ") + Text(item.toAttributedString())
                }
                Divider()
                    .padding(.vertical)
            }
        }
        Text("update.content")
            .bold()
            .font(.title2)
            .padding(.vertical, 2)
        if newestVersionInfos != nil {
            ForEach(
                getLocalizedUpdateInfos(meta: newestVersionInfos!),
                id: \.self
            ) { item in
                Text("∙ ") + Text(item.toAttributedString())
            }
        } else {
            Text("Error")
        }
    }

    @ViewBuilder
    private func justUpdatedView() -> some View {
        if let newestVersionInfos = newestVersionInfos {
            Divider().padding(.vertical)
            Text("update.history.title").bold().font(.title2).padding(.vertical, 2)
            ForEach(newestVersionInfos.updateHistory, id: \.buildVersion) { versionItem in
                Text(verbatim: "\(versionItem.shortVersion) (\(versionItem.buildVersion))")
                    .bold()
                    .padding(.top, 1)
                ForEach(getLocalizedHistoryUpdateInfos(meta: versionItem), id: \.self) { item in
                    Text("∙ ") + Text(item.toAttributedString())
                }
            }
        }
    }
}
