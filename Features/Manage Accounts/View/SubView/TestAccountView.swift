//
//  TestAccountView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//

import HBMihoyoAPI
import SwiftUI

struct TestAccountView: View {
    // MARK: Internal

    let account: Account

    var body: some View {
        Button {
            doTest()
        } label: {
            HStack {
                Text("Test account")
                Spacer()
                buttonIcon()
            }
        }
        .disabled(status == .testing)
        if case let .failure(error) = status {
            FailureView(error: error)
        }
    }

    func doTest() {
        withAnimation {
            status = .testing
        }
        Task {
            do {
                _ = try await MiHoYoAPI.note(
                    server: account.server,
                    uid: account.uid ?? "",
                    cookie: account.cookie ?? ""
                )
                withAnimation {
                    status = .succeeded
                }
            } catch {
                withAnimation {
                    status = .failure(error)
                }
            }
        }
    }

    @ViewBuilder
    func buttonIcon() -> some View {
        Group {
            switch status {
            case .succeeded:
                Image(systemSymbol: .checkmarkCircle)
                    .foregroundColor(.green)
            case .failure:
                Image(systemSymbol: .xmarkCircle)
                    .foregroundColor(.red)
            case .testing:
                ProgressView()
            default:
                EmptyView()
            }
        }
    }

    // MARK: Private

    private enum TestStatus: Identifiable, Equatable {
        case pending
        case testing
        case succeeded
        case failure(Error)

        // MARK: Internal

        var id: Int {
            switch self {
            case .pending:
                return 0
            case .testing:
                return 1
            case .succeeded:
                // swiftlint:disable:next no_magic_numbers
                return 2
            case let .failure(error):
                return error.localizedDescription.hashValue
            }
        }

        static func == (lhs: TestAccountView.TestStatus, rhs: TestAccountView.TestStatus) -> Bool {
            lhs.id == rhs.id
        }
    }

    private struct FailureView: View {
        let error: Error

        var body: some View {
            Text(error.localizedDescription)
            if let error = error as? LocalizedError {
                if let failureReason = error.failureReason {
                    Text(failureReason)
                }
                if let recoverySuggestion = error.recoverySuggestion {
                    Text(recoverySuggestion)
                }
            }
        }
    }

    @State private var status: TestStatus = .pending
}
