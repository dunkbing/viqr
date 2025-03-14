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
    @State private var showingSaveSheet = false
    @State private var showingExportSheet = false
    @State private var qrCodeName = ""

    var body: some View {
        NavigationView {
            SidebarView(viewModel: viewModel)
                .frame(minWidth: 200)

            EditorView(viewModel: viewModel)
                .frame(minWidth: 400)

            QRCodePreviewView(viewModel: viewModel)
                .frame(minWidth: 250)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }

            ToolbarItem(placement: .automatic) {
                Button(action: {
                    showingSaveSheet = true
                }) {
                    Label("Save QR Code", systemImage: "square.and.arrow.down")
                }
            }

            ToolbarItem(placement: .automatic) {
                Button(action: {
                    showingExportSheet = true
                }) {
                    Label("Export QR Image", systemImage: "arrow.up.doc")
                }
            }

            ToolbarItem(placement: .automatic) {
                Button(action: {
                    let qrData = viewModel.qrContent.data.formattedString()
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(qrData, forType: .string)
                }) {
                    Label("Copy Data", systemImage: "doc.on.doc")
                }
            }
        }
        .sheet(isPresented: $showingSaveSheet) {
            VStack(spacing: 20) {
                Text("Save QR Code")
                    .font(.headline)

                TextField("QR Code Name", text: $qrCodeName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 300)

                HStack {
                    Button("Cancel") {
                        showingSaveSheet = false
                    }
                    .keyboardShortcut(.cancelAction)

                    Button("Save") {
                        viewModel.saveCurrentQRCode(name: qrCodeName)
                        qrCodeName = ""
                        showingSaveSheet = false
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(qrCodeName.isEmpty)
                }
                .padding()
            }
            .padding()
            .frame(width: 400, height: 200)
        }
        .sheet(isPresented: $showingExportSheet) {
            MacExportPanel(viewModel: viewModel, isPresented: $showingExportSheet)
                .frame(width: 400, height: 300)
        }
        .frame(minWidth: 1000, minHeight: 600)
    }

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}
#endif
