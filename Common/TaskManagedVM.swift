//
//  TaskManagedVM.swift
//  HSRPizzaHelper
//
//  Created by ShikiSuen on 2024/10/22.
//

import Combine
import Foundation
import SwiftUI

@MainActor
open class TaskManagedVM: ObservableObject {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public enum State: String, Sendable, Hashable, Identifiable {
        case busy
        case standBy

        // MARK: Public

        public var id: String { rawValue }
    }

    @Published public var taskState: State = .standBy
    @Published public var currentError: Error?
    /// 这是能够用来干涉父 class 里面的 errorHanler 的唯一途径。
    @Published public var assignableErrorHandlingTask: ((Error) -> Void) = { _ in }
    @Published public private(set) var stateGuard: Task<Void, Never>?

    @Published public var task: Task<Void, Never>? {
        didSet {
            if let theTask = task {
                stateGuard?.cancel()
                stateGuard = Task {
                    await theTask.value
                    taskState = .standBy
                }
                taskState = .busy
            } else {
                taskState = .standBy
            }
        }
    }

    public func forceStopTheTask() {
        task?.cancel()
        // taskState = .standBy
    }

    /// 不要在子 class 内 override 这个方法，因为一点儿屌用也没有。
    /// 除非你在子 class 内也复写了 fireTask()，否则其预设的 Error 处理函式永远都是父 class 的。
    ///
    /// 正确方法是在子 class 内直接改写 `super.assignableErrorHandlingTask` 的资料值。
    /// 或者你可以在 fireTask 的参数里面就地指定如何处理错误（但与之有关的动画与状态控制得自己搞）。
    ///
    /// 你可以在其中用 `if error is CancellationError` 处理与任务取消有关的错误。
    public func handleError(_ error: Error) {
        withAnimation {
            currentError = error
            // taskState = .standBy
        }
        assignableErrorHandlingTask(error)
        task?.cancel()
    }

    public func fireTask<each T: Sendable>(
        prerequisite: (condition: Bool, notMetHandler: (() -> Void)?)? = nil,
        animatedPreparationTask: (() -> Void)? = nil,
        cancelPreviousTask: Bool = true,
        givenTask: @escaping () async throws -> (repeat each T)?,
        completionHandler: (((repeat each T)?) -> Void)? = nil,
        errorHandler: ((Error) -> Void)? = nil
    ) {
        if let prerequisite, !prerequisite.condition {
            if let notMetHandler = prerequisite.notMetHandler {
                withAnimation {
                    notMetHandler()
                }
            }
            return
        }
        withAnimation {
            currentError = nil
            taskState = .busy
            animatedPreparationTask?()
        }
        Task {
            let previousTask = task
            task = Task(priority: .background) {
                if cancelPreviousTask {
                    previousTask?.cancel() // 按需取消既有任务。
                } else {
                    await previousTask?.value // 等待既有任务执行完毕。
                }
                do {
                    let retrieved = try await givenTask()
                    Task { @MainActor in
                        withAnimation {
                            if let retrieved {
                                completionHandler?(retrieved)
                            }
                            currentError = nil
                            // taskState = .standBy
                        }
                    }
                } catch {
                    Task { @MainActor in
                        (errorHandler ?? handleError)(error) // 处理其他的错误。
                        // taskState = .standBy
                    }
                }
            }
        }
    }
}
