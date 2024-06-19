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
        print("load img cache of \(urlStr): ")
        self.viewModel = WebImageLoaderViewModel(imgUrl: urlStr)
    }

    // MARK: Internal

    var urlStr: String

    @ObservedObject var viewModel: WebImageLoaderViewModel

    var body: some View {
        if viewModel.imageData == nil {
            AsyncImage(
                url: URL(string: urlStr),
                transaction: Transaction(animation: .default)
            ) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .dispatchedTask {
                            viewModel.saveImageCache(url: urlStr)
                        }
                default:
                    ProgressView()
                        .onAppear {
                            print("imageData is nil")
                        }
                }
            }
        } else {
            Image(uiImage: viewModel.imageData!)
                .resizable().aspectRatio(contentMode: .fit)
        }
    }
}

// MARK: - WebImageLoaderViewModel

class WebImageLoaderViewModel: ObservableObject {
    // MARK: Lifecycle

    init(imgUrl: String) {
        self.imgUrl = imgUrl
        DispatchQueue.main.async {
            self.imageData = self.loadImageCache(url: imgUrl)
        }
    }

    // MARK: Internal

    let imageFolderURL = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first!.appendingPathComponent("Images")

    @Published var imageData: UIImage?

    // 判断是否存在缓存，否则保存图片
    func saveImageCache(url: String) {
        let imageURL = URL(string: url)!
        let imageFileURL = imageFolderURL
            .appendingPathComponent(imageURL.lastPathComponent)
        if !FileManager.default.fileExists(atPath: imageFileURL.path) {
            URLSession.shared.dataTask(with: imageURL) { data, _, _ in
                if let data = data {
                    print("save: fileURL:\(imageFileURL)")
                    // swiftlint:disable:next force_try
                    try! data.write(to: imageFileURL)
                }
            }.resume()
        }
    }

    // 读取图片
    func loadImageCache(url: String) -> UIImage? {
        guard let imageURL = URL(string: url) else {
            return nil
        }

        if !FileManager.default.fileExists(atPath: imageFolderURL.path) {
            // swiftlint:disable:next force_try
            try! FileManager.default.createDirectory(
                at: imageFolderURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        let imageFileURL = imageFolderURL
            .appendingPathComponent(imageURL.lastPathComponent)
        print("load: fileURL:\(imageFileURL)")
        if let image = UIImage(contentsOfFile: imageFileURL.path) {
            return image
        } else {
            print("not found on disk, get from web")
            return getImageFromWeb()
        }
    }

    func getImageFromWeb() -> UIImage? {
        let url = URL(string: imgUrl)
        var img: UIImage?
        if url != nil {
            DispatchQueue.global(qos: .userInteractive).async {
                let data = try? Data(contentsOf: url!)
                guard data != nil else {
                    return
                }
                let imageFileURL = self.imageFolderURL
                    .appendingPathComponent(url!.lastPathComponent)
                print("save: fileURL:\(imageFileURL)")
                // swiftlint:disable:next force_try
                try! data!.write(to: imageFileURL)
                img = UIImage(data: data!)
                Task.detached { @MainActor [img] in
                    self.imageData = img
                }
            }
        }
        return img
    }

    // MARK: Private

    private var imgUrl: String
}

// MARK: - NetworkImage

/// 加载完图片后才会显示，不要放在UI中，可以放在静态的内容中如widget和保存的图片
struct NetworkImage: View {
    let url: URL?

    var body: some View {
        Group {
            if let url = url, let imageData = try? Data(contentsOf: url),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                //         .aspectRatio(contentMode: .fill)
            } else {
                Image("placeholder-image")
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
        DispatchQueue.main.async {
            task()
        }
        return self
    }
}
