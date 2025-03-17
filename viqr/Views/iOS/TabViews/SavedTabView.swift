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
    @State private var hasAppeared = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search header
                    SearchHeaderView(
                        searchText: $searchText,
                        title: "Saved QR Codes",
                        placeholderText: "Search your QR codes...",
                        isEditMode: $isEditMode
                    )
                    .padding(.bottom, 16)

                    // Empty state or list content
                    if viewModel.savedCodes.isEmpty {
                        EmptyStateView()
                    } else {
                        SavedQRCodeList(
                            viewModel: viewModel,
                            filteredCodes: filteredCodes,
                            isEditMode: $isEditMode,
                            itemToDelete: $itemToDelete,
                            showingDeleteAlert: $showingDeleteAlert,
                            isEditPresented: $isEditPresented
                        )
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: searchText)
                .environment(\.editMode, $isEditMode)
                .sheet(isPresented: $isEditPresented) {
                    // Use a NavigationView to have a proper toolbar in the sheet
                    NavigationView {
                        QRCodeEditView(
                            viewModel: viewModel,
                            originalCode: viewModel.currentEditingCode!,
                            isPresented: $isEditPresented
                        )
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
            }
            .navigationTitle("")  // Hide the default navigation title
            .navigationBarHidden(true)  // Hide the navigation bar
            .onAppear {
                // Apply animation only after first appearance
                if !hasAppeared {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            hasAppeared = true
                        }
                    }
                }
            }
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

// Empty state component
struct EmptyStateView: View {
    @State private var appear = false

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 70))
                .foregroundColor(Color.appAccent.opacity(0.7))
                .padding()
                .background(
                    Circle()
                        .fill(Color.appAccent.opacity(0.1))
                        .frame(width: 150, height: 150)
                )
                .scaleEffect(appear ? 1.0 : 0.8)
                .opacity(appear ? 1.0 : 0)

            Text("No Saved QR Codes")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.appText)
                .opacity(appear ? 1.0 : 0)

            Text("Create and save QR codes in the Create tab")
                .foregroundColor(Color.appSubtitle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .opacity(appear ? 1.0 : 0)

            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(Color.appAccent)
                .opacity(appear ? 1.0 : 0)
                .offset(y: appear ? 0 : -10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.appSurface1.opacity(0.5))
                .padding(.horizontal)
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                appear = true
            }
        }
    }
}

// List of saved QR codes
struct SavedQRCodeList: View {
    @ObservedObject var viewModel: QRCodeViewModel
    let filteredCodes: [SavedQRCode]
    @Binding var isEditMode: EditMode
    @Binding var itemToDelete: IndexSet?
    @Binding var showingDeleteAlert: Bool
    @Binding var isEditPresented: Bool
    @State private var selectedQRCode: SavedQRCode? = nil

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(filteredCodes.enumerated()), id: \.element.id) { index, qrCode in
                    NavigationLink(
                        destination: SavedQRDetailView(
                            viewModel: viewModel,
                            savedCode: qrCode
                        )
                    ) {
                        SavedCodeRow(qrCode: qrCode)
                            .offset(x: isEditMode.isEditing ? 20 : 0)
                            .animation(
                                .spring(response: 0.4, dampingFraction: 0.8),
                                value: isEditMode.isEditing
                            )
                            .overlay(
                                isEditMode.isEditing
                                    ? HStack {
                                        Button(action: {
                                            itemToDelete = IndexSet([index])
                                            showingDeleteAlert = true
                                        }) {
                                            Image(systemName: "trash.circle.fill")
                                                .font(.system(size: 28))
                                                .foregroundColor(Color.appRed)
                                                .background(Circle().fill(Color.white))
                                        }
                                        .offset(x: -15)

                                        Spacer()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    : nil
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contextMenu {
                        // Context menu options (long press)
                        Button(action: {
                            viewModel.loadSavedQRCode(qrCode)
                            viewModel.currentEditingCode = qrCode
                            isEditPresented = true
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button(
                            role: .destructive,
                            action: {
                                itemToDelete = IndexSet([index])
                                showingDeleteAlert = true
                            }
                        ) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    #if os(iOS)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                itemToDelete = IndexSet([index])
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                viewModel.loadSavedQRCode(qrCode)
                                viewModel.currentEditingCode = qrCode
                                isEditPresented = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    #endif
                }

                // Extra space at bottom for tab bar
                Spacer(minLength: 100)
            }
            .padding(.horizontal)
        }
    }
}

// Enhanced QR code row
struct SavedCodeRow: View {
    let qrCode: SavedQRCode
    @State private var isPressed = false

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
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(
                                color: Color.black.opacity(0.1), radius: 2,
                                x: 0, y: 1)
                    } else {
                        // Fallback if QR code generation fails
                        Image(systemName: "qrcode")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(10)
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color.appAccent)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
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

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(qrCode.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.appText)

                    Spacer()

                    Text(formattedDate(qrCode.dateCreated))
                        .font(.caption)
                        .foregroundColor(Color.appSubtitle)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.appSurface2.opacity(0.3))
                        .cornerRadius(6)
                }

                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: qrCode.content.typeEnum.icon)
                            .font(.system(size: 12))
                        Text(qrCode.content.typeEnum.rawValue)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.appAccent.opacity(0.2))
                    .foregroundColor(Color.appAccent)
                    .cornerRadius(6)

                    Text(contentPreview(for: qrCode.content))
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.appSubtitle.opacity(0.6))
                .padding(8)
                .background(Color.appSurface2.opacity(0.3))
                .clipShape(Circle())
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appSurface1)
                .shadow(
                    color: Color.black.opacity(isPressed ? 0.01 : 0.07), radius: isPressed ? 4 : 8,
                    x: 0, y: isPressed ? 1 : 3)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func contentPreview(for content: QRCodeContent) -> String {
        switch content.data {
        case .link(let url):
            return url
        case .text(let content):
            return content.prefix(25) + (content.count > 25 ? "..." : "")
        case .phone(let number):
            return number
        case .email(let address, _, _):
            return address
        case .wifi(let ssid, _, _, _):
            return "Network: \(ssid)"
        case .whatsapp(let number, _):
            return number
        case .vCard(let firstName, let lastName, _, _, _, _, _, _, _):
            return "\(firstName) \(lastName)"
        }
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
