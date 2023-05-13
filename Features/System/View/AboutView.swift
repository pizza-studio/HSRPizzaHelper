//
//  AboutView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/5/5.
//

import SwiftUI

struct AboutView: View {
    let appVersion = (
        Bundle.main
            .infoDictionary?["CFBundleShortVersionString"] as? String
    ) ?? ""
    let buildVersion = (Bundle.main.infoDictionary!["CFBundleVersion"] as? String) ?? ""

    var body: some View {
        VStack {
            Image("icon.hsrhelper")
                .resizable()
                .frame(width: 75, height: 75, alignment: .center)
                .cornerRadius(10)
                .padding()
                .padding(.top, 50)
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
    }
}
