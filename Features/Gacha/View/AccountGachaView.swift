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
                Picker("gacha.account_detail.gacha_type", selection: $gachaType) {
                    ForEach(GachaType.allCases, id: \.rawValue) { type in
                        Text(type.description).tag(type)
                    }
                }
            }
            Section {
                if #available(iOS 16.0, *) {
                    GachaSmallChart(uid: uid, gachaType: gachaType)
                    NavigationLink {
                        GachaChartView(uid: uid, gachaType: gachaType)
                    } label: {
                        Label("gacha.account_detail.chart.more", systemSymbol: .chartBarXaxis)
                    }
                }
            } header: {
                Text("gacha.account_detail.chart.header")
            }
            Section {
                GachaStatisticSectionView(uid: uid, gachaType: gachaType)
            } header: {
                Text("gacha.account_detail.statistic.header")
            }
            Section {
                NavigationLink("gacha.account_detail.detail") {
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
            Text("gacha.account_detail.small_chart.no_data")
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
                        x: .value("gacha.account_detail.small_chart.character", item.0.id),
                        y: .value("gacha.account_detail.small_chart.pull_count", item.drawCount)
                    )
                    .annotation(position: .top) {
                        Text("\(item.drawCount)").foregroundColor(.gray)
                            .font(.caption)
                    }
                    .foregroundStyle(by: .value("gacha.account_detail.small_chart.pull_count", item.0.id))
                }
                if !fiveStarItems.isEmpty {
                    RuleMark(y: .value(
                        "gacha.account_detail.small_chart.average",
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
                Label("gacha.account_detail.statistic.after_last_5_star", systemSymbol: .flagFill)
                Spacer()
                Text(
                    String(
                        format: "gacha.account_detail.statistic.pull".localized(),
                        itemsWithDrawCount.firstIndex(where: { $0.0.rank == .five }) ?? itemsWithDrawCount.count
                    )
                )
            }
            HStack {
                Label(
                    "gacha.account_detail.statistic.total_pull",
                    systemSymbol: .handTapFill
                )
                Spacer()
                Text("\(itemsWithDrawCount.count)")
            }
            HStack {
                Label(
                    "gacha.account_detail.statistic.5_star_avg_pull",
                    systemSymbol: .star
                )
                Spacer()
                Text("\(average5StarDraw)")
            }
            if gachaType != .regularWarp {
                HStack {
                    Label(
                        "gacha.account_detail.statistic.limited_5_star_avg_pull",
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

                    Label("gacha.account_detail.statistic.won_5050", systemSymbol: .chartPieFill)
                    Spacer()
                    Text(
                        "\(fmt.string(from: lose5050percentage as NSNumber)!)"
                    )
                }
            }
            if gachaType != .regularWarp {
                VStack {
                    HStack {
                        let keyPaimon = "gacha.account_detail.statistic.paimon_review"
                        let keyPomPom = "gacha.account_detail.statistic.pom_pom_review"
                        Text(Defaults[\.useGuestGachaEvaluator] ? keyPaimon : keyPomPom)
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
                                    rank.image(neighborGame: Defaults[\.useGuestGachaEvaluator]).resizable()
                                        .scaledToFit()
                                } else {
                                    rank.image(neighborGame: Defaults[\.useGuestGachaEvaluator]).resizable()
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
    func image(neighborGame: Bool = false) -> Image {
        switch self {
        case .one:
            return neighborGame ? Image("UI_EmotionIcon5") : Image("Pom-Pom_Sticker_21")
        case .two:
            return neighborGame ? Image("UI_EmotionIcon4") : Image("Pom-Pom_Sticker_32")
        case .three:
            return neighborGame ? Image("UI_EmotionIcon3") : Image("Pom-Pom_Sticker_18")
        case .four:
            return neighborGame ? Image("UI_EmotionIcon2") : Image("Pom-Pom_Sticker_24")
        case .five:
            return neighborGame ? Image("UI_EmotionIcon1") : Image("Pom-Pom_Sticker_30")
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
