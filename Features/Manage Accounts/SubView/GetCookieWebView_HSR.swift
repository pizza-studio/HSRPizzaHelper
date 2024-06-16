//
//  GetCookieWebView_HSR.swift
//  HSRPizzaHelper
//
//  Created by ShikiSuen on 2024/6/17.
//

import HBMihoyoAPI

func getAccountPageLoginURL(region: Region) -> String {
    switch region {
    case .mainlandChina:
        return "https://user.mihoyo.com/#/login/captcha"
    case .global:
        /// 尽量避免使用 HoYoLab 论坛社区的页面，免得 Apple 审核员工瞎基蔔乱点之后找事。
        /// 以下网址为星穹铁道专用。
        return "https://act.hoyolab.com/app/community-game-records-sea/rpg/m.html#/hsr"
    }
}
