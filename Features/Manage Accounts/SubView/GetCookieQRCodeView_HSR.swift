// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import HBMihoyoAPI

extension GetCookieQRCodeView {
    func extraCookieProcess(cookie: inout String) async throws {
        let fpResult = try await MiHoYoAPI.getDeviceFingerPrint(region: .mainlandChina)
        // cookie += "DEVICEFP=\(fpResult.deviceFP); "
        // cookie += "DEVICEFP_SEED_ID=\(fpResult.seedID); "
        // cookie += "DEVICEFP_SEED_TIME=\(fpResult.seedTime); "
        deviceFP = fpResult.deviceFP
    }
}
