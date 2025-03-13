//
//  QRCodePreviewView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI
import QRCode

struct QRCodePreviewView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    @State private var selectedExportFormat: QRCodeExportFormat = .png
    @State private var showingSavePanel = false
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Preview")
                .font(.headline)
                .padding(.top)

            // QR Code Image Preview
            let qrDocument = viewModel.generateQRCode()

            #if os(iOS)
            if let uiImage = try? qrDocument.uiImage(CGSize(width: 200, height: 200)) {
                Image(uiImage: uiImage)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
            }
            #else
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
            #endif

            // Copy as text button
            Button(action: {
                #if os(iOS)
                UIPasteboard.general.string = viewModel.qrContent.data.formattedString()
                #else
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(viewModel.qrContent.data.formattedString(), forType: .string)
                #endif
            }) {
                Text("Copy as text")
                    .foregroundColor(.blue)
            }
            .padding(.bottom)

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

                // Save Button
                Button(action: {
                    #if os(iOS)
                    exportedFileURL = viewModel.exportQRCode(as: selectedExportFormat, named: "QRCode-\(Date().timeIntervalSince1970)")
                    if exportedFileURL != nil {
                        showingShareSheet = true
                    }
                    #else
                    showingSavePanel = true
                    #endif
                }) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .padding()
        #if os(iOS)
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(activityItems: [url])
            }
        }
        #else
        .sheet(isPresented: $showingSavePanel) {
            MacSavePanel(format: selectedExportFormat, viewModel: viewModel)
        }
        #endif
    }
}

#if os(iOS)
// iOS Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#else
// macOS Save Panel
struct MacSavePanel: NSViewRepresentable {
    let format: QRCodeExportFormat
    let viewModel: QRCodeViewModel

    func makeNSView(context: Context) -> NSView {
        let view = NSView()

        DispatchQueue.main.async {
            let savePanel = NSSavePanel()

            // Set file extension based on export format
            savePanel.allowedFileTypes = [format.fileExtension]
            savePanel.nameFieldStringValue = "QRCode"

            if savePanel.runModal() == .OK, let url = savePanel.url {
                let _ = viewModel.exportQRCode(as: format, named: url.lastPathComponent)
            }
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
#endif
