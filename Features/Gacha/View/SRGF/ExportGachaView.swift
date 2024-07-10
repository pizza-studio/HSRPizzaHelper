// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import CoreData
import GachaKit
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
                                Button("app.gacha.data.export.button") {
                                    exportButtonClicked()
                                }
                                .disabled(params.uid == nil)
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
                Button("button.okay") {
                    isSucceedAlertShown = false
                }
            },
            message: { thisAlert in
                switch thisAlert {
                case let .succeed(url):
                    Text("gacha.export.fileSavedTo:\(url)")
                default:
                    EmptyView()
                }
            }
        )
        .alert(
            "gacha.export.failedInSavingToFile",
            isPresented: $isFailureAlertShown,
            presenting: alert,
            actions: { _ in
                Button("button.okay") {
                    isFailureAlertShown = false
                }
            },
            message: { thisAlert in
                switch thisAlert {
                case let .failure(error):
                    Text("错误信息：\(error)")
                default:
                    EmptyView()
                }
            }
        )
        .fileExporter(
            isPresented: $isExporterPresented,
            document: file,
            contentType: .json,
            defaultFilename: defaultFileName
        ) { result in
            switch result {
            case let .success(url):
                alert = .succeed(url: url.absoluteString)
            case let .failure(failure):
                alert = .failure(message: failure.localizedDescription)
            }
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
            } footer: {
                Text("app.gacha.srgf.affLink.[SRGF](https://uigf.org/)")
            }
        }
    }

    @ViewBuilder
    func compactMain() -> some View {
        Menu("gacha.manage.srgf.export.toolbarTitle") {
            ForEach(GachaLanguageCode.allCases, id: \.rawValue) { code in
                Button(code.localized) {
                    params.lang = code
                    exportButtonClicked()
                }
            }
        }
    }

    func exportButtonClicked() {
        let uid = params.uid!
        let items = fetchAllMO(uid: uid).map {
            let timeZoneDelta = GachaItem.getServerTimeZoneDelta(uid)
            return $0.toSRGFEntry(langOverride: params.lang, timeZoneDelta: timeZoneDelta)
        }
        srgfJson = .init(
            info: .init(uid: uid, lang: params.lang),
            list: items
        )
        isExporterPresented.toggle()
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

    private var accountPickerPairs: [(value: String, tag: String?)] {
        var result = [(value: String, tag: String?)]()
        if params.uid == nil {
            let i18nStr = String(localized: .init(stringLiteral: "app.gacha.account.select.notSelected"))
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

    private var defaultFileName: String {
        srgfJson?.defaultFileNameStem ?? "Untitled"
    }

    private var file: JsonFile? {
        srgfJson?.asDocument
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

// MARK: - ExportGachaParams

private class ExportGachaParams: ObservableObject {
    @Published var uid: String?
    @Published var lang: GachaLanguageCode = .zhHans
}

// MARK: - JsonFile

typealias JsonFile = SRGFv1.Document

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
