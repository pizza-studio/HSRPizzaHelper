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
    // MARK: Internal

    struct GachaImportReport {
        let uid: String, totalCount: Int, newCount: Int
    }

    var body: some View {
        ImportView(status: $status, alert: $alert)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isHelpSheetShown.toggle()
                    } label: {
                        Image(systemSymbol: .questionmarkCircle)
                    }
                }
            })
            .sheet(isPresented: $isHelpSheetShown, content: {
                HelpSheet(isShown: $isHelpSheetShown)
            })
            .navigationTitle("app.gacha.import.uigf")
            .onChange(of: status, perform: { newValue in
                if case .succeed = newValue {
                    isCompleteAlertShown.toggle()
                }
            })
            .toast(isPresenting: $isCompleteAlertShown, alert: {
                .init(
                    displayMode: .alert,
                    type: .complete(.green),
                    title: String(localized: "app.gacha.import.success")
                )
            })
            .alert(
                "gacha.import.startImport".localized(),
                isPresented: isReadyToStartAlertShown,
                presenting: alert,
                actions: { thisAlert in
                    Button(
                        "sys.start",
                        role: .destructive,
                        action: {
                            switch thisAlert {
                            case let .readyToStartJson(url: url, format: format):
                                processJson(url: url, format: format)
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

    // MARK: Private

    @Environment(\.managedObjectContext) private var viewContext

    @State private var isHelpSheetShown: Bool = false
    @State private var isCompleteAlertShown: Bool = false
    @State private var currentFormat: UIGFFormat = .uigfv4
    @State private var fallbackLanguage: GachaLanguageCode = .enUS
    @State private var status: ImportStatus = .pending

    @State private var alert: AlertType?

    private var isReadyToStartAlertShown: Binding<Bool> {
        .init {
            alert != nil
        } set: { newValue in
            if newValue == false {
                alert = nil
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .medium
        return fmt
    }

    private func processJson(url: URL, format: UIGFFormat) {
        Task(priority: .userInitiated) {
            status = .reading
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if url.startAccessingSecurityScopedResource() {
                do {
                    let decoder = JSONDecoder()
                    let data: Data = try Data(contentsOf: url)
                    var result = [GachaImportReport]()
                    let appMeta: String?
                    let dateMeta: Date?
                    switch format {
                    case .uigfv4:
                        let uigfModel: UIGFv4 = try decoder
                            .decode(
                                UIGFv4.self,
                                from: data
                            )
                        result = importGachaFromUIGFv4(
                            uigfJson: uigfModel
                        )
                        appMeta = uigfModel.info.exportApp
                        dateMeta = uigfModel.info.maybeDateExported
                    case .srgfv1:
                        let srgfModel: SRGFv1 = try decoder
                            .decode(
                                SRGFv1.self,
                                from: data
                            )
                        result = importGachaFromSRGFv1(
                            srgfJson: srgfModel
                        )
                        appMeta = srgfModel.info.exportApp
                        dateMeta = srgfModel.info.maybeDateExported
                    }
                    var succeededMessages: [ImportSucceedInfo] = []
                    result.forEach { currentMsg in
                        succeededMessages.append(
                            ImportSucceedInfo(
                                uid: currentMsg.uid,
                                totalCount: currentMsg.totalCount,
                                newCount: currentMsg.newCount,
                                app: appMeta,
                                exportDate: dateMeta,
                                timeZone: GachaItem.getServerTimeZoneDelta(currentMsg.uid)
                            )
                        )
                    }
                    status = .succeed(succeededMessages)
                    isCompleteAlertShown.toggle()
                } catch {
                    status = .failure(error.localizedDescription)
                }
                url.stopAccessingSecurityScopedResource()
            } else {
                status = .failure(.init(localized: "app.gacha.import.fail.fileAccessFail"))
            }
        }
    }

    private func importGachaFromSRGFv1(
        srgfJson: SRGFv1
    )
        -> [GachaImportReport] {
        let info = srgfJson.info
        let items = srgfJson.list
        let newCount = addRecordItemsSRGFv1(
            items,
            uid: info.uid,
            lang: info.lang,
            timeZoneDelta: info.regionTimeZone // 优先尊重 JSON 里面写的 TimeZone 资料值。
        )
        return [.init(uid: info.uid, totalCount: items.count, newCount: newCount)]
    }

    private func importGachaFromUIGFv4(
        uigfJson: UIGFv4
    )
        -> [GachaImportReport] {
        let info = uigfJson.info
        var resultStack = [GachaImportReport]()
        uigfJson.hsrProfiles?.forEach { profile in
            let items = profile.list
            let newCount = addRecordItemsUIGFv4(
                items,
                uid: profile.uid,
                lang: profile.lang ?? fallbackLanguage,
                timeZoneDelta: profile.timezone // 优先尊重 JSON 里面写的 TimeZone 资料值。
            )
            resultStack.append(
                .init(uid: profile.uid, totalCount: items.count, newCount: newCount)
            )
        }
        return resultStack
    }

    /// 返回已保存的新数据数量
    private func addRecordItemsSRGFv1(
        _ items: [SRGFv1.DataEntry],
        uid: String,
        lang: GachaLanguageCode,
        timeZoneDelta: Int? = nil
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
                        timeZoneDelta: timeZoneDelta ?? GachaItem.getServerTimeZoneDelta(uid),
                        context: viewContext
                    )
                    count += 1
                }
            }
        }
        save()
        return count
    }

    /// 返回已保存的新数据数量
    private func addRecordItemsUIGFv4(
        _ items: [UIGFv4.DataEntry],
        uid: String,
        lang: GachaLanguageCode,
        timeZoneDelta: Int? = nil
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
                        timeZoneDelta: timeZoneDelta ?? GachaItem.getServerTimeZoneDelta(uid),
                        context: viewContext
                    )
                    count += 1
                }
            }
        }
        save()
        return count
    }

    private func checkIDAndUIDExists(uid: String, id: String) -> Bool {
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

    private func save() {
        do {
            try viewContext.save()
        } catch {
            print("ERROR SAVING. \(error.localizedDescription)")
        }
    }
}

// MARK: - AlertType

private enum AlertType: Identifiable {
    case readyToStartJson(url: URL, format: UIGFFormat)

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
    case succeed([ImportSucceedInfo])
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

private struct ImportSucceedInfo: Equatable, Identifiable {
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

    let id = UUID().uuidString
    let uid: String
    let totalCount: Int
    let newCount: Int
    let app: String?
    let exportDate: Date?
    let timeZoneDelta: Int

    @ViewBuilder var timeView: some View {
        if let date = exportDate {
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

    // MARK: Private

    private var timeZoneDeltaValueText: String {
        switch timeZoneDelta {
        case 0...: return "+\(timeZoneDelta)"
        default: return "\(timeZoneDelta)"
        }
    }

    private var importedTimeZone: TimeZone {
        .init(secondsFromGMT: 3600 * timeZoneDelta) ?? .autoupdatingCurrent
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
        fmt.timeZone = .init(secondsFromGMT: 3600 * timeZoneDelta)
        return fmt
    }
}

// MARK: - HelpSheet

private struct HelpSheet: View {
    @Binding var isShown: Bool

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
                            "app.gacha.import.help.uigf.button",
                            systemSymbol: .appBadgeCheckmark
                        )
                    }
                } footer: {
                    Text("app.gacha.import.uigf.verified.note.2")
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .navigationTitle("sys.help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("sys.done") {
                        isShown.toggle()
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

    @State var isFileImporterShown: Bool = false

    var body: some View {
        Button(title) {
            isFileImporterShown.toggle()
        }
        .fileImporter(isPresented: $isFileImporterShown, allowedContentTypes: allowedContentTypes) { result in
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
                SucceedView(status: $status, infoMsgs: info)
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
    @Binding var status: ImportStatus
    let infoMsgs: [ImportSucceedInfo]

    var body: some View {
        Section {
            Label {
                Text("app.gacha.import.success")
            } icon: {
                Image(systemSymbol: .checkmarkCircle)
                    .foregroundColor(.green)
            }
            if let app = infoMsgs.first?.app {
                let sourceInfo = String(format: "app.gacha.import.info.source:%@".localized(), app)
                Text(sourceInfo)
            }
        }
        ForEach(infoMsgs, id: \.id) { info in
            Section {
                info.timeView
                let importInfo = String(format: "app.gacha.import.info.import:%lld".localized(), info.totalCount)
                let storageInfo = String(format: "app.gacha.import.info.storage:%lld".localized(), info.newCount)
                Text(importInfo)
                Text(storageInfo)
            } header: {
                Text(verbatim: "UID: \(info.uid)")
            }
        }
        Button("app.gacha.import.continue") {
            status = .pending
        }
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
                PopFileButton(
                    title: "app.gacha.import.fromUIGF".localized() + " (Beta)",
                    allowedContentTypes: [.json]
                ) { result in
                    switch result {
                    case let .success(url):
                        alert = .readyToStartJson(url: url, format: .uigfv4)
                    case let .failure(error):
                        status = .failure(error.localizedDescription)
                    }
                }
                PopFileButton(
                    title: "app.gacha.import.fromSRGF".localized(),
                    allowedContentTypes: [.json]
                ) { result in
                    switch result {
                    case let .success(url):
                        alert = .readyToStartJson(url: url, format: .srgfv1)
                    case let .failure(error):
                        status = .failure(error.localizedDescription)
                    }
                }
            } footer: {
                VStack(alignment: .leading) {
                    Text(
                        "app.gacha.import.uigf.verified.note.1"
                    )
                    Text("app.gacha.srgf.affLink.[SRGF](https://uigf.org/)")
                }
            }
        }
    }
}
