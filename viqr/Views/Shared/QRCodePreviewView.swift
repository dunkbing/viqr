//
//  QRCodePreviewView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//  Updated by Claude on 13/3/25.
//

import SwiftUI
import QRCode
#if swift(>=5.5) && canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif

struct QRCodePreviewView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    @State private var selectedExportFormat: QRCodeExportFormat = .png
    @State private var exportFileName: String = "QRCode"
    @State private var showingExportSheet = false
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

                // Export Button
                Button(action: {
                    #if os(iOS)
                    showingExportSheet = true
                    #else
                    showingExportSheet = true
                    #endif
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
        #if os(iOS)
        .sheet(isPresented: $showingExportSheet) {
            VStack(spacing: 20) {
                Text("Export QR Code Image")
                    .font(.headline)

                // Preview
                Image(uiImage: (try? qrDocument.uiImage(CGSize(width: 150, height: 150))) ?? UIImage())
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)

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
            .presentationDetents([.height(350)])
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(activityItems: [url])
            }
        }
        #else
        .sheet(isPresented: $showingExportSheet) {
            MacExportPanel(viewModel: viewModel, isPresented: $showingExportSheet)
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
#endif
