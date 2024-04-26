import Foundation
import SwiftUI

// Ref: https://stackoverflow.com/a/75538094/4162914
public struct Divided<Content: View>: View {
    // MARK: Lifecycle

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // MARK: Public

    public var body: some View {
        _VariadicView.Tree(DividedLayout()) {
            content
        }
    }

    // MARK: Internal

    struct DividedLayout: _VariadicView_MultiViewRoot {
        @ViewBuilder
        func body(children: _VariadicView.Children) -> some View {
            let last = children.last?.id

            ForEach(children) { child in
                child

                if child.id != last {
                    Divider()
                }
            }
        }
    }

    var content: Content
}
