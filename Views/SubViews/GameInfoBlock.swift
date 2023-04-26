//
//  GameInfoBlock.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/4/26.
//  主页展示帐号信息的Block

import HBMihoyoAPI
import SwiftUI

struct GameInfoBlock: View {
    var userData: UserData?
    let accountName: String?
    var accountUUIDString: String = UUID().uuidString

//    let viewConfig = WidgetViewConfiguration.defaultConfig
    var animation: Namespace.ID

//    var widgetBackground: WidgetBackground

    var fetchComplete: Bool

    var body: some View {
        if let userData = userData {
            ZStack {
                HStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 5) {
                        if let accountName = accountName {
                            HStack(alignment: .lastTextBaseline, spacing: 2) {
                                Image(systemName: "person.fill")
                                Text(accountName)
                            }
                            .font(.footnote)
                            .foregroundColor(Color("textColor3"))
                            .matchedGeometryEffect(
                                id: "\(accountUUIDString)name",
                                in: animation
                            )
                        }
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(userData.resinInfo.currentResin)")
                                .font(.system(size: 50, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(Color("textColor3"))
                                .shadow(radius: 1)
                                .matchedGeometryEffect(
                                    id: "\(accountUUIDString)curResin",
                                    in: animation
                                )
                            Image("树脂")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 30)
                                .alignmentGuide(.firstTextBaseline) { context in
                                    context[.bottom] - 0.17 * context.height
                                }
                                .matchedGeometryEffect(
                                    id: "\(accountUUIDString)Resinlogo",
                                    in: animation
                                )
                        }
                        HStack {
                            Image(systemName: "hourglass.circle")
                                .foregroundColor(Color("textColor3"))
                                .font(.title3)
                            recoveryTimeText(resinInfo: userData.resinInfo)
                        }
                        .matchedGeometryEffect(
                            id: "\(accountUUIDString)recovery",
                            in: animation
                        )
                    }
                    .padding()
                    Spacer()
                    DetailInfo(userData: userData)
                        .padding(.vertical)
                        .frame(maxWidth: UIScreen.main.bounds.width / 8 * 3)
                        .matchedGeometryEffect(
                            id: "\(accountUUIDString)detail",
                            in: animation
                        )
                    Spacer()
                }
                .opacity(fetchComplete ? 1 : 0)
                if !fetchComplete {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
//            .background(
//                Image(widgetBackground.imageName!)
//                    .resizable()
//                    .scaledToFill()
//                    .id(widgetBackground.imageName!)
//                    .transition(.opacity)
//                    .matchedGeometryEffect(
//                        id: "\(accountUUIDString)bg",
//                        in: animation
//                    )
//                    .opacity(fetchComplete ? 1 : 0)
//            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .contentShape(RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            ))
        } else {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
    }

    @ViewBuilder
    func recoveryTimeText(resinInfo: ResinInfo) -> some View {
        if resinInfo.recoveryTime.second != 0 {
            Text(
                LocalizedStringKey(
                    "\(resinInfo.recoveryTime.describeIntervalLong())\n\(resinInfo.recoveryTime.completeTimePointFromNow()) 回满"
                )
            )
            .font(.caption)
            .lineLimit(2)
            .minimumScaleFactor(0.2)
            .foregroundColor(Color("textColor3"))
            .lineSpacing(1)
        } else {
            Text("0小时0分钟\n树脂已全部回满")
                .font(.caption)
                .lineLimit(2)
                .minimumScaleFactor(0.2)
                .foregroundColor(Color("textColor3"))
                .lineSpacing(1)
        }
    }
}
