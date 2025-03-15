//
//  SettingsTabView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import QRCode
import SwiftUI

#if os(iOS)
struct SettingsTabView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    @AppStorage("defaultQRCodeType") private var defaultQRCodeType = "Link"
    @AppStorage("defaultExportFormat") private var defaultExportFormat = "png"
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAbout = false
    @State private var showingClearConfirmation = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("App Theme", selection: $themeManager.theme) {
                        ForEach(AppTheme.allCases) { theme in
                            HStack {
                                Image(systemName: theme.icon)
                                Text(theme.rawValue)
                            }
                            .tag(theme)
                        }
                    }
                }

                Section(header: Text("Default Settings")) {
                    Picker("Default QR Code Type", selection: $defaultQRCodeType) {
                        ForEach(QRCodeType.allCases) { type in
                            Text(type.rawValue).tag(type.rawValue)
                        }
                    }

                    Picker("Default Export Format", selection: $defaultExportFormat) {
                        Text("PNG").tag("png")
                        Text("SVG").tag("svg")
                        Text("PDF").tag("pdf")
                    }
                }

                Section(header: Text("QR Code Library")) {
                    HStack {
                        Text("Saved QR Codes")
                        Spacer()
                        Text("\(viewModel.savedCodes.count)")
                            .foregroundColor(AppColors.appSubtitle)
                    }

                    if !viewModel.savedCodes.isEmpty {
                        Button(
                            role: .destructive,
                            action: {
                                showingClearConfirmation = true
                            }
                        ) {
                            Text("Clear All Saved QR Codes")
                        }
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

                Section(header: Text("About")) {
                    Button(action: {
                        showingAbout = true
                    }) {
                        HStack {
                            Text("About QR Studio")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.appSubtitle)
                        }
                    }

                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(AppColors.appSubtitle)
                    }

                    Link(
                        "QR Code Library",
                        destination: URL(string: "https://github.com/dagronf/QRCode")!
                    )
                    .foregroundColor(AppColors.appAccent)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .accentColor(AppColors.appAccent)
        }
    }
}

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // App Logo
                    Image(systemName: "qrcode")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.appAccent)
                        .padding()

                    Text("QR Studio")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.appText)

                    Text("Version 1.0.0")
                        .foregroundColor(AppColors.appSubtitle)

                    Divider()
                        .padding(.vertical)

                    VStack(alignment: .leading, spacing: 15) {
                        Text(
                            "QR Studio is a powerful QR code generator that lets you create, customize, and save QR codes for various purposes."
                        )
                        .foregroundColor(AppColors.appText)
                        .padding(.bottom)

                        Text("Features:")
                            .font(.headline)
                            .foregroundColor(AppColors.appText)

                        FeatureRow(
                            icon: "link",
                            text: "Generate QR codes for links, text, contact details, and more")
                        FeatureRow(
                            icon: "paintbrush", text: "Customize colors and styles of your QR codes"
                        )
                        FeatureRow(
                            icon: "square.and.arrow.down",
                            text: "Export QR codes in multiple formats")
                        FeatureRow(
                            icon: "folder", text: "Save and organize your frequently used QR codes")
                        FeatureRow(
                            icon: "paintpalette", text: "Beautiful Catppuccin color themes")
                    }
                    .padding()

                    Spacer()

                    Text("Made with ❤️ using Swift and SwiftUI")
                        .foregroundColor(AppColors.appSubtitle)
                        .padding()
                }
                .padding()
            }
            .background(AppColors.appBackground.ignoresSafeArea())
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.appAccent)
                .frame(width: 24, height: 24)

            Text(text)
                .foregroundColor(AppColors.appText)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
#endif
