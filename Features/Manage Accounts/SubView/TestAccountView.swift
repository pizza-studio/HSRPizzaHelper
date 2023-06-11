//
//  TestAccountView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/5.
//

import Combine
import HBMihoyoAPI
import SwiftUI

struct TestAccountView: View {
    // MARK: Internal

    let account: Account
    let shouldTestAccountSubject: PassthroughSubject<(), Never>

    var body: some View {
        Group {
            Button {
                doTest()
            } label: {
                HStack {
                    Text("account.new.test")
                    Spacer()
                    buttonIcon()
                }
            }
            .disabled(status == .testing)
            if case let .failure(error) = status {
                FailureView(error: error)
            } else if case let .verificationNeeded(verification) = status {
                VerificationNeededView(account: account, verification: verification)
            }
        }
        .onReceive(shouldTestAccountSubject) { _ in
            doTest()
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
                    cookie: account.cookie ?? "",
                    deviceFingerPrint: account.deviceFingerPrint
                )
                withAnimation {
                    status = .succeeded
                }
            } catch let MiHoYoAPIError.verificationNeeded(verification: verification) {
                withAnimation {
                    status = .verificationNeeded(verification)
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
            case .verificationNeeded:
                Image(systemSymbol: .questionmarkCircle)
                    .foregroundColor(.yellow)
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
        case verificationNeeded(Verification)

        // MARK: Internal

        var id: Int {
            switch self {
            case .pending:
                return 0
            case .testing:
                return 1
            case .succeeded:
                return 2
            case let .failure(error):
                return error.localizedDescription.hashValue
            case let .verificationNeeded(verification):
                return verification.challenge.hashValue
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

    private struct VerificationNeededView: View {
        let account: Account
        let verification: Verification

        var body: some View {
            Text("Challenge: \(verification.challenge)")
            Text("Gt: \(verification.gt)")
        }
    }

    @State private var status: TestStatus = .pending
}
