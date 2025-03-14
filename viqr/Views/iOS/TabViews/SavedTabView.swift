//
//  SavedTabView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI
import QRCode

#if canImport(UIKit)
import UIKit
#endif

struct SavedTabView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: IndexSet?

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.savedCodes.isEmpty {
                    VStack {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .padding()

                        Text("No Saved QR Codes")
                            .font(.title2)

                        Text("Create and save QR codes in the Create tab")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.savedCodes) { qrCode in
                            NavigationLink(destination: SavedQRDetailView(viewModel: viewModel, savedCode: qrCode)) {
                                HStack {
                                    // Generate a small preview
                                    let qrDocument = QRCodeGenerator.generateQRCode(
                                        from: qrCode.content,
                                        with: qrCode.style
                                    )
                                    #if canImport(UIKit)
                                    Group {
                                        if let cgImage = try? qrDocument.cgImage(CGSize(width: 60, height: 60)) {
                                            Image(uiImage: UIImage(cgImage: cgImage))
                                                .interpolation(.none)
                                                .resizable()
                                                .frame(width: 60, height: 60)
                                                .background(Color.white)
                                                .cornerRadius(8)
                                        } else {
                                            // Fallback if QR code generation fails
                                            Image(systemName: "qrcode")
                                                .resizable()
                                                .frame(width: 60, height: 60)
                                                .background(Color.white)
                                                .cornerRadius(8)
                                        }
                                    }
                                    #else
                                    // Fallback for non-UIKit platforms
                                    Image(systemName: "qrcode")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                    #endif

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(qrCode.name)
                                            .font(.headline)

                                        Text(qrCode.content.typeEnum.rawValue)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)

                                        Text(formattedDate(qrCode.dateCreated))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.leading, 8)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete { indexSet in
                            itemToDelete = indexSet
                            showingDeleteAlert = true
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Saved QR Codes")
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete QR Code"),
                    message: Text("Are you sure you want to delete this QR code? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        if let indexSet = itemToDelete {
                            viewModel.deleteSavedQRCode(at: indexSet)
                            itemToDelete = nil
                        }
                    },
                    secondaryButton: .cancel() {
                        itemToDelete = nil
                    }
                )
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .fontWeight(.medium)
                .frame(width: 80, alignment: .leading)

            Text(value)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
