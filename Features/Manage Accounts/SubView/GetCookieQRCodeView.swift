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

    @State private var isNotScannedAlertShow: Bool = false

    @State private var isCheckingScanning = false

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

    var body: some View {
        NavigationStack {
            List {
                Section {
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
                    if let qrCodeAndTicket = viewModel.qrCodeAndTicket, let qrImage = qrImage {
                        HStack(alignment: .center) {
                            Spacer()
                            ShareLink(
                                item: qrImage,
                                preview: SharePreview("account.qr_code_login.shared_qr_code_title", image: qrImage)
                            ) {
                                qrImage
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
                        if isCheckingScanning {
                            ProgressView()
                        } else {
                            Button("account.qr_code_login.check_scanned") {
                                Task {
                                    isCheckingScanning = true
                                    do {
                                        let status = try await MiHoYoAPI.queryQRCodeStatus(
                                            deviceId: viewModel.taskId,
                                            ticket: qrCodeAndTicket.ticket
                                        )

                                        if case let .confirmed(accountId: accountId, token: gameToken) = status {
                                            let stokenResult = try await MiHoYoAPI.gameToken2StokenV2(
                                                accountId: accountId,
                                                gameToken: gameToken
                                            )
                                            let stoken = stokenResult.stoken
                                            let mid = stokenResult.mid

                                            let ltoken = try await MiHoYoAPI.stoken2LTokenV1(
                                                mid: mid,
                                                stoken: stoken
                                            ).ltoken

                                            var cookie = ""
                                            cookie += "stuid=" + accountId + "; "
                                            cookie += "stoken=" + stoken + "; "
                                            cookie += "ltuid=" + accountId + "; "
                                            cookie += "ltoken=" + ltoken + "; "
                                            cookie += "mid=" + mid + "; "
                                            self.cookie = cookie

                                            dismiss()
                                        } else {
                                            isNotScannedAlertShow = true
                                        }
                                    } catch {
                                        viewModel.error = error
                                    }
                                    isCheckingScanning = false
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
                        Link(
                            destination: URL(
                                string: Self.miyousheHeader + "me"
                            )!
                        ) {
                            Text("account.qr_code_login.open_miyoushe")
                        }
                    } else {
                        Link(
                            destination: URL(
                                string: Self.miyousheStorePage
                            )!
                        ) {
                            Text("account.qr_code_login.open_miyoushe_mas_page")
                        }
                    }
                } footer: {
                    Text("account.qr_code_login.footer")
                }
            }
            .alert("account.qr_code_login.not_scanned_alert", isPresented: $isNotScannedAlertShow, actions: {
                Button("sys.done") {
                    isNotScannedAlertShow.toggle()
                }
            })
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

    static var shared: GetCookieQRCodeViewModel = .init()

    @Published var qrCodeAndTicket: (qrCode: CGImage, ticket: String)?
    @Published var taskId: UUID

    @Published var error: Error? {
        didSet {
            if error != nil {
                qrCodeAndTicket = nil
            }
        }
    }
}
