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

typealias EnkaProfileEntity = EnkaHSR.QueryRelated.DetailInfo
typealias CharInventoryEntity = MiHoYoAPI.CharacterInventory

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
            self.currentEnkaProfile = Defaults[.queriedEnkaProfiles][account.uid]
            refresh()
        } else {
            self._selectedAccount = .init(initialValue: nil)
        }
    }

    // MARK: Public

    @Published public var currentEnkaProfile: EnkaProfileEntity?
    @Published public var enkaProfileStatus: EnkaProfileStatus = .standby

    @Published public var currentCharInventory: CharInventoryEntity?
    @Published public var characterInventoryStatus: CharInventoryStatus = .standby

    // MARK: Internal

    typealias EnkaProfileStatus = Status<(EnkaProfileEntity, nextRefreshableDate: Date)>
    typealias CharInventoryStatus = Status<CharInventoryEntity>

    enum Status<T> {
        case progress(Task<Void, Never>)
        case fail(Error)
        case succeed(T)
        case standby

        // MARK: Internal

        var isBusy: Bool {
            switch self {
            case .progress: return true
            default: return false
            }
        }
    }

    static let refreshSubject: PassthroughSubject<Void, Never> = .init()

    var enkaDB: EnkaHSR.EnkaDB {
        EnkaHSR.Sputnik.sharedDB
    }

    @Published var selectedAccount: Account? {
        didSet {
            currentEnkaProfile = Defaults[.queriedEnkaProfiles][selectedAccount?.uid ?? "-1"]
            refresh()
        }
    }

    func refresh() {
        Task.detached { @MainActor [self] in
            await fetchEnkaPlayerProfile()
            await fetchCharacterInventoryList()
            Self.refreshSubject.send(())
        }
    }

    @MainActor
    func fetchEnkaPlayerProfile() async {
        // UID 需要单独 guard-let，因为 Apple Store Connect 那边有收到过与此有关的 force-unwrap 崩溃报告。
        guard let selectedAccountUID = selectedAccount?.uid else { return }
        if case let .succeed((_, refreshableDate)) = enkaProfileStatus {
            guard Date() > refreshableDate else { return }
        }
        if case let .progress(task) = enkaProfileStatus { task.cancel() }
        let task = Task.detached { @MainActor [self] in
            do {
                let queryResult = try await EnkaHSR.Sputnik.getEnkaProfile(
                    for: selectedAccountUID,
                    dateWhenNextRefreshable: nil
                )
                let queryResultAwaited = queryResult.merge(old: currentEnkaProfile)
                currentEnkaProfile = queryResultAwaited
                Defaults[.queriedEnkaProfiles][selectedAccountUID] = queryResultAwaited

                // 检查本地 EnkaDB 是否过期，过期了的话就尝试更新。
                enkaDB.updateExpiryStatus(against: queryResultAwaited)
                if enkaDB.isExpired {
                    let factoryDB = EnkaHSR.EnkaDB(locTag: Locale.langCodeForEnkaAPI)
                    factoryDB?.updateExpiryStatus(against: queryResultAwaited)
                    if let factoryDB = factoryDB, !factoryDB.isExpired {
                        enkaDB.update(new: factoryDB)
                    } else {
                        enkaDB.update(new: try await EnkaHSR.Sputnik.getEnkaDB())
                    }
                }

                // 检查本地圣遗物评分模型是否过期，过期了的话就尝试更新。
                if ArtifactRating.isScoreModelExpired(against: queryResultAwaited) {
                    ArtifactRating.resetFactoryScoreModel()
                    if ArtifactRating.isScoreModelExpired(against: queryResultAwaited) {
                        // 圣遗物评分非刚需体验。
                        // 如果在这个过程内出错的话，顶多就是该当角色没有圣遗物评分可用。
                        _ = await ArtifactRating.onlineUpdateScoreModel()
                    }
                }

                Task.detached { @MainActor in
                    withAnimation {
                        self.enkaProfileStatus = .succeed((
                            queryResultAwaited,
                            Date()
                        ))
                    }
                }
            } catch {
                Task.detached { @MainActor in
                    withAnimation {
                        self.enkaProfileStatus = .fail(error)
                    }
                }
            }
        }
        Task.detached { @MainActor in
            withAnimation {
                self.enkaProfileStatus = .progress(task)
            }
        }
    }

    @MainActor
    func fetchCharacterInventoryList() async {
        guard let selectedAccount, let selectedAccountUID = selectedAccount.uid else { return }
        if case let .progress(task) = characterInventoryStatus { task.cancel() }
        let task = Task.detached { @MainActor in
            do {
                let queryResult = try await MiHoYoAPI.characterInventory(
                    server: selectedAccount.server,
                    uid: selectedAccountUID,
                    cookie: selectedAccount.cookie ?? "",
                    deviceFingerPrint: selectedAccount.deviceFingerPrint
                )
                Task.detached { @MainActor in
                    withAnimation {
                        self.characterInventoryStatus = .succeed(queryResult)
                    }
                }
            } catch {
                Task.detached { @MainActor in
                    withAnimation {
                        self.characterInventoryStatus = .fail(error)
                    }
                }
            }
        }
        Task.detached { @MainActor in
            withAnimation {
                self.characterInventoryStatus = .progress(task)
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
                SelectAccountSection(selectedAccount: $vmDPV.selectedAccount.animation())
                    .listRowMaterialBackground()
                    .onTapGesture { uidInputFieldFocus = false }
                if let account = vmDPV.selectedAccount {
                    PlayerDetailSection(account: account)
                        .listRowMaterialBackground()
                        .onTapGesture { uidInputFieldFocus = false }
                }
                CaseQuerySection(theDB: vmDPV.enkaDB, focus: $uidInputFieldFocus)
                    .listRowMaterialBackground()
            }
            .navigationDestination(for: EnkaHSR.QueryRelated.DetailInfo.self) { result in
                CaseQueryResultView(profile: result)
            }
            .navigationDestination(for: CharInventoryEntity.self) { data in
                if let account = vmDPV.selectedAccount, !data.avatarList.isEmpty {
                    CharacterInventoryView(
                        data: data,
                        isMiyousheUID: account.server.region == .mainlandChina
                    )
                }
            }
            .scrollContentBackground(.hidden)
            .listContainerBackground()
            .refreshable {
                vmDPV.refresh()
            }
            .onDisappear {
                if case let .progress(task) = vmDPV.enkaProfileStatus, !task.isCancelled {
                    task.cancel()
                }
            }
        }
        .environmentObject(vmDPV)
    }

    // MARK: Private

    @FocusState private var uidInputFieldFocus: Bool
    @StateObject private var vmDPV: DetailPortalViewModel = .init()
}

// MARK: - CaseQueryResultView

private struct CaseQueryResultView: View {
    // MARK: Lifecycle

    public init(profile: EnkaHSR.QueryRelated.DetailInfo) {
        self.profile = profile
    }

    // MARK: Public

    public var body: some View {
        List {
            AccountHeaderView(givenProfile: profile)
                .listRowMaterialBackground()
            Section {
                CaseQueryResultListView(profile: profile, enkaDB: vmDPV.enkaDB)
            }
            .listRowMaterialBackground()
        }
        .scrollContentBackground(.hidden)
        .listContainerBackground()
        .navigationTitle(Text(verbatim: "\(profile.nickname) (\(profile.uid.description))"))
    }

    // MARK: Private

    @State private var profile: EnkaHSR.QueryRelated.DetailInfo

    @StateObject private var vmDPV: DetailPortalViewModel = .init()

    private var allAvatarSummaries: [EnkaHSR.AvatarSummarized] {
        profile.summarizeAllAvatars(theDB: vmDPV.enkaDB)
    }
}

// MARK: - AccountHeaderView

private struct AccountHeaderView<T: View>: View {
    // MARK: Lifecycle

    public init(
        profile: Binding<EnkaHSR.QueryRelated.DetailInfo?>?,
        refreshAction: (() -> Void)? = nil,
        additionalView: @escaping (() -> T) = { EmptyView() }
    ) {
        self.additionalView = additionalView
        self._profile = profile ?? Binding.constant(nil)
        self.refreshAction = refreshAction
        self.profileStatic = nil
    }

    public init(
        givenProfile: EnkaHSR.QueryRelated.DetailInfo?,
        refreshAction: (() -> Void)? = nil,
        additionalView: @escaping (() -> T) = { EmptyView() }
    ) {
        self.additionalView = additionalView
        self.profileStatic = givenProfile
        self._profile = Binding.constant(nil)
        self.refreshAction = refreshAction
    }

    // MARK: Public

    public var body: some View {
        Section {
            HStack(spacing: 0) {
                if let levelTag = levelTag {
                    avatarIconRendered.frame(width: 74)
                        .corneredTag(
                            levelTag,
                            alignment: .bottomTrailing,
                            textSize: 12
                        )
                } else {
                    avatarIconRendered.frame(width: 74)
                }
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading) {
                            Text(verbatim: name)
                                .font(.title3)
                                .bold()
                                .padding(.top, 5)
                                .lineLimit(1)
                            Text(verbatim: signature)
                                .foregroundColor(.secondary)
                                .font(.footnote)
                                .lineLimit(2)
                                .fixedSize(
                                    horizontal: false,
                                    vertical: true
                                )
                        }
                        Spacer()
                    }
                }
                additionalView()
            }
        } footer: {
            HStack {
                Text(verbatim: uidStr)
                Spacer()
                if let worldLevel = guardedProfile?.worldLevel {
                    let worldLevelTitle = "detailPortal.player.worldLevel".localized()
                    Text(verbatim: "\(worldLevelTitle): \(worldLevel)")
                }
            }
            .secondaryColorVerseBackground()
        }
    }

    // MARK: Internal

    let profileStatic: EnkaHSR.QueryRelated.DetailInfo?

    var avatarAssetName: String {
        guardedProfile?.accountPhotoFileNameStem(theDB: vmDPV.enkaDB)
            ?? EnkaHSR.QueryRelated.DetailInfo.nullPhotoAssetName
    }

    @ViewBuilder var avatarIconRendered: some View {
        HStack {
            EnkaHSR.queryImageAssetSUI(for: avatarAssetName)?
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background {
                    Color.black.opacity(0.165)
                }
                .clipShape(Circle())
                .frame(width: 64, height: 64)
            #if os(OSX) || targetEnvironment(macCatalyst)
                .contextMenu {
                    if let refreshAction = refreshAction {
                        Button("↺") {
                            withAnimation {
                                refreshAction()
                            }
                        }
                    }
                }
            #endif
            Spacer()
        }
    }

    // MARK: Private

    private let additionalView: () -> T

    private let refreshAction: (() -> Void)?

    @Binding private var profile: EnkaHSR.QueryRelated.DetailInfo?

    @StateObject private var vmDPV: DetailPortalViewModel = .init()

    private var uidStr: String {
        guard let strUid = guardedProfile?.uid.description else { return "……" }
        return "UID: \(strUid)"
    }

    private var name: String {
        guardedProfile?.nickname ?? "………"
    }

    private var signature: String {
        guardedProfile?.signature ?? ""
    }

    private var guardedProfile: EnkaHSR.QueryRelated.DetailInfo? {
        profile ?? profileStatic
    }

    private var levelTag: LocalizedStringKey? {
        if let profile = guardedProfile {
            return "detailPortal.player.adventureRank.short:\(profile.level.description)"
        } else {
            return nil
        }
    }
}

// MARK: - SelectAccountSection

private struct SelectAccountSection: View {
    @EnvironmentObject private var vmDPV: DetailPortalViewModel

    // MARK: Internal

    @Binding var selectedAccount: Account?

    var body: some View {
        if let selectedAccount {
            switch vmDPV.enkaProfileStatus {
            case .succeed:
                normalAccountPickerView(
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
        selectedAccount: Account
    )
        -> some View {
        AccountHeaderView(profile: $vmDPV.currentEnkaProfile) {
            vmDPV.refresh()
        } additionalView: {
            SelectAccountMenu {
                Image(systemSymbol: .arrowLeftArrowRightCircle)
            } completion: { account in
                self.selectedAccount = account
            }
        }
    }

    @ViewBuilder
    func noBasicInfoFallBackView(selectedAccount: Account) -> some View {
        AccountHeaderView(profile: nil) {
            vmDPV.refresh()
        } additionalView: {
            SelectAccountMenu {
                Image(systemSymbol: .arrowLeftArrowRightCircle)
            } completion: { account in
                self.selectedAccount = account
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

    var enkaProfileStatus: DetailPortalViewModel.Status<(EnkaProfileEntity, nextRefreshableDate: Date)> {
        vmDPV.enkaProfileStatus
    }

    @ViewBuilder var currentShowCase: some View {
        if let profile = vmDPV.currentEnkaProfile {
            profile.asView(theDB: vmDPV.enkaDB)
        } else if case let .succeed((profile, _)) = enkaProfileStatus {
            profile.asView(theDB: vmDPV.enkaDB)
        }
    }

    var isUpdating: Bool {
        switch vmDPV.enkaProfileStatus {
        case .progress: true
        default: false
        }
    }

    var body: some View {
        Section {
            let theCase = currentShowCase
            switch vmDPV.enkaProfileStatus {
            case .progress:
                VStack {
                    theCase
                        .disabled(true)
                        .saturation(0)
                    InfiniteProgressBar().id(UUID())
                }
            case let .fail(error):
                theCase
                DPVErrorView(account: account, apiPath: "", error: error) {
                    Task.detached { @MainActor in
                        await vmDPV.fetchEnkaPlayerProfile()
                    }
                }
            case .standby:
                theCase
            case let .succeed((playerDetail, _)):
                theCase
                if playerDetail.avatarDetailList.isEmpty {
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
            CharInventoryNavigator(account: account, status: vmDPV.characterInventoryStatus)
        }
    }

    // MARK: Private

    @EnvironmentObject private var vmDPV: DetailPortalViewModel

    private var errorTextForBlankAvatars: String {
        "account.PlayerDetail.EmptyAvatarsFetched".localized()
    }
}

// MARK: - CharInventoryNavigator

private struct CharInventoryNavigator: View {
    @EnvironmentObject private var vmDPV: DetailPortalViewModel

    // MARK: Internal

    let account: Account
    var status: DetailPortalViewModel.Status<CharInventoryEntity>

    var body: some View {
        switch status {
        case .progress:
            InformationRowView("app.detailPortal.allAvatar.title") {
                ProgressView()
            }
        case let .fail(error):
            InformationRowView("app.detailPortal.allAvatar.title") {
                DPVErrorView(
                    account: account,
                    apiPath: "https://api-takumi-record.mihoyo.com/game_record/app/hkrpg/api/avatar/info",
                    error: error
                ) {
                    Task.detached { @MainActor in
                        await vmDPV.fetchCharacterInventoryList()
                    }
                }
            }
        case let .succeed(data):
            InformationRowView("app.detailPortal.allAvatar.title") {
                let thisLabel = HStack(spacing: 3) {
                    ForEach(data.avatarList.prefix(5), id: \.id) { avatar in
                        if let charIdExp = EnkaHSR.AvatarSummarized.CharacterID(id: avatar.id.description) {
                            charIdExp.avatarPhoto(
                                size: 30, circleClipped: true, clipToHead: true
                            )
                        } else {
                            Color.gray.frame(width: 30, height: 30, alignment: .top).clipShape(Circle())
                                .overlay(alignment: .top) {
                                    WebImage(urlStr: avatar.icon).clipShape(Circle())
                                }
                        }
                    }
                }
                if data.avatarList.isEmpty {
                    Text("app.detailPortal.allAvatar.EmptyInventoryResult").font(.caption)
                } else {
                    if #unavailable(macOS 14), OS.type == .macOS {
                        SheetCaller(forceDarkMode: false) {
                            CharacterInventoryView(
                                data: data,
                                isMiyousheUID: account.server.region == .mainlandChina
                            )
                        } label: {
                            thisLabel
                        }
                    } else {
                        NavigationLink(value: data) {
                            thisLabel
                        }
                    }
                }
            }
        case .standby:
            EmptyView()
        }
    }
}

// MARK: - DPVErrorView

private struct DPVErrorView: View {
    @EnvironmentObject private var vmDPV: DetailPortalViewModel

    let account: Account
    let apiPath: String
    let error: Error

    let completion: () -> Void

    var body: some View {
        if case .verificationNeeded = error as? MiHoYoAPIError {
            VerificationNeededView(account: account, challengePath: apiPath) {
                vmDPV.refresh()
            }
        } else {
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
}

// MARK: - VerificationNeededView

private struct VerificationNeededView: View {
    // MARK: Internal

    let account: Account
    let challengePath: String
    let completion: () -> Void

    var disableButton: Bool {
        if case .progressing = status {
            true
        } else if case .gotVerification = status {
            true
        } else {
            false
        }
    }

    var body: some View {
        VStack {
            Button {
                status = .progressing
                popVerificationWebSheet()
            } label: {
                Label {
                    Text("account.test.verify.button")
                } icon: {
                    Image(systemSymbol: .exclamationmarkTriangle)
                        .foregroundStyle(.yellow)
                }
            }
            .disabled(disableButton)
            .sheet(item: $sheetItem, content: { item in
                switch item {
                case let .gotVerification(verification):
                    NavigationStack {
                        GeetestValidateView(
                            challenge: verification.challenge,
                            gt: verification.gt,
                            completion: { validate in
                                Task.detached { @MainActor in
                                    status = .pending
                                    verifyValidate(challenge: verification.challenge, validate: validate)
                                    sheetItem = nil
                                }
                            }
                        )
                        .listContainerBackground()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("sys.cancel") {
                                    status = .pending
                                    sheetItem = nil
                                }
                            }
                        }
                        .navigationTitle("account.test.verify.web_sheet.title")
                    }
                }
            })
            if case let .fail(error) = status {
                Text("Error: \(error.localizedDescription)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipShape(Rectangle())
    }

    func popVerificationWebSheet() {
        Task(priority: .userInitiated) {
            do {
                let verification = try await MiHoYoAPI.createVerification(
                    cookie: account.cookie,
                    deviceFingerPrint: account.deviceFingerPrint
                )
                Task.detached { @MainActor in
                    status = .gotVerification(verification)
                    sheetItem = .gotVerification(verification)
                }
            } catch {
                status = .fail(error)
            }
        }
    }

    func verifyValidate(challenge: String, validate: String) {
        Task.detached { @MainActor in
            do {
                _ = try await MiHoYoAPI.verifyVerification(
                    challenge: challenge,
                    validate: validate,
                    cookie: account.cookie,
                    deviceFingerPrint: account.deviceFingerPrint
                )
                completion()
            } catch {
                status = .fail(error)
            }
        }
    }

    // MARK: Private

    private enum Status: CustomStringConvertible {
        case pending
        case progressing
        case gotVerification(Verification)
        case fail(Error)

        // MARK: Internal

        var description: String {
            switch self {
            case let .fail(error):
                return "ERROR: \(error.localizedDescription)"
            case .progressing:
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

    @State private var status: Status = .pending

    @State private var sheetItem: SheetItem?

    @EnvironmentObject private var vmDPV: DetailPortalViewModel
}

// MARK: - InformationRowView

private struct InformationRowView<L: View>: View {
    // MARK: Lifecycle

    init(_ title: LocalizedStringKey, @ViewBuilder labelContent: @escaping () -> L) {
        self.title = title
        self.labelContent = labelContent
    }

    // MARK: Internal

    @ViewBuilder let labelContent: () -> L

    let title: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).bold()
            labelContent()
                .frame(maxWidth: .infinity, alignment: .leading)
                .clipShape(Rectangle())
        }
    }
}
