// Ref: https://swiftuirecipes.com/blog/material-indefinite-loading-bar-in-swiftui

import Foundation
import SwiftUI

// the height of the bar
private let height: CGFloat = 4
// how much does the blue part cover the gray part (40%)
private let coverPercentage: CGFloat = 0.4
private let minOffset: CGFloat = -2
private let maxOffset = 1 / coverPercentage * abs(minOffset)

// MARK: - InfiniteProgressBar

struct InfiniteProgressBar: View {
    // MARK: Internal

    var body: some View {
        Rectangle()
            .foregroundColor(.gray) // change the color as you see fit
            .frame(height: height)
            .overlay(GeometryReader { geo in
                overlayRect(in: geo.frame(in: .local))
            })
    }

    // MARK: Private

    @State private var offset = minOffset

    private func overlayRect(in rect: CGRect) -> some View {
        let width = rect.width * coverPercentage
        return Rectangle()
            .foregroundColor(.blue)
            .frame(width: width)
            .offset(x: width * offset)
            .onAppear {
                withAnimation(Animation.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                    self.offset = maxOffset
                }
            }
    }
}
