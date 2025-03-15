//
//  CreateTabView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import QRCode
import SwiftUI

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
                        .foregroundColor(selectedType == type ? .white : .blue)
                        .frame(width: 50, height: 50)
                        .background(selectedType == type ? Color.blue : Color.blue.opacity(0.1))
                        .cornerRadius(10)

                    Text(type.rawValue)
                        .font(.caption)
                        .foregroundColor(selectedType == type ? .blue : .primary)
                }
            }
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
            NavigationView {
                ScrollView {
                    VStack(spacing: 16) {
                        // Type Selection
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(QRCodeType.allCases) { type in
                                    TypeButton(type: type, selectedType: $viewModel.selectedType)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 8)

                        // Preview
                        QRCodePreviewView(viewModel: viewModel)

                        // Action Buttons
                        HStack(spacing: 15) {
                            ActionButton(
                                title: "Save", systemImage: "square.and.arrow.down", color: .green
                            ) {
                                showingSaveSheet = true
                            }

                            ActionButton(
                                title: "Export", systemImage: "arrow.up.doc", color: .orange
                            ) {
                                exportFileName = "QRCode"
                                showingExportSheet = true
                            }
                        }
                        .padding()

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

                            if selectedTab == 0 {
                                iOSEditorView(viewModel: viewModel)
                                    .transition(.opacity)
                            } else {
                                iOSStyleEditorView(viewModel: viewModel)
                                    .transition(.opacity)
                            }
                        }
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        .padding(.horizontal, 8)
                    }
                }
                .navigationTitle("QR Studio")
                .navigationBarHidden(true)
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
                            .foregroundColor(.red)

                            Spacer()

                            Button("Save") {
                                viewModel.saveCurrentQRCode(name: qrCodeName)
                                qrCodeName = ""
                                showingSaveSheet = false
                            }
                            .disabled(qrCodeName.isEmpty)
                        }
                        .padding()
                    }
                    .padding()
                }
                .sheet(isPresented: $showingExportSheet) {
                    VStack(spacing: 20) {
                        Text("Export QR Code Image")
                            .font(.headline)

                        // Preview
                        let qrDocument = viewModel.generateQRCode()

                        #if canImport(UIKit)
                            if let uiImage = try? qrDocument.uiImage(
                                CGSize(width: 150, height: 150))
                            {
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
                            .foregroundColor(.red)

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
                    Text(title)
                }
                .font(isSelected ? .subheadline.bold() : .subheadline)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                .foregroundColor(isSelected ? .blue : .primary)
                .cornerRadius(8)
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
                    Text(title)
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
#endif
