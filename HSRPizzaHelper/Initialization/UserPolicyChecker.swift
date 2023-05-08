//
//  UserPolicy.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/8.
//

import Foundation
import SwiftUI

// MARK: - PolicyChecker

private struct PolicyChecker: ViewModifier {
    // MARK: Internal

    func body(content: Content) -> some View {
        content
            .onAppBecomeActive {
                popPolicySheetIfHasNotShown()
            }
            .sheet(isPresented: $isPolicySheetShow) {
                UserPolicyView(isShow: $isPolicySheetShow)
                    .allowAutoDismiss(false)
            }
    }

    func popPolicySheetIfHasNotShown() {
        if !Defaults[\.isPolicyShown] {
            isPolicySheetShow.toggle()
        }
    }

    // MARK: Private

    @State private var isPolicySheetShow: Bool = false
}

extension View {
    func checkAndPopPolicySheet() -> some View {
        modifier(PolicyChecker())
    }
}

// MARK: - UserPolicyView

private struct UserPolicyView: View {
    @Binding var isShow: Bool

    var body: some View {
        NavigationView {
            WebBrowserView(url: "https://hsr.ophelper.top/static/policy.html")
                .ignoresSafeArea()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("sys.refuse") {
                            exit(1)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("sys.accept") {
                            Defaults[\.isPolicyShown] = true
                            isShow.toggle()
                        }
                    }
                }
                .navigationTitle("app.userpolicy.title")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
