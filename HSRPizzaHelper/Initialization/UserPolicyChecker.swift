//
//  UserPolicy.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/8.
//

import Foundation
import SwiftUI

// MARK: - PolicyChecker

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
                OnBoardingView()
            })
            .sheet(isPresented: $isContactUsViewShow) {
                ContactInfoForWelcomeView()
            }
    }

    func popPolicySheetIfHasNotShown() {
        if !Defaults[\.isPolicyShown] {
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

struct OnBoardingView: View {
    @Environment(\.dismiss) private var dismiss

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
                        systemSymbol: .gear
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
                Defaults[\.isPolicyShown] = true
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
        }
    }
}

// MARK: - FeatureBa

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

struct OnBoardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardingView()
    }
}

// MARK: - ContactInfoForWelcomeView

private struct ContactInfoForWelcomeView: View {
    @Environment(\.dismiss) private var dismiss

    var groupFooterText: String {
        var text = ""
        if AppConfig.appLanguage == .zhcn {
            text = "sys.contact.qq.group.footer".localized()
        }
        return text
    }

    var body: some View {
        NavigationView {
            List {
                Section(
                    header: Text("sys.contact.opensource.title.2"),
                    footer: Text("sys.contact.opensource.footer.2").textCase(.none)
                ) {
                    Link(
                        destination: URL(
                            string: "https://github.com/pizza-studio/hsrpizzahelper"
                        )!
                    ) {
                        Label {
                            Text("sys.contact.github")
                        } icon: {
                            Image("icon.github")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }

                // app contact
                Section(
                    header: Text("sys.contact.title.groups"),
                    footer: Text(groupFooterText).textCase(.none)
                ) {
                    Menu {
                        Link(
                            destination: URL(
                                string: "https://pd.qq.com/s/9z504ipbc"
                            )!
                        ) {
                            Label {
                                Text("sys.contact.qq.channel")
                            } icon: {
                                Image("icon.qq.circle")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }

                        Link(
                            destination: URL(
                                // swiftlint:disable:next line_length
                                string: "mqqapi://card/show_pslcard?src_type=internal&version=1&card_type=group&uin=794277219"
                            )!
                        ) {
                            Label {
                                Text("794277219")
                            } icon: {
                                Image("icon.qq")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                    } label: {
                        Label {
                            Text("sys.contact.qq.group")
                        } icon: {
                            Image("icon.qq")
                                .resizable()
                                .scaledToFit()
                        }
                    }

                    Link(
                        destination: URL(string: "https://discord.gg/g8nCgKsaMe")!
                    ) {
                        Label {
                            Text("sys.contact.discord")
                        } icon: {
                            Image("icon.discord")
                                .resizable()
                                .scaledToFit()
                        }
                    }

                    if AppConfig.appLanguage != .ja {
                        Menu {
                            Link(
                                destination: URL(
                                    string: "https://t.me/hsrhelper_zh"
                                )!
                            ) {
                                Label {
                                    Text("中文频道")
                                } icon: {
                                    Image("telegram")
                                        .resizable()
                                        .scaledToFit()
                                }
                            }

                            Link(
                                destination: URL(
                                    string: "https://t.me/hsrhelper_en"
                                )!
                            ) {
                                Label {
                                    Text("English Channel")
                                } icon: {
                                    Image("telegram")
                                        .resizable()
                                        .scaledToFit()
                                }
                            }
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
                        Link(
                            destination: isInstallation(urlString: "twitter://") ?
                                URL(
                                    string: "twitter://user?id=890517369637847040"
                                )! :
                                URL(string: "https://twitter.com/Haku_Bill")!
                        ) {
                            Label {
                                Text("sys.contact.hakubill.twitter")
                            } icon: {
                                Image("icon.twitter")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
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
}
