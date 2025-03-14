//
//  SidebarView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import QRCode
import SwiftUI

#if os(macOS)
    struct SidebarView: View {
        @ObservedObject var viewModel: QRCodeViewModel
        @Binding var selection: String?
        @EnvironmentObject var themeManager: ThemeManager

        var body: some View {
            List {
                Section(header: Text("Create").foregroundColor(Color.appSubtitle)) {
                    NavigationLink(
                        destination: EditorView(viewModel: viewModel)
                            .environmentObject(themeManager),
                        tag: "create",
                        selection: $selection
                    ) {
                        Label("New QR Code", systemImage: "qrcode")
                            .foregroundColor(Color.appText)
                    }
                }

                Section(header: Text("QR Code Types").foregroundColor(Color.appSubtitle)) {
                    ForEach(QRCodeType.allCases) { type in
                        HStack {
                            Image(systemName: type.icon)
                                .frame(width: 24)
                                .foregroundColor(Color.appAccent)

                            Button(action: {
                                viewModel.selectedType = type
                                selection = "create"
                            }) {
                                Text(type.rawValue)
                                    .foregroundColor(Color.appText)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 2)
                    }
                }

                Section(header: Text("Saved QR Codes").foregroundColor(Color.appSubtitle)) {
                    if viewModel.savedCodes.isEmpty {
                        Text("No saved QR codes")
                            .foregroundColor(Color.appSubtitle)
                            .italic()
                    } else {
                        ForEach(viewModel.savedCodes) { qrCode in
                            HStack {
                                NavigationLink(
                                    destination: SavedQRCodeDetailView(
                                        viewModel: viewModel,
                                        savedCode: qrCode,
                                        sidebarSelection: $selection
                                    )
                                    .environmentObject(themeManager),
                                    tag: "saved-\(qrCode.id.uuidString)",
                                    selection: $selection
                                ) {
                                    VStack(alignment: .leading) {
                                        Text(qrCode.name)
                                            .lineLimit(1)
                                            .foregroundColor(Color.appText)

                                        Text(qrCode.content.typeEnum.rawValue)
                                            .font(.caption)
                                            .foregroundColor(Color.appSubtitle)
                                    }
                                }
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.deleteSavedQRCode(at: indexSet)
                        }
                    }
                }

                // Add Settings section
                Section {
                    NavigationLink(
                        destination: MacOSSettingsView(viewModel: viewModel)
                            .environmentObject(themeManager),
                        tag: "settings",
                        selection: $selection
                    ) {
                        Label("Settings", systemImage: "gear")
                            .foregroundColor(Color.appText)
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 180)
            .background(Color.appCrust)
        }
    }

    struct SavedQRCodeDetailView: View {
        @ObservedObject var viewModel: QRCodeViewModel
        let savedCode: SavedQRCode
        @State private var selectedExportFormat: QRCodeExportFormat = .png
        @Binding var sidebarSelection: String?
        @EnvironmentObject var themeManager: ThemeManager

        var body: some View {
            VStack {
                Text(savedCode.name)
                    .font(.title)
                    .foregroundColor(Color.appText)
                    .padding(.bottom)

                // QR Code preview
                let qrDocument = QRCodeGenerator.generateQRCode(
                    from: savedCode.content, with: savedCode.style)
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
                        .foregroundColor(Color.appText)
                    Text("Created: \(formattedDate(savedCode.dateCreated))")
                        .foregroundColor(Color.appText)
                }
                .padding()

                HStack {
                    Button("Edit in Editor") {
                        viewModel.loadSavedQRCode(savedCode)
                        sidebarSelection = "create"
                    }
                    .padding()
                    .foregroundColor(Color.appAccent)

                    Button("Export...") {
                        exportQRCode()
                    }
                    .padding()
                    .foregroundColor(Color.appOrange)
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.appBackground)
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
