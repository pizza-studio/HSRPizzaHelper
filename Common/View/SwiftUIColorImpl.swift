//
//  Color.swift
//  GenshinPizzaHelper
//
//  Created by 戴藏龙 on 2023/4/4.
//

import Foundation
import SwiftUI

extension UIColor {
    func modified(
        withAdditionalHue hue: CGFloat,
        additionalSaturation: CGFloat,
        additionalBrightness: CGFloat
    )
        -> UIColor {
        var currentHue: CGFloat = 0.0
        var currentSaturation: CGFloat = 0.0
        var currentBrigthness: CGFloat = 0.0
        var currentAlpha: CGFloat = 0.0

        if getHue(
            &currentHue,
            saturation: &currentSaturation,
            brightness: &currentBrigthness,
            alpha: &currentAlpha
        ) {
            return UIColor(
                hue: currentHue + hue,
                saturation: currentSaturation + additionalSaturation,
                brightness: currentBrigthness + additionalBrightness,
                alpha: currentAlpha
            )
        } else {
            return self
        }
    }
}

extension Color {
    func addSaturation(_ added: CGFloat) -> Color {
        let uiColor = UIColor(self)
        return Color(uiColor.modified(
            withAdditionalHue: 0,
            additionalSaturation: added,
            additionalBrightness: 0
        ))
    }

    func addBrightness(_ added: CGFloat) -> Color {
        let uiColor = UIColor(self)
        return Color(uiColor.modified(
            withAdditionalHue: 0,
            additionalSaturation: 0,
            additionalBrightness: added
        ))
    }

    @ViewBuilder
    static func accessibilityAccent(_ scheme: ColorScheme? = nil) -> Color {
        Color.primary.opacity(scheme == .dark ? 0.9 : 0.7)
    }
}
