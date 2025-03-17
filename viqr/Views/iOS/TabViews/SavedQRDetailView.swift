//
//  SavedQRDetailView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 14/3/25.
//

import QRCode
import SwiftUI

struct SavedQRDetailView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    let savedCode: SavedQRCode
    @Binding var isSheetPresented: Bool
    @State private var showingShareSheet = false
    @State private var showingExportSheet = false
    @State private var exportedFileURL: URL? = nil
    @State private var selectedExportFormat: QRCodeExportFormat = .png
    @State private var exportFileName: String = ""
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    @Environment(\.presentationMode) var presentationMode
    @State private var contentAppeared = false
    @State private var showCopiedFeedback = false

    // State for handling manual dismissal
    @GestureState private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    var body: some View {
        VStack(spacing: 0) {
            // Handle area with drag indicator
            HStack {
                Spacer()
                Capsule()
                    .fill(Color.appSurface2)
                    .frame(width: 40, height: 5)
                Spacer()
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())

            ScrollView {
                VStack(spacing: 24) {
                    // Header with QR Code name
                    Text(savedCode.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.appText)
                        .padding(.top, 8)
                        .opacity(contentAppeared ? 1 : 0)
                        .offset(y: contentAppeared ? 0 : 20)

                    // QR Code metadata
                    HStack(spacing: 12) {
                        // Type badge
                        HStack(spacing: 6) {
                            Image(systemName: savedCode.content.typeEnum.icon)
                                .font(.system(size: 14))
                            Text(savedCode.content.typeEnum.rawValue)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.appAccent.opacity(0.15))
                        .foregroundColor(Color.appAccent)
                        .cornerRadius(8)

                        // Date badge
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 14))
                            Text(formattedDate(savedCode.dateCreated))
                                .font(.system(size: 14, weight: .medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.appSurface2.opacity(0.3))
                        .foregroundColor(Color.appSubtitle)
                        .cornerRadius(8)
                    }
                    .opacity(contentAppeared ? 1 : 0)
                    .offset(y: contentAppeared ? 0 : 20)

                    // QR Code Content Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Content")
                                .font(.headline)
                                .foregroundColor(Color.appText)

                            Spacer()

                            Button(action: {
                                #if canImport(UIKit)
                                    UIPasteboard.general.string = savedCode.content.data
                                        .formattedString()
                                    withAnimation {
                                        showCopiedFeedback = true

                                        // Auto-hide feedback after 2 seconds
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation {
                                                showCopiedFeedback = false
                                            }
                                        }
                                    }
                                #endif
                            }) {
                                Label(
                                    showCopiedFeedback ? "Copied!" : "Copy",
                                    systemImage: showCopiedFeedback ? "checkmark" : "doc.on.doc"
                                )
                                .font(.caption)
                                .foregroundColor(
                                    showCopiedFeedback ? Color.appGreen : Color.appAccent)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                showCopiedFeedback
                                    ? Color.appGreen.opacity(0.1) : Color.appAccent.opacity(0.1)
                            )
                            .cornerRadius(12)
                        }

                        Text(contentDisplay(for: savedCode.content))
                            .font(.subheadline)
                            .foregroundColor(Color.appSubtitle)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.appSurface2.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appSurface1)
                    )
                    .opacity(contentAppeared ? 1 : 0)
                    .offset(y: contentAppeared ? 0 : 20)

                    // QR Code image
                    ZStack {
                        // Background pattern for QR Code
                        VStack(spacing: 2) {
                            ForEach(0..<10) { _ in
                                HStack(spacing: 2) {
                                    ForEach(0..<10) { _ in
                                        Rectangle()
                                            .fill(Color.appSurface2.opacity(0.3))
                                            .frame(width: 5, height: 5)
                                    }
                                }
                            }
                        }
                        .padding(40)
                        .opacity(0.5)

                        // QR Code display
                        let qrDocument = QRCodeGenerator.generateQRCode(
                            from: savedCode.content, with: savedCode.style)
                        #if canImport(UIKit)
                            Group {
                                if let cgImage = try? qrDocument.cgImage(
                                    CGSize(width: 250, height: 250))
                                {
                                    Image(uiImage: UIImage(cgImage: cgImage))
                                        .interpolation(.none)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 250, height: 250)
                                        .background(Color.white)
                                        .cornerRadius(16)
                                        .shadow(
                                            color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2
                                        )
                                        .contextMenu {
                                            #if canImport(UIKit)
                                                Button(action: {
                                                    UIPasteboard.general.string = savedCode.content
                                                        .data.formattedString()
                                                    showCopiedFeedback = true

                                                    // Auto-hide feedback after 2 seconds
                                                    DispatchQueue.main.asyncAfter(
                                                        deadline: .now() + 2
                                                    ) {
                                                        withAnimation {
                                                            showCopiedFeedback = false
                                                        }
                                                    }
                                                }) {
                                                    Label("Copy Content", systemImage: "doc.on.doc")
                                                }
                                            #endif

                                            Button(action: {
                                                exportFileName =
                                                    savedCode.name.isEmpty
                                                    ? "QRCode" : savedCode.name
                                                showingExportSheet = true
                                            }) {
                                                Label("Export QR Code", systemImage: "arrow.up.doc")
                                            }
                                        }
                                        .onTapGesture(count: 2) {
                                            // Double tap to show export sheet
                                            exportFileName =
                                                savedCode.name.isEmpty ? "QRCode" : savedCode.name
                                            showingExportSheet = true
                                        }
                                } else {
                                    // Fallback if QR code generation fails
                                    Image(systemName: "qrcode")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 250, height: 250)
                                        .background(Color.white)
                                        .cornerRadius(16)
                                        .shadow(
                                            color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                }
                            }
                        #else
                            // Fallback for non-UIKit platforms
                            Image(systemName: "qrcode")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250, height: 250)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        #endif
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.appSurface.opacity(0.5))
                    )
                    .overlay(
                        showCopiedFeedback
                            ? VStack {
                                Text("Content Copied!")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.appGreen)
                                    .cornerRadius(20)
                                    .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .padding(.top, 20)
                            : nil
                    )
                    .opacity(contentAppeared ? 1 : 0)
                    .scaleEffect(contentAppeared ? 1 : 0.9)

                    // Action Buttons
                    VStack(spacing: 16) {
                        // Main action buttons
                        HStack(spacing: 16) {
                            ActionButton(
                                title: "Edit",
                                systemImage: "pencil",
                                color: Color.appAccent
                            ) {
                                viewModel.loadSavedQRCode(savedCode)
                                showingEditSheet = true
                            }

                            ActionButton(
                                title: "Export",
                                systemImage: "arrow.up.doc",
                                color: Color.appGreen
                            ) {
                                exportFileName = savedCode.name.isEmpty ? "QRCode" : savedCode.name
                                showingExportSheet = true
                            }
                        }

                        // Delete button
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 16, weight: .medium))
                                Text("Delete")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.appRed.opacity(0.1))
                            .foregroundColor(Color.appRed)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.top, 8)
                    .opacity(contentAppeared ? 1 : 0)
                    .offset(y: contentAppeared ? 0 : 20)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(Color.appBackground)
        .offset(y: max(0, dragOffset))
        .animation(.interactiveSpring(), value: dragOffset)
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    if value.translation.height > 0 {
                        state = value.translation.height
                        if !isDragging {
                            withAnimation { isDragging = true }
                        }
                    }
                }
                .onEnded { value in
                    withAnimation { isDragging = false }
                    if value.translation.height > 100 || value.predictedEndTranslation.height > 200
                    {
                        isSheetPresented = false
                    }
                }
        )
        .onAppear {
            // Staggered animation of content appearance
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                contentAppeared = true
            }

            // Prepare export filename
            exportFileName = savedCode.name.isEmpty ? "QRCode" : savedCode.name
        }
        #if os(iOS)
            .sheet(isPresented: $showingEditSheet) {
                // Use a NavigationView to have a proper toolbar in the sheet
                NavigationView {
                    QRCodeEditView(
                        viewModel: viewModel,
                        originalCode: savedCode,
                        isPresented: $showingEditSheet
                    )
                    .navigationBarTitleDisplayMode(.inline)
                }
                .accentColor(Color.appAccent)  // Apply accent color to navigation bar
            }
            .sheet(isPresented: $showingExportSheet) {
                VStack(spacing: 20) {
                    // Sheet header with handle indicator
                    Capsule()
                    .fill(Color.appSurface2)
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                    Text("Export QR Code Image")
                    .font(.headline)
                    .foregroundColor(Color.appText)

                    // Preview of the QR code
                    let qrDocument = QRCodeGenerator.generateQRCode(
                        from: savedCode.content, with: savedCode.style)
                    if let uiImage = try? qrDocument.uiImage(CGSize(width: 150, height: 150)) {
                        Image(uiImage: uiImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }

                    // Filename field
                    TextField("Filename", text: $exportFileName)
                    .padding()
                    .background(Color.appSurface.opacity(0.5))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // Format picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Format")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)
                        .padding(.horizontal)

                        Picker("Format", selection: $selectedExportFormat) {
                            Text("PNG").tag(QRCodeExportFormat.png)
                            Text("SVG").tag(QRCodeExportFormat.svg)
                            Text("PDF").tag(QRCodeExportFormat.pdf)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                    }

                    // Action buttons
                    HStack {
                        Button(action: {
                            showingExportSheet = false
                        }) {
                            Text("Cancel")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.appRed.opacity(0.1))
                            .foregroundColor(Color.appRed)
                            .cornerRadius(12)
                        }

                        Button(action: {
                            exportedFileURL = QRCodeGenerator.saveQRCodeToFile(
                                qrCode: qrDocument,
                                fileName: exportFileName,
                                fileFormat: selectedExportFormat
                            )

                            if exportedFileURL != nil {
                                showingExportSheet = false
                                showingShareSheet = true
                            }
                        }) {
                            Text("Export")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.appGreen)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(exportFileName.isEmpty)
                    }
                    .padding()
                }
                .padding(.bottom)
                .background(Color.appBackground)
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportedFileURL {
                    ShareSheet(items: [url])
                }
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Delete QR Code"),
                    message: Text(
                        "Are you sure you want to delete this QR code? This action cannot be undone."
                    ),
                    primaryButton: .destructive(Text("Delete")) {
                        viewModel.deleteSavedQRCode(withID: savedCode.id)
                        isSheetPresented = false
                    },
                    secondaryButton: .cancel()
                )
            }
        #else
            .sheet(isPresented: $showingExportSheet) {
                MacExportPanel_SavedCode(savedCode: savedCode, isPresented: $showingExportSheet)
                .frame(width: 400, height: 300)
            }
        #endif
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    // Helper to format content display based on type
    private func contentDisplay(for content: QRCodeContent) -> String {
        switch content.data {
        case .link(let url):
            return url
        case .text(let text):
            return text
        case .phone(let number):
            return "Phone: \(number)"
        case .email(let address, let subject, let body):
            var result = "Email: \(address)"
            if !subject.isEmpty {
                result += "\nSubject: \(subject)"
            }
            if !body.isEmpty {
                result += "\nBody: \(body)"
            }
            return result
        case .wifi(let ssid, let password, let isHidden, let security):
            var result = "Network: \(ssid)"
            if security != .nopass {
                result += "\nPassword: \(password)"
            }
            result += "\nSecurity: \(security.description)"
            if isHidden {
                result += "\nHidden Network: Yes"
            }
            return result
        case .whatsapp(let number, let message):
            var result = "WhatsApp: \(number)"
            if !message.isEmpty {
                result += "\nMessage: \(message)"
            }
            return result
        case .vCard(
            let firstName, let lastName, let organization, let title, let phone, let email,
            let address, let website, let note):
            var result = "Name: \(firstName) \(lastName)"

            let fields: [(String, String)] = [
                ("Organization", organization),
                ("Title", title),
                ("Phone", phone),
                ("Email", email),
                ("Address", address),
                ("Website", website),
                ("Note", note),
            ]

            for (label, value) in fields where !value.isEmpty {
                result += "\n\(label): \(value)"
            }

            return result
        }
    }
}

#if os(macOS)
    struct MacExportPanel_SavedCode: View {
        let savedCode: SavedQRCode
        @Binding var isPresented: Bool
        @State private var selectedFormat: QRCodeExportFormat = .png
        @State private var fileName: String = "QRCode"

        var body: some View {
            VStack(spacing: 20) {
                Text("Export QR Code Image")
                    .font(.headline)

                // Preview of the QR code
                let qrDocument = QRCodeGenerator.generateQRCode(
                    from: savedCode.content, with: savedCode.style)
                if let nsImage = try? qrDocument.nsImage(CGSize(width: 150, height: 150)) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .interpolation(.none)
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }

                // Filename field
                TextField("Filename", text: $fileName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 300)

                // Format picker
                Picker("Format", selection: $selectedFormat) {
                    Text("PNG").tag(QRCodeExportFormat.png)
                    Text("SVG").tag(QRCodeExportFormat.svg)
                    Text("PDF").tag(QRCodeExportFormat.pdf)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 300)

                HStack(spacing: 20) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .keyboardShortcut(.cancelAction)

                    Button("Export") {
                        exportQRCode()
                        isPresented = false
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(fileName.isEmpty)
                }
                .padding(.top)
            }
            .padding()
            .onAppear {
                fileName = savedCode.name.isEmpty ? "QRCode" : savedCode.name
            }
        }

        private func exportQRCode() {
            let savePanel = NSSavePanel()
            savePanel.allowedFileTypes = [selectedFormat.fileExtension]
            savePanel.nameFieldStringValue = fileName

            if savePanel.runModal() == .OK, let url = savePanel.url {
                let qrDocument = QRCodeGenerator.generateQRCode(
                    from: savedCode.content, with: savedCode.style)
                let fileExtension = url.pathExtension.lowercased()

                do {
                    var data: Data?

                    switch fileExtension {
                    case "svg":
                        data = try qrDocument.svgData(dimension: 1024)
                    case "pdf":
                        data = try qrDocument.pdfData(dimension: 1024)
                    default:
                        data = try qrDocument.pngData(dimension: 1024)
                    }

                    if let data = data {
                        try data.write(to: url)
                    }
                } catch {
                    print("Error exporting QR code: \(error)")
                }
            }
        }
    }
#endif
