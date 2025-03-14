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
        @State private var showingContentSheet = false
        @State private var showingStyleSheet = false
        @State private var showingSaveSheet = false
        @State private var showingExportSheet = false
        @State private var qrCodeName = ""
        @State private var selectedExportFormat: QRCodeExportFormat = .png
        @State private var exportFileName = ""
        @State private var showingShareSheet = false
        @State private var exportedFileURL: URL? = nil

        var body: some View {
            NavigationView {
                VStack(spacing: 0) {
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

                    Spacer(minLength: 10)

                    // Preview - using GeometryReader to adjust size dynamically
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            QRCodePreviewView(viewModel: viewModel)
                                .frame(maxWidth: geometry.size.width - 32)
                            Spacer()
                        }
                        .frame(width: geometry.size.width)
                    }

                    // Action Buttons
                    HStack(spacing: 10) {
                        Button(action: {
                            showingContentSheet = true
                        }) {
                            VStack {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 20))
                                Text("Content")
                                    .font(.caption2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }

                        Button(action: {
                            showingStyleSheet = true
                        }) {
                            VStack {
                                Image(systemName: "paintbrush")
                                    .font(.system(size: 20))
                                Text("Style")
                                    .font(.caption2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(10)
                        }

                        Button(action: {
                            showingSaveSheet = true
                        }) {
                            VStack {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 20))
                                Text("Save")
                                    .font(.caption2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                        }

                        Button(action: {
                            exportFileName = "QRCode"
                            showingExportSheet = true
                        }) {
                            VStack {
                                Image(systemName: "arrow.up.doc")
                                    .font(.system(size: 20))
                                Text("Export")
                                    .font(.caption2)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)  // Add extra padding at the bottom to avoid tab bar
                }
                .navigationTitle("QR Studio")
                .safeAreaInset(edge: .bottom) {  // Add safe area inset to respect tab bar
                    Color.clear.frame(height: 0)
                }
                // Rest of the sheets remain unchanged
                .sheet(isPresented: $showingContentSheet) {
                    NavigationView {
                        iOSEditorView(viewModel: viewModel)
                            .navigationTitle("Edit Content")
                            .navigationBarItems(
                                trailing: Button("Done") {
                                    showingContentSheet = false
                                })
                    }
                }
                .sheet(isPresented: $showingStyleSheet) {
                    NavigationView {
                        iOSStyleEditorView(viewModel: viewModel)
                            .navigationTitle("Edit Style")
                            .navigationBarItems(
                                trailing: Button("Done") {
                                    showingStyleSheet = false
                                })
                    }
                }
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
#endif
