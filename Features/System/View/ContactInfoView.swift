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
            // developer - lava
            Section(header: Text("sys.contact.title.developer")) {
                HStack {
                    Image("avatar.lava")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 50, height: 50)
                    VStack(alignment: .leading) {
                        Text("sys.contact.lava")
                            .bold()
                            .padding(.vertical, 5)
                    }
                    Spacer()
                    Image(systemSymbol: .chevronRight)
                        .rotationEffect(.degrees(isLavaDetailShow ? 90 : 0))
                }
                .onTapGesture {
                    simpleTaptic(type: .light)
                    withAnimation {
                        isLavaDetailShow.toggle()
                    }
                }
                if isLavaDetailShow {
                    Link(
                        destination: URL(
                            string: "mailto:daicanglong@gmail.com"
                        )!
                    ) {
                        Label {
                            Text("daicanglong@gmail.com")
                        } icon: {
                            Image("icon.email")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: URL(
                            string: "https://space.bilibili.com/13079935"
                        )!
                    ) {
                        Label {
                            Text("sys.contact.title.bilibili")
                        } icon: {
                            Image("icon.bilibili")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: URL(
                            string: "https://github.com/CanglongCl"
                        )!
                    ) {
                        Label {
                            Text("sys.contact.title.github")
                        } icon: {
                            Image("icon.github")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }

                // developer - hakubill
                HStack {
                    Image("avatar.hakubill")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 50, height: 50)
                    VStack(alignment: .leading) {
                        Text("sys.contact.hakubill")
                            .bold()
                            .padding(.vertical, 5)
                    }
                    Spacer()
                    Image(systemSymbol: .chevronRight)
                        .rotationEffect(.degrees(isHakubillDetailShow ? 90 : 0))
                }
                .onTapGesture {
                    simpleTaptic(type: .light)
                    withAnimation {
                        isHakubillDetailShow.toggle()
                    }
                }
                if isHakubillDetailShow {
                    Link(destination: URL(string: "https://hakubill.tech")!) {
                        Label {
                            Text("sys.contact.title.homepage")
                        } icon: {
                            Image("icon.homepage")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(destination: URL(string: "mailto:i@hakubill.tech")!) {
                        Label {
                            Text("i@hakubill.tech")
                        } icon: {
                            Image("icon.email")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: isInstallation(urlString: "twitter://") ?
                            URL(
                                string: "twitter://user?id=890517369637847040"
                            )! :
                            URL(string: "https://twitter.com/Haku_Bill")!
                    ) {
                        Label {
                            Text("sys.contact.title.twitter")
                        } icon: {
                            Image("icon.twitter")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: URL(
                            string: "https://www.youtube.com/channel/UC0ABPKMmJa2hd5nNKh5HGqw"
                        )!
                    ) {
                        Label {
                            Text("sys.contact.title.youtube")
                        } icon: {
                            Image("icon.youtube")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: URL(
                            string: "https://space.bilibili.com/158463764"
                        )!
                    ) {
                        Label {
                            Text("sys.contact.title.bilibili")
                        } icon: {
                            Image("icon.bilibili")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: URL(
                            string: "https://github.com/Bill-Haku"
                        )!
                    ) {
                        Label {
                            Text("sys.contact.title.github")
                        } icon: {
                            Image("icon.github")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }

                // developer - ShikiSuen
                Section {
                    HStack {
                        Image("avatar.shikisuen")
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 50, height: 50)
                        VStack(alignment: .leading) {
                            Text("Shiki Suen (孙志贵)")
                                .bold()
                                .padding(.vertical, 5)
                        }
                        Spacer()
                        Image(systemSymbol: .chevronRight)
                            .rotationEffect(.degrees(isShikiDetailShow ? 90 : 0))
                    }
                    .onTapGesture {
                        simpleTaptic(type: .light)
                        withAnimation {
                            isShikiDetailShow.toggle()
                        }
                    }
                    if isShikiDetailShow {
                        Link(
                            destination: URL(string: "https://music.163.com/#/artist/desc?id=60323623")!
                        ) {
                            Label {
                                Text("sys.contact.title.163MusicArtistHP")
                            } icon: {
                                Image("icon.163CloudMusic")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        Link(
                            destination: URL(string: "https://shikisuen.gitee.io/")!
                        ) {
                            Label {
                                Text("sys.contact.title.homepage")
                            } icon: {
                                Image("icon.homepage")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        Link(destination: URL(string: "mailto:shikisuen@yeah.net")!) {
                            Label {
                                Text(verbatim: "shikisuen@yeah.net")
                            } icon: {
                                Image("icon.email")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        Link(
                            destination: isInstallation(urlString: "twitter://") ?
                                URL(
                                    string: "twitter://user?id=176288731"
                                )! :
                                URL(string: "https://twitter.com/ShikiSuen")!
                        ) {
                            Label {
                                Text("sys.contact.title.twitter")
                            } icon: {
                                Image("icon.twitter")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        Link(
                            destination: URL(
                                string: "https://space.bilibili.com/911304"
                            )!
                        ) {
                            Label {
                                Text("sys.contact.title.bilibili")
                            } icon: {
                                Image("icon.bilibili")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        Link(
                            destination: URL(
                                string: "https://github.com/ShikiSuen"
                            )!
                        ) {
                            Label {
                                Text("sys.contact.title.github")
                            } icon: {
                                Image("icon.github")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                    }
                }
            }

            Section(
                header: Text("sys.contact.opensource.title"),
                footer: Text("sys.contact.opensource.footer").textCase(.none)
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
                            Text(verbatim: "794277219")
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
                                Text(verbatim: "中文频道")
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
                                Text(verbatim: "English Channel")
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
                    Link(
                        destination: isInstallation(urlString: "twitter://") ?
                            URL(
                                string: "twitter://user?id=1593423596545724416"
                            )! :
                            URL(string: "https://twitter.com/hutao_hati")!
                    ) {
                        Label {
                            Text("sys.contact.title.twitter")
                        } icon: {
                            Image("icon.twitter")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    Link(
                        destination: URL(
                            string: "https://youtube.com/c/hutao_taotao"
                        )!
                    ) {
                        Label {
                            Text("sys.contact.title.youtube")
                        } icon: {
                            Image("icon.youtube")
                                .resizable()
                                .scaledToFit()
                        }
                    }
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
                Label { Text("ShikiSuen") } icon: {
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

    @State private var isHakubillDetailShow = false
    @State private var isLavaDetailShow = false
    @State private var isShikiDetailShow = false
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
