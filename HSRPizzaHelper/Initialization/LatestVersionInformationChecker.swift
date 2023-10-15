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
    @Binding var isShow: Bool
    @Binding var newestVersionInfos: NewestVersion?
    @Binding var isJustUpdated: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text(newestVersionInfos?.shortVersion ?? "Error")
                            .font(.largeTitle).bold() +
                            Text(
                                " (\(String(newestVersionInfos?.buildVersion ?? -1)))"
                            )
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Image("AppIconHD")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                    }
                    Divider()
                        .padding(.bottom)
                    if !getLocalizedNoticeInfos(meta: newestVersionInfos!)
                        .isEmpty {
                        Text("update.announcement")
                            .bold()
                            .font(.title2)
                            .padding(.vertical, 2)
                        ForEach(
                            getLocalizedNoticeInfos(meta: newestVersionInfos!),
                            id: \.self
                        ) { item in
                            Text("∙ ") + Text(item.toAttributedString())
                        }
                        Divider()
                            .padding(.vertical)
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
                    if !isJustUpdated {
                        switch AppConfig.appConfiguration {
                        case .debug, .testFlight:
                            Link(
                                destination: URL(
                                    string: "itms-beta://beta.itunes.apple.com/v1/app/6448894222"
                                )!
                            ) {
                                Text("update.move.tf")
                            }
                            .padding(.top)
                        case .appStore:
                            Link(
                                destination: URL(
                                    string: "itms-apps://apps.apple.com/us/app/id6448894222"
                                )!
                            ) {
                                Text("update.move.as")
                            }
                            .padding(.top)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            .navigationTitle(isJustUpdated ? "update.thank" : "update.found")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("update.read") {
                        var checkedUpdateVersions = Defaults[.checkedUpdateVersions]
                        checkedUpdateVersions
                            .append(newestVersionInfos!.buildVersion)
                        Defaults[.checkedUpdateVersions] = checkedUpdateVersions
                        if isJustUpdated {
                            let showRate = Bool.random()
                            if showRate {
                                DispatchQueue.global()
                                    .asyncAfter(deadline: .now() + 2) {
                                        ReviewHandler.requestReview()
                                    }
                            }
                        }
                        isShow.toggle()
                    }
                }
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
}

// MARK: - HistoryVersionInfoView

struct HistoryVersionInfoView: View {
    let buildVersion = Int((Bundle.main.infoDictionary!["CFBundleVersion"] as? String) ?? "") ?? 0
    @State var newestVersionInfos: NewestVersion?
    @State var isJustUpdated: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text(newestVersionInfos?.shortVersion ?? "Error")
                        .font(.largeTitle).bold() +
                        Text(
                            " (\(String(newestVersionInfos?.buildVersion ?? -1)))"
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Image("AppIconHD")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .cornerRadius(10)
                }
                Divider()
                    .padding(.bottom)
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
                if !isJustUpdated {
                    switch AppConfig.appConfiguration {
                    case .debug, .testFlight:
                        Link(
                            destination: URL(
                                string: "itms-beta://beta.itunes.apple.com/v1/app/6448894222"
                            )!
                        ) {
                            Text("update.move.tf")
                        }
                        .padding(.top)
                    case .appStore:
                        Link(
                            destination: URL(
                                string: "itms-apps://apps.apple.com/us/app/id6448894222"
                            )!
                        ) {
                            Text("update.move.as")
                        }
                        .padding(.top)
                    }
                } else {
                    if let newestVersionInfos = newestVersionInfos {
                        Divider()
                            .padding(.vertical)
                        Text("update.history.title")
                            .bold()
                            .font(.title2)
                            .padding(.vertical, 2)
                        ForEach(
                            newestVersionInfos.updateHistory,
                            id: \.buildVersion
                        ) { versionItem in
                            Text(
                                "\(versionItem.shortVersion) (\(String(versionItem.buildVersion)))"
                            )
                            .bold()
                            .padding(.top, 1)
                            ForEach(
                                getLocalizedHistoryUpdateInfos(
                                    meta: versionItem
                                ),
                                id: \.self
                            ) { item in
                                Text("∙ ") + Text(item.toAttributedString())
                            }
                        }
                    }
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
    ) -> [String] {
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
}
