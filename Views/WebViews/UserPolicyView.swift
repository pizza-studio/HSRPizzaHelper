//
//  UserPolicyView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//

import SwiftUI

struct UserPolicyView: View {
    @Binding
    var sheet: ContentViewSheetType?

    var body: some View {
        NavigationView {
            WebBroswerView(url: "https://ophelper.top/static/policy.html")
                .ignoresSafeArea()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("拒绝") {
                            exit(1)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("同意") {
                            UserDefaults.standard.setValue(
                                true,
                                forKey: "isPolicyShown"
                            )
                            UserDefaults.standard.synchronize()
                            sheet = nil
                        }
                    }
                }
                .navigationTitle("用户协议")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
