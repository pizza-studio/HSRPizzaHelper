//
//  AccountGachaView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/8/11.
//

import Defaults
import DefaultsKeys
import EnkaKitHSR
import EnkaSwiftUIViews
import HBMihoyoAPI
import SwiftUI

// MARK: - AccountGachaDetailView

struct AccountGachaDetailView: View {
    // MARK: Internal

    let uid: String

    @State var gachaType: GachaType

    var body: some View {
        List {
            Section {
                Group {
                    Picker(
                        "gacha.account_detail.detail.filter.gacha_type",
                        selection: $gachaType.animation()
                    ) {
                        ForEach(GachaType.allCases, id: \.rawValue) { type in
                            Text(type.description).tag(type)
                        }
                    }
                    Picker(
                        "gacha.account_detail.detail.filter.rank",
                        selection: $rankFilter.animation()
                    ) {
                        ForEach(RankFilter.allCases, id: \.rawValue) { filter in
                            Text("\(filter.description)").tag(filter)
                        }
                    }
                    Toggle(
                        "gacha.account_detail.detail.filter.display_option.show_time",
                        isOn: $showTime.animation()
                    )
                }
                .controlSize(.small)
            } header: {
                Text("gacha.account_detail.detail.filter.display_option.title")
            }
            Section {
                GachaItemDetail(uid: uid, gachaType: gachaType, rankFilter: rankFilter, showTime: showTime)
            }
        }
        .inlineNavigationTitle("gacha.account_detail.detail.title")
    }

    // MARK: Private

    @State private var rankFilter: RankFilter = .fiveOnly

    @State private var showTime: Bool = false
}

// MARK: - RankFilter

private enum RankFilter: Int, CaseIterable {
    case fiveOnly
    case fourAndFive
    case all
}

// MARK: CustomStringConvertible

extension RankFilter: CustomStringConvertible {
    var description: String {
        switch self {
        case .fiveOnly:
            return "gacha.rank_filter.five_only".localized()
        case .fourAndFive:
            return "gacha.rank_filter.four_and_five".localized()
        case .all:
            return "gacha.rank_filter.all".localized()
        }
    }
}

// MARK: - GachaItemDetail

private struct GachaItemDetail: View {
    // MARK: Lifecycle

    init(uid: String, gachaType: GachaType, rankFilter: RankFilter, showTime: Bool) {
        self.rankFilter = rankFilter
        self._gachaItemsResult = .init(
            sortDescriptors: [.init(keyPath: \GachaItemMO.id, ascending: false)],
            predicate: NSPredicate(format: "uid = %@ AND gachaTypeRawValue = %@", uid, gachaType.rawValue),
            animation: .default
        )
        self.showTime = showTime
    }

    // MARK: Internal

    var body: some View {
        if !filteredGachaItemsWithDrawCount.isEmpty {
            ForEach(filteredGachaItemsWithDrawCount, id: \.0.id) { item, drawCount in
                GachaItemBar(item: item, drawCount: drawCount, showTime: showTime)
            }
        } else {
            Text("gacha.account_detail.detail.no_data")
                .foregroundColor(.secondary)
        }
    }

    var filteredGachaItemsWithDrawCount: [(GachaItemMO, Int)] {
        /// 补记：这里已经用 Query Predicate 筛检过了，所以 drawCounts 计算结果无误。
        let drawCounts = calculateGachaItemsDrawCount(gachaItemsResult)
        return zip(gachaItemsResult, drawCounts)
            .filter { item, _ in
                switch rankFilter {
                case .all:
                    return true
                case .fourAndFive:
                    return [.five, .four].contains(item.rank)
                case .fiveOnly:
                    return item.rank == .five
                }
            }
    }

    // MARK: Private

    private var showTime: Bool

    @FetchRequest private var gachaItemsResult: FetchedResults<GachaItemMO>
    private let rankFilter: RankFilter
}

// MARK: - GachaItemBar

private struct GachaItemBar: View {
    // MARK: Internal

    let item: GachaItemMO
    let drawCount: Int
    let showTime: Bool

    @MainActor var itemIDText: Text {
        if showTime {
            Text(verbatim: "  \(item.itemID)")
                .font(.caption).foregroundColor(.secondary)
        } else {
            Text(verbatim: "")
        }
    }

    var body: some View {
        HStack {
            GachaItemIcon(item: item)
            HStack {
                item.localizedNameView(officialNameOnly: !useRealCharacterNames) + itemIDText
                Spacer()
                VStack(alignment: .trailing) {
                    if item.rank != .three {
                        Text("\(drawCount)")
                            .font(showTime ? .caption2 : .body)
                    }
                    if showTime {
                        Text(dateFormatter.string(from: item.time))
                            .foregroundColor(.secondary)
                            .font(.caption2)
                    }
                }
            }
            #if DEBUG
            .contextMenu {
                    Text(verbatim: "Debug Info")
                    Divider()
                    Text(item.langRawValue)
                    Text(item.itemTypeRawValue)
                    Text(item.gachaTypeRawValue)
                }
            #endif
        }
    }

    // MARK: Private

    @Default(.useRealCharacterNames) private var useRealCharacterNames: Bool
}

private var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

func calculateGachaItemsDrawCount(_ gachaItems: FetchedResults<GachaItemMO>) -> [Int] {
    gachaItems.map { item in
        item.rank
    }.enumerated().map { index, rank in
        let theRestOfArray = gachaItems[(index + 1)...]
        if let nextIndexInRest = theRestOfArray
            .firstIndex(where: { $0.rank >= rank }) {
            return nextIndexInRest - index
        } else {
            return gachaItems.count - index
        }
    }
}
