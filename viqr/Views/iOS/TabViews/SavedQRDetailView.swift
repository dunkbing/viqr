//
//  SavedQRDetailView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 14/3/25.
//

import QRCode
import SwiftUI

struct SavedQRDetailView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    let savedCode: SavedQRCode
    @State private var showingShareSheet = false
    @State private var showingExportSheet = false
    @State private var exportedFileURL: URL? = nil
    @State private var selectedExportFormat: QRCodeExportFormat = .png
    @State private var exportFileName: String = ""
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(savedCode.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                // QR Code image
                let qrDocument = QRCodeGenerator.generateQRCode(
                    from: savedCode.content, with: savedCode.style)
                #if canImport(UIKit)
                    Group {
                        if let cgImage = try? qrDocument.cgImage(CGSize(width: 250, height: 250)) {
                            Image(uiImage: UIImage(cgImage: cgImage))
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250, height: 250)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(radius: 2)
                                .padding()
                        } else {
                            // Fallback if QR code generation fails
                            Image(systemName: "qrcode")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250, height: 250)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(radius: 2)
                                .padding()
                        }
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

                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        // Load the QR code into the viewModel before showing the edit sheet
                        viewModel.loadSavedQRCode(savedCode)
                        showingEditSheet = true
                    }) {
                        Label("Edit QR Code", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    #if os(iOS)
                        Button(action: {
                            #if canImport(UIKit)
                                UIPasteboard.general.string = savedCode.content.data
                                    .formattedString()
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

                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("QR Code Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Hide the tab bar when this view appears
            NotificationCenter.default.post(
                name: NSNotification.Name("TabBarVisibility"),
                object: nil,
                userInfo: ["isVisible": false]
            )
        }
        .onDisappear {
            // Show the tab bar when this view disappears
            NotificationCenter.default.post(
                name: NSNotification.Name("TabBarVisibility"),
                object: nil,
                userInfo: ["isVisible": true]
            )
        }
        #if os(iOS)
            .sheet(isPresented: $showingEditSheet) {
                // Use a NavigationView to have a proper toolbar in the sheet
                NavigationView {
                    QRCodeEditView(
                        viewModel: viewModel, originalCode: savedCode,
                        isPresented: $showingEditSheet
                    )
                    .navigationBarTitleDisplayMode(.inline)
                }
                .accentColor(Color.appAccent)  // Apply accent color to navigation bar
            }
            .sheet(isPresented: $showingExportSheet) {
                VStack(spacing: 20) {
                    Text("Export QR Code Image")
                    .font(.headline)

                    // Preview of the QR code
                    let qrDocument = QRCodeGenerator.generateQRCode(
                        from: savedCode.content, with: savedCode.style)
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
                            exportedFileURL = QRCodeGenerator.saveQRCodeToFile(
                                qrCode: qrDocument,
                                fileName: exportFileName,
                                fileFormat: selectedExportFormat
                            )

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
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete QR Code"),
                    message: Text(
                        "Are you sure you want to delete this QR code? This action cannot be undone."
                    ),
                    primaryButton: .destructive(Text("Delete")) {
                        viewModel.deleteSavedQRCode(withID: savedCode.id)
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel()
                )
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
                let qrDocument = QRCodeGenerator.generateQRCode(
                    from: savedCode.content, with: savedCode.style)
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
                let qrDocument = QRCodeGenerator.generateQRCode(
                    from: savedCode.content, with: savedCode.style)
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
