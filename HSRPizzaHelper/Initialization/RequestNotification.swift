//
//  RequestNotification.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/12.
//

import Foundation
import SwiftUI

private struct NotificationRequester: ViewModifier {
    // MARK: Internal

    func body(content: Content) -> some View {
        content.onAppBecomeActive {
            let request = Account.fetchRequest()
            if let accounts = try? viewContext.fetch(request), !accounts.isEmpty {
                Task {
                    do {
                        _ = try await HSRNotificationCenter.requestAuthorization()
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }

    // MARK: Private

    @Environment(\.managedObjectContext) private var viewContext
}
