//
//  AutoSheetDismiss.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//  控制Sheet能否滑下关闭

import Foundation
import SwiftUI

// MARK: - MbModalHackView

/// Control if allow to dismiss the sheet by the user actions
/// - Drag down on the sheet on iPhone and iPad
/// - Tap outside the sheet on iPad
/// No impact to dismiss programatically (by calling "presentationMode.wrappedValue.dismiss()")
/// -----------------
/// Tested on iOS 14.2 with Xcode 12.2 RC
/// This solution may NOT work in the furture.
/// -----------------
struct MbModalHackView: UIViewControllerRepresentable {
    var dismissable: () -> Bool = { false }

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<MbModalHackView>
    )
        -> UIViewController {
        MbModalViewController(dismissable: dismissable)
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {}
}

// MARK: MbModalHackView.MbModalViewController

extension MbModalHackView {
    private final class MbModalViewController: UIViewController,
        UIAdaptivePresentationControllerDelegate {
        // MARK: Lifecycle

        init(dismissable: @escaping () -> Bool) {
            self.dismissable = dismissable
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: Internal

        let dismissable: () -> Bool

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)

            setup()
        }

        func presentationControllerShouldDismiss(
            _ presentationController: UIPresentationController
        )
            -> Bool {
            dismissable()
        }

        // MARK: Private

        // set delegate to the presentation of the root parent
        private func setup() {
            guard let rootPresentationViewController = rootParent
                .presentationController,
                rootPresentationViewController.delegate == nil else { return }
            rootPresentationViewController.delegate = self
        }
    }
}

extension UIViewController {
    fileprivate var rootParent: UIViewController {
        if let parent = parent {
            return parent.rootParent
        } else {
            return self
        }
    }
}

/// make the call the SwiftUI style:
/// view.allowAutoDismiss(...)
extension View {
    /// Control if allow to dismiss the sheet by the user actions
    public func allowAutoDismiss(_ dismissable: @escaping () -> Bool)
        -> some View {
        if #available(iOS 15.0, *) {
            return self
                .interactiveDismissDisabled()
        } else {
            // Fallback on earlier versions
            return background(MbModalHackView(dismissable: dismissable))
        }
    }

    /// Control if allow to dismiss the sheet by the user actions
    public func allowAutoDismiss(_ dismissable: Bool) -> some View {
        if #available(iOS 15.0, *) {
            return self
                .interactiveDismissDisabled()
        } else {
            // Fallback on earlier versions
            return background(MbModalHackView(dismissable: { dismissable }))
        }
    }
}

// MARK: - ModalContent

struct ModalContent: View {
    // MARK: Internal

    var body: some View {
        VStack {
            Text("Hello")
                .padding()

            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("Dismiss")
            }
        }
    }

    // MARK: Private

    @Environment(\.presentationMode)
    private var presentationMode
}
