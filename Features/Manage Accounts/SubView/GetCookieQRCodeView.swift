// (c) 2022 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import HBMihoyoAPI
import SwiftUI

// MARK: - GetCookieQRCodeView

struct GetCookieQRCodeView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject var viewModel = GetCookieQRCodeViewModel.shared

    @Binding var cookie: String!

    @Binding var deviceFP: String

    private var qrWidth: CGFloat {
        #if os(OSX) || targetEnvironment(macCatalyst)
        340
        #else
        280
        #endif
    }

    private var qrImage: Image? {
        guard let qrCodeAndTicket = viewModel.qrCodeAndTicket else { return nil }
        let newSize = CGSize(width: qrWidth, height: qrWidth)
        guard let imgResized = qrCodeAndTicket.qrCode.resized(
            size: newSize,
            quality: .none
        ) else { return nil } // 应该不会出现这种情况。
        return Image(decorative: imgResized, scale: 1)
    }

    private static var isMiyousheInstalled: Bool {
        UIApplication.shared.canOpenURL(URL(string: miyousheHeader)!)
    }

    private static var miyousheHeader: String { "mihoyobbs://" }

    private static var miyousheStorePage: String {
        "https://apps.apple.com/cn/app/id1470182559"
    }

    private var shouldShowRetryButton: Bool {
        viewModel.qrCodeAndTicket != nil || viewModel.error != nil
    }

    private func fireAutoCheckScanningConfirmationStatus() async {
        guard !viewModel.scanningConfirmationStatus.isBusy else { return }
        guard let ticket = viewModel.qrCodeAndTicket?.ticket else { return }
        let task = Task.detached { @MainActor [weak viewModel] in
            loopTask: while case .automatically = viewModel?.scanningConfirmationStatus {
                guard let viewModel = viewModel else { break loopTask }
                do {
                    let status = try await MiHoYoAPI.queryQRCodeStatus(
                        deviceId: viewModel.taskId,
                        ticket: ticket
                    )
                    if let parsedResult = try await status.parsed() {
                        try await parseGameToken(from: parsedResult, dismiss: true)
                        break loopTask
                    }
                    try await Task.sleep(nanoseconds: 3 * 1_000_000_000) // 3sec.
                } catch {
                    viewModel.error = error
                    break loopTask
                }
            }
            viewModel?.scanningConfirmationStatus = .idle
        }
        viewModel.scanningConfirmationStatus = .automatically(task)
    }

    private func loginCheckScannedButtonDidPress(ticket: String) async {
        viewModel.cancelAllConfirmationTasks(resetState: false)
        let task = Task.detached { @MainActor in
            do {
                let status = try await MiHoYoAPI.queryQRCodeStatus(
                    deviceId: viewModel.taskId,
                    ticket: ticket
                )
                if let parsedResult = try await status.parsed() {
                    try await parseGameToken(from: parsedResult, dismiss: true)
                } else {
                    viewModel.isNotScannedAlertShown = true
                }
            } catch {
                viewModel.error = error
            }
            viewModel.scanningConfirmationStatus = .idle
        }
        viewModel.scanningConfirmationStatus = .manually(task)
    }

    private func parseGameToken(
        from parsedResult: QueryQRCodeStatus.ParsedResult,
        dismiss shouldDismiss: Bool = true
    ) async throws {
        var cookie = ""
        cookie += "stuid=" + parsedResult.accountId + "; "
        cookie += "stoken=" + parsedResult.stoken + "; "
        cookie += "ltuid=" + parsedResult.accountId + "; "
        cookie += "ltoken=" + parsedResult.ltoken + "; "
        cookie += "mid=" + parsedResult.mid + "; "
        try await extraCookieProcess(cookie: &cookie)
        self.cookie = cookie
        if shouldDismiss { dismiss() }
    }

    @ViewBuilder
    private func errorView() -> some View {
        if let error = viewModel.error {
            Label {
                Text(error.localizedDescription)
            } icon: {
                Image(systemSymbol: .exclamationmarkCircle)
                    .foregroundStyle(.red)
            }.onAppear {
                viewModel.qrCodeAndTicket = nil
            }
        }
    }

    @ViewBuilder
    private func qrImageView(_ image: Image) -> some View {
        HStack(alignment: .center) {
            Spacer()
            ShareLink(
                item: image,
                preview: SharePreview("account.qr_code_login.shared_qr_code_title", image: image)
            ) {
                image
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: qrWidth, height: qrWidth + 12, alignment: .top)
                    .padding()
            }
            Spacer()
        }
        .overlay(alignment: .bottom) {
            Text("account.qr_code_login.click_qr_to_save").font(.footnote)
                .padding(4)
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.primary.opacity(0.05)))
        }
    }

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    errorView()
                    if let qrCodeAndTicket = viewModel.qrCodeAndTicket, let qrImage = qrImage {
                        qrImageView(qrImage)
                        if case .manually = viewModel.scanningConfirmationStatus {
                            ProgressView()
                        } else {
                            Button("account.qr_code_login.check_scanned") {
                                Task {
                                    await loginCheckScannedButtonDidPress(
                                        ticket: qrCodeAndTicket.ticket
                                    )
                                }
                            }.onAppear {
                                Task {
                                    await fireAutoCheckScanningConfirmationStatus()
                                }
                            }
                        }
                    } else {
                        ProgressView()
                    }
                    if shouldShowRetryButton {
                        Button("account.qr_code_login.regenerate_qrcode") {
                            simpleTaptic(type: .light)
                            viewModel.reCreateQRCode()
                        }
                    }
                    if Self.isMiyousheInstalled {
                        Link(destination: URL(string: Self.miyousheHeader + "me")!) {
                            Text("account.qr_code_login.open_miyoushe")
                        }
                    } else {
                        Link(destination: URL(string: Self.miyousheStorePage)!) {
                            Text("account.qr_code_login.open_miyoushe_mas_page")
                        }
                    }
                } footer: {
                    Text("account.qr_code_login.footer")
                }
            }
            .alert("account.qr_code_login.not_scanned_alert", isPresented: $viewModel.isNotScannedAlertShown) {
                Button("sys.done") {
                    viewModel.isNotScannedAlertShown.toggle()
                }
            }
            .navigationTitle("account.qr_code_login.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("sys.cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - GetCookieQRCodeViewModel

// Credit: Bill Haku for the fix.
class GetCookieQRCodeViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        self.taskId = .init()
        reCreateQRCode()
    }

    deinit {
        scanningConfirmationStatus = .idle
    }

    // MARK: Public

    public func reCreateQRCode() {
        taskId = .init()
        Task.detached { @MainActor in
            do {
                self.qrCodeAndTicket = try await MiHoYoAPI.generateLoginQRCode(deviceId: self.taskId)
                self.error = nil
            } catch {
                self.error = error
            }
        }
    }

    // MARK: Internal

    enum ScanningConfirmationStatus {
        case manually(Task<Void, Never>)
        case automatically(Task<Void, Never>)
        case idle

        // MARK: Internal

        var isBusy: Bool {
            switch self {
            case .automatically, .manually: return true
            case .idle: return false
            }
        }
    }

    static var shared: GetCookieQRCodeViewModel = .init()

    @Published var qrCodeAndTicket: (qrCode: CGImage, ticket: String)?
    @Published var taskId: UUID
    @Published var scanningConfirmationStatus: ScanningConfirmationStatus = .idle
    @Published var isNotScannedAlertShown: Bool = false

    @Published var error: Error? {
        didSet {
            if error != nil {
                qrCodeAndTicket = nil
            }
        }
    }

    func cancelAllConfirmationTasks(resetState: Bool) {
        switch scanningConfirmationStatus {
        case let .automatically(task), let .manually(task):
            task.cancel()
            if resetState {
                scanningConfirmationStatus = .idle
            }
        case .idle: return
        }
    }
}
