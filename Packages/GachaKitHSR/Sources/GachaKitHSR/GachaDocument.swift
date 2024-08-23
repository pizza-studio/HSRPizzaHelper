// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import SwiftUI
import UniformTypeIdentifiers

/// 该结构仅用作导出内容之用途。
/// 由于 SwiftUI 给单个 View 连续挂接 fileExporter 的时候只有最后挂接的会生效的缘故，
/// 必须让 SRGF 与 UIGF 混用一个 Document 结构。
public struct GachaDocument: FileDocument {
    // MARK: Lifecycle

    public init(configuration: ReadConfiguration) throws {
        let uigfModel = try? JSONDecoder().decode(UIGFv4.self, from: configuration.file.regularFileContents!)
        if let uigfModel {
            self.model = uigfModel
        } else {
            self.model = try JSONDecoder().decode(SRGFv1.self, from: configuration.file.regularFileContents!)
        }
    }

    public init(model: Codable) {
        self.model = model
    }

    // MARK: Public

    public static var readableContentTypes: [UTType] = [.json]

    public let model: Codable

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(model)
        return FileWrapper(regularFileWithContents: data)
    }
}
