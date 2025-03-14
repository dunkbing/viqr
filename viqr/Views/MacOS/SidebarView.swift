//
//  SidebarView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI
import QRCode

struct SidebarView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    @State private var selection: String? = "create"

    var body: some View {
        List {
            Section(header: Text("Create")) {
                NavigationLink(
                    destination: EditorView(viewModel: viewModel),
                    tag: "create",
                    selection: $selection
                ) {
                    Label("New QR Code", systemImage: "qrcode")
                }
            }

            Section(header: Text("QR Code Types")) {
                ForEach(QRCodeType.allCases) { type in
                    HStack {
                        Image(systemName: type.icon)
                            .frame(width: 24)

                        Button(action: {
                            viewModel.selectedType = type
                            selection = "create"
                        }) {
                            Text(type.rawValue)
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.vertical, 2)
                }
            }

            Section(header: Text("Saved QR Codes")) {
                if viewModel.savedCodes.isEmpty {
                    Text("No saved QR codes")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    ForEach(viewModel.savedCodes) { qrCode in
                        HStack {
                            NavigationLink(
                                destination: SavedQRCodeDetailView(
                                    viewModel: viewModel,
                                    savedCode: qrCode,
                                    sidebarSelection: $selection
                                ),
                                tag: "saved-\(qrCode.id.uuidString)",
                                selection: $selection
                            ) {
                                VStack(alignment: .leading) {
                                    Text(qrCode.name)
                                        .lineLimit(1)

                                    Text(qrCode.content.typeEnum.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.deleteSavedQRCode(at: indexSet)
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 180)
    }
}

struct SavedQRCodeDetailView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    let savedCode: SavedQRCode
    @State private var selectedExportFormat: QRCodeExportFormat = .png
    @Binding var sidebarSelection: String?

    var body: some View {
        VStack {
            Text(savedCode.name)
                .font(.title)
                .padding(.bottom)

            // QR Code preview
            let qrDocument = QRCodeGenerator.generateQRCode(from: savedCode.content, with: savedCode.style)
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

            VStack(alignment: .leading) {
                Text("Type: \(savedCode.content.typeEnum.rawValue)")
                Text("Created: \(formattedDate(savedCode.dateCreated))")
            }
            .padding()

            HStack {
                Button("Edit in Editor") {
                    viewModel.loadSavedQRCode(savedCode)
                    sidebarSelection = "create"
                }
                .padding()

                Button("Export...") {
                    exportQRCode()
                }
                .padding()
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func exportQRCode() {
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = [selectedExportFormat.fileExtension]
        savePanel.nameFieldStringValue = savedCode.name

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
                print("Error saving QR code: \(error)")
            }
        }
    }
}
