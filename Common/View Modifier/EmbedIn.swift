//
//  EmbedIn.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/10.
//

import Foundation
import SwiftUI

extension View {
    func embed(in position: EmbedIn.EmbedPosition) -> some View {
        modifier(EmbedIn(position))
    }
}

// MARK: - EmbedIn

struct EmbedIn: ViewModifier {
    // MARK: Lifecycle

    fileprivate init(_ position: EmbedIn.EmbedPosition) {
        self.position = position
    }

    // MARK: Internal

    enum EmbedPosition {
        case top
        case bottom
        case left
        case right
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case center

        // MARK: Fileprivate

        fileprivate enum VerticalEdge {
            case top
            case bottom
            case center
        }

        fileprivate enum HorizontalEdge {
            case left
            case right
            case center
        }

        fileprivate var verticalEdge: VerticalEdge {
            switch self {
            case .top, .topLeft, .topRight:
                return .top
            case .bottom, .bottomLeft, .bottomRight:
                return .bottom
            default:
                return .center
            }
        }

        fileprivate var horizontalEdge: HorizontalEdge {
            switch self {
            case .bottomLeft, .left, .topLeft:
                return .left
            case .bottomRight, .right, .topRight:
                return .right
            default:
                return .center
            }
        }
    }

    let position: EmbedPosition

    func body(content: Content) -> some View {
        VStack {
            OptionalSpacer(position.verticalEdge == .bottom)
            HStack {
                OptionalSpacer(position.horizontalEdge == .right)
                content
                OptionalSpacer(position.horizontalEdge == .left)
            }
            OptionalSpacer(position.verticalEdge == .top)
        }
    }
}
