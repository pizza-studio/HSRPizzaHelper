// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import SwiftUI

public struct LinkLabelItem: View {
    // MARK: Lifecycle

    public init(verbatim: String, imageKey: String, url: String) {
        self.text = verbatim
        self.imageKey = imageKey
        self.destination = URL(string: url)!
    }

    public init(_ textKey: String, imageKey: String, url: String) {
        self.text = String(localized: .init(stringLiteral: textKey))
        self.imageKey = imageKey
        self.destination = URL(string: url)!
    }

    public init(email: String) {
        self.text = email
        self.imageKey = "icon.email"
        self.destination = URL(string: "mailto:\(email)")!
    }

    public init(qqPersonal: String) {
        var urlStr = "mqqapi://card/show_pslcard?"
        urlStr.append("src_type=internal&version=1&uin=\(qqPersonal)")
        self.text = String(localized: .init(stringLiteral: "sys.contact.qq.channel"))
        self.imageKey = "icon.qq.circle"
        self.destination = URL(string: urlStr)!
    }

    public init(
        qqGroup: String,
        titleOverride: String? = nil,
        verbatim: Bool = false
    ) {
        var urlStr = "mqqapi://card/show_pslcard?"
        urlStr.append("src_type=internal&version=1&card_type=group&uin=\(qqGroup)")
        let fallbackKey = qqGroup
        if verbatim {
            self.text = titleOverride ?? fallbackKey
        } else {
            if let titleOverride {
                self.text = String(localized: .init(stringLiteral: titleOverride))
            } else {
                self.text = fallbackKey
            }
        }
        self.imageKey = "icon.qq"
        self.destination = URL(string: urlStr)!
    }

    public init(qqChannel: String) {
        let urlStr = "https://pd.qq.com/s/\(qqChannel)"
        self.text = String(localized: .init(stringLiteral: "sys.contact.qq.channel"))
        self.imageKey = "icon.qq.circle"
        self.destination = URL(string: urlStr)!
    }

    public init(homePage: String) {
        self.text = String(localized: .init(stringLiteral: "sys.contact.title.homepage"))
        self.imageKey = "icon.homepage"
        self.destination = URL(string: homePage)!
    }

    public init(officialWebsite: String) {
        self.text = String(localized: .init(stringLiteral: "sys.contact.title.officialWebsite"))
        self.imageKey = "icon.homepage"
        self.destination = URL(string: officialWebsite)!
    }

    public init(
        twitter twitterName: String,
        titleOverride: String? = nil,
        verbatim: Bool = false
    ) {
        let fallbackKey = "sys.contact.title.twitter"
        if verbatim {
            self.text = titleOverride ?? String(localized: .init(stringLiteral: fallbackKey))
        } else {
            self.text = String(localized: .init(stringLiteral: titleOverride ?? fallbackKey))
        }
        self.imageKey = "icon.twitter"
        self.destination = URL(string: "https://twitter.com/\(twitterName)")!
    }

    public init(youtube youtubeURLStr: String) {
        self.text = String(localized: .init(stringLiteral: "sys.contact.title.youtube"))
        self.imageKey = "icon.youtube"
        self.destination = URL(string: youtubeURLStr)!
    }

    public init(bilibiliSpace buid: String) {
        self.text = String(localized: .init(stringLiteral: "sys.contact.title.bilibili"))
        self.imageKey = "icon.bilibili"
        self.destination = URL(string: "https://space.bilibili.com/\(buid)")!
    }

    public init(github ghName: String) {
        self.text = String(localized: .init(stringLiteral: "sys.contact.title.github"))
        self.imageKey = "icon.github"
        self.destination = URL(string: "https://github.com/\(ghName)")!
    }

    public init(neteaseMusic artistID: String) {
        self.text = String(localized: .init(stringLiteral: "sys.contact.title.163MusicArtistHP"))
        self.imageKey = "icon.163CloudMusic"
        self.destination = URL(string: "https://music.163.com/#/artist/desc?id=\(artistID)")!
    }

    // MARK: Public

    public var body: some View {
        Link(destination: destination) {
            Label {
                Text(verbatim: text)
            } icon: {
                Image(imageKey)
                    .resizable()
                    .scaledToFit()
            }
        }
    }

    // MARK: Private

    private let text: String
    private let imageKey: String
    private let destination: URL

    private static func isAppInstalled(urlString: String?) -> Bool {
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
