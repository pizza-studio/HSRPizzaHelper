//
//  WebImageView.swift
//  GenshinPizzaHelper
//
//  Created by Bill Haku on 2022/8/12.
//  封装了iOS 14与iOS 15中两种方法的异步加载网络图片的View

import SwiftUI

// MARK: - WebImage

struct WebImage: View {
    // MARK: Lifecycle

    init(urlStr: String) {
        self.urlStr = urlStr
    }

    // MARK: Internal

    var urlStr: String

    var body: some View {
        AsyncImage(
            url: URL(string: urlStr),
            transaction: Transaction(animation: .default)
        ) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            default:
                ProgressView()
                    .onAppear {
                        print("imageData is nil")
                    }
            }
        }
    }
}

// MARK: - EnkaWebIcon

struct EnkaWebIcon: View {
    var iconString: String

    var body: some View {
        if let image = UIImage(named: iconString) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            WebImage(urlStr: "https://enka.network/ui/\(iconString).png")
        }
    }
}

// MARK: - HomeSourceWebIcon

struct HomeSourceWebIcon: View {
    var iconString: String

    var body: some View {
        if let image = UIImage(named: iconString) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            WebImage(urlStr: "https://gi.pizzastudio.org/resource/\(iconString).png")
        }
    }
}

// MARK: - Dispatched Task for a View

extension View {
    fileprivate func dispatchedTask(_ task: @escaping () -> Void) -> some View {
        Task.detached { @MainActor in
            task()
        }
        return self
    }
}
