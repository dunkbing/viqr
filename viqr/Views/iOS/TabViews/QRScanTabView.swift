//
//  QRScanTabView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 24/3/25.
//

import CodeScanner
import SwiftUI
import TikimUI

#if os(iOS)
    struct QRScanTabView: View {
        @ObservedObject var viewModel: QRCodeViewModel
        @Binding var isScannerActive: Bool

        @State private var isShowingScanner = true
        @State private var scannedCode: String? = nil
        @State private var showSaveDialog = false
        @State private var qrCodeName = ""
        @State private var showScannedDetail = false
        @State private var savedQRCode: SavedQRCode? = nil
        @State private var showCameraPermissionAlert = false
        @State private var scannerError: String? = nil

        var body: some View {
            ZStack {
                // Background
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Scan QR Code")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color.appText)

                        Spacer()

                        // Rescan button
                        if !isShowingScanner {
                            Button(action: {
                                isShowingScanner = true
                                scannedCode = nil
                            }) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color.appAccent)
                                    .padding(10)
                                    .background(Color.appSurface2.opacity(0.3))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Scanner view
                    ZStack {
                        if isShowingScanner && isScannerActive {
                            CodeScannerView(
                                codeTypes: [.qr, .ean8, .ean13, .pdf417, .aztec, .code128],
                                scanMode: .continuous,
                                showViewfinder: true,
                                simulatedData: "https://example.com",
                                shouldVibrateOnSuccess: true
                            ) { response in
                                switch response {
                                case .success(let result):
                                    // Process the scanned code
                                    scannedCode = result.string
                                    isShowingScanner = false
                                    handleScannedCode(result.string)
                                case .failure(let error):
                                    scannerError = error.localizedDescription
                                    showCameraPermissionAlert = true
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let error = scannerError {
                            // Error view
                            VStack(spacing: 20) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color.appOrange)

                                Text("Scanner Error")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(Color.appText)

                                Text(error)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color.appSubtitle)
                                    .padding(.horizontal)

                                Button(action: {
                                    scannerError = nil
                                    isShowingScanner = true
                                }) {
                                    Text("Try Again")
                                        .font(.system(size: 16, weight: .medium))
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 30)
                                        .background(Color.appAccent)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                .padding(.top, 10)
                            }
                            .padding()
                            .background(Color.appSurface)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.1), radius: 10)
                            .padding(.horizontal, 20)
                        } else {
                            // Processing indicator
                            VStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(1.5)
                                    .padding()

                                Text("Processing QR code...")
                                    .foregroundColor(Color.appSubtitle)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.7))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .sheet(isPresented: $showSaveDialog) {
                SaveScannedQRBottomSheet(
                    isPresented: $showSaveDialog,
                    qrCodeName: $qrCodeName,
                    qrContent: scannedCode ?? "",
                    onSave: {
                        saveScannedQRCode()
                    },
                    onCancel: {
                        scannedCode = nil
                        isShowingScanner = true
                    }
                )
                .background(Color.appBackground)
            }
            .sheet(item: $savedQRCode) { saved in
                SavedQRDetailView(
                    viewModel: viewModel,
                    savedCode: saved
                )
                .onDisappear {
                    scannedCode = nil
                    isShowingScanner = true
                }
            }
            .alert(isPresented: $showCameraPermissionAlert) {
                Alert(
                    title: Text("Camera Access Required"),
                    message: Text("Please allow camera access in Settings to scan QR codes."),
                    primaryButton: .default(Text("Open Settings")) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }

        private func handleScannedCode(_ code: String) {
            // Analyze the code to determine its type and parse content
            let qrContent = analyzeScannedCode(code)

            // Determine a default name based on content
            qrCodeName = generateDefaultName(for: qrContent)

            // Save automatically and show detail
            if UserDefaults.standard.bool(forKey: "autoSaveScans") {
                saveScannedQRCode()
            } else {
                // Ask user to save
                showSaveDialog = true
            }
        }

        private func analyzeScannedCode(_ code: String) -> QRCodeContent {
            // Let's try to determine what type of QR code this is

            // Check if it's a URL
            if code.lowercased().hasPrefix("http://") || code.lowercased().hasPrefix("https://") {
                viewModel.qrContent = QRCodeContent(type: .link, data: .link(url: code))
                return viewModel.qrContent
            }

            // Check if it's an email
            if code.lowercased().hasPrefix("mailto:") {
                let emailCode = code.replacingOccurrences(of: "mailto:", with: "")
                let components = emailCode.components(separatedBy: "?")

                let address = components[0]
                var subject = ""
                var body = ""

                if components.count > 1 {
                    let params = components[1].components(separatedBy: "&")
                    for param in params {
                        let keyValue = param.components(separatedBy: "=")
                        if keyValue.count == 2 {
                            let key = keyValue[0].lowercased()
                            let value = keyValue[1].removingPercentEncoding ?? keyValue[1]

                            if key == "subject" {
                                subject = value
                            } else if key == "body" {
                                body = value
                            }
                        }
                    }
                }

                viewModel.qrContent = QRCodeContent(
                    type: .email, data: .email(address: address, subject: subject, body: body))
                return viewModel.qrContent
            }

            // Check if it's a phone number
            if code.lowercased().hasPrefix("tel:") {
                let number = code.replacingOccurrences(of: "tel:", with: "")
                viewModel.qrContent = QRCodeContent(type: .phone, data: .phone(number: number))
                return viewModel.qrContent
            }

            // Check if it's a WhatsApp
            if code.lowercased().hasPrefix("https://wa.me/") {
                let waCode = code.replacingOccurrences(of: "https://wa.me/", with: "")
                let components = waCode.components(separatedBy: "?text=")

                let number = components[0]
                let message =
                    components.count > 1
                    ? (components[1].removingPercentEncoding ?? components[1]) : ""

                viewModel.qrContent = QRCodeContent(
                    type: .whatsapp, data: .whatsapp(number: number, message: message))
                return viewModel.qrContent
            }

            // Check if it's a WiFi configuration
            if code.uppercased().hasPrefix("WIFI:") {
                // Parse WiFi format: WIFI:S:<SSID>;T:<TYPE>;P:<PASSWORD>;H:<HIDDEN>;;
                let wifiCode = code.replacingOccurrences(of: "WIFI:", with: "")

                var ssid = ""
                var password = ""
                var security: WiFiSecurity = .WPA
                var isHidden = false

                let components = wifiCode.components(separatedBy: ";")
                for component in components {
                    if component.hasPrefix("S:") {
                        ssid = component.replacingOccurrences(of: "S:", with: "")
                    } else if component.hasPrefix("P:") {
                        password = component.replacingOccurrences(of: "P:", with: "")
                    } else if component.hasPrefix("T:") {
                        let securityStr = component.replacingOccurrences(of: "T:", with: "")
                            .uppercased()
                        if securityStr == "WPA" || securityStr == "WPA2" {
                            security = .WPA
                        } else if securityStr == "WEP" {
                            security = .WEP
                        } else if securityStr == "NOPASS" {
                            security = .nopass
                        }
                    } else if component.hasPrefix("H:") {
                        let hiddenStr = component.replacingOccurrences(of: "H:", with: "")
                            .lowercased()
                        isHidden = hiddenStr == "true"
                    }
                }

                viewModel.qrContent = QRCodeContent(
                    type: .wifi,
                    data: .wifi(
                        ssid: ssid, password: password, isHidden: isHidden, security: security))
                return viewModel.qrContent
            }

            // Check if it's a vCard
            if code.uppercased().hasPrefix("BEGIN:VCARD") {
                var firstName = ""
                var lastName = ""
                var organization = ""
                var title = ""
                var phone = ""
                var email = ""
                var address = ""
                var website = ""
                var note = ""

                let lines = code.components(separatedBy: .newlines)
                for line in lines {
                    if line.uppercased().hasPrefix("N:") {
                        let nameParts = line.replacingOccurrences(of: "N:", with: "").components(
                            separatedBy: ";")
                        if nameParts.count > 1 {
                            lastName = nameParts[0]
                            firstName = nameParts[1]
                        }
                    } else if line.uppercased().hasPrefix("ORG:") {
                        organization = line.replacingOccurrences(of: "ORG:", with: "")
                    } else if line.uppercased().hasPrefix("TITLE:") {
                        title = line.replacingOccurrences(of: "TITLE:", with: "")
                    } else if line.uppercased().hasPrefix("TEL:")
                        || line.uppercased().hasPrefix("TEL;")
                    {
                        phone = line.components(separatedBy: ":").last ?? ""
                    } else if line.uppercased().hasPrefix("EMAIL:")
                        || line.uppercased().hasPrefix("EMAIL;")
                    {
                        email = line.components(separatedBy: ":").last ?? ""
                    } else if line.uppercased().hasPrefix("ADR:")
                        || line.uppercased().hasPrefix("ADR;")
                    {
                        address = line.components(separatedBy: ":").last ?? ""
                    } else if line.uppercased().hasPrefix("URL:") {
                        website = line.replacingOccurrences(of: "URL:", with: "")
                    } else if line.uppercased().hasPrefix("NOTE:") {
                        note = line.replacingOccurrences(of: "NOTE:", with: "")
                    }
                }

                viewModel.qrContent = QRCodeContent(
                    type: .vCard,
                    data: .vCard(
                        firstName: firstName,
                        lastName: lastName,
                        organization: organization,
                        title: title,
                        phone: phone,
                        email: email,
                        address: address,
                        website: website,
                        note: note
                    ))
                return viewModel.qrContent
            }

            // If we can't determine a specific type, treat it as plain text
            viewModel.qrContent = QRCodeContent(type: .text, data: .text(content: code))
            return viewModel.qrContent
        }

        private func generateDefaultName(for content: QRCodeContent) -> String {
            // Create a meaningful name based on the content type and data
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
            let timestamp = dateFormatter.string(from: Date())

            switch content.data {
            case .link(let url):
                // Extract domain from URL
                if let host = URL(string: url)?.host {
                    return "Link_\(host)"
                }
                return "QR_Link_\(timestamp)"

            case .text(let text):
                let previewText = text.prefix(15)
                return "Text_\(previewText)".replacingOccurrences(of: " ", with: "_")

            case .email(let address, _, _):
                return "Email_\(address)"

            case .phone(let number):
                return "Phone_\(number)"

            case .whatsapp(let number, _):
                return "WhatsApp_\(number)"

            case .wifi(let ssid, _, _, _):
                return "WiFi_\(ssid)"

            case .vCard(let firstName, let lastName, _, _, _, _, _, _, _):
                if !firstName.isEmpty || !lastName.isEmpty {
                    return "Contact_\(firstName)_\(lastName)"
                }
                return "Contact_\(timestamp)"
            }
        }

        private func saveScannedQRCode() {
            // Generate a default style for the QR code
            let style = QRCodeStyle()

            // Create a new saved QR code
            let newSavedCode = SavedQRCode(
                name: qrCodeName,
                content: viewModel.qrContent,
                style: style
            )

            // Add to saved codes
            viewModel.savedCodes.append(newSavedCode)
            viewModel.saveToDisk()

            // Set as the selected code to show details
            savedQRCode = newSavedCode

            // Reset scanning state
            showSaveDialog = false
        }
    }

    struct SaveScannedQRBottomSheet: View {
        @Binding var isPresented: Bool
        @Binding var qrCodeName: String
        let qrContent: String
        var onSave: () -> Void
        var onCancel: () -> Void

        var body: some View {
            VStack(spacing: 20) {
                Text("Save Scanned QR Code")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.appText)
                    .padding(.top, 8)

                // QR Content preview
                VStack(alignment: .leading, spacing: 10) {
                    Text("Scanned Content:")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)

                    Text(qrContent.prefix(100) + (qrContent.count > 100 ? "..." : ""))
                        .font(.system(size: 14))
                        .foregroundColor(Color.appText)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.appSurface2.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // Name input field
                VStack(alignment: .leading, spacing: 8) {
                    Text("QR Code Name")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)

                    TextField("Enter a name for this QR code", text: $qrCodeName)
                        .padding()
                        .background(Color.appSurface.opacity(0.5))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appAccent.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal)

                // Action buttons
                HStack(spacing: 16) {
                    Button(action: {
                        onCancel()
                        isPresented = false
                    }) {
                        HStack {
                            Image(systemName: "xmark")
                            Text("Cancel")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.appRed.opacity(0.1))
                        .foregroundColor(Color.appRed)
                        .cornerRadius(16)
                    }

                    Button(action: {
                        onSave()
                    }) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Save")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            qrCodeName.isEmpty ? Color.appGreen.opacity(0.5) : Color.appGreen
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    }
                    .disabled(qrCodeName.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .padding(.top, 4)
        }
    }
#endif
