//
//  LatestVersionInfoView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/5/8.
//

import HBPizzaHelperAPI
import StoreKit
import SwiftUI

struct LatestVersionInfoView: View {
    @Binding var sheetType: ContentViewSheetType?
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
                            if #available(iOS 15.0, *) {
                                Text("∙ ") + Text(item.toAttributedString())
                            } else {
                                // Fallback on earlier versions
                                Text("- \(item)")
                            }
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
                            if #available(iOS 15.0, *) {
                                Text("∙ ") + Text(item.toAttributedString())
                            } else {
                                // Fallback on earlier versions
                                Text("- \(item)")
                            }
                        }
                    } else {
                        Text("Error")
                    }
                    if !isJustUpdated {
                        switch AppConfig.appConfiguration {
                        case .debug, .testFlight:
                            // TODO: Change to HSR App ID
                            Link(
                                destination: URL(
                                    string: "itms-beta://beta.itunes.apple.com/v1/app/1635319193"
                                )!
                            ) {
                                Text("update.move.tf")
                            }
                            .padding(.top)
                        case .appStore:
                            // TODO: Change to HSR App ID
                            Link(
                                destination: URL(
                                    string: "itms-apps://apps.apple.com/us/app/id1635319193"
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
                        var checkedUpdateVersions = Defaults[\.checkedUpdateVersions]
                        checkedUpdateVersions
                            .append(newestVersionInfos!.buildVersion)
                        Defaults[\.checkedUpdateVersions] = checkedUpdateVersions
                        if isJustUpdated {
                            let showRate = Bool.random()
                            if showRate {
                                DispatchQueue.global()
                                    .asyncAfter(deadline: .now() + 2) {
                                        ReviewHandler.requestReview()
                                    }
                            }
                        }
                        sheetType = nil
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
