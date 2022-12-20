//
//  SelfieViewController.swift
//  MapsApp
//
//  Created by Polina Tikhomirova on 20.12.2022.
//

import UIKit
import AVFoundation

class SelfieViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        
        let cameraOutput = makeCameraOutput()
        self.cameraOutput = cameraOutput
    }
    
    private(set) lazy var imageView: UIImageView = {
        var imageView = UIImageView()
        
        
        return imageView
    }()
    
    var image: UIImage?
    var onTakePicture: ((UIImage) -> Void)?
    var captureSession: AVCaptureSession?
    var cameraOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var deviceOrientationOnCapture: UIDeviceOrientation?
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        previewLayer?.frame = view.layer.bounds
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if previewLayer?.connection?.isVideoOrientationSupported == true {
            previewLayer?.connection?.videoOrientation = UIDevice.current.orientation.getAVCaptureVideoOrientationFromDevice()
        }
    }
    
    func makeCameraOutput() -> AVCapturePhotoOutput {
        let cameraOutput = AVCapturePhotoOutput()
        cameraOutput.isHighResolutionCaptureEnabled = true
        cameraOutput.isLivePhotoCaptureEnabled = false
        
        return cameraOutput
    }
    
    func makeCameraSession(cameraOutput: AVCapturePhotoOutput) -> AVCaptureSession? {
        let captureSession = AVCaptureSession()
        let device = cameraDeviceFind()
        guard
            let input = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(input)
        else { return nil }
        captureSession.addInput(input)
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        captureSession.addOutput(cameraOutput)
        
        return captureSession
    }
    
    func configurePreviewLayer(_ captureSession: AVCaptureSession, _ cameraOutput: AVCapturePhotoOutput) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.insertSublayer(previewLayer, at: 0)
        previewLayer.frame = view.layer.bounds
        self.previewLayer = previewLayer
    }
    
    func cameraDeviceFind() -> AVCaptureDevice {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .front)
        let devices = discoverySession.devices
        guard let device = devices.first(where: { $0.hasMediaType(AVMediaType.video) && $0.position == .front }) else { return devices.first ?? devices[0] }
        
        return device
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SelfieViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard
            let imageData = photo.fileDataRepresentation(),
            let image = UIImage(data: imageData),
            let cgImage = image.cgImage,
            let deviceOrientationOnCapture = self.deviceOrientationOnCapture
        else { return }
        
        let image1 = UIImage(
            cgImage: cgImage,
            scale: 1.0,
            orientation: deviceOrientationOnCapture.getUIImageOrientationFromDevice())
        onTakePicture?(image1)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        deviceOrientationOnCapture = UIDevice.current.orientation
    }
}

fileprivate extension UIDeviceOrientation {
    func getUIImageOrientationFromDevice() -> UIImage.Orientation {
        let orientation: UIImage.Orientation
        switch self {
        case .portrait, .faceUp:
            orientation = .right
        case .portraitUpsideDown, .faceDown:
            orientation = .left
        case .landscapeLeft:
            orientation = .down
        case .landscapeRight:
            orientation = .up
        case .unknown:
            orientation = .down
        @unknown default:
            fatalError("fatal error")
        }
        return orientation
    }
    
    func getAVCaptureVideoOrientationFromDevice() -> AVCaptureVideoOrientation {
        let orientation: AVCaptureVideoOrientation
        switch self {
        case .portrait,
        .faceUp:
        orientation = .portrait
        case .portraitUpsideDown, .faceDown:
        orientation = .portraitUpsideDown case .landscapeLeft:
        orientation = .landscapeRight case .landscapeRight:
        orientation = .landscapeLeft case .unknown:
        orientation = .landscapeLeft }
        return orientation
    }
}


