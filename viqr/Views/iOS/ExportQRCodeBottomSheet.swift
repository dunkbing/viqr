//
//  ExportQRCodeBottomSheet.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 23/3/25.
//

import Photos
import QRCode
import SwiftUI
import TikimUI

#if os(iOS)
    struct ExportQRCodeBottomSheet: View {
        @Binding var isPresented: Bool
        @Binding var exportFileName: String
        @Binding var selectedExportFormat: QRCodeExportFormat
        @Binding var exportedFileURL: URL?
        let qrDocument: QRCode.Document
        @State private var showExportSuccess = false
        @State private var exportSuccessMessage = ""
        @State private var showExportError = false
        @State private var exportErrorMessage = ""

        @State private var cachedQRImage: UIImage? = nil

        var body: some View {
            VStack(spacing: 20) {
                Text("Export QR Code Image")
                    .font(.headline)
                    .foregroundColor(Color.appText)
                    .padding(.top, 8)

                if let cachedImage = cachedQRImage {
                    Image(uiImage: cachedImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }

                // Filename field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Filename")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)

                    TextField("Enter a filename", text: $exportFileName)
                        .padding()
                        .background(Color.appSurface.opacity(0.5))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appAccent.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Format")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)
                        .padding(.horizontal)

                    TabPickerView(
                        selection: $selectedExportFormat,
                        options: [
                            (value: QRCodeExportFormat.png, title: "PNG"),
                            (value: QRCodeExportFormat.svg, title: "SVG"),
                            (value: QRCodeExportFormat.pdf, title: "PDF"),
                        ]
                    )
                    .padding(.horizontal)
                }

                // Export destination info
                HStack {
                    Image(systemName: selectedExportFormat == .png ? "photo" : "folder")
                        .foregroundColor(Color.appSubtitle)

                    Text(
                        selectedExportFormat == .png ? "Will save to Photos" : "Will save to Files"
                    )
                    .font(.caption)
                    .foregroundColor(Color.appSubtitle)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, -4)

                // Action buttons
                HStack(spacing: 16) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Cancel")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.appRed.opacity(0.1))
                            .foregroundColor(Color.appRed)
                            .cornerRadius(16)
                    }

                    Button(action: {
                        exportToFiles()
                    }) {
                        Text("Export")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                exportFileName.isEmpty
                                    ? Color.appGreen.opacity(0.5) : Color.appGreen
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .disabled(exportFileName.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .padding(.top, 4)
            .onAppear {
                generateQRImage()
            }
            .alert("Export Successful", isPresented: $showExportSuccess) {
                Button("OK") {
                    isPresented = false
                }
            } message: {
                Text(exportSuccessMessage)
            }
            .alert("Export Failed", isPresented: $showExportError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(exportErrorMessage)
            }
        }

        private func generateQRImage() {
            do {
                // Generate the image once and store it
                if cachedQRImage == nil {
                    let imageData = try qrDocument.pngData(dimension: 150)
                    cachedQRImage = UIImage(data: imageData)
                }
            } catch {
                print("Error generating QR image preview: \(error)")
            }
        }

        // In ExportQRCodeBottomSheet.swift
        private func exportToFiles() {
            do {
                var data: Data?

                switch selectedExportFormat {
                case .svg:
                    data = try qrDocument.svgData(dimension: 1024)
                case .pdf:
                    data = try qrDocument.pdfData(dimension: 1024)
                case .png:
                    data = try qrDocument.pngData(dimension: 1024)
                }

                if let data = data {
                    let fileName = exportFileName.isEmpty ? "QRCode" : exportFileName
                    let tempDir = FileManager.default.temporaryDirectory
                    let fileURL = tempDir.appendingPathComponent(fileName)
                        .appendingPathExtension(selectedExportFormat.fileExtension)

                    try data.write(to: fileURL)

                    // Use UIKit's activity view controller directly
                    presentShareSheet(with: fileURL)
                }
            } catch {
                exportErrorMessage = "Error: \(error.localizedDescription)"
                showExportError = true
            }
        }

        private func presentShareSheet(with url: URL) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let rootViewController = windowScene.windows.first?.rootViewController
            else {
                print("Could not find root view controller")
                return
            }

            // Create the activity view controller
            let activityViewController = UIActivityViewController(
                activityItems: [url],
                applicationActivities: nil
            )

            // Present it
            activityViewController.completionWithItemsHandler = { _, _, _, _ in
                // Clean up after sharing is done
            }

            // For iPad, set the sourceView and sourceRect to prevent app crash
            if let popoverController = activityViewController.popoverPresentationController {
                popoverController.sourceView = rootViewController.view
                popoverController.sourceRect = CGRect(
                    x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0,
                    height: 0)
                popoverController.permittedArrowDirections = []
            }

            rootViewController.present(activityViewController, animated: true)
        }
    }
#endif
