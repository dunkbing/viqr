//
//  SavedTabView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI
import QRCode

#if canImport(UIKit)
import UIKit
#endif

struct SavedTabView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: IndexSet?

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.savedCodes.isEmpty {
                    VStack {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .padding()

                        Text("No Saved QR Codes")
                            .font(.title2)

                        Text("Create and save QR codes in the Create tab")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.savedCodes) { qrCode in
                            // Fixed NavigationLink with explicit destination type
                            NavigationLink(destination: SavedQRDetailView(viewModel: viewModel, savedCode: qrCode)) {
                                HStack {
                                    // Generate a small preview
                                    let qrDocument = QRCodeGenerator.generateQRCode(from: qrCode.content, with: qrCode.style)
                                    // This line is causing issues - let's use proper conversion method
                                    #if canImport(UIKit)
                                    if let cgImage = qrDocument.cgImage(CGSize(width: 60, height: 60)) {
                                        Image(uiImage: UIImage(cgImage: cgImage))
                                            .interpolation(.none)
                                            .resizable()
                                            .frame(width: 60, height: 60)
                                            .background(Color.white)
                                            .cornerRadius(8)
                                    }
                                    #else
                                    // Fallback for non-UIKit platforms
                                    Image(systemName: "qrcode")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                    #endif

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(qrCode.name)
                                            .font(.headline)

                                        Text(qrCode.content.typeEnum.rawValue)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)

                                        Text(formattedDate(qrCode.dateCreated))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.leading, 8)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete { indexSet in
                            itemToDelete = indexSet
                            showingDeleteAlert = true
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Saved QR Codes")
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete QR Code"),
                    message: Text("Are you sure you want to delete this QR code? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let indexSet = itemToDelete {
                            viewModel.deleteSavedQRCode(at: indexSet)
                            itemToDelete = nil
                        }
                    },
                    secondaryButton: .cancel() {
                        itemToDelete = nil
                    }
                )
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct SavedQRDetailView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    let savedCode: SavedQRCode
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL? = nil
    @State private var selectedExportFormat: QRCodeExportFormat = .png
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
                        exportedFileURL = viewModel.exportQRCode(as: selectedExportFormat, named: "QRCode-\(savedCode.name)")
                        if exportedFileURL != nil {
                            showingShareSheet = true
                        }
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
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
//        .navigationBarTitle("QR Code Details", displayMode: .inline)
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportedFileURL {
                #if os(iOS)
                ShareSheet(items: [url])
                #endif
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#if os(iOS)
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .fontWeight(.medium)
                .frame(width: 80, alignment: .leading)

            Text(value)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
