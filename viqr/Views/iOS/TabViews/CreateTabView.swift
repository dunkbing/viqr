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
        let isEnabled: Bool

        init(type: QRCodeType, selectedType: Binding<QRCodeType>, isEnabled: Bool = true) {
            self.type = type
            self._selectedType = selectedType
            self.isEnabled = isEnabled
        }

        var body: some View {
            Button(action: {
                if isEnabled {
                    selectedType = type
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: type.icon)
                        .font(.system(size: 18))
                        .frame(width: 25, height: 25)

                    Text(type.rawValue)
                        .font(.system(size: 14, weight: .medium))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .foregroundColor(
                    selectedType == type ? .white : isEnabled ? Color.appAccent : Color.appSubtitle
                )
                .background(
                    selectedType == type
                        ? Color.appSecondaryAccent
                        : isEnabled ? Color.appSecondaryAccent.opacity(0.1) : Color.appSurface2
                )
                .cornerRadius(8)
                .opacity(isEnabled ? 1.0 : 0.7)
            }
            .buttonStyle(BouncyButtonStyle())
            .disabled(!isEnabled)
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

        // New state for edit mode
        @State private var isEditMode = false
        @State private var originalQRCode: SavedQRCode?
        @State private var editedQRCodeName = ""
        @Environment(\.presentationMode) var presentationMode

        // Initialize for creating a new QR code
        init(viewModel: QRCodeViewModel) {
            self.viewModel = viewModel
            self._isEditMode = State(initialValue: false)
        }

        // Initialize for editing an existing QR code
        init(viewModel: QRCodeViewModel, editQRCode: SavedQRCode) {
            self.viewModel = viewModel
            self._isEditMode = State(initialValue: true)
            self._originalQRCode = State(initialValue: editQRCode)
            self._editedQRCodeName = State(initialValue: editQRCode.name)
            self._qrCodeName = State(initialValue: editQRCode.name)
        }

        var body: some View {
            KeyboardAwareScrollView {
                VStack(spacing: 20) {
                    // Header based on mode
                    HStack {
                        Text(isEditMode ? "Edit QR Code" : "Create QR Code")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.appText)

                        Spacer()

                        if isEditMode {
                            Button(action: cancelEdit) {
                                Text("Cancel")
                                    .foregroundColor(Color.appRed)
                            }
                            .padding(.trailing, 8)

                            Button(action: saveEditedQRCode) {
                                Text("Save")
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.appGreen)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)

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

                    // Action Buttons - Only show when not in edit mode
                    if !isEditMode {
                        HStack(spacing: 15) {
                            ActionButton(
                                title: "Save",
                                systemImage: "square.and.arrow.down",
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
                    }

                    // Type Selection - Disabled in edit mode for certain QR code types
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(QRCodeType.allCases) { type in
                                TypeButton(
                                    type: type,
                                    selectedType: $viewModel.selectedType,
                                    isEnabled: !isEditMode || viewModel.canChangeType
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Content/Style Tabs
                    VStack {
                        TabPickerView(
                            selection: $selectedTab,
                            options: [
                                (value: 0, title: "Content"),
                                (value: 1, title: "Style"),
                            ]
                        )
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

                    Spacer(minLength: 50)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .dismissKeyboardOnTap()
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
            .onAppear {
                if isEditMode, let originalQRCode = originalQRCode {
                    // Load the QR code data for editing
                    viewModel.loadSavedQRCode(originalQRCode)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
        }

        // Save the edited QR code
        private func saveEditedQRCode() {
            guard let originalQRCode = originalQRCode else { return }

            // Update the saved QR code with the current values
            viewModel.updateSavedQRCode(
                originalID: originalQRCode.id,
                name: editedQRCodeName.isEmpty ? originalQRCode.name : editedQRCodeName
            )

            // Dismiss the view
            presentationMode.wrappedValue.dismiss()
        }

        private func cancelEdit() {
            presentationMode.wrappedValue.dismiss()
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
            }
            .buttonStyle(BouncyButtonStyle())
        }
    }
#endif
