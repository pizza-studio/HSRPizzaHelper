// (c) 2023 and onwards Pizza Studio (GPL v3.0 License).
// ====================
// This code is released under the GPL v3.0 License (SPDX-License-Identifier: GPL-3.0)

import Combine
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

// MARK: - DeviceOrientation

final class DeviceOrientation: ObservableObject {
    // MARK: Lifecycle

    init() {
        #if canImport(UIKit)
        self.orientation = UIDevice.current.orientation
            .isLandscape ? .landscape : .portrait
        self.listener = NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .compactMap { ($0.object as? UIDevice)?.orientation }
            .compactMap { deviceOrientation -> Orientation? in
                if deviceOrientation.isPortrait {
                    return .portrait
                } else if deviceOrientation.isLandscape {
                    return .landscape
                } else {
                    return nil
                }
            }
            .assign(to: \.orientation, on: self)
        #else
        self.orientation = .landscape
        #endif
    }

    deinit {
        listener?.cancel()
    }

    // MARK: Internal

    enum Orientation {
        case portrait
        case landscape
    }

    @Published var orientation: Orientation

    // MARK: Private

    private var listener: AnyCancellable?
}

extension DeviceOrientation {
    public static var basicWindowSize: CGSize {
        .init(
            width: 622,
            height: 1107
        )
    }

    public static var scaleRatioCompatible: CGFloat {
        guard let windowSize = getKeyWindowSize() else { return 1 }
        // 对哀凤优先使用宽度适配，没准哪天哀凤长得跟法棍面包似的也说不定。
        var result = windowSize.width / basicWindowSize.width
        let zoomedSize = CGSize(
            width: basicWindowSize.width * result,
            height: basicWindowSize.height * result
        )
        let compatible = CGRect(origin: .zero, size: windowSize)
            .contains(CGRect(origin: .zero, size: zoomedSize))
        if !compatible {
            result = windowSize.height / basicWindowSize.height
        }
        return result
    }

    public static func getKeyWindowSize() -> CGSize? {
        #if canImport(UIKit)
        return UIApplication.shared.connectedScenes
            .compactMap { scene -> UIWindow? in
                (scene as? UIWindowScene)?.keyWindow
            }
            .first?.frame.size
        #elseif canImport(AppKit)
        return NSApplication.shared.keyWindow?.frame.size
        #endif
    }
}
