//
//  SettingsTabView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import QRCode
import SwiftUI

struct SettingsTabView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    @AppStorage("defaultQRCodeType") private var defaultQRCodeType = "Link"
    @AppStorage("defaultExportFormat") private var defaultExportFormat = "png"
    @State private var showingAbout = false

    var body: some View {
        NavigationView {
            Form {
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
                            .foregroundColor(.gray)
                    }

                    if !viewModel.savedCodes.isEmpty {
                        Button(
                            role: .destructive,
                            action: {
                                // Add confirmation dialog
                                let _ = viewModel.savedCodes.removeAll()
                            }
                        ) {
                            Text("Clear All Saved QR Codes")
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
                                .foregroundColor(.gray)
                        }
                    }

                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }

                    Link(
                        "QR Code Library",
                        destination: URL(string: "https://github.com/dagronf/QRCode")!)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // App Logo
                    Image(systemName: "qrcode")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .padding()

                    Text("QR Studio")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Version 1.0.0")
                        .foregroundColor(.gray)

                    Divider()
                        .padding(.vertical)

                    VStack(alignment: .leading, spacing: 15) {
                        Text(
                            "QR Studio is a powerful QR code generator that lets you create, customize, and save QR codes for various purposes."
                        )
                        .padding(.bottom)

                        Text("Features:")
                            .font(.headline)

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
                    }
                    .padding()

                    Spacer()

                    Text("Made with ❤️ using Swift and SwiftUI")
                        .foregroundColor(.gray)
                        .padding()
                }
                .padding()
            }
            //            .navigationBarTitle("About", displayMode: .inline)
            //            .navigationBarItems(trailing: Button("Done") {
            //                presentationMode.wrappedValue.dismiss()
            //            })
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
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)

            Text(text)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
