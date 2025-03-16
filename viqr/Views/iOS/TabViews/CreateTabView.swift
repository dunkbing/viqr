//
//  CreateTabView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import QRCode
import SwiftUI
import TikimUI

#if canImport(UIKit)
    import UIKit
#endif

#if os(iOS)
    struct TypeButton: View {
        let type: QRCodeType
        @Binding var selectedType: QRCodeType

        var body: some View {
            Button(action: {
                selectedType = type
            }) {
                VStack {
                    Image(systemName: type.icon)
                        .font(.system(size: 24))
                        .foregroundColor(selectedType == type ? .white : Color.appAccent)
                        .frame(width: 50, height: 50)
                        .background(
                            selectedType == type ? Color.appAccent : Color.appAccent.opacity(0.1)
                        )
                        .cornerRadius(15)

                    Text(type.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(selectedType == type ? Color.appAccent : Color.appText)
                }
            }
            .buttonStyle(BouncyButtonStyle())
        }
    }

    struct CreateTabView: View {
        @ObservedObject var viewModel: QRCodeViewModel
        @State private var showingSaveSheet = false
        @State private var showingExportSheet = false
        @State private var qrCodeName = ""
        @State private var selectedExportFormat: QRCodeExportFormat = .png
        @State private var exportFileName = ""
        @State private var showingShareSheet = false
        @State private var exportedFileURL: URL? = nil
        @State private var selectedTab = 0

        var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    // Type Selection
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(QRCodeType.allCases) { type in
                                TypeButton(type: type, selectedType: $viewModel.selectedType)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                    }

                    // Preview
                    QRCodePreviewView(viewModel: viewModel)
                        .frame(height: 250)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.appSurface1)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)

                    // Action Buttons
                    HStack(spacing: 15) {
                        ActionButton(
                            title: "Save", systemImage: "square.and.arrow.down",
                            color: Color.appGreen
                        ) {
                            showingSaveSheet = true
                        }

                        ActionButton(
                            title: "Export", systemImage: "arrow.up.doc", color: Color.appOrange
                        ) {
                            exportFileName = "QRCode"
                            showingExportSheet = true
                        }
                    }
                    .padding(.horizontal)

                    // Content/Style Tabs
                    VStack {
                        HStack {
                            TabButton(
                                title: "Content", systemImage: "doc.text",
                                isSelected: selectedTab == 0
                            ) {
                                selectedTab = 0
                            }

                            TabButton(
                                title: "Style", systemImage: "paintbrush",
                                isSelected: selectedTab == 1
                            ) {
                                selectedTab = 1
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)

                        if selectedTab == 0 {
                            iOSEditorView(viewModel: viewModel)
                                .transition(.opacity)
                        } else {
                            iOSStyleEditorView(viewModel: viewModel)
                                .transition(.opacity)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.appSurface.opacity(0.5))
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 100)  // Extra padding for the tab bar
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .sheet(isPresented: $showingSaveSheet) {
                VStack(spacing: 20) {
                    Text("Save QR Code")
                        .font(.headline)

                    TextField("QR Code Name", text: $qrCodeName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    HStack {
                        Button("Cancel") {
                            showingSaveSheet = false
                        }
                        .foregroundColor(Color.appRed)

                        Spacer()

                        Button("Save") {
                            viewModel.saveCurrentQRCode(name: qrCodeName)
                            qrCodeName = ""
                            showingSaveSheet = false
                        }
                        .disabled(qrCodeName.isEmpty)
                        .foregroundColor(Color.appGreen)
                    }
                    .padding()
                }
                .padding()
                .background(Color.appBackground)
                .cornerRadius(20)
            }
            .sheet(isPresented: $showingExportSheet) {
                // Export sheet content
                VStack(spacing: 20) {
                    Text("Export QR Code Image")
                        .font(.headline)

                    // Preview
                    let qrDocument = viewModel.generateQRCode()

                    #if canImport(UIKit)
                        if let uiImage = try? qrDocument.uiImage(CGSize(width: 150, height: 150)) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .interpolation(.none)
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                        }
                    #endif

                    // Filename field
                    TextField("Filename", text: $exportFileName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    // Format picker
                    Picker("Format", selection: $selectedExportFormat) {
                        Text("PNG").tag(QRCodeExportFormat.png)
                        Text("SVG").tag(QRCodeExportFormat.svg)
                        Text("PDF").tag(QRCodeExportFormat.pdf)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    HStack {
                        Button("Cancel") {
                            showingExportSheet = false
                        }
                        .foregroundColor(Color.appRed)

                        Spacer()

                        Button("Export") {
                            exportedFileURL = viewModel.exportQRCode(
                                as: selectedExportFormat, named: exportFileName)
                            if exportedFileURL != nil {
                                showingExportSheet = false
                                showingShareSheet = true
                            }
                        }
                        .disabled(exportFileName.isEmpty)
                        .foregroundColor(Color.appGreen)
                    }
                    .padding()
                }
                .padding()
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportedFileURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    // Tab Button component
    struct TabButton: View {
        let title: String
        let systemImage: String
        let isSelected: Bool
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack {
                    Image(systemName: systemImage)
                        .font(.system(size: 18))
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.appAccent.opacity(0.15) : Color.clear)
                .foregroundColor(isSelected ? Color.appAccent : Color.appText)
                .cornerRadius(12)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(maxWidth: .infinity)
        }
    }

    // Action Button component
    struct ActionButton: View {
        let title: String
        let systemImage: String
        let color: Color
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack {
                    Image(systemName: systemImage)
                        .font(.system(size: 18))
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .buttonStyle(BouncyButtonStyle())
        }
    }
#endif
