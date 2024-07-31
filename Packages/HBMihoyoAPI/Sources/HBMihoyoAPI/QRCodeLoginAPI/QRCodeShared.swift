/// Ref: https://uigf.org/zh/mihoyo-api-collection/hoyolab/login/qrcode_hk4e.html
/// game_id2name = {
/// "bh2_cn": "崩坏2 (7)",
/// "bh3_cn": "崩坏3 (1)",
/// "nxx_cn": "未定事件簿 (2)",
/// "hk4e_cn": "原神 (4)",
/// "hkrpg_cn": "崩坏： 星穹铁道 (8)",
/// "nap_cn": "绝区零 (12)"
/// }

import Foundation
enum QRCodeShared {
    static let appID = "7"
    static let appTag = "bh2_cn"
    static let url4Query = URL(string: "https://hk4e-sdk.mihoyo.com/\(QRCodeShared.appTag)/combo/panda/qrcode/query")!
    static let url4Fetch = URL(string: "https://hk4e-sdk.mihoyo.com/\(QRCodeShared.appTag)/combo/panda/qrcode/fetch")!
}
