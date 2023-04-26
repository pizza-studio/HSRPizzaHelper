//
//  TextEditorView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//  封装了TextEditor和TextField的修改文本的页面

import HBMihoyoAPI
import SwiftUI

// MARK: - TextEditorView

struct TextEditorView: View {
    // MARK: Internal

    @EnvironmentObject
    var viewModel: ViewModel

    var title: String
    var note: String?
    @Binding
    var content: String
    var showPasteButton: Bool = false
    var showShortCutsLink: Bool = false

    var body: some View {
        List {
            if showPasteButton {
                Section {
                    if showShortCutsLink {
                        Link(
                            "获取Cookie的脚本",
                            destination: URL(
                                string: "https://www.icloud.com/shortcuts/fe68f22c624949c9ad8959993239e19c"
                            )!
                        )
                        Menu {
                            Button("国服") {
                                getCookieRegion = .cn
                                isWebShown.toggle()
                            }
                            Button("国际服") {
                                getCookieRegion = .global
                                isWebShown.toggle()
                            }
                        } label: {
                            Text("登录帐号获取Cookie")
                        }
                    }
                    Button("粘贴自剪贴板") {
                        content = UIPasteboard.general.string ?? ""
                    }
                }
            }
            Section(footer: Text(note ?? "").font(.footnote)) {
                TextEditor(text: $content)
                    .frame(height: 500)
            }
        }
        .navigationBarTitle(title, displayMode: .inline)
        .sheet(item: $getCookieRegion) { region in
            switch region {
            case .cn:
                GetCookieWebView(
                    isShown: $isWebShown,
                    cookie: $content,
                    region: .cn
                )
                .onChange(of: isWebShown) { _ in
                    getCookieRegion = nil
                }
            case .global:
                GetCookieWebView(
                    isShown: $isWebShown,
                    cookie: $content,
                    region: .global
                )
                .onChange(of: isWebShown) { _ in
                    getCookieRegion = nil
                }
            }
        }
    }

    // MARK: Private

    @State
    private var isWebShown: Bool = false
    @State
    private var getCookieRegion: Region?
}

// MARK: - TextFieldEditorView

struct TextFieldEditorView: View {
    var title: String
    var note: String?
    @Binding
    var content: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        if note == nil {
            List {
                if #available(iOS 15.0, *) {
                    TextField("", text: $content)
                        .keyboardType(keyboardType)
                        .submitLabel(.done)
                } else {
                    // Fallback on earlier versions
                    TextField("", text: $content)
                        .keyboardType(keyboardType)
                }
            }
            .navigationBarTitle(title, displayMode: .inline)
        } else {
            List {
                Section(
                    footer: Text(LocalizedStringKey(note!))
                        .font(.footnote)
                ) {
                    if #available(iOS 15.0, *) {
                        TextField(note!, text: $content)
                            .keyboardType(keyboardType)
                            .submitLabel(.done)
                    } else {
                        // Fallback on earlier versions
                        TextField(note!, text: $content)
                            .keyboardType(keyboardType)
                    }
                }
            }
            .navigationBarTitle(title, displayMode: .inline)
        }
    }
}
