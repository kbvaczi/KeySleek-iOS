//
//  ImageCropRow.swift
//  barcodeManager
//
//  Created by Kenneth Vaczi on 2/17/19.
//  Copyright © 2019 Vaczoway Solutions. All rights reserved.
//

import Eureka
import Foundation
import IGRPhotoTweaks

public struct ImageCropRowSourceTypes: OptionSet {
    public let rawValue: Int
    public var imagePickerControllerSourceTypeRawValue: Int { return self.rawValue >> 1 }

    public init(rawValue: Int) { self.rawValue = rawValue }
    init(_ sourceType: UIImagePickerController.SourceType) { self.init(rawValue: 1 << sourceType.rawValue) }

    public static let PhotoLibrary = ImageCropRowSourceTypes(.photoLibrary)
    public static let Camera = ImageCropRowSourceTypes(.camera)
    public static let All: ImageCropRowSourceTypes = [Camera, PhotoLibrary]
}

public extension ImageCropRowSourceTypes {
    var localizedString: String {
        switch self {
        case ImageCropRowSourceTypes.Camera:
            return NSLocalizedString("Take photo", comment: "")
        case ImageCropRowSourceTypes.PhotoLibrary:
            return NSLocalizedString("Photo Library", comment: "")
        default:
            return ""
        }
    }
}

public enum ImageClearAction {
    case no
    case yes(style: UIAlertAction.Style)
}


protocol ImageRowProtocol {
    var placeholderImage: UIImage? { get }
}

open class _ImageCropRow<Cell: CellType>: OptionsRow<Cell>, PresenterRowType, ImageRowProtocol where Cell: BaseCell, Cell.Value == UIImage {

    public typealias PresenterRow = ImageCropPickerController

    /// Defines how the view controller will be presented, pushed, etc.
    open var presentationMode: PresentationMode<PresenterRow>?

    /// Will be called before the presentation occurs.
    open var onPresentCallback: ((FormViewController, PresenterRow) -> Void)?

    open var sourceTypes: ImageCropRowSourceTypes
    open var imageToCrop: UIImage?
    open var clearAction = ImageClearAction.yes(style: .destructive)
    open var placeholderImage: UIImage?

    open var userPickerInfo : [UIImagePickerController.InfoKey:Any]?
    open var allowEditor : Bool
    open var useEditedImage : Bool

    private var _sourceType: UIImagePickerController.SourceType = .camera

    public required init(tag: String?) {
        sourceTypes = .All
        userPickerInfo = nil
        allowEditor = false
        useEditedImage = false

        super.init(tag: tag)

        presentationMode = .presentModally(controllerProvider: ControllerProvider.callback { return ImageCropPickerController() }, onDismiss: { [weak self] vc in
            self?.select()
            vc.dismiss(animated: false)
            if self?.imageToCrop != nil {
                self?.displayImageCropController()
            }
        })

        self.displayValueFor = nil
    }

    // copy over the existing logic from the SelectorRow
    func displayImagePickerController(_ sourceType: UIImagePickerController.SourceType) {
        if let presentationMode = presentationMode, !isDisabled {
            if let controller = presentationMode.makeController(){
                controller.row = self
                controller.sourceType = sourceType
                controller.title = selectorTitle ?? controller.title
                controller.onDismissCallback = presentationMode.onDismissCallback ?? controller.onDismissCallback
                onPresentCallback?(cell.formViewController()!, controller)
                presentationMode.present(controller, row: self, presentingController: cell.formViewController()!)
            } else {
                _sourceType = sourceType
                presentationMode.present(nil, row: self, presentingController: cell.formViewController()!)
            }
        }
    }
    
    /// Display view to crop image once selected by picker
    func displayImageCropController() {
        let cropPresentationMode = PresentationMode.presentModally(controllerProvider: ControllerProvider.callback { return ImageCropViewController() }, onDismiss: nil)
        if let controller = cropPresentationMode.makeController(), !isDisabled {
            controller.image = self.imageToCrop
            controller.delegate = self
            cropPresentationMode.present(controller, row: self, presentingController: cell.formViewController()!)
        }
    }

    /// Extends `didSelect` method
    /// Selecting the Image Row cell will open a popup to choose where to source the photo from,
    /// based on the `sourceTypes` configured and the available sources.
    open override func customDidSelect() {
        guard !isDisabled else {
            super.customDidSelect()
            return
        }
        deselect()
        selectSource()
    }

    open func selectSource() {
        var availableSources: ImageCropRowSourceTypes = []

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let _ = availableSources.insert(.PhotoLibrary)
        }
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let _ = availableSources.insert(.Camera)
        }

        sourceTypes.formIntersection(availableSources)

        if sourceTypes.isEmpty {
            super.customDidSelect()
            guard let presentationMode = presentationMode else { return }

            if let controller = presentationMode.makeController() {
                controller.row = self
                controller.title = selectorTitle ?? controller.title
                onPresentCallback?(cell.formViewController()!, controller)
                presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
            } else {
                presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
            }

            return
        }

        // Now that we know the number of sources aren't empty, let the user select the source
        let sourceActionSheet = UIAlertController(title: nil, message: selectorTitle, preferredStyle: .actionSheet)

        guard let tableView = cell.formViewController()?.tableView  else { fatalError() }

        if let popView = sourceActionSheet.popoverPresentationController {
            popView.sourceView = tableView
            popView.sourceRect = tableView.convert(cell.accessoryView?.frame ?? cell.contentView.frame, from: cell)
        }

        createOptionsForAlertController(sourceActionSheet)

        if case .yes(let style) = clearAction, value != nil {
            let clearPhotoOption = UIAlertAction(title: NSLocalizedString("Clear Photo", comment: ""), style: style) { [weak self] _ in
                self?.value = nil
                self?.imageToCrop = nil
                self?.updateCell()
            }

            sourceActionSheet.addAction(clearPhotoOption)
        }

        if sourceActionSheet.actions.count == 1 {
            if let imagePickerSourceType = UIImagePickerController.SourceType(rawValue: sourceTypes.imagePickerControllerSourceTypeRawValue) {
                displayImagePickerController(imagePickerSourceType)
            }
        } else {
            let cancelOption = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)

            sourceActionSheet.addAction(cancelOption)

            if let presentingViewController = cell.formViewController() {
                presentingViewController.present(sourceActionSheet, animated: true)
            }
        }
    }

}

public extension _ImageCropRow {
    func createOptionForAlertController(_ alertController: UIAlertController, sourceType: ImageCropRowSourceTypes) {
        guard let pickerSourceType = UIImagePickerController.SourceType(rawValue: sourceType.imagePickerControllerSourceTypeRawValue), sourceTypes.contains(sourceType) else { return }

        let option = UIAlertAction(title: NSLocalizedString(sourceType.localizedString, comment: ""), style: .default) { [weak self] _ in
            self?.displayImagePickerController(pickerSourceType)
        }

        alertController.addAction(option)
    }

    func createOptionsForAlertController(_ alertController: UIAlertController) {
        createOptionForAlertController(alertController, sourceType: .Camera)
        createOptionForAlertController(alertController, sourceType: .PhotoLibrary)
    }
}

extension _ImageCropRow: IGRPhotoTweakViewControllerDelegate {
    
    public func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        self.value = croppedImage
        self.updateCell()
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
        self.value = controller.image
        self.updateCell()
        controller.dismiss(animated: true, completion: nil)
    }
    
}

/// A selector row where the user can pick an image
public final class ImageCropRow: _ImageCropRow<ImageCropCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
