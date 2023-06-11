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
            } else if status == .verificationNeeded {
                VerificationNeededView(account: account, shouldTestAccountSubject: shouldTestAccountSubject)
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
            } catch MiHoYoAPIError.verificationNeeded {
                withAnimation {
                    status = .verificationNeeded
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
        case verificationNeeded

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
            case .verificationNeeded:
                return 4
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
        // MARK: Internal

        let account: Account
        let shouldTestAccountSubject: PassthroughSubject<(), Never>

        var body: some View {
            Button("Verify") {
                status = .gettingVerification
                Task(priority: .userInitiated) {
                    do {
                        let verification = try await MiHoYoAPI.createVerification(
                            cookie: account.cookie,
                            deviceFingerPrint: account.deviceFingerPrint
                        )
                        status = .gotVerification(verification)
                        sheetItem = .gotVerification(verification)
                    } catch {
                        status = .fail(error)
                    }
                }
            }
            .sheet(item: $sheetItem, content: { item in
                switch item {
                case let .gotVerification(verification):
                    GeetestValidateView(
                        challenge: verification.challenge,
                        gt: verification.gt,
                        completion: { validate in
                            status = .pending
                            verifyValidate(validate: validate)
                            sheetItem = nil
                        }
                    )
                }
            })
        }

        func verifyValidate(validate: String) {}

        // MARK: Private

        private enum Status: CustomStringConvertible {
            case pending
            case gettingVerification
            case gotVerification(Verification)
            case fail(Error)

            // MARK: Internal

            var description: String {
                switch self {
                case let .fail(error):
                    return "ERROR: \(error.localizedDescription)"
                case .gettingVerification:
                    return "gettingVerification"
                case let .gotVerification(verification):
                    return "Challenge: \(verification.challenge)"
                case .pending:
                    return "PENDING"
                }
            }
        }

        private enum SheetItem: Identifiable {
            case gotVerification(Verification)

            // MARK: Internal

            var id: Int {
                switch self {
                case let .gotVerification(verification):
                    return verification.challenge.hashValue
                }
            }
        }

        @State private var status: Status = .gettingVerification

        @State private var sheetItem: SheetItem?
    }

    @State private var status: TestStatus = .pending
}
