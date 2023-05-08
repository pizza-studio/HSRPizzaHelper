//
//  ManageWidgetBackgroundView.swift
//  HSRPizzaHelper
//
//  Created by 戴藏龙 on 2023/5/8.
//

import PhotosUI
import SwiftUI

// MARK: - WidgetBackgroundSettingView

@available(iOS 16.0, *)
struct WidgetBackgroundSettingView: View {
    var body: some View {
        List {
            NavigationLink("setting.widgetbackground.destination.square") {
                ManageWidgetBackgroundView(backgroundType: .square)
            }
            NavigationLink("setting.widgetbackground.destination.rectangular") {
                ManageWidgetBackgroundView(backgroundType: .rectangular)
            }
        }
    }
}

// MARK: - ManageWidgetBackgroundView

@available(iOS 16.0, *)
private struct ManageWidgetBackgroundView: View, ContainBackgroundType {
    // MARK: Internal

    let backgroundType: BackgroundType

    @State var imageUrls: [URL] = []

    var body: some View {
        List {
            Section {
                Button("setting.widgetbackground.manage.add.title") {
                    isAddBackgroundSheetShow.toggle()
                }
                .sheet(isPresented: $isAddBackgroundSheetShow) {
                    AddWidgetBackgroundSheet(backgroundType: backgroundType, isShow: $isAddBackgroundSheetShow)
                }
            }
            ForEach(imageUrls, id: \.self) { url in
                if let data = try? Data(contentsOf: url),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(
                            getRatio(),
                            contentMode: .fill
                        )
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .contentShape(RoundedRectangle(
                            cornerRadius: 20,
                            style: .continuous
                        ))
                        .listRowBackground(Color.white.opacity(0))
                }
            }
        }
        .onChange(of: isAddBackgroundSheetShow, perform: { newValue in
            if newValue == false {
                reloadImage()
            }
        })
        .onAppear {
            reloadImage()
        }
    }

    func reloadImage() {
        imageUrls = (
            try? WidgetBackgroundOptionsProvider
                .getWidgetBackgroundUrlsFromFolder(in: getFolderUrl())
        ) ?? []
    }

    // MARK: Private

    @State private var isAddBackgroundSheetShow: Bool = false
}

// MARK: - AddWidgetBackgroundSheet

@available(iOS 16.0, *)
private struct AddWidgetBackgroundSheet: View, ContainBackgroundType {
    // MARK: Internal

    let backgroundType: BackgroundType

    @Binding var isShow: Bool

    var image: UIImage? {
        if let selectedPhotoData {
            return UIImage(data: selectedPhotoData)
        } else {
            return nil
        }
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    Button("setting.widgetbackground.manage.reselect") {
                        isPhotoPickerShow.toggle()
                    }
                }
                if let image {
                    Section {
                        HStack {
                            Text("setting.widgetbackground.manage.add.name")
                            Spacer()
                            TextField(
                                "setting.widgetbackground.manage.add.name",
                                text: $backgroundName
                            )
                            .multilineTextAlignment(.trailing)
                        }
                    }
                    Section {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(
                                getRatio(),
                                contentMode: .fill
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .contentShape(RoundedRectangle(
                                cornerRadius: 20,
                                style: .continuous
                            ))
                            .listRowBackground(Color.white.opacity(0))
                    } header: {
                        Text("setting.widgetbackground.manage.add.preview")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("sys.save") {
                        guard backgroundName != "" else {
                            isNeedNameAlertShow.toggle()
                            return
                        }
                        let image = image!
                        let data = image.pngData()!
                        do {
                            let fileUrl = try getFolderUrl().appendingPathComponent(backgroundName, conformingTo: .png)
                            try data.write(to: fileUrl)
                            isShow.toggle()
                        } catch {
                            self.error = .init(source: error)
                            isErrorAlertShow.toggle()
                        }
                    }
                    .disabled(image == nil)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("sys.cancel") {
                        isShow.toggle()
                    }
                }
            }
            .navigationTitle("setting.widgetbackground.manage.add.title")
            .navigationBarTitleDisplayMode(.inline)
        }
        .photosPicker(
            isPresented: $isPhotoPickerShow,
            selection: $selectedPhotoItem,
            matching: .images
        )
        .onChange(of: selectedPhotoItem) { newItem in
            Task {
                do {
                    if let data = try await newItem?.loadTransferable(type: Data.self) {
                        selectedPhotoData = data
                    }
                } catch {
                    self.error = .init(source: error)
                }
            }
        }
        .alert("setting.widgetbackground.manage.add.needname", isPresented: $isNeedNameAlertShow, actions: {
            Button("sys.ok") {
                isNeedNameAlertShow.toggle()
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
    }

    // MARK: Private

    @State private var backgroundName: String = ""

    @State private var isPhotoPickerShow: Bool = true

    @State private var selectedPhotoItem: PhotosPickerItem?

    @State private var selectedPhotoData: Data?

    @State private var error: SaveBackgroundError?
    @State private var isErrorAlertShow: Bool = false

    @State private var isNeedNameAlertShow: Bool = false
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

    func getRatio() -> CGSize {
        switch backgroundType {
        case .square:
            return CGSize(width: 1, height: 1)
        case .rectangular:
            return CGSize(width: 1, height: 0.48)
        }
    }
}