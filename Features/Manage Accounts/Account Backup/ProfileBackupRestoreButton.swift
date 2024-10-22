//
//  ProfileBackupRestoreMenu.swift
//  HSRPizzaHelper
//
//  Created by ShikiSuen on 2024/10/22.
//

import Combine
import CoreData
import Foundation
import Observation
import SFSafeSymbols
import SwiftUI
import UniformTypeIdentifiers

// MARK: - ProfileBackupRestoreButton

struct ProfileBackupRestoreButton: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    @MainActor @ViewBuilder public var body: some View {
        let msgPack = theVM.fileSaveActionResultMessagePack
        Button {
            theVM.currentExportableDocument = Result.success(.init(prepareAllExportableProfiles()))
        } label: {
            Label("accountMgr.exchange.export.menuTitle".localized(), systemSymbol: .squareAndArrowUpOnSquare)
        }
        .apply { coreContent in
            coreContent
                .fileExporter(
                    isPresented: theVM.isExporterVisible,
                    document: theVM.getCurrentExportableDocument(),
                    contentType: .json,
                    defaultFilename: theVM.defaultFileName
                ) { result in
                    theVM.fileSaveActionResult = result
                    theVM.currentExportableDocument = nil
                }
                .alert(
                    msgPack.title,
                    isPresented: theVM.isExportResultAvailable,
                    actions: {
                        Button("sys.ok".localized()) {
                            theVM.fileSaveActionResult = nil
                        }
                    },
                    message: {
                        Text(verbatim: msgPack.message)
                    }
                )
        }
        .onDisappear {
            theVM.currentExportableDocument = nil
        }
    }

    // MARK: Fileprivate

    @StateObject fileprivate var theVM = Coordinator()

    // MARK: Private

    @Environment(\.managedObjectContext) private var modelContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Account.priority, ascending: true),
        ],
        animation: .default
    ) private var accounts: FetchedResults<Account>
}

extension ProfileBackupRestoreButton {
    fileprivate func prepareAllExportableProfiles() -> [PZProfileSendable] {
        accounts.map(\.asPZProfile)
    }
}

// MARK: ProfileBackupRestoreButton.Coordinator

extension ProfileBackupRestoreButton {
    fileprivate final class Coordinator: TaskManagedVM {
        @Published var fileSaveActionResult: Result<URL, any Error>?
        @Published var currentExportableDocument: Result<PZProfilesDocument, Error>?
        @Published var isImporterVisible: Bool = false

        var fileSaveActionResultMessagePack: (title: String, message: String) {
            switch fileSaveActionResult {
            case let .success(url):
                (
                    "accountMgr.exchange.export.succeededInSavingToFile".localized(),
                    "accountMgr.exchange.export.fileSavedTo:".localized() + "\n\n\(url)"
                )
            case let .failure(message):
                ("accountMgr.exchange.export.failedInSavingToFile".localized(), "⚠︎ \(message)")
            case nil: ("", "")
            }
        }

        var isExporterVisible: Binding<Bool> {
            .init(get: {
                switch self.currentExportableDocument {
                case .success: true
                case .failure, .none: false
                }
            }, set: { result in
                if !result {
                    self.currentExportableDocument = nil
                }
            })
        }

        var isExportResultAvailable: Binding<Bool> {
            .init(get: { self.fileSaveActionResult != nil }, set: { _ in })
        }

        var defaultFileName: String? {
            switch currentExportableDocument {
            case let .success(document): document.fileNameStem
            case .failure, .none: nil
            }
        }

        func getCurrentExportableDocument() -> PZProfilesDocument? {
            switch currentExportableDocument {
            case let .success(document): document
            case .failure, .none: nil
            }
        }
    }
}

// MARK: - PZProfilesDocument

private struct PZProfilesDocument: FileDocument {
    // MARK: Lifecycle

    public init(configuration: ReadConfiguration) throws {
        let theModel = try JSONDecoder().decode(FileType.self, from: configuration.file.regularFileContents!)
        self.model = theModel
    }

    public init(_ fileObj: FileType) {
        self.model = fileObj
    }

    // MARK: Public

    public typealias FileType = [PZProfileSendable]

    public static let readableContentTypes: [UTType] = [.json]

    public let model: Codable & Sendable

    public let fileNameStem: String = "PZProfiles_\(dateFormatter.string(from: Date()))"

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(model)
        return FileWrapper(regularFileWithContents: data)
    }

    // MARK: Private

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        return dateFormatter
    }()
}
