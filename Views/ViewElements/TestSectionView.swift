//
//  TestSectionView.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//
//  测试连接部分的View

import HBMihoyoAPI
import SwiftUI

struct TestSectionView: View {
    // MARK: Internal

    @Binding
    var connectStatus: ConnectStatus

    @Binding
    var uid: String
    @Binding
    var cookie: String
    @Binding
    var server: Server

    var body: some View {
        Section {
            Button(action: {
                connectStatus = .testing
            }) {
                HStack {
                    Text("测试连接")
                    Spacer()
                    switch connectStatus {
                    case .unknown:
                        Text("")
                    case .success:
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    case .fail:
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                    case .testing:
                        ProgressView()
                    }
                }
            }
            if connectStatus == .fail {
                InfoPreviewer(title: "错误内容", content: error?.description ?? "")
                InfoPreviewer(title: "DEBUG", content: error?.message ?? "")
                    .foregroundColor(.gray)
                if let error = error {
                    switch error {
                    case .accountAbnormal:
                        Section {
                            let mihoyobbsURLString: String = "mihoyobbs://"
                            if isInstallation(urlString: mihoyobbsURLString) {
                                if let url = URL(string: mihoyobbsURLString) {
                                    Link(destination: url) {
                                        Text("点击打开米游社App")
                                    }
                                }
                            } else {
                                if let url =
                                    URL(
                                        string: "https://apps.apple.com/cn/app/id1470182559"
                                    ) {
                                    Link(destination: url) {
                                        Text("点击打开米游社App")
                                    }
                                }
                            }
                        }
                    default:
                        EmptyView()
                    }
                }
            }
            if connectStatus == .success {
                if !cookie.contains("stoken"), server.region == .cn {
                    Label {
                        Text("本帐号无stoken，可能影响简洁模式下小组件使用。建议重新登录以获取stoken。")
                    } icon: {
                        Image(
                            systemName: "checkmark.circle.trianglebadge.exclamationmark"
                        )
                        .foregroundColor(.red)
                    }
                }
            }
        } footer: {
            if let error = error {
                switch error {
                case .accountAbnormal:
                    Button("反复出现帐号异常？点击查看解决方案") {
                        is1034WebShown.toggle()
                    }
                    .font(.footnote)
                default:
                    EmptyView()
                }
            }
        }
        .sheet(isPresented: $is1034WebShown, content: {
            NavigationView {
                WebBroswerView(
                    url: "https://ophelper.top/static/1034_error_soution"
                )
                .dismissableSheet(isSheetShow: $is1034WebShown)
                .navigationTitle("1034问题的解决方案")
                .navigationBarTitleDisplayMode(.inline)
            }
        })
        .onAppear {
            if connectStatus == .testing {
                MihoyoAPI.fetchInfos(
                    region: server.region,
                    serverID: server.id,
                    uid: uid,
                    cookie: cookie
                ) { result in
                    switch result {
                    case .success:
                        connectStatus = .success
                    case let .failure(error):
                        connectStatus = .fail
                        self.error = error
                    }
                }
            }
        }
        .onChange(of: connectStatus) { newValue in
            if newValue == .testing {
                MihoyoAPI.fetchInfos(
                    region: server.region,
                    serverID: server.id,
                    uid: uid,
                    cookie: cookie
                ) { result in
                    switch result {
                    case .success:
                        connectStatus = .success
                    case let .failure(error):
                        connectStatus = .fail
                        self.error = error
                    }
                }
            }
        }
    }

    func isInstallation(urlString: String) -> Bool {
        if let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url)
        } else {
            return false
        }
    }

    // MARK: Private

    @State
    private var error: FetchError?

    @State
    private var is1034WebShown: Bool = false
}
