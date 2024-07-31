//
//  ContactInfoView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/5/20.
//  Contact us

import SFSafeSymbols
import SwiftUI

// MARK: - ContactInfoView

struct ContactInfoView: View {
    // MARK: Internal

    var groupFooterText: String {
        var text = ""
        if AppConfig.appLanguage == .zhcn {
            text = "sys.contact.qq.group.footer".localized()
        }
        return text
    }

    var body: some View {
        List {
            mainDeveloperTeamSection()
            Section(
                header: Text("sys.contact.opensource.title"),
                footer: Text("sys.contact.opensource.footer").textCase(.none)
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
                    LinkLabelItem(qqChannel: "9z504ipbc")
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

            // special thanks
            Section(header: Text("sys.contact.i18n.en")) {
                Label { Text("sys.contact.lava") } icon: {
                    Image("avatar.lava")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
                Label { Text("sys.contact.hakubill") } icon: {
                    Image("avatar.hakubill")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
            }

            Section(header: Text("sys.contact.i18n.ja")) {
                Label { Text("sys.contact.hakubill") } icon: {
                    Image("avatar.hakubill")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
                Menu {
                    LinkLabelItem(twitter: "hutao_hati")
                    LinkLabelItem(youtube: "https://youtube.com/c/hutao_taotao")
                } label: {
                    Label { Text("sys.contact.tao") } icon: {
                        Image("avatar.tao")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                    }
                }
                Label { Text("sys.contact.shikisuen") } icon: {
                    Image("avatar.shikisuen")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
            }

            Section(header: Text("sys.contact.i18n.zhtw")) {
                Label { Text("contact.nameText.shikisuen") } icon: {
                    Image("avatar.shikisuen")
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                }
            }
        }
        .navigationTitle("sys.label.contact")
        .navigationBarTitleDisplayMode(.inline)
    }

    func isInstalled(urlString: String?) -> Bool {
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

    @State private var isPizzaStudioDetailVisible = false
    @State private var isLavaDetailVisible = false
    @State private var isHakubillDetailVisible = false
    @State private var isShikiDetailVisible = false

    @ViewBuilder
    private func mainDeveloperTeamSection() -> some View {
        Section(header: Text("sys.contact.title.developer")) {
            // developer - Pizza Studio
            HStack {
                Image("AppIcon256").resizable().clipShape(Circle())
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading) {
                    Text(verbatim: "Pizza Studio").bold().padding(.vertical, 5)
                }
                Spacer()
                Image(systemSymbol: .chevronRight)
                    .rotationEffect(.degrees(isPizzaStudioDetailVisible ? 90 : 0))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                simpleTaptic(type: .light)
                withAnimation { isPizzaStudioDetailVisible.toggle() }
            }
            if isPizzaStudioDetailVisible {
                LinkLabelItem(officialWebsite: "https://pizzastudio.org")
                LinkLabelItem(email: "contact@pizzastudio.org")
                LinkLabelItem(github: "pizza-studio")
                if AppConfig.appLanguage == .ja {
                    LinkLabelItem(twitter: "PizzaStudio_jp")
                }
            }

            // developer - lava
            HStack {
                Image("avatar.lava").resizable().clipShape(Circle())
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading) {
                    Text("sys.contact.lava").bold().padding(.vertical, 5)
                }
                Spacer()
                Image(systemSymbol: .chevronRight)
                    .rotationEffect(.degrees(isLavaDetailVisible ? 90 : 0))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                simpleTaptic(type: .light)
                withAnimation { isLavaDetailVisible.toggle() }
            }
            if isLavaDetailVisible {
                LinkLabelItem(email: "daicanglong@gmail.com")
                LinkLabelItem(bilibiliSpace: "13079935")
                LinkLabelItem(github: "CanglongCl")
            }

            // developer - hakubill
            HStack {
                Image("avatar.hakubill").resizable().clipShape(Circle())
                    .frame(width: 50, height: 50)
                VStack(alignment: .leading) {
                    Text("sys.contact.hakubill").bold().padding(.vertical, 5)
                }
                Spacer()
                Image(systemSymbol: .chevronRight)
                    .rotationEffect(.degrees(isHakubillDetailVisible ? 90 : 0))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                simpleTaptic(type: .light)
                withAnimation { isHakubillDetailVisible.toggle() }
            }
            if isHakubillDetailVisible {
                LinkLabelItem(homePage: "https://hakubill.tech")
                LinkLabelItem(email: "i@hakubill.tech")
                LinkLabelItem(twitter: "Haku_Bill")
                LinkLabelItem(youtube: "https://www.youtube.com/channel/UC0ABPKMmJa2hd5nNKh5HGqw")
                LinkLabelItem(bilibiliSpace: "158463764")
                LinkLabelItem(github: "Bill-Haku")
            }

            // developer - ShikiSuen
            Section {
                HStack {
                    Image("avatar.shikisuen").resizable().clipShape(Circle())
                        .frame(width: 50, height: 50)
                    VStack(alignment: .leading) {
                        Text("contact.nameText.shikisuen").bold().padding(.vertical, 5)
                    }
                    Spacer()
                    Image(systemSymbol: .chevronRight)
                        .rotationEffect(.degrees(isShikiDetailVisible ? 90 : 0))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    simpleTaptic(type: .light)
                    withAnimation { isShikiDetailVisible.toggle() }
                }
                if isShikiDetailVisible {
                    LinkLabelItem(neteaseMusic: "60323623")
                    LinkLabelItem(homePage: "https://shikisuen.github.io")
                    LinkLabelItem(email: "shikisuen@yeah.net")
                    LinkLabelItem(twitter: "ShikiSuen")
                    LinkLabelItem(bilibiliSpace: "911304")
                    LinkLabelItem(github: "ShikiSuen")
                }
            }
        }
    }
}

// MARK: - CaptionLabelStyle

private struct CaptionLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
            configuration.title
        }
    }
}
