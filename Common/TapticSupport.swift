//
//  TapticSupport.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/5/8.
//  Taptic Engine支持

import Foundation
import UIKit
#if !os(watchOS)
import AudioToolbox
import CoreHaptics

enum SimpleTapticType {
    case success
    case warning
    case error
    case light
    case medium
    case heavy
    case rigid
    case soft
    case selection
}

// swiftlint:disable:next cyclomatic_complexity
func simpleTaptic(gachaType: SimpleTapticType) {
    let feedbackGenerator = UINotificationFeedbackGenerator()
    switch gachaType {
    case .success:
        feedbackGenerator.notificationOccurred(.success)
    case .warning:
        feedbackGenerator.notificationOccurred(.warning)
    case .error:
        feedbackGenerator.notificationOccurred(.error)
    case .light:
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
    case .medium:
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
    case .heavy:
        let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
    case .rigid:
        let impactGenerator = UIImpactFeedbackGenerator(style: .rigid)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
    case .soft:
        let impactGenerator = UIImpactFeedbackGenerator(style: .soft)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
    case .selection:
        let selectionGenerator = UISelectionFeedbackGenerator()
        selectionGenerator.selectionChanged()
    }
    if UIDevice.modelName == "iPhone 6s" || UIDevice
        .modelName == "iPhone 6s Plus" || UIDevice
        .modelName == "iPhone SE" {
        switch gachaType {
        case .error, .heavy, .medium, .rigid, .success, .warning:
            AudioServicesPlaySystemSound(1519) // Actuate `Peek` feedback (weak boom)
        case .light, .selection, .soft:
            AudioServicesPlaySystemSound(1520) // Actuate `Pop` feedback (strong boom)
        }
    }
    print("Taptic Success")
}

class CHTaptic {
    // MARK: Internal

    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics
        else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("创建引擎时出现错误： \(error.localizedDescription)")
        }
    }

    func complexTaptic() {
        // Make sure support Taptic
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics
        else { return }
        var events = [CHHapticEvent]()

        let intensity = CHHapticEventParameter(
            parameterID: .hapticIntensity,
            value: 1
        )
        let sharpness = CHHapticEventParameter(
            parameterID: .hapticSharpness,
            value: 1
        )
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [intensity, sharpness],
            relativeTime: 0
        )
        events.append(event)

        do {
            let pattern = try CHHapticPattern(
                events: events,
                parameters: []
            )
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }

    // MARK: Private

    private var engine: CHHapticEngine?
}
#endif
