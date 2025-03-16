//
//  SettingsTabView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import QRCode
import SwiftUI
import TikimUI

#if os(iOS)
    struct SettingsTabView: View {
        @ObservedObject var viewModel: QRCodeViewModel
        @AppStorage("defaultQRCodeType") private var defaultQRCodeType = "Link"
        @AppStorage("defaultExportFormat") private var defaultExportFormat = "png"
        @EnvironmentObject var themeManager: ThemeManager
        @State private var showingAbout = false
        @State private var showingClearConfirmation = false

        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("Settings")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.appText)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Appearance Section
                    SettingsSection(title: "Appearance", icon: "paintpalette") {
                        VStack(spacing: 16) {
                            HStack {
                                Text("App Theme")
                                    .foregroundColor(Color.appText)
                                    .font(.headline)
                                Spacer()
                            }

                            HStack(spacing: 20) {
                                ForEach(AppTheme.allCases) { theme in
                                    ThemeButton(
                                        theme: theme,
                                        isSelected: themeManager.theme == theme,
                                        action: {
                                            themeManager.theme = theme
                                        }
                                    )
                                }
                                Spacer()
                            }
                        }
                        .padding()
                    }

                    // Default Settings
                    SettingsSection(title: "Default Settings", icon: "gearshape") {
                        VStack(spacing: 16) {
                            SettingRow(title: "Default QR Code Type") {
                                Menu {
                                    ForEach(QRCodeType.allCases) { type in
                                        Button {
                                            defaultQRCodeType = type.rawValue
                                        } label: {
                                            HStack {
                                                Image(systemName: type.icon)
                                                Text(type.rawValue)
                                                if defaultQRCodeType == type.rawValue {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(defaultQRCodeType)
                                            .foregroundColor(Color.appText)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.appSubtitle)
                                    }
                                }
                            }

                            SettingRow(title: "Default Export Format") {
                                Menu {
                                    Button {
                                        defaultExportFormat = "png"
                                    } label: {
                                        HStack {
                                            Text("PNG")
                                            if defaultExportFormat == "png" {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }

                                    Button {
                                        defaultExportFormat = "svg"
                                    } label: {
                                        HStack {
                                            Text("SVG")
                                            if defaultExportFormat == "svg" {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }

                                    Button {
                                        defaultExportFormat = "pdf"
                                    } label: {
                                        HStack {
                                            Text("PDF")
                                            if defaultExportFormat == "pdf" {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(defaultExportFormat.uppercased())
                                            .foregroundColor(Color.appText)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.appSubtitle)
                                    }
                                }
                            }
                        }
                        .padding()
                    }

                    // QR Library Management
                    SettingsSection(title: "QR Code Library", icon: "folder") {
                        VStack(spacing: 16) {
                            HStack {
                                Text("Saved QR Codes")
                                    .foregroundColor(Color.appText)
                                Spacer()
                                Text("\(viewModel.savedCodes.count)")
                                    .foregroundColor(Color.appSubtitle)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.appSurface2.opacity(0.5))
                                    .cornerRadius(8)
                            }

                            if !viewModel.savedCodes.isEmpty {
                                Button(action: {
                                    showingClearConfirmation = true
                                }) {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Clear All Saved QR Codes")
                                    }
                                    .foregroundColor(Color.appRed)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.appRed.opacity(0.1))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(BouncyButtonStyle())
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
                    SettingsSection(title: "About", icon: "info.circle") {
                        VStack(spacing: 16) {
                            Button(action: {
                                showingAbout = true
                            }) {
                                HStack {
                                    Text("About QR Studio")
                                        .foregroundColor(Color.appText)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.appSubtitle)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())

                            HStack {
                                Text("Version")
                                    .foregroundColor(Color.appText)
                                Spacer()
                                Text("1.0.0")
                                    .foregroundColor(Color.appSubtitle)
                            }

                            Link(destination: URL(string: "https://github.com/dagronf/QRCode")!) {
                                HStack {
                                    Text("QR Code Library")
                                        .foregroundColor(Color.appAccent)
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .foregroundColor(Color.appAccent)
                                }
                            }
                        }
                        .padding()
                    }

                    Spacer()
                        .frame(height: 100)  // Extra padding for the tab bar
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }

    struct SettingsSection<Content: View>: View {
        let title: String
        let icon: String
        let content: Content

        init(title: String, icon: String, @ViewBuilder content: () -> Content) {
            self.title = title
            self.icon = icon
            self.content = content()
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.appAccent)
                        .padding(8)
                        .background(Color.appAccent.opacity(0.1))
                        .clipShape(Circle())

                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color.appText)
                }
                .padding(.horizontal)

                content
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appMantle)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.appAccent.opacity(0.15), lineWidth: 1)
                    )
            }
            .padding(.horizontal)
        }
    }

    struct SettingRow<Content: View>: View {
        let title: String
        let content: Content

        init(title: String, @ViewBuilder content: () -> Content) {
            self.title = title
            self.content = content()
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(Color.appSubtitle)

                content
            }
        }
    }

    struct ThemeButton: View {
        let theme: AppTheme
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                VStack(spacing: 8) {
                    Image(systemName: theme.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? Color.appAccent : Color.appText)

                    Text(theme.rawValue)
                        .font(.caption)
                        .foregroundColor(isSelected ? Color.appAccent : Color.appText)
                }
                .frame(width: 80, height: 70)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isSelected
                                ? Color.appAccent.opacity(0.1) : Color.appSurface2.opacity(0.5))
                )
            }
            .buttonStyle(BouncyButtonStyle())
        }
    }

    struct AboutView: View {
        @Environment(\.presentationMode) var presentationMode

        var body: some View {
            ScrollView {
                VStack(spacing: 24) {
                    // App Logo
                    Image(systemName: "qrcode")
                        .font(.system(size: 80))
                        .foregroundColor(Color.appAccent)
                        .padding(.top, 40)

                    Text("QR Studio")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.appText)

                    Text("Version 1.0.0")
                        .foregroundColor(Color.appSubtitle)

                    Divider()
                        .padding(.vertical)

                    VStack(alignment: .leading, spacing: 20) {
                        Text(
                            "QR Studio is a powerful QR code generator that lets you create, customize, and save QR codes for various purposes."
                        )
                        .foregroundColor(Color.appText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                        Text("Features:")
                            .font(.headline)
                            .foregroundColor(Color.appText)
                            .padding(.horizontal)

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
                        FeatureRow(icon: "paintpalette", text: "Beautiful Catppuccin color themes")
                    }
                    .padding()

                    Spacer()

                    Text("Made with ❤️ using Swift and SwiftUI")
                        .foregroundColor(Color.appSubtitle)
                        .padding(.bottom, 40)

                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.appAccent)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .padding(.bottom, 30)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
        }
    }

    struct FeatureRow: View {
        let icon: String
        let text: String

        var body: some View {
            HStack(alignment: .top, spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color.appAccent)
                    .frame(width: 24, height: 24)

                Text(text)
                    .foregroundColor(Color.appText)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
    }
#endif
