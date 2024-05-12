//
//  File.swift
//
//
//  Created by 戴藏龙 on 2024/5/10.
//

import Foundation

// MARK: - GenerateQRCodeURLData

public struct GenerateQRCodeURLData: Decodable, Hashable {
    let url: URL
}

// MARK: DecodableFromMiHoYoAPIJSONResult

extension GenerateQRCodeURLData: DecodableFromMiHoYoAPIJSONResult {}
