//
//  AccountGachaView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/11.
//

import Charts
import HBMihoyoAPI
import SwiftUI

// MARK: - AccountGachaView

struct AccountGachaView: View {
    // MARK: Internal

    let uid: String
    let name: String?

    var body: some View {
        List {
            Section {
                Picker("Gacha Type", selection: $gachaType) {
                    ForEach(GachaType.allCases, id: \.rawValue) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }
            Section {
                if #available(iOS 16.0, *) {
                    GachaSmallChart(uid: uid, gachaType: gachaType)
                    NavigationLink {
                        GachaChartView(uid: uid, gachaType: gachaType)
                    } label: {
                        Label("更多图表", systemSymbol: .chartBarXaxis)
                    }
                }
            } header: {
                Text("chart")
            }
            Section {
                GachaStatisticSectionView(uid: uid, gachaType: gachaType)
            } header: {
                Text("statistic")
            }
            Section {
                NavigationLink("Detail") {
                    AccountGachaDetailView(uid: uid, gachaType: gachaType)
                }
            }
        }
        .navigationTitle(name ?? uid)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Private

    @State private var gachaType: GachaType = .characterEventWarp
}

// MARK: - GachaSmallChart

@available(iOS 16.0, *)
private struct GachaSmallChart: View {
    // MARK: Lifecycle

    init(uid: String, gachaType: GachaType) {
        self._gachaItemsResult = .init(
            sortDescriptors: [.init(keyPath: \GachaItemMO.id, ascending: false)],
            predicate: NSPredicate(format: "uid = %@ AND gachaTypeRawValue = %@", uid, gachaType.rawValue),
            animation: .default
        )
    }

    // MARK: Internal

    var fiveStarItems: [(GachaItemMO, drawCount: Int)] {
        let drawCounts = calculateGachaItemsDrawCount(gachaItemsResult)
        return zip(gachaItemsResult, drawCounts)
            .filter { item, _ in
                item.rank == .five
            }
    }

    var body: some View {
        if fiveStarItems.isEmpty {
            Text("No data. ")
        } else {
            chart()
        }
    }

    var colors: [Color] {
        fiveStarItems.map { _, count in
            switch count {
            case 0 ..< 60:
                return .green
            case 60 ..< 80:
                return .yellow
            default:
                return .red
            }
        }
    }

    @ViewBuilder
    func chart() -> some View {
        ScrollView(.horizontal) {
            Chart {
                ForEach(fiveStarItems, id: \.0.id) { item in
                    BarMark(
                        x: .value("角色", item.0.id),
                        y: .value("抽数", item.drawCount)
                    )
                    .annotation(position: .top) {
                        Text("\(item.drawCount)").foregroundColor(.gray)
                            .font(.caption)
                    }
                    .foregroundStyle(by: .value("抽数", item.0.id))
                }
                if !fiveStarItems.isEmpty {
                    RuleMark(y: .value(
                        "平均",
                        fiveStarItems.map { $0.drawCount }
                            .reduce(0) { $0 + $1 } / max(fiveStarItems.count, 1)
                    ))
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                }
            }
            .chartXAxis(content: {
                AxisMarks { value in
                    AxisValueLabel(content: {
                        if let id = value.as(String.self),
                           let item = fiveStarItems
                           .first(where: { $0.0.id == id })?.0 {
                            ItemIcon(item: item)
                        } else {
                            EmptyView()
                        }
                    })
                }
            })
            .chartLegend(position: .top)
            .chartYAxis(content: {
                AxisMarks(position: .leading)
            })
            .chartForegroundStyleScale(range: colors)
            .chartLegend(.hidden)
            .frame(width: CGFloat(fiveStarItems.count * 50))
            .padding(.top)
            .padding(.bottom, 5)
            .padding(.leading, 1)
        }
    }

    // MARK: Private

    @FetchRequest private var gachaItemsResult: FetchedResults<GachaItemMO>
}

// MARK: - ItemIcon

private struct ItemIcon: View {
    let item: GachaItemMO

    var body: some View {
        Group {
            if let uiImage = item.icon {
                Image(uiImage: uiImage).resizable().scaledToFit()
            } else {
                Image(systemSymbol: .questionmarkCircle).resizable().scaledToFit()
            }
        }
        .background {
            Image(item.rank.backgroundKey)
                .scaledToFit()
                .scaleEffect(1.5)
                .offset(y: 3)
        }
        .clipShape(Circle())
        .contentShape(Circle())
        .frame(width: 35, height: 35)
    }
}

// MARK: - GachaStatisticSectionView

private struct GachaStatisticSectionView: View {
    // MARK: Lifecycle

    init(uid: String, gachaType: GachaType) {
        self._gachaItemsResult = .init(
            sortDescriptors: [.init(keyPath: \GachaItemMO.id, ascending: false)],
            predicate: NSPredicate(format: "uid = %@ AND gachaTypeRawValue = %@", uid, gachaType.rawValue),
            animation: .default
        )
        self.gachaType = gachaType
    }

    // MARK: Internal

    enum Rank: Int, CaseIterable {
        case one
        case two
        case three
        case four
        case five
    }

    let gachaType: GachaType

    var itemsWithDrawCount: [(GachaItemMO, drawCount: Int)] {
        Array(zip(gachaItemsResult, calculateGachaItemsDrawCount(gachaItemsResult)))
    }

    var fiveStarItemsWithDrawCount: [(GachaItemMO, drawCount: Int)] { itemsWithDrawCount.filter { item, _ in
        item.rank == .five
    } }

    var fiveStarsNotLose: [GachaItemMO] { gachaItemsResult.filter { item in
        item.rank == .five && !item.isLose5050
    }}

    var limitedDrawCount: Int { fiveStarItemsWithDrawCount
        .map(\.drawCount)
        .reduce(0, +) /
        max(
            fiveStarsNotLose.count,
            1
        )
    }

    // 如果获得的第一个五星是限定，默认其不歪
    var lose5050percentage: Double {
        1.0 -
            Double(
                fiveStarItemsWithDrawCount.count - fiveStarsNotLose
                    .count // 歪次数 = 非限定五星数量
            ) /
            Double(
                fiveStarsNotLose
                    .count +
                    ((fiveStarItemsWithDrawCount.last?.0.isLose5050 ?? false) ? 1 : 0)
            ) // 小保底次数 = 限定五星数量（如果抽的第一个是非限定，则多一次小保底）
    }

    var average5StarDraw: Int { fiveStarItemsWithDrawCount.map { $0.drawCount }
        .reduce(0) { $0 + $1 } /
        max(fiveStarItemsWithDrawCount.count, 1)
    }

    var body: some View {
        Section {
            HStack {
                Label("当前已垫", systemSymbol: .flagFill)
                Spacer()
                Text(
                    "\(itemsWithDrawCount.firstIndex(where: { $0.0.rank == .five }) ?? itemsWithDrawCount.count)抽"
                )
            }
            HStack {
                Label(
                    "总抽数",
                    systemSymbol: .handTapFill
                )
                Spacer()
                Text("\(itemsWithDrawCount.count)")
            }
            HStack {
                Label(
                    "五星平均抽数",
                    systemSymbol: .star
                )
                Spacer()
                Text("\(average5StarDraw)")
            }
            if gachaType != .regularWarp {
                HStack {
                    Label(
                        "限定五星平均抽数",
                        systemSymbol: .starFill
                    )
                    Spacer()
                    Text(
                        "\(limitedDrawCount)"
                    )
                }
                HStack {
                    let fmt: NumberFormatter = {
                        let fmt = NumberFormatter()
                        fmt.maximumFractionDigits = 2
                        fmt.numberStyle = .percent
                        return fmt
                    }()

                    Label("不歪率", systemSymbol: .chartPieFill)
                    Spacer()
                    Text(
                        "\(fmt.string(from: lose5050percentage as NSNumber)!)"
                    )
                }
            }
            if gachaType != .regularWarp {
                VStack {
                    HStack {
                        Text("派蒙的评价")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        let judgedRank = Rank.judge(
                            limitedDrawNumber: limitedDrawCount,
                            gachaType: gachaType
                        )
                        ForEach(Rank.allCases, id: \.rawValue) { rank in
                            Group {
                                if judgedRank == rank {
                                    rank.image().resizable()
                                        .scaledToFit()
                                } else {
                                    rank.image().resizable()
                                        .scaledToFit()
                                        .opacity(0.25)
                                }
                            }
                            .frame(width: 50, height: 50)
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    // MARK: Private

    @FetchRequest private var gachaItemsResult: FetchedResults<GachaItemMO>
}

extension GachaStatisticSectionView.Rank {
    func image() -> Image {
        switch self {
        case .one:
            return Image("Pom-Pom_Sticker_21")
        case .two:
            return Image("Pom-Pom_Sticker_32")
        case .three:
            return Image("Pom-Pom_Sticker_18")
        case .four:
            return Image("Pom-Pom_Sticker_24")
        case .five:
            return Image("Pom-Pom_Sticker_30")
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    fileprivate static func judge(
        limitedDrawNumber: Int,
        gachaType: GachaType
    )
        -> Self {
        switch gachaType {
        case .characterEventWarp:
            switch limitedDrawNumber {
            case ...80:
                return .five
            case 80 ..< 90:
                return .four
            case 90 ..< 100:
                return .three
            case 100 ..< 110:
                return .two
            case 110...:
                return .one
            default:
                return .one
            }
        case .lightConeEventWarp:
            switch limitedDrawNumber {
            case ...80:
                return .five
            case 80 ..< 90:
                return .four
            case 90 ..< 100:
                return .three
            case 100 ..< 110:
                return .two
            case 110...:
                return .one
            default:
                return .one
            }
        default:
            return .one
        }
    }
}
