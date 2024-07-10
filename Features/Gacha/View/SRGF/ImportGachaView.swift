// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import AlertToast
import GachaKit
import HBMihoyoAPI
import SFSafeSymbols
import SwiftUI
import UniformTypeIdentifiers

// MARK: - ImportGachaView

struct ImportGachaView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: Internal

    struct GachaImportReport {
        let uid: String, totalCount: Int, newCount: Int
    }

    @State var isHelpSheetShow: Bool = false

    @State var isCompleteAlertShow: Bool = false

    var body: some View {
        ImportView(status: $status, alert: $alert)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isHelpSheetShow.toggle()
                    } label: {
                        Image(systemSymbol: .questionmarkCircle)
                    }
                }
            })
            .sheet(isPresented: $isHelpSheetShow, content: {
                HelpSheet(isShow: $isHelpSheetShow)
            })
            .navigationTitle("app.gacha.import.srgf")
            .onChange(of: status, perform: { newValue in
                if case .succeed = newValue {
                    isCompleteAlertShow.toggle()
                }
            })
            .toast(isPresenting: $isCompleteAlertShow, alert: {
                .init(
                    displayMode: .alert,
                    type: .complete(.green),
                    title: String(localized: "app.gacha.import.success")
                )
            })
            .alert(
                "gacha.import.startImport".localized(),
                isPresented: isReadyToStartAlertShow,
                presenting: alert,
                actions: { thisAlert in
                    Button(
                        "sys.start",
                        role: .destructive,
                        action: {
                            switch thisAlert {
                            case let .readyToStartJson(url: url):
                                processJson(url: url)
                            }
                        }
                    )
                    Button("sys.cancel", role: .cancel, action: { alert = nil })

                },
                message: { _ in
                    Text("gacha.import.informThatItNeedsWait")
                }
            )
    }

    func processJson(url: URL) {
        Task(priority: .userInitiated) {
            status = .reading
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if url.startAccessingSecurityScopedResource() {
                do {
                    let decoder = JSONDecoder()
                    let data: Data = try Data(contentsOf: url)
                    let srgfModel: SRGFv1 = try decoder
                        .decode(
                            SRGFv1.self,
                            from: data
                        )
                    let result = importGachaFromSRGFv1(
                        srgfJson: srgfModel
                    )
                    status = .succeed(ImportSucceedInfo(
                        uid: result.uid,
                        totalCount: result.totalCount,
                        newCount: result.newCount,
                        app: srgfModel.info.exportApp,
                        exportDate: srgfModel.info.exportDate,
                        timeZone: GachaItem.getServerTimeZoneDelta(result.uid)
                    ))
                    isCompleteAlertShow.toggle()
                } catch {
                    status = .failure(error.localizedDescription)
                }
                url.stopAccessingSecurityScopedResource()
            } else {
                status = .failure(.init(localized: "app.gacha.import.fail.fileAccessFail"))
            }
        }
    }

    func importGachaFromSRGFv1(
        srgfJson: SRGFv1
    )
        -> GachaImportReport {
        let info = srgfJson.info
        let items = srgfJson.list
        let newCount = addRecordItems(
            items,
            uid: info.uid,
            lang: info.lang
        )
        return .init(uid: info.uid, totalCount: items.count, newCount: newCount)
    }

    /// 返回已保存的新数据数量
    func addRecordItems(
        _ items: [SRGFv1.DataEntry],
        uid: String,
        lang: GachaLanguageCode
    )
        -> Int {
        var count = 0
        viewContext.performAndWait {
            items.enumerated().forEach { index, item in
                var item = item
                if item.id.isEmpty {
                    item.id = String(index)
                }
                if !checkIDAndUIDExists(uid: uid, id: item.id) {
                    _ = item.toManagedModel(
                        uid: uid, lang: lang,
                        timeZoneDelta: GachaItem.getServerTimeZoneDelta(uid),
                        context: viewContext
                    )
                    count += 1
                }
            }
        }
        save()
        return count
    }

    func checkIDAndUIDExists(uid: String, id: String) -> Bool {
        let request = GachaItemMO.fetchRequest()
        let predicate = NSPredicate(format: "(id = %@) AND (uid = %@)", id, uid)
        request.predicate = predicate

        do {
            let gachaItemMOs = try viewContext.fetch(request)
            return !gachaItemMOs.isEmpty
        } catch {
            print("ERROR FETCHING CONFIGURATION. \(error.localizedDescription)")
            return true
        }
    }

    func save() {
        do {
            try viewContext.save()
        } catch {
            print("ERROR SAVING. \(error.localizedDescription)")
        }
    }

    // MARK: Fileprivate

    @State fileprivate var status: ImportStatus = .pending

    fileprivate var isReadyToStartAlertShow: Binding<Bool> {
        .init {
            alert != nil
        } set: { newValue in
            if newValue == false {
                alert = nil
            }
        }
    }

    // MARK: Private

    @State private var alert: AlertType?

    private var dateFormatter: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .medium
        return fmt
    }
}

// MARK: - AlertType

private enum AlertType: Identifiable {
    case readyToStartJson(url: URL)

    // MARK: Internal

    var id: String {
        switch self {
        case .readyToStartJson:
            return "readyToStart"
        }
    }
}

// MARK: - ImportStatus

private enum ImportStatus {
    case pending
    case reading
    case succeed(ImportSucceedInfo)
    case failure(String)
}

// MARK: Equatable

extension ImportStatus: Equatable {}

// MARK: Identifiable

extension ImportStatus: Identifiable {
    var id: String {
        switch self {
        case .pending:
            return "pending"
        case .reading:
            return "reading"
        case .succeed:
            return "succeed"
        case .failure:
            return "failure"
        }
    }
}

// MARK: - ImportSucceedInfo

private struct ImportSucceedInfo: Equatable {
    // MARK: Lifecycle

    init(
        uid: String,
        totalCount: Int,
        newCount: Int,
        app: String? = nil,
        exportDate: Date? = nil,
        timeZone: Int
    ) {
        self.uid = uid
        self.totalCount = totalCount
        self.newCount = newCount
        self.app = app
        self.exportDate = exportDate
        self.timeZoneDelta = timeZone
    }

    // MARK: Internal

    let uid: String
    let totalCount: Int
    let newCount: Int
    let app: String?
    let exportDate: Date?
    let timeZoneDelta: Int
}

// MARK: - ImportFileSourceType

private enum ImportFileSourceType {
    case SRGFJSON
}

// MARK: - HelpSheet

private struct HelpSheet: View {
    @Binding var isShow: Bool

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Link(
                        destination: URL(
                            string: "https://uigf.org/partnership.html"
                        )!
                    ) {
                        Label(
                            "app.gacha.import.help.srgf.button",
                            systemSymbol: .appBadgeCheckmark
                        )
                    }
                } footer: {
                    Text("app.gacha.import.srgf.verified.note.2")
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .navigationTitle("sys.help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("sys.done") {
                        isShow.toggle()
                    }
                }
            }
        }
    }
}

// MARK: - PopFileButton

private struct PopFileButton: View {
    /// localized key
    let title: String

    let allowedContentTypes: [UTType]

    let completion: (Result<URL, Error>) -> Void

    @State var isFileImporterShow: Bool = false

    var body: some View {
        Button(title.localized()) {
            isFileImporterShow.toggle()
        }
        .fileImporter(isPresented: $isFileImporterShow, allowedContentTypes: allowedContentTypes) { result in
            completion(result)
        }
    }
}

// MARK: - StatusView

private struct StatusView<V: View>: View {
    @Binding var status: ImportStatus
    @ViewBuilder var pendingForImportView: () -> V

    var body: some View {
        List {
            switch status {
            case .pending:
                pendingForImportView()
            case .reading:
                ReadingView()
            case let .succeed(info):
                SucceedView(status: $status, info: info)
            case let .failure(string):
                FailureView(status: $status, errorMessage: string)
            }
        }
    }
}

// MARK: - FailureView

private struct FailureView: View {
    @Binding var status: ImportStatus
    let errorMessage: String

    var body: some View {
        Text("app.gacha.import.fail")
        let errorContent = String(format: "app.gacha.import.errorContent:%@".localized(), errorMessage)
        Text(errorContent)
        Button("app.gacha.import.retry") {
            status = .pending
        }
    }
}

// MARK: - SucceedView

private struct SucceedView: View {
    // MARK: Internal

    @Binding var status: ImportStatus
    let info: ImportSucceedInfo

    var timeZoneDeltaValueText: String {
        switch info.timeZoneDelta {
        case 0...: return "+\(info.timeZoneDelta)"
        default: return "\(info.timeZoneDelta)"
        }
    }

    var body: some View {
        Section {
            Label {
                Text("app.gacha.import.success")
            } icon: {
                Image(systemSymbol: .checkmarkCircle)
                    .foregroundColor(.green)
            }
            Text(verbatim: "UID: \(info.uid)")
            if let app = info.app {
                let sourceInfo = String(format: "app.gacha.import.info.source:%@".localized(), app)
                Text(sourceInfo)
            }
            if let date = info.exportDate {
                VStack(alignment: .leading) {
                    let timeInfo = String(
                        format: "app.gacha.import.info.time:%@".localized(),
                        dateFormatterCurrent.string(from: date)
                    )
                    Text(timeInfo)
                    if importedTimeZone.secondsFromGMT() != TimeZone.autoupdatingCurrent.secondsFromGMT() {
                        let timeInfo2 = "UTC\(timeZoneDeltaValueText): " + dateFormatterAsImported.string(from: date)
                        Text(timeInfo2).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
        Section {
            let importInfo = String(format: "app.gacha.import.info.import:%lld".localized(), info.totalCount)
            let storageInfo = String(format: "app.gacha.import.info.storage:%lld".localized(), info.newCount)
            Text(importInfo)
            Text(storageInfo)
        }
        Button("app.gacha.import.continue") {
            status = .pending
        }
    }

    // MARK: Private

    private var importedTimeZone: TimeZone {
        .init(secondsFromGMT: 3600 * info.timeZoneDelta) ?? .autoupdatingCurrent
    }

    private var dateFormatterAsImported: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .medium
        return fmt
    }

    private var dateFormatterCurrent: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .medium
        fmt.timeZone = .init(secondsFromGMT: 3600 * info.timeZoneDelta)
        return fmt
    }
}

// MARK: - ReadingView

private struct ReadingView: View {
    var body: some View {
        Label {
            Text("app.gacha.import.working")
        } icon: {
            ProgressView()
        }
    }
}

// MARK: - ImportView

private struct ImportView: View {
    @Binding var status: ImportStatus
    @Binding var alert: AlertType?

    var body: some View {
        StatusView(status: $status) {
            Section {
                PopFileButton(title: "app.gacha.import.srgf.json", allowedContentTypes: [.json]) { result in
                    switch result {
                    case let .success(url):
                        alert = .readyToStartJson(url: url)
                    case let .failure(error):
                        status = .failure(error.localizedDescription)
                    }
                }
            } footer: {
                VStack(alignment: .leading) {
                    Text(
                        "app.gacha.import.srgf.verified.note.1"
                    )
                    Text("app.gacha.srgf.affLink.[SRGF](https://uigf.org/)")
                }
            }
        }
    }
}
