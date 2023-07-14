//
//  AboutView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/5/5.
//

import SwiftUI
import SwiftyUserDefaults

// MARK: - AboutView

struct AboutView: View {
    let appVersion = (
        Bundle.main
            .infoDictionary?["CFBundleShortVersionString"] as? String
    ) ?? ""
    let buildVersion = (Bundle.main.infoDictionary!["CFBundleVersion"] as? String) ?? ""

    @State var isDevelopSettingsShow = false

    var body: some View {
        VStack {
            Image("icon.hsrhelper")
                .resizable()
                .frame(width: 75, height: 75, alignment: .center)
                .cornerRadius(10)
                .padding()
                .padding(.top, 50)
                .onTapGesture(count: 5) {
                    isDevelopSettingsShow.toggle()
                }
            Text("app.name")
                .font(.title3)
                .fontWeight(.regular)
                .foregroundColor(.primary)
            Text("\(appVersion) (\(buildVersion))")
                .font(.callout)
                .fontWeight(.regular)
                .foregroundColor(.secondary)
            Spacer()

            NavigationLink(destination: ThanksView()) {
                Text("sys.thank.title")
                    .padding()
                    .font(.callout)
            }
            Text("app.note.3")
                .font(.caption2)
            Text("app.note.1")
                .font(.caption2)
            Text("app.note.2")
                .font(.caption2)
        }
        .sheet(isPresented: $isDevelopSettingsShow) {
            DevelopSettings(isShow: $isDevelopSettingsShow)
        }
    }
}

// MARK: - DevelopSettings

struct DevelopSettings: View {
    @Binding var isShow: Bool
    @State var isAlertShow = false
    @State var alertMessage = ""

    var body: some View {
        NavigationView {
            List {
                Button("Clean All User Defaults Key") {
                    Defaults.removeAll()
                }
                .buttonStyle(.borderless)

//                Button("Print all notification") {
//                }
//                .buttonStyle(.borderless)

                NavigationLink("All Notifications") {
                    ScrollView {
                        Text(alertMessage)
                            .font(.footnote)
                            .padding()
                            .onAppear {
                                Task {
                                    for message in await HSRNotificationCenter.getAllNotificationsDescriptions() {
                                        alertMessage += message + "\n"
                                    }
                                }
                            }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("sys.done") {
                        isShow.toggle()
                    }
                }
            }
            .navigationTitle("Develop Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
