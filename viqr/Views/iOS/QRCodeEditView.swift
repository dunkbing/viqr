//
//  QRCodeEditView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 16/3/25.
//

import QRCode
import SwiftUI
import TikimUI

#if os(iOS)
    struct QRCodeEditView: View {
        @ObservedObject var viewModel: QRCodeViewModel
        let originalCode: SavedQRCode
        @Binding var isPresented: Bool
        @State private var qrCodeName: String
        @State private var selectedTab = 0
        @State private var showSaveConfirmation = false

        // Initialize with the original QR code
        init(viewModel: QRCodeViewModel, originalCode: SavedQRCode, isPresented: Binding<Bool>) {
            self.viewModel = viewModel
            self.originalCode = originalCode
            self._isPresented = isPresented
            self._qrCodeName = State(initialValue: originalCode.name)
        }

        var body: some View {
            ZStack {
                // Background
                Color.appBackground.ignoresSafeArea()

                KeyboardAwareScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            Text("Edit QR Code")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.appText)

                            Spacer()
                        }
                        .padding(.top)
                        .padding(.horizontal)

                        // QR Code Preview
                        QRCodePreviewView(viewModel: viewModel)
                            .frame(height: 200)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.appSurface1)
                                    .shadow(
                                        color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                            )
                            .padding(.horizontal)

                        // QR Code Name with animated placeholder
                        VStack(alignment: .leading, spacing: 8) {
                            Text("QR Code Name")
                                .font(.headline)
                                .foregroundColor(Color.appText)
                                .padding(.horizontal)

                            TextField("", text: $qrCodeName)
                                .placeholder(when: qrCodeName.isEmpty) {
                                    Text("Enter a name for your QR code")
                                        .foregroundColor(Color.appSubtitle.opacity(0.7))
                                }
                                .padding()
                                .background(Color.appSurface2.opacity(0.15))
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }

                        // Type Selection
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(QRCodeType.allCases) { type in
                                    TypeButton(
                                        type: type,
                                        selectedType: $viewModel.selectedType,
                                        isEnabled: viewModel.canChangeType
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

                        // Action Buttons
                        HStack(spacing: 15) {
                            Button(action: {
                                isPresented = false
                            }) {
                                Text("Cancel")
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.appRed.opacity(0.1))
                                    .foregroundColor(Color.appRed)
                                    .cornerRadius(16)
                            }

                            Button(action: {
                                if qrCodeName.isEmpty {
                                    showSaveConfirmation = true
                                } else {
                                    saveChanges()
                                }
                            }) {
                                Text("Save Changes")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        qrCodeName.isEmpty
                                            ? Color.appAccent.opacity(0.5) : Color.appAccent
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)

                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .dismissKeyboardOnTap()
            .overlay(
                VStack {
                    HStack {
                        DismissButton(isPresented: $isPresented, label: "Cancel")

                        Spacer()

                        Button(action: {
                            if qrCodeName.isEmpty {
                                showSaveConfirmation = true
                            } else {
                                saveChanges()
                            }
                        }) {
                            Text("Save")
                                .fontWeight(.semibold)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.appGreen.opacity(0.2))
                                .foregroundColor(Color.appGreen)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(
                        Rectangle()
                            .fill(Color.appBackground.opacity(0.98))
                            .shadow(color: Color.black.opacity(0.05), radius: 3, y: 1)
                    )

                    Spacer()
                }
                .ignoresSafeArea()
                .frame(height: 80)
            )
            .alert("Missing QR Code Name", isPresented: $showSaveConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Continue") {
                    if qrCodeName.isEmpty {
                        qrCodeName = originalCode.name
                    }
                    saveChanges()
                }
            } message: {
                Text("Would you like to keep the original name: '\(originalCode.name)'?")
            }
        }

        private func saveChanges() {
            viewModel.updateSavedQRCode(
                originalID: originalCode.id,
                name: qrCodeName.isEmpty ? originalCode.name : qrCodeName
            )
            isPresented = false
        }
    }

    // Extension for placeholder text
    extension View {
        func placeholder<Content: View>(
            when shouldShow: Bool, alignment: Alignment = .leading,
            @ViewBuilder placeholder: () -> Content
        ) -> some View {
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
    }
#endif
