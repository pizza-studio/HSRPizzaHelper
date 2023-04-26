//
//  ContentView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//

//import HBPizzaHelperAPI
import SwiftUI
import WidgetKit

// MARK: - ContentView

struct ContentView: View {
    @EnvironmentObject
    var viewModel: ViewModel

    @Environment(\.scenePhase)
    var scenePhase

    @State
    var selection: Int = UserDefaults.standard
        .integer(forKey: "AppTabIndex") == 3 ? 0 : UserDefaults.standard
        .integer(forKey: "AppTabIndex")

    @State
    var sheetType: ContentViewSheetType?
//    @State
//    var newestVersionInfos: NewestVersion?
    @State
    var isJustUpdated: Bool = false

    @AppStorage(
        "autoDeliveryResinTimerLiveActivity"
    )
    var autoDeliveryResinTimerLiveActivity: Bool =
        false

    @State
    var isPopUpViewShow: Bool = false
    @Namespace
    var animation

    @StateObject
    var storeManager: StoreManager
    @State
    var isJumpToSettingsView: Bool = false

    let appVersion = Bundle.main
        .infoDictionary!["CFBundleShortVersionString"] as! String
    let buildVersion = Int(
        Bundle.main
            .infoDictionary!["CFBundleVersion"] as! String
    )!

    @State
    var settingForAccountIndex: Int?

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
        ZStack {
            TabView(selection: index) {
                HomeView(animation: animation)
                    .tag(0)
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("Overview", systemImage: "list.bullet")
                    }
                SettingsView(storeManager: storeManager)
                    .tag(2)
//                    .environmentObject(viewModel)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .zIndex(0)

//            if let showDetailOfAccount = viewModel.showDetailOfAccount {
//                Color.black
//                    .ignoresSafeArea()
//                AccountDisplayView(
//                    account: showDetailOfAccount,
//                    animation: animation
//                )
//                .zIndex(1)
//            }
        }
        .onChange(of: scenePhase, perform: { newPhase in
            switch newPhase {
            case .active:
                // 检查是否同意过用户协议
                let isPolicyShown = UserDefaults.standard
                    .bool(forKey: "isPolicyShown")
                if !isPolicyShown { sheetType = .userPolicy }
                DispatchQueue.main.async {
                    viewModel.fetchAccount()
                }
                DispatchQueue.main.async {
                    viewModel.refreshData()
                }
                UIApplication.shared.applicationIconBadgeNumber = -1

                if isPolicyShown {
                    // 检查最新版本
//                    checkNewestVersion()
                }
            case .inactive:
                WidgetCenter.shared.reloadAllTimelines()
                #if canImport(ActivityKit)
                if autoDeliveryResinTimerLiveActivity {
                    let pinToTopAccountUUIDString = UserDefaults.standard
                        .string(forKey: "pinToTopAccountUUIDString")
                } else {
                    print("not allow autoDeliveryResinTimerLiveActivity")
                }
                #endif
            default:
                break
            }
        })
        .sheet(item: $sheetType) { item in
            switch item {
            case .userPolicy:
                UserPolicyView(sheet: $sheetType)
                    .allowAutoDismiss(false)
//            case .foundNewestVersion:
//                LatestVersionInfoView(
//                    sheetType: $sheetType,
//                    newestVersionInfos: $newestVersionInfos,
//                    isJustUpdated: $isJustUpdated
//                )
//                .allowAutoDismiss(false)
//            case .accountSetting:
//                NavigationView {
//                    AccountDetailView(
//                        account: $viewModel
//                            .accounts[settingForAccountIndex!]
//                    )
//                    .dismissableSheet(sheet: $sheetType)
//                }
            }
        }
        .onOpenURL { url in
            switch url.host {
            case "settings":
                print("jump to settings")
                isJumpToSettingsView.toggle()
                selection = 1
            case "accountSetting":
                selection = 2
//                if let accountUUIDString = URLComponents(
//                    url: url,
//                    resolvingAgainstBaseURL: true
//                )?.queryItems?.first(where: { $0.name == "accountUUIDString" })?
//                    .value,
//                    let accountIndex = viewModel.accounts
//                    .firstIndex(where: {
//                        ($0.config.uuid?.uuidString ?? "") == accountUUIDString
//                    }) {
//                    settingForAccountIndex = accountIndex
//                    sheetType = .accountSetting
//                }
            default:
                return
            }
        }
        .onAppear {
            print(
                "Locale: \(Bundle.main.preferredLocalizations.first ?? "Unknown")"
            )
        }
        .onAppear {
            UserDefaults(suiteName: "group.GenshinPizzaHelper")?
                .register(defaults: [
                    "lockscreenWidgetSyncFrequencyInMinute": 60,
                    "mainWidgetSyncFrequencyInMinute": 60,
                    "homeCoinRefreshFrequencyInHour": 30,
                    "watchWidgetUseSimplifiedMode": true,
                ])
            UserDefaults.standard.register(defaults: [
                "alreadyInstallCA": false,
                "isGachaHelpsheetShown": false,
            ])
        }
//        .navigate(
//            to: NotificationSettingView().environmentObject(viewModel),
//            when: $isJumpToSettingsView
//        )
    }

//    func checkNewestVersion() {
//        DispatchQueue.global(qos: .default).async {
//            switch AppConfig.appConfiguration {
//            case .AppStore:
//                PizzaHelperAPI.fetchNewestVersion(isBeta: false) { result in
//                    newestVersionInfos = result
//                    guard let newestVersionInfos = newestVersionInfos else {
//                        return
//                    }
//                    // 发现新版本
//                    if buildVersion < newestVersionInfos.buildVersion {
//                        let checkedUpdateVersions = (
//                            UserDefaults.standard
//                                .array(forKey: "checkedUpdateVersions") ??
//                                []
//                        ) as? [Int]
//                        // 若已有存储的检查过的版本号数组
//                        if let checkedUpdateVersions = checkedUpdateVersions {
//                            if !(
//                                checkedUpdateVersions
//                                    .contains(newestVersionInfos.buildVersion)
//                            ) {
//                                sheetType = .foundNewestVersion
//                            }
//                        } else {
//                            // 不存在该数组，仍然显示提示
//                            sheetType = .foundNewestVersion
//                        }
//                    } else {
//                        // App版本号>=服务器版本号
//                        let checkedNewestVersion = UserDefaults.standard
//                            .integer(forKey: "checkedNewestVersion")
//                        // 已经看过的版本号小于服务器版本号，说明是第一次打开该新版本
//                        if checkedNewestVersion < newestVersionInfos
//                            .buildVersion {
//                            isJustUpdated = true
//                            sheetType = .foundNewestVersion
//                            UserDefaults.standard.setValue(
//                                newestVersionInfos.buildVersion,
//                                forKey: "checkedNewestVersion"
//                            )
//                            UserDefaults.standard.synchronize()
//                        }
//                    }
//                }
//            case .Debug, .TestFlight:
//                PizzaHelperAPI.fetchNewestVersion(isBeta: true) { result in
//                    newestVersionInfos = result
//                    guard let newestVersionInfos = newestVersionInfos else {
//                        return
//                    }
//                    if buildVersion < newestVersionInfos.buildVersion {
//                        let checkedUpdateVersions = (
//                            UserDefaults.standard
//                                .array(forKey: "checkedUpdateVersions") ??
//                                []
//                        ) as? [Int]
//                        if let checkedUpdateVersions = checkedUpdateVersions {
//                            if !(
//                                checkedUpdateVersions
//                                    .contains(newestVersionInfos.buildVersion)
//                            ) {
//                                sheetType = .foundNewestVersion
//                            }
//                        } else {
//                            sheetType = .foundNewestVersion
//                        }
//                    } else {
//                        let checkedNewestVersion = UserDefaults.standard
//                            .integer(forKey: "checkedNewestVersion")
//                        if checkedNewestVersion < newestVersionInfos
//                            .buildVersion {
//                            isJustUpdated = true
//                            sheetType = .foundNewestVersion
//                            UserDefaults.standard.setValue(
//                                newestVersionInfos.buildVersion,
//                                forKey: "checkedNewestVersion"
//                            )
//                            UserDefaults.standard.synchronize()
//                        }
//                    }
//                }
//            }
//        }
//    }
}

// MARK: - ContentViewSheetType

enum ContentViewSheetType: Identifiable {
    case userPolicy
//    case foundNewestVersion
//    case accountSetting

    // MARK: Internal

    var id: Int {
        hashValue
    }
}

