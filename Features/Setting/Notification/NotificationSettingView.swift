//
//  NotificationSettingView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/12.
//

import SwiftUI
import SwiftyUserDefaults

// MARK: - NotificationSettingView

struct NotificationSettingView: View {
    // MARK: Internal

    var body: some View {
        List {
            if authorizationStatus != nil {
                if !allowPushNotification {
                    AskForNotificationPermissionView()
                }
                NotificationSettingDetailView()
                    .disabled(!allowPushNotification)
            } else {
                ProgressView()
            }
        }
        .inlineNavigationTitle("setting.notification.title")
        .onAppear {
            Task {
                authorizationStatus = await HSRNotificationCenter.authorizationStatus()
                if authorizationStatus == .notDetermined {
                    _ = try await HSRNotificationCenter.requestAuthorization()
                }
            }
        }
    }

    // MARK: Private

    @State private var authorizationStatus: UNAuthorizationStatus?

    private var allowPushNotification: Bool {
        authorizationStatus == .authorized || authorizationStatus == .provisional || authorizationStatus == .ephemeral
    }
}

// MARK: - NotificationSettingViewModel

private class NotificationSettingViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        self.allowStaminaNotification = Defaults[\.allowStaminaNotification]
        self.staminaAdditionalNotificationNumbers = Defaults[\.staminaAdditionalNotificationNumbers]
        self.allowExpeditionNotification = Defaults[\.allowExpeditionNotification]
        self.expeditionNotificationSetting = Defaults[\.expeditionNotificationSetting]
    }

    // MARK: Internal

    @Published var staminaAdditionalNotificationNumbers: [Int] {
        didSet {
            Defaults[\.staminaAdditionalNotificationNumbers] = staminaAdditionalNotificationNumbers
        }
    }

    @Published var allowExpeditionNotification: Bool {
        didSet {
            Defaults[\.allowExpeditionNotification] = allowExpeditionNotification
        }
    }

    @Published var expeditionNotificationSetting: DailyNoteNotificationSetting.ExpeditionNotificationSetting {
        didSet {
            Defaults[\.expeditionNotificationSetting] = expeditionNotificationSetting
        }
    }

    @Published var allowStaminaNotification: Bool {
        didSet {
            Defaults[\.allowStaminaNotification] = allowStaminaNotification
        }
    }
}

// MARK: - NotificationSettingDetailView

private struct NotificationSettingDetailView: View {
    // MARK: Internal

    var body: some View {
        Section {
            NavigationLink("setting.notification.eachaccountssetting.title") {
                AccountsNotificationPermissionView()
            }
        } header: {
            Text("setting.notification.account.header")
        }
        Section {
            Toggle(
                "setting.notification.stamina.allow",
                isOn: $setting.allowStaminaNotification
            )
            NavigationLink("setting.notification.stamina.customize.title") {
                CustomizeStaminaNotificationSettingView()
            }
        } header: {
            Text("setting.notification.stamina.header")
        } footer: {
            Text("setting.notification.stamina.footer")
        }

        Section {
            Toggle(
                "setting.notification.expedition.allow",
                isOn: $setting.allowExpeditionNotification
            )
            Picker("setting.notification.expedition.method", selection: $setting.expeditionNotificationSetting) {
                ForEach(DailyNoteNotificationSetting.ExpeditionNotificationSetting.allCases, id: \.self) { setting in
                    Text(setting.description.localized())
                        .tag(setting)
                }
            }
            .disabled(!setting.allowExpeditionNotification)
        } header: {
            Text("setting.notification.expedition.header")
        }
    }

    // MARK: Private

    @State private var setting: DailyNoteNotificationSetting = .init()
}

// MARK: - CustomizeStaminaNotificationSettingView

private struct CustomizeStaminaNotificationSettingView: View {
    // MARK: Internal

    @StateObject var setting: NotificationSettingViewModel = .init()

    var body: some View {
        List {
            Section {
                if isActivated {
                    HStack {
                        Text("setting.notification.stamina.customize.add.title")
                        Spacer()
                        Text("\(numberToSave)")
                            .foregroundColor(newNumberIsValid ? .primary : .red)
                    }
                    .onTapGesture {
                        isActivated.toggle()
                    }
                    Slider(value: $newNumber, in: 10.0 ... 179.0, step: 5.0) {
                        Text("\(numberToSave)")
                            .foregroundColor(newNumberIsValid ? .primary : .red)
                    }
                    Button {
                        if newNumberIsValid {
                            withAnimation {
                                setting.staminaAdditionalNotificationNumbers.append(numberToSave)
                            }
                        } else {
                            isNumberExistAlertShow.toggle()
                        }
                    } label: {
                        Text("sys.save")
                    }
                } else {
                    Button("setting.notification.stamina.customize.add.title") {
                        withAnimation {
                            isActivated.toggle()
                        }
                    }
                }
            }
            .alert("setting.notification.stamina.customize.numexisterr", isPresented: $isNumberExistAlertShow) {
                Button("sys.ok") {
                    isNumberExistAlertShow.toggle()
                }
            }
            Section {
                ForEach(setting.staminaAdditionalNotificationNumbers, id: \.self) { number in
                    Text("\(number)")
                }
                .onDelete(perform: deleteItems)
            } header: {
                Text("setting.notification.stamina.customize.numbers.header")
            }
        }
        .toolbar {
            EditButton()
        }
        .inlineNavigationTitle("setting.notification.stamina.customize.title")
    }

    // MARK: Private

    @State private var isActivated: Bool = false

    @State private var isNumberExistAlertShow: Bool = false

    @State private var newNumber: Double = 140.0

    private var newNumberIsValid: Bool {
        !setting.staminaAdditionalNotificationNumbers.contains(numberToSave)
    }

    private var numberToSave: Int {
        Int(newNumber)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            setting.staminaAdditionalNotificationNumbers.remove(atOffsets: offsets)
        }
    }
}

// MARK: - AccountsNotificationPermissionView

private struct AccountsNotificationPermissionView: View {
    // MARK: Internal

    var body: some View {
        List {
            ForEach(accounts) { account in
                Toggle(
                    "\(account.name) (\(account.uid))",
                    isOn: allowNotificationBinding(for: account)
                )
            }
        }
        .onDisappear {
            try? viewContext.save()
        }
        .inlineNavigationTitle("setting.notification.eachaccountssetting.title")
    }

    // MARK: Private

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Account.priority, ascending: true),
        ],
        animation: .default
    ) private var accounts: FetchedResults<Account>

    private func allowNotificationBinding(for account: Account) -> Binding<Bool> {
        .init {
            account.allowNotification as? Bool ?? true
        } set: { newValue in
            account.allowNotification = newValue as NSNumber
        }
    }
}

// MARK: - AskForNotificationPermissionView

private struct AskForNotificationPermissionView: View {
    var body: some View {
        Section {
            Label {
                Text("setting.notification.notpermitted")
            } icon: {
                Image(systemSymbol: .bellSlashFill)
            }
            Button {
                UIApplication.shared
                    .open(URL(string: UIApplication.openSettingsURLString)!)
            } label: {
                Label("setting.notification.navigatetosetting", systemSymbol: .gear)
            }
        }
    }
}
