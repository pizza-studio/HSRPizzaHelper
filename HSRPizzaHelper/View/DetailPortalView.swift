// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Combine
import EnkaSwiftUIViews
import Foundation
import HBEnkaAPI
import HBMihoyoAPI
import HBPizzaHelperAPI
import SwiftUI

let detailPortalRefreshSubject: PassthroughSubject<Void, Never> = .init()

typealias EnkaProfileEntity = EnkaHSR.QueryRelated.DetailInfo

// MARK: - DetailPortalViewModel

@MainActor
final class DetailPortalViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {}

    // MARK: Internal

    enum Status<T> {
        case progress(Task<Void, Never>?)
        case fail(Error)
        case succeed(T)
    }

    typealias PlayerDetailStatus = Status<(EnkaProfileEntity, nextRefreshableDate: Date)>

    @Published var playerDetailStatus: PlayerDetailStatus = .progress(nil)

    @Published var currentBasicInfo: EnkaProfileEntity?

    // swiftlint:disable force_unwrapping
    let enkaDB = EnkaHSR.EnkaDB(locTag: Locale.langCodeForEnkaAPI)!

    @Published var selectedAccount: Account? {
        didSet { refresh() }
    }

    // swiftlint:enable force_unwrapping

    func refresh() {
        fetchPlayerDetail()
        detailPortalRefreshSubject.send(())
    }

    func fetchPlayerDetail() {
        guard let selectedAccount else { return }
        if case let .succeed((_, refreshableDate)) = playerDetailStatus {
            guard Date() > refreshableDate else { return }
        }
        if case let .progress(task) = playerDetailStatus { task?.cancel() }
        let task = Task {
            do {
                async let queryResult = try await EnkaHSR.Sputnik.getEnkaProfile(
                    for: selectedAccount.uid,
                    dateWhenNextRefreshable: nil
                )
                enkaDB.update(new: try await EnkaHSR.Sputnik.getEnkaDB())
                let queryResultAwaited = try await queryResult
                currentBasicInfo = queryResultAwaited

                DispatchQueue.main.async {
                    withAnimation {
                        self.playerDetailStatus = .succeed((
                            queryResultAwaited,
                            Date()
                        ))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.playerDetailStatus = .fail(error)
                }
            }
        }
        DispatchQueue.main.async {
            withAnimation {
                self.playerDetailStatus = .progress(task)
            }
        }
    }
}

// MARK: - DetailPortalView

struct DetailPortalView: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            List {
                SelectAccountSection(selectedAccount: $detailPortalViewModel.selectedAccount)
                if let account = detailPortalViewModel.selectedAccount {
                    PlayerDetailSection(account: account)
                }
            }
            .onAppear {
                if let account = accounts.first {
                    detailPortalViewModel.selectedAccount = account
                } else {
                    detailPortalViewModel.selectedAccount = nil
                }
            }
            .refreshable {
                detailPortalViewModel.refresh()
            }
        }
        .environmentObject(detailPortalViewModel)
    }

    // MARK: Private

    @StateObject private var detailPortalViewModel: DetailPortalViewModel = .init()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.priority, ascending: true)],
        animation: .default
    ) private var accounts: FetchedResults<Account>
}

// MARK: - SelectAccountSection

private struct SelectAccountSection: View {
    @EnvironmentObject private var detailPortalViewModel: DetailPortalViewModel

    // MARK: Internal

    @Binding var selectedAccount: Account?

    var body: some View {
        if let selectedAccount {
            switch detailPortalViewModel.playerDetailStatus {
            case let .succeed((playerDetail, _)):
                normalAccountPickerView(
                    basicInfo: playerDetail,
                    selectedAccount: selectedAccount
                )
            default:
                noBasicInfoFallBackView(selectedAccount: selectedAccount)
            }
        } else {
            noSelectAccountView()
        }
    }

    @ViewBuilder
    func normalAccountPickerView(
        basicInfo: EnkaProfileEntity,
        selectedAccount: Account
    )
        -> some View {
        Section {
            HStack(spacing: 0) {
                HStack {
                    let path = basicInfo.accountPhotoFilePath(theDB: detailPortalViewModel.enkaDB)
                    AsyncImage(url: URL(fileURLWithPath: path)) { imageObj in
                        imageObj
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .background {
                                Color.black.opacity(0.165)
                            }
                    } placeholder: {
                        Color.clear
                    }
                    .clipShape(Circle())
                    .frame(width: 64, height: 64)
                    #if os(OSX) || targetEnvironment(macCatalyst)
                        .contextMenu {
                            Group {
                                Button("↺") {
                                    withAnimation {
                                        detailPortalViewModel.refresh()
                                    }
                                }
                            }
                        }
                    #endif
                    Spacer()
                }
                .frame(width: 74)
                .corneredTag(
                    "detailPortal.player.adventureRank.short:\(basicInfo.trailblazingLevel.description)",
                    alignment: .bottomTrailing,
                    textSize: 12
                )
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading) {
                            Text(basicInfo.nickNameGuarded)
                                .font(.title3)
                                .bold()
                                .padding(.top, 5)
                                .lineLimit(1)
                            Text(basicInfo.signatureGuarded)
                                .foregroundColor(.secondary)
                                .font(.footnote)
                                .lineLimit(2)
                                .fixedSize(
                                    horizontal: false,
                                    vertical: true
                                )
                        }
                        Spacer()
                        SelectAccountMenu {
                            Image(systemSymbol: .arrowLeftArrowRightCircle)
                        } completion: { account in
                            self.selectedAccount = account
                        }
                    }
                }
            }
        } footer: {
            HStack {
                Text(verbatim: "UID: \(selectedAccount.uid.description)")
                Spacer()
                let worldLevelTitle = "detailPortal.player.worldLevel".localized()
                Text("\(worldLevelTitle): \(basicInfo.equilibriumLevel.description)")
            }
        }
    }

    @ViewBuilder
    func noBasicInfoFallBackView(selectedAccount: Account) -> some View {
        Section {
            HStack(spacing: 0) {
                HStack {
                    let path = EnkaProfileEntity.nullPhotoFilePath
                    AsyncImage(url: URL(fileURLWithPath: path)) { imageObj in
                        imageObj
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .background {
                                Color.black.opacity(0.165)
                            }
                    } placeholder: {
                        Color.clear
                    }
                    .clipShape(Circle())
                    .frame(width: 64, height: 64)
                    #if os(OSX) || targetEnvironment(macCatalyst)
                        .contextMenu {
                            Group {
                                Button("↺") {
                                    withAnimation {
                                        detailPortalViewModel.refresh()
                                    }
                                }
                            }
                        }
                    #endif
                    Spacer()
                }
                .frame(width: 74)
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading) {
                            Text(selectedAccount.name)
                                .font(.title3)
                                .bold()
                                .padding(.top, 5)
                                .lineLimit(1)
                        }
                        Spacer()
                        SelectAccountMenu {
                            Image(systemSymbol: .arrowLeftArrowRightCircle)
                        } completion: { account in
                            self.selectedAccount = account
                        }
                    }
                }
            }
        } footer: {
            HStack {
                Text(verbatim: "UID: \(selectedAccount.uid.description)")
            }
        }
    }

    @ViewBuilder
    func noSelectAccountView() -> some View {
        Section {
            SelectAccountMenu {
                Label("detailPortal.prompt.pleaseSelectAccount", systemSymbol: .arrowLeftArrowRightCircle)
            } completion: { account in
                selectedAccount = account
            }
        }
    }

    // MARK: Private

    private struct SelectAccountMenu<T: View>: View {
        @FetchRequest(sortDescriptors: [
            .init(
                keyPath: \Account.priority,
                ascending: true
            ),
        ]) var accounts: FetchedResults<Account>

        let label: () -> T

        let completion: (Account) -> Void

        var body: some View {
            Menu {
                ForEach(accounts, id: \.uid) { account in
                    Button(account.name) {
                        completion(account)
                    }
                }
            } label: {
                label()
            }
        }
    }
}

// MARK: - PlayerDetailSection

private struct PlayerDetailSection: View {
    @EnvironmentObject private var detailPortalViewModel: DetailPortalViewModel

    let account: Account

    var playerDetailStatus: DetailPortalViewModel.Status<(EnkaProfileEntity, nextRefreshableDate: Date)> {
        detailPortalViewModel.playerDetailStatus
    }

    var errorTextForBlankAvatars: String {
        "account.PlayerDetail.EmptyAvatarsFetched".localized()
    }

    var body: some View {
        Section {
            switch playerDetailStatus {
            case .progress:
                ProgressView().id(UUID())
            case let .fail(error):
                ErrorView(account: account, apiPath: "", error: error) {
                    detailPortalViewModel.fetchPlayerDetail()
                }
            case let .succeed((playerDetail, _)):
                if playerDetail.allAvatars.isEmpty {
                    Button {
                        detailPortalViewModel.refresh()
                    } label: {
                        Label {
                            VStack {
                                Text(errorTextForBlankAvatars)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemSymbol: .xmarkCircle)
                                .foregroundColor(.red)
                        }
                    }
                } else {
                    playerDetail.asView(theDB: detailPortalViewModel.enkaDB)
                }
            }
        }
    }
}

// MARK: - ErrorView

private struct ErrorView: View {
    @EnvironmentObject private var detailPortalViewModel: DetailPortalViewModel

    let account: Account
    let apiPath: String
    let error: Error

    let completion: () -> Void

    var body: some View {
        Button {
            completion()
        } label: {
            Label {
                HStack {
                    Text(error.localizedDescription)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemSymbol: .arrowClockwiseCircle)
                }
            } icon: {
                Image(systemSymbol: .exclamationmarkCircle)
                    .foregroundStyle(.red)
            }
        }
    }
}
