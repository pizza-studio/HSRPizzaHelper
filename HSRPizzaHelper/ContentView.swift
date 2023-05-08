//
//  ContentView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import CoreData
import HBPizzaHelperAPI
import SFSafeSymbols
import SwiftUI

// MARK: - ContentView

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @State var sheetType: ContentViewSheetType?
    @State var newestVersionInfos: NewestVersion?
    @State var isJustUpdated: Bool = false
    @State var selection: Int = 0
    let buildVersion = Int((Bundle.main.infoDictionary!["CFBundleVersion"] as? String) ?? "") ?? 0

    var index: Binding<Int> { Binding(
        get: { selection },
        set: {
            if $0 != selection {
                simpleTaptic(type: .medium)
            }
            selection = $0
            UserDefaults.standard.setValue($0, forKey: "AppTabIndex")
            UserDefaults.standard.synchronize()
        }
    ) }

    var body: some View {
        TabView(selection: index) {
            HomeView()
                .tag(0)
                .tabItem {
                    Label("tab.home", systemSymbol: .listBullet)
                }
            SettingView()
                .tag(1)
                .tabItem {
                    Label("tab.settings", systemSymbol: .gear)
                }
        }
        .onChange(of: scenePhase, perform: { newPhase in
            switch newPhase {
            case .active:
                // 检查是否同意过用户协议
                let isPolicyShown = Defaults[\.isPolicyShown]
                if !isPolicyShown { sheetType = .userPolicy }
                UIApplication.shared.applicationIconBadgeNumber = -1

                if isPolicyShown {
                    // 检查最新版本
                    checkNewestVersion()
                }
            case .inactive:
                break
            default:
                break
            }
        })
        .sheet(item: $sheetType) { item in
            switch item {
            case .userPolicy:
                UserPolicyView(sheet: $sheetType)
                    .allowAutoDismiss(false)
            case .foundNewestVersion:
                LatestVersionInfoView(
                    sheetType: $sheetType,
                    newestVersionInfos: $newestVersionInfos,
                    isJustUpdated: $isJustUpdated
                )
                .allowAutoDismiss(false)
            }
        }
    }

    func checkNewestVersion() {
        DispatchQueue.global(qos: .default).async {
            switch AppConfig.appConfiguration {
            case .appStore:
                PizzaHelperAPI.fetchNewestVersion(isBeta: false) { result in
                    newestVersionInfos = result
                    guard let newestVersionInfos = newestVersionInfos else {
                        return
                    }
                    if buildVersion < newestVersionInfos.buildVersion {
                        let checkedUpdateVersions = Defaults[\.checkedUpdateVersions]
                        if !(checkedUpdateVersions.contains(newestVersionInfos.buildVersion)) {
                            sheetType = .foundNewestVersion
                        }
                    } else {
                        let checkedNewestVersion = Defaults[\.checkedNewestVersion]
                        if checkedNewestVersion < newestVersionInfos
                            .buildVersion {
                            isJustUpdated = true
                            sheetType = .foundNewestVersion
                            Defaults[\.checkedNewestVersion] = newestVersionInfos.buildVersion
                        }
                    }
                }
            case .debug, .testFlight:
                PizzaHelperAPI.fetchNewestVersion(isBeta: true) { result in
                    newestVersionInfos = result
                    guard let newestVersionInfos = newestVersionInfos else {
                        return
                    }
                    if buildVersion < newestVersionInfos.buildVersion {
                        let checkedUpdateVersions = Defaults[\.checkedUpdateVersions]
                        if !(checkedUpdateVersions.contains(newestVersionInfos.buildVersion)) {
                            sheetType = .foundNewestVersion
                        }
                    } else {
                        let checkedNewestVersion = Defaults[\.checkedNewestVersion]
                        if checkedNewestVersion < newestVersionInfos
                            .buildVersion {
                            isJustUpdated = true
                            sheetType = .foundNewestVersion
                            Defaults[\.checkedNewestVersion] = newestVersionInfos.buildVersion
                        }
                    }
                }
            }
        }
    }
}

// MARK: - ContentViewSheetType

enum ContentViewSheetType: Identifiable {
    case userPolicy
    case foundNewestVersion

    // MARK: Internal

    var id: Int {
        hashValue
    }
}
