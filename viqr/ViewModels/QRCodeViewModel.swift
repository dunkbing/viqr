//
//  QRCodeViewModel.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import Combine
import Foundation
import QRCode
import SwiftUI

class QRCodeViewModel: ObservableObject {
    @Published var selectedType: QRCodeType = .link
    @Published var qrContent: QRCodeContent
    @Published var qrStyle: QRCodeStyle = QRCodeStyle()
    @Published var savedCodes: [SavedQRCode] = []

    // Flag to determine if editing an existing QR code
    @Published var isEditingExisting = false

    // Reference to currently editing QR code
    @Published var currentEditingCode: SavedQRCode?

    // Property to check if type can be changed (some types might be complex to convert)
    var canChangeType: Bool {
        // For now we'll allow changing type for all QR codes
        // You could add logic here to prevent changing types for certain QR codes
        // if there's concern about data loss when switching types
        return true
    }

    private let savedCodesKey = "SavedQRCodes"
    private var cancellables = Set<AnyCancellable>()

    private var isLoadingSavedQRCode = false

    init() {
        self.qrContent = QRCodeContent(type: .link, data: .link(url: "https://"))

        // Load saved codes from UserDefaults
        loadSavedCodes()

        // Set up observers for automatic content type switching
        $selectedType
            .sink { [weak self] newType in
                if self?.isLoadingSavedQRCode != true {
                    self?.updateContentType(to: newType)
                }
            }
            .store(in: &cancellables)
    }

    // Generate QR code with current content and style
    func generateQRCode() -> QRCode.Document {
        return QRCodeGenerator.generateQRCode(from: qrContent, with: qrStyle)
    }

    // Save current QR code
    func saveCurrentQRCode(name: String) {
        let newSavedCode = SavedQRCode(
            name: name,
            content: qrContent,
            style: qrStyle
        )

        savedCodes.append(newSavedCode)
        saveToDisk()
    }

    // Update an existing QR code
    func updateSavedQRCode(originalID: UUID, name: String) {
        // Find the index of the QR code to update
        if let index = savedCodes.firstIndex(where: { $0.id == originalID }) {
            // Create an updated QR code
            let updatedQRCode = SavedQRCode(
                id: originalID,
                name: name,
                dateCreated: savedCodes[index].dateCreated,
                content: qrContent,
                style: qrStyle
            )

            // Replace the old QR code with the updated one
            savedCodes[index] = updatedQRCode
            saveToDisk()

            // Reset the editing state
            isEditingExisting = false
        }
    }

    // Delete a saved QR code
    func deleteSavedQRCode(at indexSet: IndexSet) {
        savedCodes.remove(atOffsets: indexSet)
        saveToDisk()
    }

    // Delete a saved QR code by ID
    func deleteSavedQRCode(withID id: UUID) {
        savedCodes.removeAll { $0.id == id }
        saveToDisk()
    }

    // Load a saved QR code into the current editor
    func loadSavedQRCode(_ savedCode: SavedQRCode) {
        isLoadingSavedQRCode = true

        qrStyle = savedCode.style
        selectedType = savedCode.content.typeEnum
        qrContent = savedCode.content

        // Set the editing flag
        isEditingExisting = true

        DispatchQueue.main.async {
            self.isLoadingSavedQRCode = false
        }

        print("Loaded QR Code: Type=\(savedCode.content.typeEnum.rawValue)")
    }

    // Reset to create a new QR code
    func resetForNewQRCode() {
        isEditingExisting = false
        currentEditingCode = nil
        qrContent = QRCodeContent(type: .link, data: .link(url: "https://"))
        qrStyle = QRCodeStyle()
        selectedType = .link
    }

    // Export QR code as an image file
    func exportQRCode(as format: QRCodeExportFormat, named fileName: String) -> URL? {
        let qrCode = generateQRCode()
        return QRCodeGenerator.saveQRCodeToFile(
            qrCode: qrCode, fileName: fileName, fileFormat: format)
    }

    // Update content type when selected type changes
    private func updateContentType(to newType: QRCodeType) {
        print("Updating content type to: \(newType.rawValue)")

        let currentData: ContentData

        switch newType {
        case .link:
            currentData = .link(url: "https://")
        case .text:
            currentData = .text(content: "")
        case .email:
            currentData = .email(address: "", subject: "", body: "")
        case .phone:
            currentData = .phone(number: "")
        case .whatsapp:
            currentData = .whatsapp(number: "", message: "")
        case .wifi:
            currentData = .wifi(ssid: "", password: "", isHidden: false, security: .WPA)
        case .vCard:
            currentData = .vCard(
                firstName: "", lastName: "", organization: "", title: "", phone: "", email: "",
                address: "", website: "", note: "")
        }

        qrContent = QRCodeContent(type: newType, data: currentData)
    }

    // Save to UserDefaults - make this public so we can call it from settings
    func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(savedCodes) {
            UserDefaults.standard.set(encoded, forKey: savedCodesKey)
        }
    }

    // Load from UserDefaults
    private func loadSavedCodes() {
        if let savedData = UserDefaults.standard.data(forKey: savedCodesKey),
            let decodedCodes = try? JSONDecoder().decode([SavedQRCode].self, from: savedData)
        {
            savedCodes = decodedCodes
        }
    }
}

// Extension for SavedQRCode to add a custom initializer with ID
extension SavedQRCode {
    init(id: UUID, name: String, dateCreated: Date, content: QRCodeContent, style: QRCodeStyle) {
        self.id = id
        self.name = name
        self.dateCreated = dateCreated
        self.content = content
        self.style = style
    }
}
