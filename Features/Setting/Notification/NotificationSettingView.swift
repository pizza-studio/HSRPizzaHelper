//
//  NotificationSettingView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/12.
//

import SwiftUI

// MARK: - NotificationSettingView

struct NotificationSettingView: View {
    // MARK: Internal

    var body: some View {
        List {
            if let authorizationStatus, allowPushNotification {
                AskForNotificationPermissionView()
            }
            NotificationSettingDetailView()
                .disabled(!allowPushNotification)
        }
        .navigationTitle("setting.notification.title")
        .onAppear {
            Task {
                authorizationStatus = await HSRNotificationCenter.authorizationStatus()
                if authorizationStatus == .notDetermined {
                    _ = try await HSRNotificationCenter.requestAuthorization()
                }
            }
        }
    }

    private var allowPushNotification: Bool {
        authorizationStatus == .authorized || authorizationStatus == .provisional || authorizationStatus == .ephemeral
    }

    // MARK: Private

    @State private var authorizationStatus: UNAuthorizationStatus?
}

// MARK: - NotificationSettingDetailView

private struct NotificationSettingDetailView: View {
    var body: some View {
        Text("")
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
