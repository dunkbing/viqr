//
//  SavedQRDetailView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 14/3/25.
//

import SwiftUI
import QRCode

struct SavedQRDetailView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    let savedCode: SavedQRCode
    @State private var showingShareSheet = false
    @State private var showingExportSheet = false
    @State private var exportedFileURL: URL? = nil
    @State private var selectedExportFormat: QRCodeExportFormat = .png
    @State private var exportFileName: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(savedCode.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                // QR Code image
                let qrDocument = QRCodeGenerator.generateQRCode(from: savedCode.content, with: savedCode.style)
                #if canImport(UIKit)
                if let cgImage = qrDocument.cgImage(CGSize(width: 250, height: 250)) {
                    Image(uiImage: UIImage(cgImage: cgImage))
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(radius: 2)
                        .padding()
                }
                #else
                // Fallback for non-UIKit platforms
                Image(systemName: "qrcode")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    .padding()
                #endif

                // QR Code Details
                GroupBox(label: Label("Details", systemImage: "info.circle")) {
                    VStack(alignment: .leading, spacing: 8) {
                        DetailRow(label: "Type", value: savedCode.content.typeEnum.rawValue)
                        DetailRow(label: "Created", value: formattedDate(savedCode.dateCreated))

                        // Show content-specific details
                        switch savedCode.content.data {
                        case .link(let url):
                            DetailRow(label: "URL", value: url)
                        case .text(let content):
                            DetailRow(label: "Text", value: content.prefix(50) + (content.count > 50 ? "..." : ""))
                        case .phone(let number):
                            DetailRow(label: "Phone", value: number)
                        case .email(let address, let subject, _):
                            DetailRow(label: "Email", value: address)
                            if !subject.isEmpty {
                                DetailRow(label: "Subject", value: subject)
                            }
                        case .wifi(let ssid, _, _, let security):
                            DetailRow(label: "Network", value: ssid)
                            DetailRow(label: "Security", value: security.description)
                        case .whatsapp(let number, _):
                            DetailRow(label: "Number", value: number)
                        case .vCard(let firstName, let lastName, let organization, _, _, _, _, _, _):
                            DetailRow(label: "Name", value: "\(firstName) \(lastName)")
                            if !organization.isEmpty {
                                DetailRow(label: "Organization", value: organization)
                            }
                        }
                    }
                    .padding()
                }
                .padding(.horizontal)

                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        viewModel.loadSavedQRCode(savedCode)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Label("Edit in Creator", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    #if os(iOS)
                    Button(action: {
                        #if canImport(UIKit)
                        UIPasteboard.general.string = savedCode.content.data.formattedString()
                        #endif
                    }) {
                        Label("Copy to Clipboard", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    #endif

                    Button(action: {
                        exportFileName = "QRCode-\(savedCode.name)"
                        showingExportSheet = true
                    }) {
                        Label("Export", systemImage: "arrow.up.doc")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        #if os(iOS)
        .sheet(isPresented: $showingExportSheet) {
            VStack(spacing: 20) {
                Text("Export QR Code Image")
                    .font(.headline)

                // Preview of the QR code
                let qrDocument = QRCodeGenerator.generateQRCode(from: savedCode.content, with: savedCode.style)
                if let uiImage = try? qrDocument.uiImage(CGSize(width: 150, height: 150)) {
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

                // Format picker
                Picker("Format", selection: $selectedExportFormat) {
                    Text("PNG").tag(QRCodeExportFormat.png)
                    Text("SVG").tag(QRCodeExportFormat.svg)
                    Text("PDF").tag(QRCodeExportFormat.pdf)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                HStack {
                    Button("Cancel") {
                        showingExportSheet = false
                    }
                    .foregroundColor(.red)

                    Spacer()

                    Button("Export") {
                        // Create a new temporary QR generator to use the saved code's style
                        exportedFileURL = viewModel.exportQRCode(as: selectedExportFormat, named: exportFileName)
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
            .presentationDetents([.height(400)])
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(items: [url])
            }
        }
        #else
        .sheet(isPresented: $showingExportSheet) {
            MacExportPanel_SavedCode(savedCode: savedCode, isPresented: $showingExportSheet)
                .frame(width: 400, height: 300)
        }
        #endif
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#if os(macOS)
struct MacExportPanel_SavedCode: View {
    let savedCode: SavedQRCode
    @Binding var isPresented: Bool
    @State private var selectedFormat: QRCodeExportFormat = .png
    @State private var fileName: String = "QRCode"

    var body: some View {
        VStack(spacing: 20) {
            Text("Export QR Code Image")
                .font(.headline)

            // Preview of the QR code
            let qrDocument = QRCodeGenerator.generateQRCode(from: savedCode.content, with: savedCode.style)
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
            let qrDocument = QRCodeGenerator.generateQRCode(from: savedCode.content, with: savedCode.style)
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
