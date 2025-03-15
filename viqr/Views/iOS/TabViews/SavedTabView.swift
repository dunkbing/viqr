//
//  SavedTabView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import QRCode
import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

struct SavedTabView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: IndexSet?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Saved QR Codes")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.appText)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)

                if viewModel.savedCodes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(Color.appSubtitle)
                            .padding()

                        Text("No Saved QR Codes")
                            .font(.title2)
                            .foregroundColor(Color.appText)

                        Text("Create and save QR codes in the Create tab")
                            .foregroundColor(Color.appSubtitle)
                            .multilineTextAlignment(.center)
                            .padding()

                        Image(systemName: "arrow.down")
                            .font(.system(size: 24))
                            .foregroundColor(Color.appSubtitle)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.appSurface1.opacity(0.5))
                    )
                    .padding(.horizontal)
                } else {
                    // Saved QR codes list
                    VStack(spacing: 12) {
                        ForEach(viewModel.savedCodes) { qrCode in
                            NavigationLink(
                                destination: SavedQRDetailView(
                                    viewModel: viewModel, savedCode: qrCode)
                            ) {
                                HStack(spacing: 16) {
                                    // Generate a small preview
                                    let qrDocument = QRCodeGenerator.generateQRCode(
                                        from: qrCode.content,
                                        with: qrCode.style
                                    )
                                    #if canImport(UIKit)
                                        Group {
                                            if let cgImage = try? qrDocument.cgImage(
                                                CGSize(width: 60, height: 60))
                                            {
                                                Image(uiImage: UIImage(cgImage: cgImage))
                                                    .interpolation(.none)
                                                    .resizable()
                                                    .frame(width: 60, height: 60)
                                                    .background(Color.white)
                                                    .cornerRadius(12)
                                                    .shadow(
                                                        color: Color.black.opacity(0.1), radius: 2,
                                                        x: 0, y: 1)
                                            } else {
                                                // Fallback if QR code generation fails
                                                Image(systemName: "qrcode")
                                                    .resizable()
                                                    .frame(width: 60, height: 60)
                                                    .foregroundColor(Color.appAccent)
                                                    .background(Color.white)
                                                    .cornerRadius(12)
                                            }
                                        }
                                    #else
                                        // Fallback for non-UIKit platforms
                                        Image(systemName: "qrcode")
                                            .resizable()
                                            .frame(width: 60, height: 60)
                                            .foregroundColor(Color.appAccent)
                                            .background(Color.white)
                                            .cornerRadius(12)
                                    #endif

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(qrCode.name)
                                            .font(.headline)
                                            .foregroundColor(Color.appText)

                                        Text(qrCode.content.typeEnum.rawValue)
                                            .font(.subheadline)
                                            .foregroundColor(Color.appSubtitle)

                                        Text(formattedDate(qrCode.dateCreated))
                                            .font(.caption)
                                            .foregroundColor(Color.appSubtitle)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color.appSubtitle)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.appSurface1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.appSurface2, lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 100)  // Extra padding for the tab bar
                }
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete QR Code"),
                message: Text(
                    "Are you sure you want to delete this QR code? This action cannot be undone."
                ),
                primaryButton: .destructive(Text("Delete")) {
                    if let indexSet = itemToDelete {
                        viewModel.deleteSavedQRCode(at: indexSet)
                        itemToDelete = nil
                    }
                },
                secondaryButton: .cancel {
                    itemToDelete = nil
                }
            )
        }
        .onDrag {
            showingDeleteAlert = true
            return NSItemProvider(object: "delete" as NSString)
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
                .foregroundColor(Color.appText)

            Text(value)
                .foregroundColor(Color.appSubtitle)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
