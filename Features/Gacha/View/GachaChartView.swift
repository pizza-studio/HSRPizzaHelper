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

    var items: [(GachaItemMO, count: Int)] {
        Array(zip(gachaItemsResult, calculateGachaItemsDrawCount(gachaItemsResult)))
    }

    var fiveStarItems: [(GachaItemMO, count: Int)] {
        items.filter { $0.0.rank == .five }
    }

    var averagePullsCount: Int {
        fiveStarItems.map(\.count).reduce(0, +) / max(fiveStarItems.count, 1)
    }

    var body: some View {
        if !fiveStarItems.isEmpty {
            VStack(spacing: -12) {
                ForEach(fiveStarItems.chunked(into: 60), id: \.first!.0.id) { items in
                    let isFirst = fiveStarItems.first!.0.id == items.first!.0.id
                    let isLast = fiveStarItems.last!.0.id == items.last!.0.id
                    if isFirst {
                        subChart(items: items, isFirst: isFirst, isLast: isLast).padding(.top)
                    } else {
                        subChart(items: items, isFirst: isFirst, isLast: isLast)
                    }
                }
            }
        } else {
            Text("gacha.account_detail.chart.no_five_star")
                .foregroundColor(.secondary)
        }
    }

    var lose5050IconStr: String {
        useGuestGachaEvaluator ? "UI_EmotionIcon5" : "Pom-Pom_Sticker_32"
    }

    func matchedItems(with value: String) -> [GachaItemMO] {
        items.map(\.0).filter { $0.id == value }
    }

    func colors(items: [(GachaItemMO, count: Int)]) -> [Color] {
        fiveStarItems.map { _, count in
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

    @ViewBuilder
    func subChart(items: [(GachaItemMO, count: Int)], isFirst: Bool, isLast: Bool) -> some View {
        Chart {
            ForEach(items, id: \.0.id) { item in
                BarMark(
                    x: .value("gacha.account_detail.chart.pull_count", item.count),
                    y: .value("gacha.account_detail.chart.character", item.0.id),
                    width: 20
                )
                .annotation(position: .trailing) {
                    HStack(spacing: 3) {
                        let frame: CGFloat = 35
                        Text("\(item.count)").foregroundColor(.gray)
                            .font(.caption)
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
            if !fiveStarItems.isEmpty {
                RuleMark(x: .value(
                    "gacha.account_detail.chart.average",
                    fiveStarItems.map { $0.count }
                        .reduce(0, +) / max(fiveStarItems.count, 1)
                ))
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
                       let item = items
                       .first(where: { $0.0.id == id })?.0 {
                        GachaItemIcon(item: item, size: 45)
                    } else {
                        EmptyView()
                    }
                })
            }
            AxisMarks { value in
                AxisValueLabel(content: {
                    if let theValue = value.as(String.self),
                       let item = matchedItems(with: theValue).first {
                        item.localizedNameView(officialNameOnly: !useRealCharacterNames)
                            .offset(y: items.count == 1 ? 0 : 8)
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
        .frame(height: CGFloat(items.count * 65))
        .chartForegroundStyleScale(range: colors(items: items))
        .chartLegend(.hidden)
    }

    // MARK: Private

    @Default(.useGuestGachaEvaluator) private var useGuestGachaEvaluator: Bool
    @Default(.useRealCharacterNames) private var useRealCharacterNames: Bool

    private let gachaType: GachaType

    @FetchRequest private var gachaItemsResult: FetchedResults<GachaItemMO>
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
