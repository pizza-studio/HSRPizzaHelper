//
//  InfoPreviewerView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//  显示具体栏目信息的工具类View

import SwiftUI

// MARK: - InfoPreviewer

struct InfoPreviewer: View {
    enum ContentStyle {
        case standard
        case capsule
    }

    var title: String
    var content: String
    var contentStyle: ContentStyle = .standard
    var textColor: Color = .white
    var backgroundColor: Color = .white

    var body: some View {
        HStack {
            Text(LocalizedStringKey(title.localized))
            Spacer()
            switch contentStyle {
            case .standard:
                Text(content)
                    .foregroundColor(.gray)
            case .capsule:
                Text(content)
                    .foregroundColor(textColor)
                    .padding(.horizontal)
                    .background(
                        Capsule()
                            .fill(backgroundColor)
                            .frame(height: 20)
                            .frame(maxWidth: 200)
                            .opacity(0.25)
                    )
            }
        }
    }
}

// MARK: - InfoEditor

struct InfoEditor: View {
    var title: String
    @Binding
    var content: String
    var keyboardType: UIKeyboardType = .default
    var placeholderText: String = ""
    @State
    var contentColor: Color = .init(UIColor.systemGray)

    var body: some View {
        HStack {
            Text(LocalizedStringKey(title))
            Spacer()
            TextEditor(text: $content)
                .multilineTextAlignment(.trailing)
                .foregroundColor(contentColor)
                .keyboardType(keyboardType)
                .onTapGesture { contentColor = Color.primary }
        }
    }
}
