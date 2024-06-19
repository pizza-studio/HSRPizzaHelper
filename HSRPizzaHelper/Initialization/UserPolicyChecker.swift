//
//  UserPolicy.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/8.
//

import Defaults
import DefaultsKeys
import Foundation
import SwiftUI

// MARK: - OnBoardingViewShower

private struct OnBoardingViewShower: ViewModifier {
    // MARK: Internal

    func body(content: Content) -> some View {
        content
            .onAppBecomeActive {
                popPolicySheetIfHasNotShown()
            }
            .fullScreenCover(isPresented: $isOnBoardingViewShow, onDismiss: {
                isContactUsViewShow.toggle()
            }, content: {
                OnBoardingView(isShow: $isOnBoardingViewShow)
            })
            .sheet(isPresented: $isContactUsViewShow) {
                ContactInfoForWelcomeView()
            }
    }

    func popPolicySheetIfHasNotShown() {
        if !Defaults[.isPolicyShown] {
            isOnBoardingViewShow.toggle()
        }
    }

    // MARK: Private

    @State private var isOnBoardingViewShow: Bool = false
    @State private var isContactUsViewShow: Bool = false
}

extension View {
    func checkAndPopOnBoardingView() -> some View {
        modifier(OnBoardingViewShower())
    }
}

// MARK: - OnBoardingView

struct OnBoardingView: View {
    // MARK: Internal

    @Binding var isShow: Bool

    var body: some View {
        VStack {
            VStack {
                Image("icon.hsrhelper")
                    .resizable()
                    .frame(width: 75, height: 75, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("app.name")
                    .font(.title)
                    .bold()
            }
            .padding()
            .padding(.vertical)
            VStack(alignment: .leading, spacing: 30) {
                FeatureBar(
                    icon: Image(
                        systemSymbol: .platter2FilledIphone
                    ),
                    title: "boarding.feature.widget.title",
                    detail: "boarding.feature.widget.detail",
                    color: .red
                )
                FeatureBar(
                    icon: Image(
                        systemSymbol: .bellBadge
                    ),
                    title: "boarding.feature.notification.title",
                    detail: "boarding.feature.notification.detail",
                    color: .purple
                )
                FeatureBar(
                    icon: Image(
                        systemSymbol: .photoOnRectangle
                    ),
                    title: "boarding.feature.background.title",
                    detail: "boarding.feature.background.detail",
                    color: .orange
                )
                FeatureBar(
                    icon: Image(
                        systemSymbol: .gearshape2
                    ),
                    title: "boarding.feature.customize.title",
                    detail: "boarding.feature.customize.detail",
                    color: .teal
                )
            }
            .padding(.horizontal)
            Spacer()
            Text("boarding.protocol.link")
                .font(.footnote)
            Button("boarding.protocol.agree") {
                Defaults[.isPolicyShown] = true
                isShow.toggle()
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss
}

// MARK: - FeatureBar

private struct FeatureBar: View {
    let icon: Image
    let title: LocalizedStringKey
    let detail: LocalizedStringKey

    let color: Color

    var body: some View {
        HStack(alignment: .center) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(.horizontal, 10)
                .foregroundColor(color)
            Text(title).bold() + Text("\n") + Text(detail)
        }
    }
}

// MARK: - OnBoardingView_Previews

struct OnBoardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardingView(isShow: .init(get: { true }, set: { _ in }))
    }
}

// MARK: - ContactInfoForWelcomeView

private struct ContactInfoForWelcomeView: View {
    // MARK: Internal

    var groupFooterText: String {
        var text = ""
        if AppConfig.appLanguage == .zhcn {
            text = "sys.contact.qq.group.footer".localized()
        } else {
            text = "boarding.contact.group.footer".localized()
        }
        return text
    }

    var body: some View {
        NavigationStack {
            List {
                Section(
                    header: Text("sys.contact.opensource.title.2"),
                    footer: Text("sys.contact.opensource.footer.2").textCase(.none)
                ) {
                    LinkLabelItem(
                        "sys.contact.github",
                        imageKey: "icon.github",
                        url: "https://github.com/pizza-studio/hsrpizzahelper"
                    )
                }

                // app contact
                Section(
                    header: Text("sys.contact.title.groups"),
                    footer: Text(groupFooterText).textCase(.none)
                ) {
                    Menu {
                        LinkLabelItem(
                            "sys.contact.qq.channel",
                            imageKey: "icon.qq.circle",
                            url: "https://pd.qq.com/s/9z504ipbc"
                        )
                        LinkLabelItem(qqGroup: "794277219")
                    } label: {
                        Label {
                            Text("sys.contact.qq.group")
                        } icon: {
                            Image("icon.qq")
                                .resizable()
                                .scaledToFit()
                        }
                    }

                    LinkLabelItem(
                        "sys.contact.discord",
                        imageKey: "icon.discord",
                        url: "https://discord.gg/g8nCgKsaMe"
                    )

                    if AppConfig.appLanguage != .ja {
                        Menu {
                            LinkLabelItem(
                                verbatim: "Telegram 中文频道",
                                imageKey: "telegram",
                                url: "https://t.me/hsrhelper_zh"
                            )
                            LinkLabelItem(
                                verbatim: "Telegram English Channel",
                                imageKey: "telegram",
                                url: "https://t.me/hsrhelper_en"
                            )
                        } label: {
                            Label {
                                Text("sys.contact.telegram")
                            } icon: {
                                Image("icon.telegram")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                    }
                }

                if AppConfig.appLanguage == .ja {
                    Section(
                        header: Text("sys.contact.hakubill.twitter.header").textCase(.none),
                        footer: Text("sys.contact.hakubill.twitter.footer").textCase(.none)
                    ) {
                        LinkLabelItem(
                            twitter: "PizzaStudio_jp",
                            titleOverride: "sys.contact.hakubill.twitter"
                        )
                    }
                }
            }
            .navigationTitle("sys.label.contact.welcome")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("sys.done") {
                        dismiss()
                    }
                }
            }
        }
    }

    func isInstallation(urlString: String?) -> Bool {
        let url = URL(string: urlString!)
        if url == nil {
            return false
        }
        if UIApplication.shared.canOpenURL(url!) {
            return true
        }
        return false
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss
}
