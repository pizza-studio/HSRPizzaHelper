// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import CoreData
import GachaKitHSR
import HBMihoyoAPI
import SwiftUI
import UniformTypeIdentifiers

// MARK: - ExportGachaView

struct ExportGachaView: View {
    // MARK: Lifecycle

    public init(compactLayout: Bool = false, uid: String? = nil) {
        self.compactLayout = compactLayout
        params.uid = uid
    }

    // MARK: Internal

    var body: some View {
        Group {
            if compactLayout {
                compactMain()
            } else {
                NavigationStack {
                    main()
                        .navigationTitle("app.gacha.data.export.button")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                exportButton()
                            }
                        }
                }
            }
        }
        .alert(
            "gacha.export.succeededInSavingToFile",
            isPresented: $isSucceedAlertShown,
            presenting: alert,
            actions: { _ in
                Button("button.okay") { isSucceedAlertShown = false }
            },
            message: { _ in
                postAlertMessage()
            }
        )
        .alert(
            "gacha.export.failedInSavingToFile",
            isPresented: $isFailureAlertShown,
            presenting: alert,
            actions: { _ in
                Button("button.okay") { isSucceedAlertShown = false }
            },
            message: { _ in
                postAlertMessage()
            }
        )
        .fileExporter(
            isPresented: $isExporterPresented,
            document: currentDocument,
            contentType: .json,
            defaultFilename: fileNameStem
        ) { result in
            handleFileExporterResult(result)
        }
    }

    @ViewBuilder
    func main() -> some View {
        List {
            Section {
                accountPicker()
            }
            Section {
                Picker("gacha.export.chooseLanguage", selection: $params.lang) {
                    ForEach(GachaLanguageCode.allCases, id: \.rawValue) { code in
                        Text(code.localized).tag(code)
                    }
                }
                Picker("gacha.export.chooseFormat", selection: $currentFormat) {
                    Text(verbatim: "UIGFv4.0").tag(UIGFFormat.uigfv4)
                    Text(verbatim: "SRGFv1").tag(UIGFFormat.srgfv1)
                }
            } footer: {
                Text("app.gacha.uigf.affLink.[UIGF](https://uigf.org/)")
            }
        }
    }

    @ViewBuilder
    func compactMain() -> some View {
        Menu {
            Menu {
                ForEach(GachaLanguageCode.allCases, id: \.rawValue) { code in
                    Button(code.localized) {
                        params.lang = code
                        exportButtonClicked(format: .uigfv4)
                    }
                }
            } label: {
                Text(verbatim: "UIGFv4.0")
            }
            Menu {
                ForEach(GachaLanguageCode.allCases, id: \.rawValue) { code in
                    Button(code.localized) {
                        params.lang = code
                        exportButtonClicked(format: .srgfv1)
                    }
                }
            } label: {
                Text(verbatim: "SRGFv1")
            }
        } label: {
            Label("gacha.manage.uigf.export.toolbarTitle", systemSymbol: .squareAndArrowUpOnSquare)
        }
    }

    // MARK: Private

    @State private var isSucceedAlertShown: Bool = false
    @State private var isFailureAlertShown: Bool = false
    private let compactLayout: Bool

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(sortDescriptors: [
        .init(keyPath: \Account.priority, ascending: true),
    ]) private var accounts: FetchedResults<Account>

    @ObservedObject private var params: ExportGachaParams = .init()

    @State private var isExporterPresented: Bool = false

    @State private var srgfJson: SRGFv1?
    @State private var uigfJson: UIGFv4?
    @State private var currentFormat: UIGFFormat = .uigfv4

    private var currentDocument: GachaDocument? {
        switch currentFormat {
        case .uigfv4: uigfJson?.asDocument
        case .srgfv1: srgfJson?.asDocument
        }
    }

    private var fileNameStem: String {
        switch currentFormat {
        case .uigfv4:
            return uigfJson?.getFileNameStem(uid: params.uid, for: .starRail) ?? "Untitled"
        case .srgfv1:
            return srgfJson?.defaultFileNameStem ?? "Untitled"
        }
    }

    private var accountPickerPairs: [(value: String, tag: String?)] {
        var result = [(value: String, tag: String?)]()
        if params.uid == nil {
            var i18nKey = "app.gacha.account.select.selectAll"
            if currentFormat == .srgfv1 {
                i18nKey = "app.gacha.account.select.notSelected"
            }
            let i18nStr = String(localized: .init(stringLiteral: i18nKey))
            result.append((i18nStr, nil))
        }
        result.append(contentsOf: allAvaliableAccountUID.map { uid in
            if let name = firstAccount(uid: uid)?.name {
                return (value: "\(name) (\(uid))", tag: uid)
            } else {
                return (value: "UID: \(uid)", tag: uid)
            }
        })
        return result
    }

    @State private var alert: AlertType? {
        didSet {
            if let alert = alert {
                switch alert {
                case .succeed:
                    isSucceedAlertShown = true
                case .failure:
                    isFailureAlertShown = true
                }
            } else {
                isSucceedAlertShown = false
                isFailureAlertShown = false
            }
        }
    }

    private func exportButtonClicked(format: UIGFFormat) {
        switch format {
        case .uigfv4:
            currentFormat = format
            srgfJson = nil
            if let uid = params.uid {
                let itemsUIGF = fetchAllMO(uid: uid).map {
                    $0.toUIGFEntry(
                        langOverride: params.lang,
                        timeZoneDeltaOverride: nil
                    )
                }
                let hsrProfile = UIGFv4.ProfileHSR(
                    lang: params.lang,
                    list: itemsUIGF,
                    timezone: nil,
                    uid: uid
                )
                uigfJson = .init(info: .init(), hsrProfiles: [hsrProfile])
            } else {
                uigfJson = exportAllAccountDataIntoSingleUIGFv4()
            }
            isExporterPresented = true
        case .srgfv1:
            guard let uid = params.uid else { return }
            currentFormat = format
            uigfJson = nil
            let itemsSRGF = fetchAllMO(uid: uid).map {
                $0.toSRGFEntry(
                    langOverride: params.lang,
                    timeZoneDeltaOverride: nil
                )
            }
            srgfJson = .init(
                info: .init(uid: uid, lang: params.lang),
                list: itemsSRGF
            )
            isExporterPresented = true
        }
    }

    @ViewBuilder
    private func accountPicker() -> some View {
        Picker("app.gacha.account.select.title", selection: $params.uid) {
            Group {
                ForEach(accountPickerPairs, id: \.tag) { value, tag in
                    Text(value).tag(tag)
                }
            }
        }
    }

    private func firstAccount(uid: String) -> Account? {
        accounts.first(where: { $0.uid! == uid })
    }

    private func handleFileExporterResult(_ result: Result<URL, any Error>) {
        switch result {
        case let .success(url):
            alert = .succeed(url: url.absoluteString)
        case let .failure(failure):
            alert = .failure(message: failure.localizedDescription)
        }
    }

    @ViewBuilder
    private func postAlertMessage() -> some View {
        switch alert {
        case let .succeed(url): Text("gacha.export.fileSavedTo:\(url)")
        case let .failure(message): Text(verbatim: "⚠︎ \(message)")
        case nil: EmptyView()
        }
    }

    @ViewBuilder
    private func exportButton() -> some View {
        Button("app.gacha.data.export.button") {
            exportButtonClicked(format: currentFormat)
        }
        .disabled(params.uid == nil && currentFormat == .srgfv1)
    }
}

extension ExportGachaView {
    var allAvaliableAccountUID: [String] {
        let request =
            NSFetchRequest<NSFetchRequestResult>(entityName: "GachaItemMO")
        request.resultType = .dictionaryResultType
        request.returnsDistinctResults = true
        request.propertiesToFetch = ["uid"]
        return ((try? viewContext.fetch(request) as? [[String: String]]) ?? []).compactMap { $0["uid"] }
    }

    func fetchAllMO(uid: String, gachaType: GachaType? = nil) -> [GachaItemMO] {
        viewContext.performAndWait {
            viewContext.refreshAllObjects()
        }
        let request = GachaItemMO.fetchRequest()
        var predicate = NSPredicate(format: "(uid = %@)", uid)
        ifHavingType: do {
            guard let rawType = gachaType?.rawValue else { break ifHavingType }
            predicate = NSPredicate(format: "(uid = %@) AND (gachaType = %i)", uid, rawType)
        }
        request.predicate = predicate
        let dateSortId = NSSortDescriptor(
            keyPath: \GachaItemMO.id,
            ascending: false
        )
        let dateSortTime = NSSortDescriptor(
            keyPath: \GachaItemMO.time, ascending: false
        )
        request.sortDescriptors = [dateSortTime, dateSortId]
        do {
            let gachaItemMOs = try viewContext.fetch(request)
            return gachaItemMOs
        } catch {
            print("ERROR FETCHING CONFIGURATION. \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: - Batch Export Support (UIGFv4 Only).

extension ExportGachaView {
    public func exportAllAccountDataIntoSingleUIGFv4() -> UIGFv4 {
        let profiles: [UIGFv4.ProfileHSR] = allAvaliableAccountUID.compactMap { uid in
            let itemsUIGF = fetchAllMO(uid: uid).map {
                $0.toUIGFEntry(
                    langOverride: params.lang,
                    timeZoneDeltaOverride: nil
                )
            }
            return !itemsUIGF.isEmpty ? UIGFv4.ProfileHSR(
                lang: params.lang,
                list: itemsUIGF,
                timezone: nil,
                uid: uid
            ) : nil
        }
        return .init(info: .init(), hsrProfiles: profiles)
    }
}

// MARK: - ExportGachaParams

private class ExportGachaParams: ObservableObject {
    @Published var uid: String?
    @Published var lang: GachaLanguageCode = .zhHans
}

// MARK: - AlertType

private enum AlertType: Identifiable {
    case succeed(url: String)
    case failure(message: String)

    // MARK: Internal

    var id: String {
        switch self {
        case .succeed:
            return "succeed"
        case .failure:
            return "failure"
        }
    }
}
