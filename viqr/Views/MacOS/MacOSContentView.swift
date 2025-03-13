//
//  MacOSContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI
import SwiftData

struct MacOSContentView: View {
    @StateObject var viewModel = QRCodeViewModel()
    @State private var showingSaveSheet = false
    @State private var showingExportSheet = false
    @State private var qrCodeName = ""

    init(modelContext: ModelContext) {
        // Initialize the view model with SwiftData context
        let vm = QRCodeViewModel()
        vm.modelContext = modelContext

        // Load data from SwiftData on initialization
        vm.loadQRCodesFromSwiftData()

        _viewModel = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationView {
            SidebarView(viewModel: viewModel)
                .frame(minWidth: 200)

            EditorView(viewModel: viewModel)
                .frame(minWidth: 400)

            QRCodePreviewView(viewModel: viewModel)
                .frame(minWidth: 250)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }

            ToolbarItem(placement: .automatic) {
                Button(action: {
                    showingSaveSheet = true
                }) {
                    Label("Save QR Code", systemImage: "square.and.arrow.down")
                }
            }

            ToolbarItem(placement: .automatic) {
                Button(action: {
                    showingExportSheet = true
                }) {
                    Label("Export QR Image", systemImage: "arrow.up.doc")
                }
            }

            ToolbarItem(placement: .automatic) {
                Button(action: {
                    let qrData = viewModel.qrContent.data.formattedString()
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(qrData, forType: .string)
                }) {
                    Label("Copy Data", systemImage: "doc.on.doc")
                }
            }
        }
        .sheet(isPresented: $showingSaveSheet) {
            VStack(spacing: 20) {
                Text("Save QR Code")
                    .font(.headline)

                TextField("QR Code Name", text: $qrCodeName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 300)

                HStack {
                    Button("Cancel") {
                        showingSaveSheet = false
                    }
                    .keyboardShortcut(.cancelAction)

                    Button("Save") {
                        viewModel.saveCurrentQRCode(name: qrCodeName)
                        qrCodeName = ""
                        showingSaveSheet = false
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(qrCodeName.isEmpty)
                }
                .padding()
            }
            .padding()
            .frame(width: 400, height: 200)
        }
        .sheet(isPresented: $showingExportSheet) {
            MacExportPanel(viewModel: viewModel, isPresented: $showingExportSheet)
                .frame(width: 400, height: 300)
        }
        .frame(minWidth: 1000, minHeight: 600)
    }

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

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
