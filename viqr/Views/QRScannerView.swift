//
//  QRScannerView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI
import AVFoundation

#if os(iOS)
class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var onCodeFound: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Check camera authorization status
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCaptureSession()
                    }
                }
            }
        default:
            showNoCameraAccessAlert()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if captureSession?.isRunning == false {
            captureSession?.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
    }

    private func setupCaptureSession() {
        let captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        self.captureSession = captureSession
        self.previewLayer = previewLayer

        captureSession.startRunning()
    }

    private func failed() {
        let alertController = UIAlertController(
            title: "Scanning Not Supported",
            message: "Your device does not support scanning a code. Please use a device with a camera.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)

        captureSession = nil
    }

    private func showNoCameraAccessAlert() {
        let alertController = UIAlertController(
            title: "Camera Access Required",
            message: "Please allow camera access to scan QR codes.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }

    // MARK: - AVCaptureMetadataOutputObjectsDelegate

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let stringValue = metadataObject.stringValue else {
            return
        }

        // Stop capturing
        captureSession?.stopRunning()

        // Call the completion handler with the scanned code
        onCodeFound?(stringValue)
    }
}

struct QRCodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    var isScanning: Bool

    func makeUIViewController(context: Context) -> QRScannerController {
        let controller = QRScannerController()
        controller.onCodeFound = { code in
            scannedCode = code
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerController, context: Context) {
        if isScanning {
            uiViewController.captureSession?.startRunning()
        } else {
            uiViewController.captureSession?.stopRunning()
        }
    }
}

struct ScannerView: View {
    @State private var scannedCode: String?
    @State private var isScanning = true
    @State private var showScannedResult = false

    var body: some View {
        ZStack {
            QRCodeScannerView(scannedCode: $scannedCode, isScanning: isScanning)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 250, height: 250)

                    // Scanner Corner UI
                    VStack {
                        HStack {
                            Image(systemName: "l.square")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .rotationEffect(.degrees(180))
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "l.square")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .rotationEffect(.degrees(270))
                                .foregroundColor(.white)
                        }
                        .frame(width: 250)

                        Spacer()

                        HStack {
                            Image(systemName: "l.square")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .rotationEffect(.degrees(90))
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "l.square")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                        }
                        .frame(width: 250)
                    }
                    .frame(width: 250, height: 250)
                }

                Spacer()

                Text("Position QR code within the scanner frame")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)

                Spacer()
            }
        }
        .alert(isPresented: $showScannedResult) {
            Alert(
                title: Text("Scanned QR Code"),
                message: Text(scannedCode ?? "No data found"),
                primaryButton: .default(Text("Copy")) {
                    if let code = scannedCode {
                        #if os(iOS)
                        UIPasteboard.general.string = code
                        #endif
                    }
                    isScanning = true
                },
                secondaryButton: .default(Text("Scan Again")) {
                    isScanning = true
                }
            )
        }
        .onChange(of: scannedCode) { _ in
            if scannedCode != nil {
                isScanning = false
                showScannedResult = true
            }
        }
    }
}
#endif

struct ScannerPlaceholderView: View {
    var body: some View {
        VStack {
            Image(systemName: "qrcode.viewfinder")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)

            Text("QR Code Scanner")
                .font(.title)
                .padding()

            Text("Camera access is not supported in the macOS simulator.")
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
