//
//  ViewController.swift
//  annotator
//
//  Created by Kumar Aman on 26/02/24.
//

import UIKit

// MARK: - Main View Controller
class ViewController: UIViewController {

    // MARK: Properties
    var drawableImageFrame: CGRect = .zero
    @IBOutlet weak var drawingView: DrawingView!
    @IBOutlet weak var imageView: UIImageView!
    var controlPanelView: ControlPanelView!

    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViews()
    }
    
    // MARK: Initialization
    private func initializeViews() {
        configureDrawingView()
        configureControlPanelView()
    }
    
    private func configureDrawingView() {
        drawingView.backgroundColor = .clear
    }
    
    private func configureControlPanelView() {
        controlPanelView = ControlPanelView()
        controlPanelView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controlPanelView)
        setupControlPanelViewConstraints()
        setupControlPanelActions()
        updateControlPanelVisibility(imageLoaded: false)
    }
    
    // MARK: Control Panel Setup
    private func setupControlPanelViewConstraints() {
        NSLayoutConstraint.activate([
            controlPanelView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            controlPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlPanelView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupControlPanelActions() {
        controlPanelView.undoButton.addTarget(self, action: #selector(undoAction), for: .touchUpInside)
        controlPanelView.redoButton.addTarget(self, action: #selector(redoAction), for: .touchUpInside)
        controlPanelView.colorPickerButton.addTarget(self, action: #selector(colorPickerAction), for: .touchUpInside)
        controlPanelView.saveButton.addTarget(self, action: #selector(saveImageAction), for: .touchUpInside)
    }
    
    // MARK: Control Panel Actions
    @objc private func undoAction() {
        drawingView.undo()
    }
    
    @objc private func redoAction() {
        drawingView.redo()
    }
    
    @objc private func colorPickerAction() {
        presentColorPicker()
    }
    
    @objc private func saveImageAction() {
        guard let imageToSave = captureImageWithDrawing() else { return }
        UIImageWriteToSavedPhotosAlbum(imageToSave, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // MARK: Image Handling
    private func updateDrawableImageFrame() {
        drawableImageFrame = imageView.calculateAspectFitFrame()
        drawingView.drawableImageFrame = drawableImageFrame
    }
    
    private func updateControlPanelVisibility(imageLoaded: Bool) {
        controlPanelView.isHidden = !imageLoaded
    }
    
    private func captureImageWithDrawing() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        drawingView.layer.render(in: context)
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return combinedImage
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved successfully")
        }
    }
    
    // MARK: Color Picker Presentation
    private func presentColorPicker() {
        let colorPickerVC = UIColorPickerViewController()
        colorPickerVC.delegate = self
        colorPickerVC.selectedColor = drawingView.currentColor
        present(colorPickerVC, animated: true, completion: nil)
    }
}

// MARK: - Image Picker Controller Delegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            drawingView.clearDrawing()
            updateDrawableImageFrame()
            updateControlPanelVisibility(imageLoaded: true)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pickImageTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - Color Picker View Controller Delegate
extension ViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        drawingView.setStrokeColor(viewController.selectedColor)
    }
}

// MARK: - UIImageView Extension for Aspect Fit Frame Calculation
extension UIImageView {
    func calculateAspectFitFrame() -> CGRect {
        guard let imageSize = self.image?.size else { return .zero }
        let imageAspectRatio = imageSize.width / imageSize.height
        let viewAspectRatio = self.bounds.width / self.bounds.height
        var imageFrame = CGRect.zero
        
        if imageAspectRatio < viewAspectRatio {
            let scale = self.bounds.height / imageSize.height
            let width = scale * imageSize.width
            let xOffset = (self.bounds.width - width) / 2
            imageFrame = CGRect(x: xOffset, y: 0, width: width, height: self.bounds.height)
        } else {
            let scale = self.bounds.width / imageSize.width
            let height = scale * imageSize.height
            let yOffset = (self.bounds.height - height) / 2
            imageFrame = CGRect(x: 0, y: yOffset, width: self.bounds.width, height: height)
        }
        
        return imageFrame
    }
}


