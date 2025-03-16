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

        // Initialize with the original QR code
        init(viewModel: QRCodeViewModel, originalCode: SavedQRCode, isPresented: Binding<Bool>) {
            self.viewModel = viewModel
            self.originalCode = originalCode
            self._isPresented = isPresented
            self._qrCodeName = State(initialValue: originalCode.name)
        }

        var body: some View {
            KeyboardAwareScrollView {
                VStack(spacing: 20) {
                    // QR Code Preview
                    QRCodePreviewView(viewModel: viewModel)
                        .frame(height: 200)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.appSurface1)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)

                    // QR Code Name
                    TextField("QR Code Name", text: $qrCodeName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    // Type Selection - Disabled to prevent type changes that could lose data
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

                    Spacer(minLength: 50)
                }
            }
            .padding(.top)
            .navigationTitle("Edit QR Code")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(Color.appRed)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundColor(Color.appGreen)
                    .disabled(qrCodeName.isEmpty)
                }
            }
            .background(Color.appBackground.ignoresSafeArea())
            .dismissKeyboardOnTap()
        }

        private func saveChanges() {
            viewModel.updateSavedQRCode(
                originalID: originalCode.id,
                name: qrCodeName
            )
            isPresented = false
        }
    }
#endif
