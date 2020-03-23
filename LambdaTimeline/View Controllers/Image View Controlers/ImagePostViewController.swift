//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins

// CIMaskedVariableBlur (use hard-coded defaults), CIGaussianBlur, CIColorControls, CIColorMatirx (use hard-coded defaults), CIExposureAdjust, CIHueAdjust

enum CurrentActiveFilter {
    case maskedBlur
    case contrast
    case hue
    case exposure
    case scaleTransform
}

class ImagePostViewController: ShiftableViewController {
    
        // MARK: - Properties
        private let context = CIContext()
        private let maskedBlurFilter = CIFilter.maskedVariableBlur()
        private let colorControlFilter = CIFilter.colorControls()
        private let hueAdjustFilter = CIFilter.hueAdjust()
        private let exposureAdjustFilter = CIFilter.exposureAdjust()
        private let scaleTransformFilter = CIFilter.lanczosScaleTransform()
        
        private var _filter = CurrentActiveFilter.exposure
        private var maskSliderValue: NSNumber = 0.00
        private var contrastSliderValue: NSNumber = 1.00
        private var hueSliderValue: NSNumber = 0.00
        private var exposureSliderValue: NSNumber = 0.50
        private var scaleTransformSliderValue: NSNumber = 1.00
        var postController: PostController!
        var post: Post?
        var imageData: Data?
    
    var geotagState: Bool = true
        
        private var selectedImage: UIImage? {
            didSet {
                guard let selectedImage = selectedImage else { return }
                
                var scaledSize = imageView.bounds.size
                let scale = UIScreen.main.scale
                
                scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
                
                let scaledUIImage = selectedImage.imageByScaling(toSize: scaledSize)
                guard let scaledCGImage = scaledUIImage?.cgImage else { return }
                
                scaledImage = CIImage(cgImage: scaledCGImage)
            }
        }
        
        private var scaledImage: CIImage? {
            didSet {
                updateImage()
            }
        }
        
        private var maskImage: CIImage? {
            let mask = #imageLiteral(resourceName: "swirl")
            guard let scaledImage = scaledImage else { return nil }
            guard (selectedImage != nil) else { return nil }
            var scaledSize = scaledImage.extent
            let scale = UIScreen.main.scale
            
            scaledSize = CGRect(x: 0, y: 0, width: scaledSize.width * scale, height: scaledSize.height * scale)
    //            CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            
            let scaledMaskImage = mask.imageByScaling(toSize: CGSize(width: scaledSize.width, height: scaledSize.height))
            guard let maskCGImage = scaledMaskImage?.cgImage else { return nil }
            return CIImage(cgImage: maskCGImage)
        }
        
        
        // MARK: - Outlets
        @IBOutlet weak var imageView: UIImageView!
        @IBOutlet weak var titleTextField: UITextField!
        @IBOutlet weak var chooseImageButton: UIButton!
        @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
        @IBOutlet weak var postButton: UIBarButtonItem!
        @IBOutlet weak var geotagSwitch: UISwitch!
    
        @IBOutlet weak var filterSlider: UISlider!
        @IBOutlet weak var maskButton: UIButton!
        @IBOutlet weak var contrastButton: UIButton!
        @IBOutlet weak var hueButton: UIButton!
        @IBOutlet weak var exposureButton: UIButton!
        @IBOutlet weak var colorButton: UIButton!
        
        
        
        // MARK: - View Controller Life Cycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setImageViewHeight(with: 1.0)
            titleTextField.delegate = self
            updateViews()
        }
        
        // MARK: - Actions
        @IBAction func adjustmentSlider(_ sender: UISlider) {
            updateImage()
        }
    
        @IBAction func toggleGeotag(_ sender: UISwitch) {
            geotagState.toggle()
        }
    
        // The buttons all set the enum to the appropriate filter setting and call update views
        //
        @IBAction func maskFilter(_ sender: UIButton) {
            _filter = CurrentActiveFilter.maskedBlur
            updateViews()
        }
        @IBAction func contrastFilter(_ sender: UIButton) {
            _filter = CurrentActiveFilter.contrast
            updateViews()
        }
        @IBAction func hueFilter(_ sender: UIButton) {
            _filter = CurrentActiveFilter.hue
            updateViews()
        }
        @IBAction func exposureFilter(_ sender: UIButton) {
            _filter = CurrentActiveFilter.exposure
            updateViews()
        }
        @IBAction func scaleFilter(_ sender: UIButton) {
            _filter = CurrentActiveFilter.scaleTransform
            updateViews()
        }
        
        
        // MARK: - Methods
        private func filterImage(for inputImage: CIImage) -> UIImage {
            
            scaleTransformFilter.inputImage = inputImage//?.clampedToExtent()
            scaleTransformFilter.aspectRatio = 1.00
            scaleTransformFilter.scale = Float(truncating: scaleTransformSliderValue)
            colorControlFilter.inputImage = scaleTransformFilter.outputImage
            colorControlFilter.contrast = Float(truncating: contrastSliderValue)
            hueAdjustFilter.inputImage = colorControlFilter.outputImage//?.clampedToExtent()
            hueAdjustFilter.angle = Float(truncating: hueSliderValue)
            maskedBlurFilter.inputImage = hueAdjustFilter.outputImage//?.clampedToExtent()
            maskedBlurFilter.mask = maskImage?.clampedToExtent()
            maskedBlurFilter.radius = Float(truncating: maskSliderValue)
            exposureAdjustFilter.inputImage = maskedBlurFilter.outputImage//?.clampedToExtent()
            exposureAdjustFilter.ev = Float(truncating: exposureSliderValue)
            
            guard let outputImage = exposureAdjustFilter.outputImage else { return UIImage(ciImage: inputImage)}
            guard let renderedImage = context.createCGImage(outputImage, from: CGRect(origin: CGPoint.zero, size: UIImage(ciImage: inputImage).size)) else { return UIImage(ciImage: inputImage)}
            
            return UIImage(cgImage: renderedImage)
        }
        
        // updateImage checks the current filter state enum and assigns the slider value to the appropriate filter variable.  It then sets the imageView.image to the filtered image and calls the height method.
        private func updateImage() {
            if let scaledImage = scaledImage,
            let _ = selectedImage {
                switch _filter {
                case .maskedBlur:
                    maskSliderValue = NSNumber(value: filterSlider.value)
                case .contrast:
                    contrastSliderValue = NSNumber(value: filterSlider.value)
                case .hue:
                    hueSliderValue = NSNumber(value: filterSlider.value)
                case .exposure:
                    exposureSliderValue = NSNumber(value: filterSlider.value)
                case .scaleTransform:
                    scaleTransformSliderValue = NSNumber(value: filterSlider.value)
                }
                imageView.image = filterImage(for: scaledImage)
            } else {
                imageView.image = nil
            }
        }
        
        func updateViews() {

            switch _filter {
            case .maskedBlur:
                filterSlider.minimumValue = 0.0
                filterSlider.maximumValue = 20.0
                filterSlider.value = 0.0
            case .contrast:
                filterSlider.minimumValue = 0.25
                filterSlider.maximumValue = 4.00
                filterSlider.value = 1.0
            case .hue:
                filterSlider.minimumValue = -3.14
                filterSlider.maximumValue = 3.14
                filterSlider.value = 0.0
            case .exposure:
                filterSlider.minimumValue = 0.0
                filterSlider.maximumValue = 1.0
                filterSlider.value = 0.5
            case .scaleTransform:
                filterSlider.minimumValue = 0.25
                filterSlider.maximumValue = 1.00
                filterSlider.value = 1.00
            }
            guard selectedImage != nil else { return }
        }
        
        @IBAction func createPost(_ sender: Any) {
            
            view.endEditing(true)
            
            guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
                let title = titleTextField.text, title != "" else {
                presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
                return
            }
            
            postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio, geotag: geotagState) { (success) in
                guard success else {
                    DispatchQueue.main.async {
                        self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        @IBAction func chooseImage(_ sender: Any) {
            
            let authorizationStatus = PHPhotoLibrary.authorizationStatus()
            
            switch authorizationStatus {
            case .authorized:
                presentImagePickerController()
            case .notDetermined:
                
                PHPhotoLibrary.requestAuthorization { (status) in
                    guard status == .authorized else {
                        NSLog("User did not authorize access to the photo library")
                        self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                        return
                    }
                    self.presentImagePickerController()
                }
                
            case .denied:
                self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
            case .restricted:
                self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            @unknown default:
                preconditionFailure("The app does not handle this new case provided by Apple")
            }
            presentImagePickerController()
        }
        
        private func presentImagePickerController() {
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
                return
            }
            DispatchQueue.main.async {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        func setImageViewHeight(with aspectRatio: CGFloat) {
            if 375 < imageView.frame.size.width {
                imageHeightConstraint.constant = 375
            } else {
            imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
            }
            view.layoutSubviews()
        }
    }

    extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            chooseImageButton.setTitle("", for: [])
            picker.dismiss(animated: true, completion: nil)
        
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            selectedImage = image
    //        setImageViewHeight(with: image.ratio)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
