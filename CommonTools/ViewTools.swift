//
//  ViewTools.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//  View的一些高效扩展

import Foundation
import SwiftUI

extension View {
    /// 将View转化为UIImage
    func asUiImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(
                in: controller.view.bounds,
                afterScreenUpdates: true
            )
        }
    }
}

extension View {
    /// Navigate to a new view.
    /// - Parameters:
    ///   - view: View to navigate to.
    ///   - binding: Only navigates when this condition is `true`.
    func navigate<NewView: View>(
        to view: NewView,
        when binding: Binding<Bool>
    )
        -> some View {
        ZStack {
            self
                .navigationBarTitle("")
                .navigationBarHidden(true)

            if binding.wrappedValue {
                NavigationView {
                    NavigationLink(
                        destination: view,
                        isActive: binding
                    ) {
                        EmptyView()
                    }
                }.animation(.default)
            }
        }
    }
}

// MARK: - ScrollViewOffsetPreferenceKey

// Scroll View Offset Getter
struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    typealias value = CGPoint

    static var defaultValue: CGPoint = .zero

    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

// MARK: - ScrollViewOffsetModifier

struct ScrollViewOffsetModifier: ViewModifier {
    let coordinateSpace: String
    @Binding
    var offset: CGPoint

    func body(content: Content) -> some View {
        ZStack {
            content
            GeometryReader { proxy in
                let x = proxy.frame(in: .named(coordinateSpace)).minX
                let y = proxy.frame(in: .named(coordinateSpace)).minY
                Color.clear.preference(
                    key: ScrollViewOffsetPreferenceKey.self,
                    value: CGPoint(x: x * -1, y: y * -1)
                )
            }
        }
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
            offset = value
        }
    }
}

extension View {
    func readingScrollView(
        from coordinateSpace: String,
        into binding: Binding<CGPoint>
    )
        -> some View {
        modifier(ScrollViewOffsetModifier(
            coordinateSpace: coordinateSpace,
            offset: binding
        ))
    }
}

// MARK: - Blur Background

extension View {
    func blurMaterialBackground() -> some View {
        modifier(BlurMaterialBackground())
    }

    func alternativeBlurMaterialBackground() -> some View {
        modifier(AlternativeBlurMaterialBackground())
    }
}

// MARK: - BlurMaterialBackground

struct BlurMaterialBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.background(
                .regularMaterial,
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .contentShape(RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            ))
        } else {
            content
                .background(
                    RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    )
                    .foregroundColor(Color(UIColor.systemGray6))
                )
                .contentShape(RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                ))
        }
    }
}

// MARK: - AlternativeBlurMaterialBackground

struct AlternativeBlurMaterialBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .contentShape(RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            ))
        } else {
            content
                .background(
                    RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    )
                    .foregroundColor(Color(UIColor.systemGray4).opacity(0.5))
                )
                .contentShape(RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                ))
        }
    }
}

// MARK: - DismissableSheet

struct DismissableSheet<Item>: ViewModifier where Item: Identifiable {
    @Binding
    var sheet: Item?
    var title: String = "完成"
    var todoOnDismiss: () -> ()

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem {
                Button(title.localized) {
                    sheet = nil
                    todoOnDismiss()
                }
            }
        }
    }
}

extension View {
    func dismissableSheet<Item>(
        sheet: Binding<Item?>,
        title: String = "完成",
        todoOnDismiss: @escaping () -> () = {}
    )
        -> some View
        where Item: Identifiable {
        modifier(DismissableSheet(
            sheet: sheet,
            title: title,
            todoOnDismiss: todoOnDismiss
        ))
    }
}

// MARK: - DismissableBoolSheet

struct DismissableBoolSheet: ViewModifier {
    @Binding
    var isSheetShow: Bool
    var title: String = "完成"
    var todoOnDismiss: () -> ()

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem {
                Button(title.localized) {
                    isSheetShow = false
                    todoOnDismiss()
                }
            }
        }
    }
}

extension View {
    func dismissableSheet(
        isSheetShow: Binding<Bool>,
        title: String = "完成",
        todoOnDismiss: @escaping () -> () = {}
    )
        -> some View {
        modifier(DismissableBoolSheet(
            isSheetShow: isSheetShow,
            title: title,
            todoOnDismiss: todoOnDismiss
        ))
    }
}
