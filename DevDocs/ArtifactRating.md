### 圣遗物评分系统白皮书

星穹铁道披萨小助手在 2024 年 5 月（v1.3.4）由 Shiki Suen 引入了来自[爱丽丝工房的原神圣遗物评分系统](https://github.com/Kamihimmel/artifactrating) 架构、将评分算法与评分权重依据换成针对崩坏星穹铁道特化的[三月七评分仓库](https://github.com/Mar-7th/StarRailScore)的内容。下文将该新系统简称为「缝合怪评分系统」。

1. 考虑到星穹铁道「刷到极品圣遗物的概率比原神更低」的现状，这套缝合怪系统的评分对单件圣遗物的满分定为三百分。
2. 仅五星圣遗物：就是拿三月七评分仓库系统的说明手册当中的百分比换算法（满分是 100% 也就是 1.0）直接乘以 300。
    - 四星圣遗物在此基础上会受到 defaultRoll 的影响，下文会详述。
3. 缝合怪系统继承了爱丽丝工房原神圣遗物评分系统的「defaultRoll」机制：
    - 由于缝合怪系统不是拿计算好的面板参数来评分、而是看不同的词条歪了多少次，所以所有词条共享 defaultRoll 数值。
    - 计算方法：「`星数 * 0.2`」。对五星圣遗物的所有词条的 defaultRoll 都是 1.0。
4. 与原神披萨助手用的「改造版爱丽丝工房的原神圣遗物评分系统」不同，缝合怪系统也会考虑「生命基础装备（原神的花、星穹铁道的头部遗器）」与「攻击基础装备（原神的翎、星穹铁道的手部遗器）」的主词条。因此，后者取消了前者「对于其他部位的圣遗物的总分抵销代偿机制」，也就不再出现「因为带错了其他属性的伤害的位面球/杯子、而导致被倒扣分」的问题。
    - 备注：原版爱丽丝工房的原神圣遗物评分系统完全没有考虑主词条，至少在截至 2024 年 5 月 11 日是这样的。

星穹铁道披萨助手的缝合怪系统也对 FDCBEAS 圣遗物评价等级系统做了一些调整，见下文。

修改前的圣遗物评价等级系统的圣遗物评价等级系统的段位划分规则（Swift）：

```swift
public static func tellTier(score: Int) -> String {
    switch score {
    case 1350...: return "SSS+"
    case 1300 ..< 1350: return "SSS"
    case 1250 ..< 1300: return "SSS-"
    case 1200 ..< 1250: return "SS+"
    case 1150 ..< 1200: return "SS"
    case 1100 ..< 1150: return "SS-"
    case 1050 ..< 1100: return "S+"
    case 1000 ..< 1050: return "S"
    case 950 ..< 1000: return "S-"
    case 900 ..< 950: return "A+"
    case 850 ..< 900: return "A"
    case 800 ..< 850: return "A-"
    case 750 ..< 800: return "B+"
    case 700 ..< 750: return "B"
    case 650 ..< 700: return "B-"
    case 600 ..< 650: return "C+"
    case 550 ..< 600: return "C"
    case 500 ..< 550: return "C-"
    case 450 ..< 500: return "D+"
    case 400 ..< 450: return "D"
    case 350 ..< 400: return "D-"
    case 300 ..< 350: return "E+"
    case 250 ..< 300: return "E"
    case 200 ..< 250: return "E-"
    default: return "F"
    }
}
```

$ EOF.
