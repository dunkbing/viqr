//
//  MacOSSettingsView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 14/3/25.
//

import SwiftUI

#if os(macOS)
    struct MacOSSettingsView: View {
        @ObservedObject var viewModel: QRCodeViewModel
        @AppStorage("defaultQRCodeType") private var defaultQRCodeType = "Link"
        @AppStorage("defaultExportFormat") private var defaultExportFormat = "png"
        @EnvironmentObject var themeManager: ThemeManager
        @State private var showingClearConfirmation = false

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Theme Settings
                    GroupBox(label: Label("Appearance", systemImage: "paintpalette")) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("App Theme")
                                .font(.headline)

                            HStack(spacing: 20) {
                                ForEach(AppTheme.allCases) { theme in
                                    Button(action: {
                                        themeManager.theme = theme
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: theme.icon)
                                                .font(.system(size: 28))
                                                .foregroundColor(
                                                    themeManager.theme == theme
                                                        ? AppColors.appAccent : AppColors.appText)

                                            Text(theme.rawValue)
                                                .font(.caption)
                                                .foregroundColor(
                                                    themeManager.theme == theme
                                                        ? AppColors.appAccent : AppColors.appText)
                                        }
                                        .frame(width: 80, height: 60)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(
                                                    themeManager.theme == theme
                                                        ? Color.appSurface : Color.clear)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }

                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                        .padding()
                    }

                    // Default Settings
                    GroupBox(label: Label("Default Settings", systemImage: "gearshape")) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Default QR Code Type")
                                    .frame(width: 180, alignment: .leading)

                                Picker("", selection: $defaultQRCodeType) {
                                    ForEach(QRCodeType.allCases) { type in
                                        Text(type.rawValue).tag(type.rawValue)
                                    }
                                }
                                .frame(width: 200)

                                Spacer()
                            }

                            HStack {
                                Text("Default Export Format")
                                    .frame(width: 180, alignment: .leading)

                                Picker("", selection: $defaultExportFormat) {
                                    Text("PNG").tag("png")
                                    Text("SVG").tag("svg")
                                    Text("PDF").tag("pdf")
                                }
                                .frame(width: 200)

                                Spacer()
                            }
                        }
                        .padding()
                    }

                    // QR Library Management
                    GroupBox(label: Label("QR Code Library", systemImage: "folder")) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Saved QR Codes")
                                    .frame(width: 180, alignment: .leading)

                                Text("\(viewModel.savedCodes.count)")
                                    .foregroundColor(Color.appSubtitle)

                                Spacer()
                            }

                            if !viewModel.savedCodes.isEmpty {
                                Button("Clear All Saved QR Codes") {
                                    showingClearConfirmation = true
                                }
                                .foregroundColor(Color.appRed)
                                .alert(isPresented: $showingClearConfirmation) {
                                    Alert(
                                        title: Text("Clear All Saved QR Codes"),
                                        message: Text(
                                            "Are you sure you want to delete all saved QR codes? This action cannot be undone."
                                        ),
                                        primaryButton: .destructive(Text("Delete All")) {
                                            viewModel.savedCodes.removeAll()
                                            viewModel.saveToDisk()
                                        },
                                        secondaryButton: .cancel()
                                    )
                                }
                            }
                        }
                        .padding()
                    }

                    // About Section
                    GroupBox(label: Label("About", systemImage: "info.circle")) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Version")
                                    .frame(width: 180, alignment: .leading)

                                Text("1.0.0")
                                    .foregroundColor(Color.appSubtitle)

                                Spacer()
                            }

                            Link(
                                "QR Code Library",
                                destination: URL(string: "https://github.com/dagronf/QRCode")!
                            )
                            .foregroundColor(Color.appAccent)

                            Text(
                                "QR Studio is a powerful QR code generator that lets you create, customize, and save QR codes for various purposes."
                            )
                            .foregroundColor(Color.appText)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 8)

                            Text("Made with ❤️ using Swift and SwiftUI")
                                .font(.caption)
                                .foregroundColor(Color.appSubtitle)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 4)
                        }
                        .padding()
                    }
                }
                .padding()
            }
        }
    }
#endif
