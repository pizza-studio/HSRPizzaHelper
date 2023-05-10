//
//  ImageCroper.swift
//  HSRPizzaHelper
//
//  Created by Bill Haku on 2023/5/10.
//

import Mantis
import SwiftUI

// MARK: - ImageCropperType

enum ImageCropperType {
    case normal
    case noRotaionDial
    case noAttachedToolbar
}

// MARK: - ImageCropper

struct ImageCropper: UIViewControllerRepresentable {
    class Coordinator: CropViewControllerDelegate {
        // MARK: Lifecycle

        init(_ parent: ImageCropper) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: ImageCropper

        func cropViewControllerDidFailToCrop(_ cropViewController: Mantis.CropViewController, original: UIImage) {}

        func cropViewControllerDidBeginResize(_ cropViewController: Mantis.CropViewController) {}

        func cropViewControllerDidEndResize(
            _ cropViewController: Mantis.CropViewController,
            original: UIImage,
            cropInfo: Mantis.CropInfo
        ) {}

        func cropViewControllerDidCrop(
            _ cropViewController: Mantis.CropViewController,
            cropped: UIImage,
            transformation: Transformation,
            cropInfo: CropInfo
        ) {
            parent.image = cropped
            print("transformation is \(transformation)")
            parent.presentationMode.wrappedValue.dismiss()
        }

        func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    @Binding var image: UIImage?
    @Binding var cropShapeType: Mantis.CropShapeType
    @Binding var presetFixedRatioType: Mantis.PresetFixedRatioType
    @Binding var type: ImageCropperType

    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
//        switch type {
//        case .normal:
        makeNormalImageCropper(context: context)
//        case .noRotaionDial:
//            return makeImageCropperHiddingRotationDial(context: context)
//        case .noAttachedToolbar:
//            return makeImageCropperWithoutAttachedToolbar(context: context)
//        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

extension ImageCropper {
    func makeNormalImageCropper(context: Context) -> UIViewController {
        var config = Mantis.Config()
//        config.cropViewConfig.cropShapeType = cropShapeType
        config.presetFixedRatioType = presetFixedRatioType
        let cropViewController = Mantis.cropViewController(
            image: image!,
            config: config
        )
        cropViewController.delegate = context.coordinator
        return cropViewController
    }

//    func makeImageCropperHiddingRotationDial(context: Context) -> UIViewController {
//        var config = Mantis.Config()
//        config.cropViewConfig.showRotationDial = false
//        let cropViewController = Mantis.cropViewController(image: image!, config: config)
//        cropViewController.delegate = context.coordinator
//
//        return cropViewController
//    }

//    func makeImageCropperWithoutAttachedToolbar(context: Context) -> UIViewController {
//        var config = Mantis.Config()
//        config.showAttachedCropToolbar = false
//        let cropViewController: CustomViewController = Mantis.cropViewController(image: image!, config: config)
//        cropViewController.delegate = context.coordinator
//
//        return UINavigationController(rootViewController: cropViewController)
//    }
}
