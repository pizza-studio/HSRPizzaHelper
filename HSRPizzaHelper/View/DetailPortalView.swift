// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Combine
import Defaults
import EnkaKitHSR
import EnkaSwiftUIViews
import Foundation
import HBMihoyoAPI
import HBPizzaHelperAPI
import SwiftUI

let detailPortalRefreshSubject: PassthroughSubject<Void, Never> = .init()

typealias EnkaProfileEntity = EnkaHSR.QueryRelated.DetailInfo

// MARK: - DetailPortalViewModel

@MainActor
final class DetailPortalViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        let viewContext = PersistenceController.shared.container.viewContext

        let request = Account.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Account.priority, ascending: true)]
        let accounts = try? viewContext.fetch(request)

        if let account = accounts?.first {
            self._selectedAccount = .init(initialValue: account)
            self.currentBasicInfo = Defaults[.queriedEnkaProfiles][account.uid]
            refresh()
        } else {
            self._selectedAccount = .init(initialValue: nil)
        }
    }

    // MARK: Public

    @Published public var currentBasicInfo: EnkaProfileEntity?

    @Published public var playerDetailStatus: PlayerDetailStatus = .progress(nil)

    // MARK: Internal

    enum Status<T> {
        case progress(Task<Void, Never>?)
        case fail(Error)
        case succeed(T)

        // MARK: Internal

        var isBusy: Bool {
            switch self {
            case .progress: return true
            default: return false
            }
        }

        var saturationValue: CGFloat {
            isBusy ? 0 : 1
        }
    }

    typealias PlayerDetailStatus = Status<(EnkaProfileEntity, nextRefreshableDate: Date)>

    // swiftlint:disable force_unwrapping
    let enkaDB = EnkaHSR.EnkaDB(locTag: Locale.langCodeForEnkaAPI)!

    @Published var selectedAccount: Account? {
        didSet {
            currentBasicInfo = Defaults[.queriedEnkaProfiles][selectedAccount?.uid ?? "-1"]
            refresh()
        }
    }

    // swiftlint:enable force_unwrapping

    func refresh() {
        Task {
            fetchPlayerDetail()
            detailPortalRefreshSubject.send(())
        }
    }

    func fetchPlayerDetail() {
        guard let selectedAccount else { return }
        if case let .succeed((_, refreshableDate)) = playerDetailStatus {
            guard Date() > refreshableDate else { return }
        }
        if case let .progress(task) = playerDetailStatus { task?.cancel() }
        let task = Task {
            do {
                enkaDB.update(new: try await EnkaHSR.Sputnik.getEnkaDB())
                let queryResult = try await EnkaHSR.Sputnik.getEnkaProfile(
                    for: selectedAccount.uid,
                    dateWhenNextRefreshable: nil
                )
                let queryResultAwaited = queryResult.merge(old: currentBasicInfo)
                currentBasicInfo = queryResultAwaited
                Defaults[.queriedEnkaProfiles][selectedAccount.uid] = queryResultAwaited
                Task {
                    withAnimation {
                        self.playerDetailStatus = .succeed((
                            queryResultAwaited,
                            Date()
                        ))
                    }
                }
            } catch {
                Task {
                    withAnimation {
                        self.playerDetailStatus = .fail(error)
                    }
                }
            }
        }
        Task {
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
                SelectAccountSection(selectedAccount: $vmDPV.selectedAccount)
                if let account = vmDPV.selectedAccount {
                    PlayerDetailSection(account: account)
                }
            }
            .refreshable {
                vmDPV.refresh()
            }
        }
        .environmentObject(vmDPV)
    }

    // MARK: Private

    @StateObject private var vmDPV: DetailPortalViewModel = .init()
}

// MARK: - SelectAccountSection

private struct SelectAccountSection: View {
    @EnvironmentObject private var vmDPV: DetailPortalViewModel

    // MARK: Internal

    @Binding var selectedAccount: Account?

    var body: some View {
        if let selectedAccount {
            switch vmDPV.playerDetailStatus {
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
                    ResIcon(basicInfo.accountPhotoFilePath(theDB: vmDPV.enkaDB)) {
                        $0.resizable()
                    } placeholder: {
                        AnyView(Color.clear)
                    }
                    .aspectRatio(contentMode: .fit)
                    .background {
                        Color.black.opacity(0.165)
                    }
                    .clipShape(Circle())
                    .frame(width: 64, height: 64)
                    #if os(OSX) || targetEnvironment(macCatalyst)
                        .contextMenu {
                            Group {
                                Button("↺") {
                                    withAnimation {
                                        vmDPV.refresh()
                                    }
                                }
                            }
                        }
                    #endif
                    Spacer()
                }
                .frame(width: 74)
                .corneredTag(
                    "detailPortal.player.adventureRank.short:\(basicInfo.level.description)",
                    alignment: .bottomTrailing,
                    textSize: 12
                )
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading) {
                            Text(basicInfo.nickname)
                                .font(.title3)
                                .bold()
                                .padding(.top, 5)
                                .lineLimit(1)
                            Text(basicInfo.signature)
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
                Text("\(worldLevelTitle): \(basicInfo.worldLevel.description)")
            }
        }
    }

    @ViewBuilder
    func noBasicInfoFallBackView(selectedAccount: Account) -> some View {
        Section {
            HStack(spacing: 0) {
                HStack {
                    let path = vmDPV.currentBasicInfo?.accountPhotoFilePath(theDB: vmDPV.enkaDB)
                    ResIcon(path ?? EnkaProfileEntity.nullPhotoFilePath) {
                        $0.resizable()
                    } placeholder: {
                        AnyView(Color.clear)
                    }
                    .aspectRatio(contentMode: .fit)
                    .background {
                        Color.black.opacity(0.165)
                    }
                    .clipShape(Circle())
                    .frame(width: 64, height: 64)
                    #if os(OSX) || targetEnvironment(macCatalyst)
                        .contextMenu {
                            Group {
                                Button("↺") {
                                    withAnimation {
                                        vmDPV.refresh()
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
    // MARK: Internal

    let account: Account

    @ViewBuilder var currentShowCase: some View {
        profileStorage[account.uid]?.asView(theDB: vmDPV.enkaDB)
            .disabled(vmDPV.playerDetailStatus.isBusy)
            .saturation(vmDPV.playerDetailStatus.saturationValue)
    }

    var isUpdating: Bool {
        switch vmDPV.playerDetailStatus {
        case .progress: true
        default: false
        }
    }

    var body: some View {
        Section {
            currentShowCase
            switch vmDPV.playerDetailStatus {
            case .progress:
                InfiniteProgressBar().id(UUID())
            case let .fail(error):
                Divider()
                ErrorView(account: account, apiPath: "", error: error) {
                    vmDPV.refresh()
                }
            case let .succeed((playerDetail, _)):
                if playerDetail.avatarDetailList.isEmpty {
                    Divider()
                    Button {
                        vmDPV.refresh()
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
                }
            }
        }
    }

    // MARK: Private

    @EnvironmentObject private var vmDPV: DetailPortalViewModel

    @Default(.queriedEnkaProfiles) private var profileStorage: [String: EnkaHSR.QueryRelated.DetailInfo]

    private var errorTextForBlankAvatars: String {
        "account.PlayerDetail.EmptyAvatarsFetched".localized()
    }
}

// MARK: - ErrorView

private struct ErrorView: View {
    @EnvironmentObject private var vmDPV: DetailPortalViewModel

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
