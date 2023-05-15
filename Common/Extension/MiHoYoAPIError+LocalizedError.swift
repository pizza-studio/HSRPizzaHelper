//
//  MiHoYoAPIError+LocalizedError.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/15.
//

import Foundation
import HBMihoyoAPI

extension MiHoYoAPIError: LocalizedError {
    public var errorDescription: String? {
        String(format: "mihoyoapi.error.errdesc".localized(comment: "Error(retcode): message"), retcode, message)
    }
}
