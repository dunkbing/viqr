//
//  SavedTabView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import QRCode
import SwiftUI
import TikimUI

#if os(iOS)
    import Combine
#endif

#if canImport(UIKit)
    import UIKit
#endif

struct SavedTabView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: IndexSet?
    @State private var searchText = ""
    @State private var isEditMode: EditMode = .inactive
    @State private var isEditPresented = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $searchText, placeholder: "Search saved QR codes")
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.appSurface1)

                ScrollView {
                    VStack(spacing: 16) {
                        // Header
                        HStack {
                            Text("Saved QR Codes")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color.appText)
                            Spacer()

                            #if os(iOS)
                                CustomEditButton(editMode: $isEditMode)
                            #else
                                EditButton()
                                    .foregroundColor(Color.appAccent)
                            #endif
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
                            LazyVStack(spacing: 12) {
                                ForEach(filteredCodes) { qrCode in
                                    NavigationLink(
                                        destination: SavedQRDetailView(
                                            viewModel: viewModel,
                                            savedCode: qrCode
                                        )
                                    ) {
                                        SavedCodeRow(qrCode: qrCode)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    #if os(iOS)
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                itemToDelete = IndexSet([
                                                    filteredCodes.firstIndex(where: {
                                                        $0.id == qrCode.id
                                                    })!
                                                ])
                                                showingDeleteAlert = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }

                                            Button {
                                                viewModel.loadSavedQRCode(qrCode)
                                                viewModel.currentEditingCode = qrCode
                                                NotificationCenter.default.post(
                                                    name: NSNotification.Name("TabBarVisibility"),
                                                    object: nil,
                                                    userInfo: ["isVisible": false]
                                                )
                                                isEditPresented = true
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            .tint(.blue)
                                        }
                                    #endif
                                }
                                .onDelete { indexSet in
                                    if isEditMode.isEditing {
                                        itemToDelete = indexSet
                                        showingDeleteAlert = true
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Spacer for tab bar
                        Spacer(minLength: 100)
                    }
                }
                .background(Color.appBackground.ignoresSafeArea())
            }
            .environment(\.editMode, $isEditMode)
            .sheet(isPresented: $isEditPresented) {
                // Use a NavigationView to have a proper toolbar in the sheet
                NavigationView {
                    QRCodeEditView(
                        viewModel: viewModel, originalCode: viewModel.currentEditingCode!,
                        isPresented: $isEditPresented
                    )
                    .navigationBarTitleDisplayMode(.inline)
                }
                .accentColor(Color.appAccent)
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete QR Code"),
                    message: Text(
                        "Are you sure you want to delete this QR code? This action cannot be undone."
                    ),
                    primaryButton: .destructive(Text("Delete")) {
                        if let indexSet = itemToDelete {
                            // Convert indexSet from filtered to model indexes
                            let toDelete = indexSet.map { filteredCodes[$0] }
                            for code in toDelete {
                                viewModel.deleteSavedQRCode(withID: code.id)
                            }
                            itemToDelete = nil
                        }
                    },
                    secondaryButton: .cancel {
                        itemToDelete = nil
                    }
                )
            }
            .navigationTitle("")  // Hide the default navigation title
            .navigationBarHidden(true)  // Hide the navigation bar
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // Filtered QR codes based on search text
    private var filteredCodes: [SavedQRCode] {
        if searchText.isEmpty {
            return viewModel.savedCodes
        } else {
            return viewModel.savedCodes.filter { qrCode in
                qrCode.name.lowercased().contains(searchText.lowercased())
                    || qrCode.content.typeEnum.rawValue.lowercased().contains(
                        searchText.lowercased())
            }
        }
    }
}

// Search bar component
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(text.isEmpty ? Color.appSubtitle : Color.appAccent)
                .padding(.leading, 8)

            TextField(placeholder, text: $text)
                .foregroundColor(Color.appText)
                .padding(10)

            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.appSubtitle)
                        .padding(.trailing, 8)
                }
            }
        }
        .background(Color.appSurface2.opacity(0.5))
        .cornerRadius(12)
    }
}

struct SavedCodeRow: View {
    let qrCode: SavedQRCode

    var body: some View {
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
