//
//  NotificationSettingView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/12.
//

import Defaults
import DefaultsKeys
import SwiftUI

// MARK: - NotificationSettingView

struct NotificationSettingView: View {
    // MARK: Internal

    var body: some View {
        List {
            if AppConfig.isDebug {
                let buttonText = "*DEBUG* Print all notification"
                Button(buttonText) {
                    Task {
                        await HSRNotificationCenter.printAllNotifications()
                    }
                }
            }
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
        self.allowStaminaNotification = Defaults[.allowStaminaNotification]
        self.staminaAdditionalNotificationNumbers = Defaults[.staminaAdditionalNotificationNumbers]
        self.allowExpeditionNotification = Defaults[.allowExpeditionNotification]
        self.expeditionNotificationSetting = Defaults[.expeditionNotificationSetting]
        self.dailyTrainingNotificationSetting = Defaults[.dailyTrainingNotificationSetting]
        self.simulatedUniverseNotificationSetting = Defaults[.simulatedUniverseNotificationSetting]
    }

    // MARK: Internal

    @Published var staminaAdditionalNotificationNumbers: [Int] {
        didSet {
            Defaults[.staminaAdditionalNotificationNumbers] = staminaAdditionalNotificationNumbers
        }
    }

    @Published var allowExpeditionNotification: Bool {
        didSet {
            Defaults[.allowExpeditionNotification] = allowExpeditionNotification
            if !allowStaminaNotification {
                HSRNotificationCenter.deleteDailyNoteNotification(for: .expeditionEach)
                HSRNotificationCenter.deleteDailyNoteNotification(for: .expeditionSummary)
            }
        }
    }

    @Published var expeditionNotificationSetting: DailyNoteNotificationSetting.ExpeditionNotificationSetting {
        didSet {
            Defaults[.expeditionNotificationSetting] = expeditionNotificationSetting
            HSRNotificationCenter
                .deleteDailyNoteNotification(
                    for: expeditionNotificationSetting == .forEachExpedition ?
                        .expeditionSummary : .expeditionEach
                )
        }
    }

    @Published var allowStaminaNotification: Bool {
        didSet {
            Defaults[.allowStaminaNotification] = allowStaminaNotification
            HSRNotificationCenter.deleteDailyNoteNotification(for: .stamina)
            HSRNotificationCenter.deleteDailyNoteNotification(for: .staminaFull)
        }
    }

    @Published var dailyTrainingNotificationSetting: DailyNoteNotificationSetting.DailyTrainingNotificationSetting {
        didSet {
            Defaults[.dailyTrainingNotificationSetting] = dailyTrainingNotificationSetting
            HSRNotificationCenter.deleteDailyNoteNotification(for: .dailyTraining)
        }
    }

    @Published var simulatedUniverseNotificationSetting: DailyNoteNotificationSetting
        .SimulatedUniverseNotificationSetting {
        didSet {
            Defaults[.simulatedUniverseNotificationSetting] = simulatedUniverseNotificationSetting
            HSRNotificationCenter.deleteDailyNoteNotification(for: .simulatedUniverse)
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
            .disabled(!setting.allowStaminaNotification)
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
            Picker(
                "setting.notification.expedition.method",
                selection: $setting.expeditionNotificationSetting
            ) {
                ForEach(DailyNoteNotificationSetting.ExpeditionNotificationSetting.allCases, id: \.self) { setting in
                    Text(setting.description.localized())
                        .tag(setting)
                }
            }
            .disabled(!setting.allowExpeditionNotification)
        } header: {
            Text("setting.notification.expedition.header")
        }

        Section {
            Toggle("setting.notification.daily_training.toggle", isOn: allowDailyTrainingNotification)
            if let bindingDate = Binding(dailyTrainingNotificationTime) {
                DatePicker(
                    "setting.notification.daily_training.date_picker",
                    selection: bindingDate,
                    displayedComponents: .hourAndMinute
                )
            }
        } header: {
            Text("setting.notification.daily_training.header")
        } footer: {
            Text("setting.notification.daily_training.footer")
        }

        Section {
            Toggle("setting.notification.simulated_universe.toggle", isOn: allowSimulatedUniverseNotification)
            if let bindingDate = Binding(simulatedUniverseNotificationTime),
               let bindingWeekday = Binding(simulatedUniverseNotificationWeekday) {
                DatePicker(
                    "setting.notification.simulated_universe.date_picker",
                    selection: bindingDate,
                    displayedComponents: .hourAndMinute
                )
                Picker(selection: bindingWeekday) {
                    ForEach(Weekday.allCases, id: \.rawValue) { weekday in
                        Text(weekday.description)
                            .tag(weekday)
                    }
                } label: {
                    Text("setting.notification.simulated_universe.weekday_picker")
                }
            }
        } header: {
            Text("setting.notification.simulated_universe.header")
        } footer: {
            Text("setting.notification.simulated_universe.footer")
        }
    }

    // MARK: Private

    @StateObject private var setting: NotificationSettingViewModel = .init()

    private var dailyTrainingNotificationTime: Binding<Date?> {
        .init {
            switch setting.dailyTrainingNotificationSetting {
            case let .notifyAt(hour, minute):
                return Calendar.current.nextDate(
                    after: Date(),
                    matching: DateComponents(hour: hour, minute: minute),
                    matchingPolicy: .nextTime
                )!
            case .disallowed:
                return nil
            }
        } set: { date in
            setting.dailyTrainingNotificationSetting = .notifyAt(hour: date!.hour, minute: date!.minute)
        }
    }

    private var allowDailyTrainingNotification: Binding<Bool> {
        .init {
            if case .disallowed = setting.dailyTrainingNotificationSetting {
                return false
            } else {
                return true
            }
        } set: { newValue in
            if !newValue {
                setting.dailyTrainingNotificationSetting = .disallowed
            } else {
                setting.dailyTrainingNotificationSetting = .notifyAt(hour: 19, minute: 0)
            }
        }
    }

    private var simulatedUniverseNotificationTime: Binding<Date?> {
        .init {
            switch setting.simulatedUniverseNotificationSetting {
            case let .notifyAt(weekday: _, hour: hour, minute: minute):
                return Calendar.current.nextDate(
                    after: Date(),
                    matching: DateComponents(hour: hour, minute: minute),
                    matchingPolicy: .nextTime
                )!
            case .disallowed:
                return nil
            }
        } set: { date in
            switch setting.simulatedUniverseNotificationSetting {
            case let .notifyAt(weekday: weekday, hour: _, minute: _):
                setting.simulatedUniverseNotificationSetting = .notifyAt(
                    weekday: weekday,
                    hour: date!.hour,
                    minute: date!.minute
                )
            case .disallowed:
                break
            }
        }
    }

    private var simulatedUniverseNotificationWeekday: Binding<Weekday?> {
        .init {
            switch setting.simulatedUniverseNotificationSetting {
            case let .notifyAt(weekday: weekday, hour: _, minute: _):
                return Weekday(rawValue: weekday)
            case .disallowed:
                return nil
            }
        } set: { weekday in
            switch setting.simulatedUniverseNotificationSetting {
            case let .notifyAt(weekday: _, hour: hour, minute: minute):
                setting.simulatedUniverseNotificationSetting = .notifyAt(
                    weekday: weekday!.rawValue,
                    hour: hour,
                    minute: minute
                )
            case .disallowed:
                break
            }
        }
    }

    private var allowSimulatedUniverseNotification: Binding<Bool> {
        .init {
            if case .disallowed = setting.simulatedUniverseNotificationSetting {
                return false
            } else {
                return true
            }
        } set: { newValue in
            if !newValue {
                setting.simulatedUniverseNotificationSetting = .disallowed
            } else {
                setting.simulatedUniverseNotificationSetting = .notifyAt(weekday: 7, hour: 19, minute: 0)
            }
        }
    }
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
                        withAnimation {
                            isActivated.toggle()
                        }
                    }
                    Slider(value: $newNumber, in: 10.0 ... 240.0, step: 5.0) {
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
                ForEach(setting.staminaAdditionalNotificationNumbers.sorted(by: <), id: \.self) { number in
                    Text("\(number)")
                }
                .onDelete(perform: deleteItems)
            } header: {
                Text("setting.notification.stamina.customize.numbers.header")
                    .textCase(.none)
            } footer: {
                Text("setting.notification.stamina.customize.numbers.footer")
                    .textCase(.none)
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
