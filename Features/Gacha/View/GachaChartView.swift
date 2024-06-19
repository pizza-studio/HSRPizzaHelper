//
//  GachaChartView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/11.
//

import Charts
import Defaults
import DefaultsKeys
import EnkaKitHSR
import EnkaSwiftUIViews
import HBMihoyoAPI
import SwiftUI

// MARK: - GachaChartView

struct GachaChartView: View {
    let uid: String
    @State var gachaType: GachaType

    var nextGachaType: GachaType {
        if let nextGachaType = gachaType.next() {
            return nextGachaType
        } else {
            return GachaType.allCases.first!
        }
    }

    var body: some View {
        List {
            Section {
                Picker("gacha.account_detail.chart.gacha_type", selection: $gachaType) {
                    ForEach(GachaType.allCases, id: \.rawValue) { type in
                        Text(type.description).tag(type)
                    }
                }
            }
            Section {
                GachaItemChart(
                    uid: uid, gachaType: gachaType
                )
            }
        }
        .inlineNavigationTitle("gacha.account_detail.chart.title")
    }
}

// MARK: - GachaItemChart

private struct GachaItemChart: View {
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

    var body: some View {
        let frozenItems: [ItemPair] = items
        let itemsOf5Star = extract5Stars(frozenItems)
        if !itemsOf5Star.isEmpty {
            VStack(spacing: -12) {
                ForEach(itemsOf5Star.chunked(into: 60), id: \.first!.0.id) { chunkedItems in
                    let chunkedItemsOf5Star = extract5Stars(chunkedItems)
                    let isFirst = Bool(equalCheck: itemsOf5Star.first?.0.id, against: chunkedItems.first?.0.id)
                    let isLast = Bool(equalCheck: itemsOf5Star.last?.0.id, against: chunkedItems.last?.0.id)
                    subChart(
                        givenItems: chunkedItems,
                        fiveStarItems: chunkedItemsOf5Star,
                        isFirst: isFirst,
                        isLast: isLast
                    ).padding(isFirst ? .top : [])
                }
            }
        } else {
            Text("gacha.account_detail.chart.no_five_star")
                .foregroundColor(.secondary)
        }
    }

    // MARK: Private

    private typealias ItemPair = (GachaItemMO, count: Int)

    @Default(.useGuestGachaEvaluator) private var useGuestGachaEvaluator: Bool
    @Default(.useRealCharacterNames) private var useRealCharacterNames: Bool

    private let gachaType: GachaType

    @FetchRequest private var gachaItemsResult: FetchedResults<GachaItemMO>

    private var items: [ItemPair] {
        Array(zip(gachaItemsResult, calculateGachaItemsDrawCount(gachaItemsResult)))
    }

    private var lose5050IconStr: String {
        useGuestGachaEvaluator ? "UI_EmotionIcon5" : "Pom-Pom_Sticker_32"
    }

    private func extract5Stars(_ source: [ItemPair]) -> [ItemPair] {
        source.filter { $0.0.rank == .five }
    }

    @ViewBuilder
    private func subChart(
        givenItems: borrowing [ItemPair],
        fiveStarItems: borrowing [ItemPair],
        isFirst: Bool,
        isLast: Bool
    )
        -> some View {
        let averagePullsCount: Int = fiveStarItems.map(\.count).reduce(0, +) / max(fiveStarItems.count, 1)
        Chart {
            ForEach(givenItems, id: \.0.id) { item in
                drawChartContent(for: item)
            }
            if !fiveStarItems.isEmpty {
                RuleMark(x: .value("gacha.account_detail.chart.average", averagePullsCount))
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                    .annotation(alignment: .topLeading) {
                        if isFirst {
                            Text(
                                "gacha.account_detail.chart.avg_pull_count"
                                    .localized() + averagePullsCount.description
                            )
                            .font(.caption).foregroundColor(.gray)
                        }
                    }
            }
        }
        .chartYAxis(content: {
            AxisMarks(preset: .aligned, position: .leading) { value in
                AxisValueLabel(content: {
                    if let id = value.as(String.self),
                       let item = matchedItems(among: givenItems, with: id).first {
                        GachaItemIcon(item: item, size: 45)
                    } else {
                        EmptyView()
                    }
                })
            }
            AxisMarks { value in
                AxisValueLabel(content: {
                    if let theValue = value.as(String.self),
                       let item = matchedItems(among: givenItems, with: theValue).first {
                        item.localizedNameView(officialNameOnly: !useRealCharacterNames)
                            .offset(y: givenItems.count == 1 ? 0 : 8)
                    } else {
                        EmptyView()
                    }
                })
            }
        })
        .chartXAxis(content: {
            AxisMarks(values: [0, 25, 50, 75, 100]) { _ in
                AxisGridLine()
                if isLast {
                    AxisValueLabel()
                } else {
                    AxisValueLabel {
                        EmptyView()
                    }
                }
            }
        })
        .chartXScale(domain: 0 ... 110)
        .frame(height: CGFloat(givenItems.count * 65))
        .chartForegroundStyleScale(range: colors(items: fiveStarItems))
        .chartLegend(.hidden)
    }

    private func matchedItems(
        among source: borrowing [ItemPair],
        with value: String
    )
        -> [GachaItemMO] {
        source.map(\.0).filter { $0.id == value }
    }

    private func colors(items: borrowing [ItemPair]) -> [Color] {
        items.map { _, count in
            switch count {
            case 0 ..< 62:
                return .green
            case 62 ..< 80:
                return .yellow
            default:
                return .red
            }
        }
    }

    @ChartContentBuilder
    private func drawChartContent(for item: (GachaItemMO, count: Int)) -> some ChartContent {
        BarMark(
            x: .value("gacha.account_detail.chart.pull_count", item.count),
            y: .value("gacha.account_detail.chart.character", item.0.id),
            width: 20
        )
        .annotation(position: .trailing) {
            HStack(spacing: 3) {
                let frame: CGFloat = 35
                Text("\(item.count)").foregroundColor(.gray).font(.caption)
                if gachaType.isLimitedWarp, item.0.isLose5050 {
                    Image(lose5050IconStr).resizable().scaledToFit()
                        .frame(width: frame, height: frame)
                        .offset(y: -5)
                } else {
                    EmptyView()
                }
            }
        }
        .foregroundStyle(by: .value("gacha.account_detail.chart.pull_count", item.0.id))
    }
}

// MARK: - GachaTypeDateCountAndIfContain5Star

struct GachaTypeDateCountAndIfContain5Star: Hashable, Identifiable {
    let date: Date
    var count: Int
    let type: GachaType
    let contain5Star: String

    var id: Int {
        hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(type)
    }
}

extension Collection {
    public func chunked(into size: Int) -> [[Self.Element]] where Self.Index == Int {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, self.count)])
        }
    }
}

extension Bool {
    fileprivate init<T: Comparable>(equalCheck lhs: T?, against rhs: T?) {
        guard let lhs, let rhs else { self = false; return }
        self = lhs == rhs
    }
}
