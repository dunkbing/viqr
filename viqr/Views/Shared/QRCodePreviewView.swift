//
//  QRCodePreviewView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import QRCode
import SwiftUI

#if os(iOS) && canImport(UIKit)
    import UIKit
#endif

struct QRCodePreviewView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    @State private var selectedExportFormat: QRCodeExportFormat = .png
    @State private var exportFileName: String = "QRCode"
    @State private var showingExportSheet = false
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL? = nil

    var body: some View {
        #if os(iOS) && canImport(UIKit)
            // Simplified iOS version
            let qrDocument = viewModel.generateQRCode()

            VStack(spacing: 10) {
                // QR Code Image Preview only
                if let uiImage = try? qrDocument.uiImage(CGSize(width: 200, height: 200)) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(maxWidth: 220, maxHeight: 220)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }

                // Copy as text button (compressed)
                Button(action: {
                    UIPasteboard.general.string = viewModel.qrContent.data.formattedString()
                }) {
                    Label("Copy Text", systemImage: "doc.on.doc")
                        .font(.footnote)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.vertical, 5)
            .sheet(isPresented: $showingExportSheet) {
                VStack(spacing: 20) {
                    Text("Export QR Code Image")
                        .font(.headline)

                    // Preview
                    let qrDocument = viewModel.generateQRCode()
                    if let uiImage = (try? qrDocument.uiImage(CGSize(width: 150, height: 150))) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }

                    // Filename field
                    TextField("Filename", text: $exportFileName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    HStack {
                        Button("Cancel") {
                            showingExportSheet = false
                        }
                        .foregroundColor(.red)

                        Spacer()

                        Button("Export") {
                            exportedFileURL = viewModel.exportQRCode(
                                as: selectedExportFormat, named: exportFileName)
                            if exportedFileURL != nil {
                                showingExportSheet = false
                                showingShareSheet = true
                            }
                        }
                        .disabled(exportFileName.isEmpty)
                    }
                    .padding()
                }
                .padding()
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportedFileURL {
                    ShareSheet(items: [url])
                }
            }
        #elseif os(macOS)
            // Full macOS version remains unchanged
            VStack(spacing: 20) {
                Text("Preview")
                    .font(.headline)

                // QR Code Image Preview
                let qrDocument = viewModel.generateQRCode()
                if let nsImage = try? qrDocument.nsImage(CGSize(width: 200, height: 200)) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }

                // Copy as text button
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(
                        viewModel.qrContent.data.formattedString(), forType: .string)
                }) {
                    Text("Copy as text")
                        .foregroundColor(.blue)
                }

                // Export Options
                VStack(alignment: .leading, spacing: 10) {
                    Text("Format")
                        .font(.subheadline)

                    Picker("Format", selection: $selectedExportFormat) {
                        Text("SVG").tag(QRCodeExportFormat.svg)
                        Text("PNG").tag(QRCodeExportFormat.png)
                        Text("PDF").tag(QRCodeExportFormat.pdf)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.bottom)

                    // Export Button
                    Button(action: {
                        showingExportSheet = true
                    }) {
                        Text("Export")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .padding()
            .sheet(isPresented: $showingExportSheet) {
                MacExportPanel(viewModel: viewModel, isPresented: $showingExportSheet)
            }
        #endif
    }
}

#if os(macOS)
    struct MacExportPanel: View {
        @ObservedObject var viewModel: QRCodeViewModel
        @Binding var isPresented: Bool
        @State private var selectedFormat: QRCodeExportFormat = .png
        @State private var fileName: String = "QRCode"

        var body: some View {
            VStack(spacing: 20) {
                Text("Export QR Code Image")
                    .font(.headline)

                // Preview of the QR code
                let qrDocument = viewModel.generateQRCode()
                if let nsImage = try? qrDocument.nsImage(CGSize(width: 150, height: 150)) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }

                // Filename field
                TextField("Filename", text: $fileName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 300)

                // Format picker
                Picker("Format", selection: $selectedFormat) {
                    Text("PNG").tag(QRCodeExportFormat.png)
                    Text("SVG").tag(QRCodeExportFormat.svg)
                    Text("PDF").tag(QRCodeExportFormat.pdf)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 300)

                HStack(spacing: 20) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .keyboardShortcut(.cancelAction)

                    Button("Export") {
                        exportQRCode()
                        isPresented = false
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(fileName.isEmpty)
                }
                .padding(.top)
            }
            .padding()
        }

        private func exportQRCode() {
            let savePanel = NSSavePanel()
            savePanel.allowedFileTypes = [selectedFormat.fileExtension]
            savePanel.nameFieldStringValue = fileName

            if savePanel.runModal() == .OK, let url = savePanel.url {
                let qrDocument = viewModel.generateQRCode()
                let fileExtension = url.pathExtension.lowercased()

                do {
                    var data: Data?

                    switch fileExtension {
                    case "svg":
                        data = try qrDocument.svgData(dimension: 1024)
                    case "pdf":
                        data = try qrDocument.pdfData(dimension: 1024)
                    default:
                        data = try qrDocument.pngData(dimension: 1024)
                    }

                    if let data = data {
                        try data.write(to: url)
                    }
                } catch {
                    print("Error exporting QR code: \(error)")
                }
            }
        }
    }
#endif
