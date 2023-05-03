//
//  AccountViewModel.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/3.
//

import Foundation

@MainActor
class AccountViewModel: ObservableObject {
    // MARK: Lifecycle

    private init() {
        self.accountPersistenceController = .shared
        fetchAccounts()
    }

    // MARK: Internal

    let accountPersistenceController: AccountPersistenceController

    @Published
    var accounts: [Account] = []

    func fetchAccounts() {
        let request = Account.fetchRequest()
        let result = try? accountPersistenceController
            .container
            .viewContext
            .fetch(request)
        accounts = result ?? []
    }

    func remove(_ account: Account) {
        accountPersistenceController
            .container
            .viewContext
            .delete(account)
    }

    func save() {
        do {
            try accountPersistenceController.container.viewContext.save()
            fetchAccounts()
        } catch {
            print("ERROR SAVING. \(error.localizedDescription)")
        }
    }
}
