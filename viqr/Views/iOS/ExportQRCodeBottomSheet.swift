//
//  ExportQRCodeBottomSheet.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 23/3/25.
//

import Photos
import QRCode
import SwiftUI

#if os(iOS)
    struct ExportQRCodeBottomSheet: View {
        @Binding var isPresented: Bool
        @Binding var exportFileName: String
        @Binding var selectedExportFormat: QRCodeExportFormat
        @Binding var showingShareSheet: Bool
        @Binding var exportedFileURL: URL?
        let qrDocument: QRCode.Document
        @FocusState private var isTextFieldFocused: Bool
        @State private var showExportSuccess = false
        @State private var exportSuccessMessage = ""
        @State private var showExportError = false
        @State private var exportErrorMessage = ""

        var body: some View {
            VStack(spacing: 20) {
                Text("Export QR Code Image")
                    .font(.headline)
                    .foregroundColor(Color.appText)
                    .padding(.top, 8)

                // QR Code preview
                if let uiImage = try? qrDocument.uiImage(CGSize(width: 150, height: 150)) {
                    Image(uiImage: uiImage)
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
                        .focused($isTextFieldFocused)
                        .padding()
                        .background(Color.appSurface.opacity(0.5))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appAccent.opacity(0.3), lineWidth: 1)
                        )
                        .onAppear {
                            // Focus the text field when the sheet appears
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isTextFieldFocused = true
                            }
                        }
                }
                .padding(.horizontal)

                // Format picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Format")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)
                        .padding(.horizontal)

                    Picker("Format", selection: $selectedExportFormat) {
                        Text("PNG").tag(QRCodeExportFormat.png)
                        Text("SVG").tag(QRCodeExportFormat.svg)
                        Text("PDF").tag(QRCodeExportFormat.pdf)
                    }
                    .pickerStyle(SegmentedPickerStyle())
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
                        exportQRCode()
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

        private func exportQRCode() {
            if selectedExportFormat == .png {
                // Export to Photos
                exportToPNG()
            } else {
                // Export to Files
                exportToFiles()
            }
        }

        private func exportToPNG() {
            // Request permission to access Photos
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        do {
                            let imageData = try qrDocument.pngData(dimension: 1024)
                            let imageWrapped = UIImage(data: imageData)
                            if let image = imageWrapped {
                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                exportSuccessMessage =
                                    "QR Code has been saved to your Photos library"
                                showExportSuccess = true
                            } else {
                                exportErrorMessage = "Failed to create image data"
                                showExportError = true
                            }
                        } catch {
                            exportErrorMessage = "Error: \(error.localizedDescription)"
                            showExportError = true
                        }
                    } else {
                        exportErrorMessage = "Permission denied to access Photos"
                        showExportError = true
                    }
                }
            }
        }

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
                    let fileURL = tempDir.appendingPathComponent(fileName).appendingPathExtension(
                        selectedExportFormat.fileExtension)

                    try data.write(to: fileURL)
                    exportedFileURL = fileURL
                    isPresented = false
                    showingShareSheet = true
                }
            } catch {
                exportErrorMessage = "Error: \(error.localizedDescription)"
                showExportError = true
            }
        }
    }
#endif
