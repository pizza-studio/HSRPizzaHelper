//
//  ManageWidgetBackgroundView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/8.
//

import Mantis
import PhotosUI
import SwiftUI

// MARK: - WidgetBackgroundSettingView

struct WidgetBackgroundSettingView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("setting.widget.background.destination.square") {
                    ManageWidgetBackgroundView(backgroundType: .square)
                        .navigationTitle("setting.widget.background.destination.square")
                }
                NavigationLink("setting.widget.background.destination.rectangular") {
                    ManageWidgetBackgroundView(backgroundType: .rectangular)
                        .navigationTitle("setting.widget.background.destination.rectangular")
                }
            } footer: {
                Text("setting.widget.holdon.tips")
            }
        }
        .navigationTitle("setting.widget.background.title")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - ManageWidgetBackgroundView

private struct ManageWidgetBackgroundView: View, ContainBackgroundType {
    // MARK: Internal

    let backgroundType: BackgroundType

    @State var imageUrls: [URL] = []

    var body: some View {
        List {
            Section {
                Button("setting.widget.background.manage.add.title") {
                    isAddBackgroundSheetShow.toggle()
                }
                .fullScreenCover(isPresented: $isAddBackgroundSheetShow) {
                    AddWidgetBackgroundCover(backgroundType: backgroundType, isShow: $isAddBackgroundSheetShow)
                }
            }
            Section {
                ForEach(imageUrls, id: \.self) { url in
                    if let data = try? Data(contentsOf: url),
                       let uiImage = UIImage(data: data) {
                        BackgroundPreviewView(
                            imageName: url.lastPathComponent.deletingPathExtension,
                            image: uiImage,
                            backgroundType: backgroundType
                        )
                        .contextMenu {
                            Button("setting.widget.background.context.menu.delete", role: .destructive) {
                                if #available(iOS 16, *) {
                                    alert = .deletingConfirmation(url)
                                } else {
                                    deleteSelectedBackground(url: url)
                                }
                            }
                            Button("setting.widget.background.context.menu.rename") {
                                alert = .renaming(url, newName: "")
                            }
                        }
                    }
                }
            } footer: {
                Text("setting.widget.Background.delete.tips")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: isAddBackgroundSheetShow, perform: { newValue in
            if newValue == false {
                reloadImage()
            }
        })
        .onAppear {
            reloadImage()
        }
        .alert(isPresented: $isErrorAlertShow, error: error) {
            Button("sys.ok") {
                isErrorAlertShow.toggle()
                error = nil
            }
        }
        .alert("setting.widget.background.alert.rename.title", isPresented: isRenameAlertShow) {
            TextField("setting.widget.background.alert.rename.textfield.title", text: newName)
            Button("setting.widget.background.alert.rename.button.save") {
                renameSelectedBackground()
            }
            cancelButton()
        }
        .confirmationDialog(
            "setting.widget.background.delete.confirmation.title",
            isPresented: isDeletingConfirmationShow
        ) {
            Button("setting.widget.background.delete.confirmation.delete", role: .destructive) {
                if case let .deletingConfirmation(url) = alert {
                    deleteSelectedBackground(url: url)
                } else {
                    alert = .notShowing
                }
            }
            cancelButton()
        }
    }

    func reloadImage() {
        withAnimation {
            imageUrls = (
                try? WidgetBackgroundOptionsProvider
                    .getWidgetBackgroundUrlsFromFolder(in: getFolderUrl())
            ) ?? []
        }
    }

    func renameSelectedBackground() {
        defer {
            reloadImage()
            alert = .notShowing
        }
        switch alert {
        case let .renaming(url, newName):
            let newFileURL = url.deletingLastPathComponent().appendingPathComponent(newName)
            do {
                try FileManager.default.moveItem(at: url, to: newFileURL)
            } catch {
                self.error = .init(source: error)
            }
        default:
            return
        }
    }

    func deleteSelectedBackground(url: URL) {
        defer {
            reloadImage()
            alert = .notShowing
        }
        if #available(iOS 16, *) {
            switch alert {
            case let .deletingConfirmation(url):
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    self.error = .init(source: error)
                    isErrorAlertShow.toggle()
                }
            default:
                return
            }
        } else {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                self.error = .init(source: error)
                isErrorAlertShow.toggle()
            }
        }
    }

    @ViewBuilder
    func cancelButton() -> some View {
        Button("sys.cancel", role: .cancel) {
            alert = .notShowing
        }
    }

    // MARK: Private

    private enum Alert {
        case notShowing
        case renaming(URL, newName: String)
        case deletingConfirmation(URL)
    }

    @State private var isAddBackgroundSheetShow: Bool = false

    @State private var isErrorAlertShow: Bool = false
    @State private var error: SourceLocalizedError?

    @State private var alert: Alert = .notShowing

    private var newName: Binding<String> {
        .init {
            if case let .renaming(_, newName) = alert {
                return newName
            } else {
                return ""
            }
        } set: { newValue in
            if case let .renaming(url, _) = alert {
                alert = .renaming(url, newName: newValue)
            }
        }
    }

    private var isRenameAlertShow: Binding<Bool> {
        .init {
            if case .renaming = alert {
                return true
            } else {
                return false
            }
        } set: { newValue in
            if newValue == false {
                alert = .notShowing
            }
        }
    }

    private var isDeletingConfirmationShow: Binding<Bool> {
        .init {
            if case .deletingConfirmation = alert {
                return true
            } else {
                return false
            }
        } set: { newValue in
            if newValue == false {
                alert = .notShowing
            }
        }
    }
}

// MARK: - AddWidgetBackgroundCover

private struct AddWidgetBackgroundCover: View, ContainBackgroundType {
    // MARK: Internal

    let backgroundType: BackgroundType

    @Binding var isShow: Bool

    var body: some View {
        NavigationView {
            List {
                Section {
                    Button("setting.widget.background.manage.reselect") {
                        isPhotoPickerShow.toggle()
                    }
                }
                if let image {
                    Section {
                        HStack {
                            Text("setting.widget.background.manage.add.name")
                            Spacer()
                            TextField(
                                "setting.widget.background.manage.add.name",
                                text: $backgroundName
                            )
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(backgroundNameIsNotNamed ? .secondary : .primary)
                            .onFocused {
                                if backgroundNameIsNotNamed {
                                    backgroundName = ""
                                }
                            }
                        }
                        Button("setting.widget.background.manage.add.edit") {
                            isEditImageCoverShow.toggle()
                        }
                    }
                    BackgroundPreviewView(imageName: backgroundName, image: image, backgroundType: backgroundType)
                }
            }
            .fullScreenCover(isPresented: $isEditImageCoverShow, content: {
                ImageCropper(
                    image: $image,
                    presetFixedRatioType: .alwaysUsingOnePresetFixedRatio(ratio: ratio)
                )
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("sys.save") {
                        isAskForNameAlertShow.toggle()
                    }
                    .disabled(image == nil)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("sys.cancel") {
                        isShow.toggle()
                    }
                }
            }
            .navigationTitle("setting.widget.background.manage.add.title")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $isPhotoPickerShow, content: {
            ImagePickerView(image: $image)
                .onDisappear {
                    if image != nil {
                        isEditImageCoverShow.toggle()
                    }
                }
        })
        .alert("setting.widget.background.manage.add.needname", isPresented: $isNeedNameAlertShow, actions: {
            Button("sys.ok") {
                isNeedNameAlertShow.toggle()
                isAskForNameAlertShow.toggle()
            }
        })
        .alert("setting.widget.background.manage.add.duplicatedname",
               isPresented: $isNameDuplicatedAlertShow,
               actions: {
            Button("sys.ok") {
                isNameDuplicatedAlertShow.toggle()
                isAskForNameAlertShow.toggle()
            }
        })
        .alert(isPresented: $isErrorAlertShow, error: error) { _ in
            Button("sys.ok") {
                isErrorAlertShow.toggle()
                error = nil
            }
        } message: { error in
            Text(error.localizedDescription)
        }
        .alert("setting.widget.background.manage.add.needname", isPresented: $isAskForNameAlertShow) {
            TextField("setting.widget.background.manage.add.name", text: $backgroundName)
                .foregroundColor(backgroundNameIsNotNamed ? .secondary : .primary)
                .onFocused {
                    if backgroundNameIsNotNamed {
                        backgroundName = ""
                    }
                }
            Button("sys.save") {
                guard backgroundName != "" else {
                    isNeedNameAlertShow.toggle()
                    return
                }
                let data = image!.resized()!.jpegData(compressionQuality: 0.8)!
                do {
                    // Check if name is existed
                    let fileManager = FileManager.default
                    let folderURL = try getFolderUrl()
                    let contents = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
                    guard contents.allSatisfy({ fileUrl in
                        fileUrl.lastPathComponent.deletingPathExtension != backgroundName
                    }) else {
                        isNameDuplicatedAlertShow.toggle()
                        return
                    }

                    // Save image data
                    let fileUrl = folderURL.appendingPathComponent(backgroundName, conformingTo: .png)
                    try data.write(to: fileUrl)
                    isShow.toggle()
                } catch {
                    self.error = .init(source: error)
                    isErrorAlertShow.toggle()
                }
            }
            Button("sys.cancel", role: .cancel) {
                isAskForNameAlertShow.toggle()
            }
        }
        .onAppear {
            // Set an default name for image
            var name: Int = 1
            let fileManager = FileManager.default
            guard let folderURL = try? getFolderUrl() else { return }
            while true {
                do {
                    let contents = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
                    let pendingName = "setting.widget.background.manage.add.notname".localized() + " " + "\(name)"
                    if contents.allSatisfy({ fileUrl in
                        fileUrl.lastPathComponent.deletingPathExtension != pendingName
                    }) {
                        backgroundName = pendingName
                        break
                    } else {
                        name += 1
                    }
                } catch {
                    print("Error while enumerating files \(folderURL.path): \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: Private

    @State private var image: UIImage?

    @State private var isEditImageCoverShow: Bool = false

    @State private var backgroundName: String = ""

    @State private var isPhotoPickerShow: Bool = true

    @State private var error: SaveBackgroundError?
    @State private var isErrorAlertShow: Bool = false

    @State private var isAskForNameAlertShow: Bool = false

    @State private var isNeedNameAlertShow: Bool = false
    @State private var isNameDuplicatedAlertShow: Bool = false

    private var ratio: Double {
        switch backgroundType {
        case .square:
            return 1.0
        case .rectangular:
            return 2.0
        }
    }

    private var backgroundNameIsNotNamed: Bool {
        backgroundName.starts(
            with: "setting.widget.background.manage.add.notname".localized()
        )
    }
}

// MARK: - BackgroundType

private enum BackgroundType {
    case square
    case rectangular
}

// MARK: - SaveBackgroundError

struct SaveBackgroundError {
    let source: Error
}

// MARK: LocalizedError

extension SaveBackgroundError: LocalizedError {
    var errorDescription: String? {
        source.localizedDescription
    }
}

// MARK: - ContainBackgroundType

private protocol ContainBackgroundType {
    var backgroundType: BackgroundType { get }
}

extension ContainBackgroundType {
    func getFolderUrl() throws -> URL {
        try Self.getFolderUrl(backgroundType: backgroundType)
    }

    static func getFolderUrl(backgroundType: BackgroundType) throws -> URL {
        let folderName: String
        switch backgroundType {
        case .square:
            folderName = AppConfig.squareBackgroundImageFolderName
        case .rectangular:
            folderName = AppConfig.rectangularBackgroundImageFolderName
        }
        return try WidgetBackgroundOptionsProvider.documentBackgroundFolderUrl(folderName: folderName)
    }

    func getSize() -> CGSize {
        switch backgroundType {
        case .square:
            return CGSize(width: 158, height: 158)
        case .rectangular:
            return CGSize(width: 338, height: 158)
        }
    }
}

// MARK: - BackgroundPreviewView

private struct BackgroundPreviewView: View, ContainBackgroundType {
    let imageName: String
    let image: UIImage
    let backgroundType: BackgroundType

    var body: some View {
        Section {
            VStack {
                Spacer()
                HStack {
                    HStack(spacing: 5) {
                        Image("Item_Trailblaze_Power")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 27)
                            .shadow(radius: 10)
                        HStack(alignment: .lastTextBaseline, spacing: 3) {
                            Text("\(60)")
                                .font(.title)
                                .shadow(radius: 10)
                            (
                                Text(Date(timeIntervalSinceNow: (180 - 60) * 6 * 60), style: .time)
                                    + Text("\n")
                                    + Text(Date(timeIntervalSinceNow: (180 - 60) * 6 * 60), style: .relative)
                            )
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.5)
                            .font(.caption2)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        .ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 15, style: .continuous)
                    )
                    Spacer()
                }
            }
            .padding(10)
        }
        .frame(getSize())
        .background {
            VStack {
                HStack {
                    WidgetAccountCard(
                        accountName: imageName,
                        useAccessibilityBackground: true
                    )
                    Spacer()
                }
                Spacer()
            }
            .padding(10)
        }
        .background {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .clipped()
                .ignoresSafeArea()
        }
        .ignoresSafeArea(edges: [.top, .bottom])
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .contentShape(RoundedRectangle(
            cornerRadius: 20,
            style: .continuous
        ))
        .listRowBackground(Color.clear)
    }
}

extension View {
    func frame(_ size: CGSize) -> some View {
        frame(width: size.width, height: size.height)
    }
}

// MARK: - ImagePickerView

private struct ImagePickerView: UIViewControllerRepresentable {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        // MARK: Lifecycle

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        // MARK: Internal

        let parent: ImagePickerView

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>)
        -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: UIViewControllerRepresentableContext<ImagePickerView>
    ) {}
}

/// An extension of `UIImage` to add functionality of resizing images.
extension UIImage {
    /// Resizes the image to a specified width and height.
    /// - Parameters:
    ///     - width: The width to resize the image to.
    ///     - isOpaque: A boolean indicating whether the resulting image should be opaque or not.
    /// - Returns: A `UIImage` object representing the resized image.
    fileprivate func resized(toWidth width: CGFloat = 860, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width / size.width * size.height)))
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(
            size: canvas,
            format: format
        )
        .image { _ in
            draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
