//
//  MacOSContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI

#if os(macOS)
    struct MacOSContentView: View {
        @StateObject var viewModel = QRCodeViewModel()
        @EnvironmentObject var themeManager: ThemeManager
        @State private var showingSaveSheet = false
        @State private var showingExportSheet = false
        @State private var qrCodeName = ""
        @State private var selectedSidebar: String? = "create"

        var body: some View {
            NavigationView {
                SidebarView(viewModel: viewModel, selection: $selectedSidebar)
                    .frame(minWidth: 200)
                    .environmentObject(themeManager)

                Group {
                    if selectedSidebar == "settings" {
                        MacOSSettingsView(viewModel: viewModel)
                            .environmentObject(themeManager)
                    } else if selectedSidebar?.starts(with: "saved-") ?? false {
                        // Handle saved QR code selection
                        if let uuid = selectedSidebar?.replacingOccurrences(of: "saved-", with: ""),
                            let savedCode = viewModel.savedCodes.first(where: {
                                $0.id.uuidString == uuid
                            })
                        {
                            SavedQRCodeDetailView(viewModel: viewModel, savedCode: savedCode)
                                .environmentObject(themeManager)
                        }
                    } else {
                        EditorView(viewModel: viewModel)
                            .frame(minWidth: 400)
                            .environmentObject(themeManager)
                    }
                }

                QRCodePreviewView(viewModel: viewModel)
                    .frame(minWidth: 250)
                    .environmentObject(themeManager)
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar) {
                        Image(systemName: "sidebar.left")
                            .foregroundColor(Color.appText)
                    }
                }

                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        showingSaveSheet = true
                    }) {
                        Label("Save QR Code", systemImage: "square.and.arrow.down")
                            .foregroundColor(Color.appText)
                    }
                }

                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        showingExportSheet = true
                    }) {
                        Label("Export QR Image", systemImage: "arrow.up.doc")
                            .foregroundColor(Color.appText)
                    }
                }

                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        let qrData = viewModel.qrContent.data.formattedString()
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(qrData, forType: .string)
                    }) {
                        Label("Copy Data", systemImage: "doc.on.doc")
                            .foregroundColor(Color.appText)
                    }
                }
            }
            .sheet(isPresented: $showingSaveSheet) {
                VStack(spacing: 20) {
                    Text("Save QR Code")
                        .font(.headline)
                        .foregroundColor(Color.appText)

                    TextField("QR Code Name", text: $qrCodeName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 300)

                    HStack {
                        Button("Cancel") {
                            showingSaveSheet = false
                        }
                        .keyboardShortcut(.cancelAction)
                        .foregroundColor(Color.appRed)

                        Button("Save") {
                            viewModel.saveCurrentQRCode(name: qrCodeName)
                            qrCodeName = ""
                            showingSaveSheet = false
                        }
                        .keyboardShortcut(.defaultAction)
                        .disabled(qrCodeName.isEmpty)
                        .foregroundColor(Color.appGreen)
                    }
                    .padding()
                }
                .padding()
                .frame(width: 400, height: 200)
                .background(Color.appBackground)
            }
            .sheet(isPresented: $showingExportSheet) {
                MacExportPanel(viewModel: viewModel, isPresented: $showingExportSheet)
                    .frame(width: 400, height: 300)
                    .background(Color.appBackground)
                    .environmentObject(themeManager)
            }
            .frame(minWidth: 1000, minHeight: 600)
            .accentColor(Color.appAccent)
        }

        private func toggleSidebar() {
            NSApp.keyWindow?.firstResponder?.tryToPerform(
                #selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        }
    }
#endif
