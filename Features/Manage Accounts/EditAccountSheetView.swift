//
//  EditAccountSheetView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//

import SwiftUI

// MARK: - EditAccountSheetView

struct EditAccountSheetView: View {
    // MARK: Lifecycle

    init(account: Account, isShown: Binding<Bool>) {
        self._account = StateObject(wrappedValue: account)
        self._isShown = isShown
    }

    // MARK: Internal

    var body: some View {
        NavigationView {
            List {
                EditAccountView(account: account)
            }
            .navigationTitle("account.edit.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("sys.done") {
                        viewContext.performAndWait {
                            do {
                                try viewContext.save()
                                isShown.toggle()
                            } catch {
                                saveAccountError = .saveDataError(error)
                                isSaveAccountFailAlertShown.toggle()
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("sys.cancel") {
                        viewContext.rollback()
                        isShown.toggle()
                    }
                }
            }
            .alert(isPresented: $isSaveAccountFailAlertShown, error: saveAccountError) {
                Button("sys.ok") {
                    isSaveAccountFailAlertShown.toggle()
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.managedObjectContext) private var viewContext

    @StateObject private var account: Account

    @Binding private var isShown: Bool

    @State private var isSaveAccountFailAlertShown: Bool = false
    @State private var saveAccountError: SaveAccountError?
}

// MARK: - SaveAccountError

private enum SaveAccountError {
    case saveDataError(Error)
    case missingFieldError(String)
}

// MARK: LocalizedError

extension SaveAccountError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .saveDataError(error):
            return "Save Account Fail\nSave Error: \(error).\nPlease try again."
        case let .missingFieldError(field):
            return "Save Account Fail\nMissing Fields: \(field).\nPlease try again."
        }
    }

    var failureReason: String? {
        switch self {
        case let .saveDataError(error):
            return "Save Error: \(error)."
        case let .missingFieldError(field):
            return "Missing Fields: \(field)."
        }
    }

    var helpAnchor: String? {
        "Please try login again. "
    }
}
