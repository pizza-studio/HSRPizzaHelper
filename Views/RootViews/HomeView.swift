//
//  HomeView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//

import SwiftUI
import AlertToast
import HBMihoyoAPI

struct HomeView: View {
    @EnvironmentObject
    var viewModel: ViewModel

    @Environment(\.scenePhase)
    var scenePhase

    var animation: Namespace.ID

    var accounts: [Account] { viewModel.accounts }
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if viewModel.accounts.isEmpty {
                        NavigationLink(destination: AddAccountView()) {
                            Label("Add an Account", systemImage: "plus.circle")
                        }
                        .padding()
                        .blurMaterialBackground()
                        .clipShape(RoundedRectangle(
                            cornerRadius: 10,
                            style: .continuous
                        ))
                        .padding(.top, 30)
                    } else {
                        // MARK: - 帐号信息

                        AccountInfoCards(animation: animation)
                    }
                }
            }
            .navigationTitle("HSR Pizza Helper")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(.stack)
        .myRefreshable {
            withAnimation {
                DispatchQueue.main.async {
                    viewModel.refreshData()
                }
            }
        }
    }
}

extension View {
    @ViewBuilder
    func myRefreshable(action: @escaping () -> ()) -> some View {
        if #available(iOS 15, *) {
            self.refreshable {
                action()
            }
        } else {
            self
        }
    }
}

// MARK: - AccountInfoCards

private struct AccountInfoCards: View {
    @EnvironmentObject
    var viewModel: ViewModel
    var animation: Namespace.ID

    @AppStorage(
        "pinToTopAccountUUIDString"
    )
    var pinToTopAccountUUIDString: String =
        ""

    @State
    var isErrorAlertShow: Bool = false
    @State
    var errorMessage: String = ""
    @State
    var isSucceedAlertShow: Bool = false

    var body: some View {
        PinnedAccountInfoCard(
            animation: animation,
            isErrorAlertShow: $isErrorAlertShow,
            errorMessage: $errorMessage,
            isSucceedAlertShow: $isSucceedAlertShow
        )
        .overlay(
            EmptyView()
//                .alert(isPresented: $isSucceedAlertShow) {
//                    Alert(title: Text("创建树脂计时器成功".localized))
//                }
                .toast(isPresenting: $isSucceedAlertShow) {
                    AlertToast(
                        displayMode: .hud,
                        type: .complete(.green),
                        title: "创建树脂计时器成功"
                    )
                }
        )
        .overlay(
            EmptyView()
//                .alert(isPresented: $isErrorAlertShow) {
//                    Alert(title: Text("ERROR \(errorMessage)"))
//                }
                .toast(isPresenting: $isErrorAlertShow) {
                    AlertToast(
                        displayMode: .hud,
                        type: .error(.red),
                        title: "ERROR \(errorMessage)"
                    )
                }
        )
        ForEach($viewModel.accounts, id: \.config.uuid) { $account in
            if account != viewModel.showDetailOfAccount,
               account != viewModel.accounts
               .first(where: {
                   $0.config.uuid?
                       .uuidString ?? "1" == pinToTopAccountUUIDString
               }) {
                if account.result != nil {
                    switch account.result! {
                    case let .success(userData):
                        // 我也不知道为什么如果不检查的话删除帐号会崩溃
                        if account.config.uuid != nil {
                            GameInfoBlock(
                                userData: userData,
                                accountName: account.config.name,
                                accountUUIDString: account.config.uuid!
                                    .uuidString,
                                animation: animation,
//                                widgetBackground: account.background,
                                fetchComplete: account.fetchComplete
                            )
                            .padding([.bottom, .horizontal])
                            .listRowBackground(Color.white.opacity(0))
                            .onTapGesture {
                                simpleTaptic(type: .medium)
                                withAnimation(
                                    .interactiveSpring(
                                        response: 0.5,
                                        dampingFraction: 0.8,
                                        blendDuration: 0.8
                                    )
                                ) {
                                    viewModel.showDetailOfAccount = account
                                }
                            }
                            .contextMenu {
                                Button("顶置".localized) {
                                    withAnimation {
                                        pinToTopAccountUUIDString = account
                                            .config.uuid!.uuidString
                                    }
                                }
//                                if #available(iOS 16, *) {
//                                    Button("保存图片".localized) {
//                                        let view = GameInfoBlockForSave(
//                                            userData: userData,
//                                            accountName: account.config
//                                                .name ?? "",
//                                            accountUUIDString: account
//                                                .config.uuid?.uuidString ?? "",
//                                            animation: animation,
//                                            widgetBackground: account
//                                                .background
//                                        ).environment(
//                                            \.locale,
//                                            .init(
//                                                identifier: Locale.current
//                                                    .identifier
//                                            )
//                                        )
//                                        let renderer =
//                                            ImageRenderer(content: view)
//                                        renderer.scale = UIScreen.main.scale
//                                        if let image = renderer.uiImage {
//                                            UIImageWriteToSavedPhotosAlbum(
//                                                image,
//                                                nil,
//                                                nil,
//                                                nil
//                                            )
//                                        }
//                                    }
//                                }
                                #if canImport(ActivityKit)
//                                if #available(iOS 16.1, *) {
//                                    Button("为该帐号开启树脂计时器") {
//                                        do {
//                                            try ResinRecoveryActivityController
//                                                .shared
//                                                .createResinRecoveryTimerActivity(
//                                                    for: account
//                                                )
//                                            isSucceedAlertShow.toggle()
//                                        } catch {
//                                            errorMessage = error
//                                                .localizedDescription
//                                            isErrorAlertShow.toggle()
//                                        }
//                                    }
//                                }
                                #endif
                                #if DEBUG
                                Button("Toast Debug") {
                                    isSucceedAlertShow.toggle()
                                    print("isSucceedAlertShow toggle")
                                }
                                #endif
                            }
                        }
                    case .failure:
                        HStack {
                            NavigationLink {
                                AccountDetailView(account: $account)
                            } label: {
                                ZStack {
                                    Image(
                                        systemName: "exclamationmark.arrow.triangle.2.circlepath"
                                    )
                                    .padding()
                                    .foregroundColor(.red)
                                    HStack {
                                        Spacer()
                                        Text(account.config.name ?? "")
                                            .foregroundColor(Color(
                                                UIColor
                                                    .systemGray4
                                            ))
                                            .font(.caption2)
                                            .padding(.horizontal)
                                    }
                                }
                                .padding([.bottom, .horizontal])
                            }
                        }
                    }
                } else {
                    ProgressView()
                        .padding([.bottom, .horizontal])
                }
            }
        }
    }
}

// MARK: - PinnedAccountInfoCard

private struct PinnedAccountInfoCard: View {
    // MARK: Internal

    @EnvironmentObject
    var viewModel: ViewModel
    var animation: Namespace.ID
    @AppStorage(
        "pinToTopAccountUUIDString"
    )
    var pinToTopAccountUUIDString: String =
        ""
    @Binding
    var isErrorAlertShow: Bool
    @Binding
    var errorMessage: String

    @Binding
    var isSucceedAlertShow: Bool

    var accountIndex: Int? {
        viewModel.accounts
            .firstIndex(where: {
                $0.config.uuid?.uuidString ?? "1" == pinToTopAccountUUIDString
            })
    }

    var bindingAccount: Binding<Account>? {
        if let accountIndex = accountIndex {
            return $viewModel.accounts[accountIndex]
        } else {
            return nil
        }
    }

    var body: some View {
        realBody
    }

    // MARK: Private

    private var realBody: some View {
        guard let accountIndex = accountIndex
        else { return AnyView(EmptyView()) }
        let account: Account = viewModel.accounts[accountIndex]
        guard account != viewModel.showDetailOfAccount
        else { return AnyView(EmptyView()) }
        guard let accountResult = account.result
        else { return AnyView(ProgressView().padding([.bottom, .horizontal])) }
        return AnyView(buildBodyView(for: accountResult, account: account))
    }

    @ViewBuilder
    private func buildBodyView(
        for accountResult: FetchResult,
        account: Account
    )
        -> some View {
        switch accountResult {
        case let .success(userData)
            where account.config.uuid != nil:
            GameInfoBlock(
                userData: userData,
                accountName: account.config.name,
                accountUUIDString: account.config.uuid!
                    .uuidString,
                animation: animation,
//                widgetBackground: account.background,
                fetchComplete: account.fetchComplete
            )
            .padding([.bottom, .horizontal])
            .listRowBackground(Color.white.opacity(0))
            .onTapGesture {
                simpleTaptic(type: .medium)
                withAnimation(
                    .interactiveSpring(
                        response: 0.5,
                        dampingFraction: 0.8,
                        blendDuration: 0.8
                    )
                ) {
                    viewModel
                        .showDetailOfAccount = account
                }
            }
            .contextMenu {
//                if #available(iOS 16, *) {
//                    Button("保存图片".localized) {
//                        let view = GameInfoBlockForSave(
//                            userData: userData,
//                            accountName: account.config
//                                .name ?? "",
//                            accountUUIDString: account
//                                .config.uuid?
//                                .uuidString ?? "",
//                            animation: animation,
//                            widgetBackground: account
//                                .background
//                        ).environment(
//                            \.locale,
//                            .init(
//                                identifier: Locale
//                                    .current.identifier
//                            )
//                        )
//                        let renderer =
//                            ImageRenderer(content: view)
//                        renderer.scale = UIScreen.main
//                            .scale
//                        if let image = renderer
//                            .uiImage {
//                            UIImageWriteToSavedPhotosAlbum(
//                                image,
//                                nil,
//                                nil,
//                                nil
//                            )
//                        }
//                    }
//                }
                #if canImport(ActivityKit)
//                if #available(iOS 16.1, *) {
//                    Button("为该帐号开启树脂计时器") {
//                        do {
//                            try ResinRecoveryActivityController
//                                .shared
//                                .createResinRecoveryTimerActivity(
//                                    for: account
//                                )
//                            isSucceedAlertShow.toggle()
//                        } catch {
//                            errorMessage = error
//                                .localizedDescription
//                            isErrorAlertShow.toggle()
//                        }
//                    }
//                }
                #endif
            }
        case .failure:
            HStack {
                NavigationLink {
                    AccountDetailView(account: bindingAccount!)
                } label: {
                    ZStack {
                        Image(
                            systemName: "exclamationmark.arrow.triangle.2.circlepath"
                        )
                        .padding()
                        .foregroundColor(.red)
                        HStack {
                            Spacer()
                            Text(account.config.name ?? "")
                                .foregroundColor(Color(
                                    UIColor
                                        .systemGray4
                                ))
                                .font(.caption2)
                                .padding(.horizontal)
                        }
                    }
                    .padding([.bottom, .horizontal])
                }
            }
        default: EmptyView()
        }
    }
}
