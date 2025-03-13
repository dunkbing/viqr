//
//  QRCodeViewModel.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import Foundation
import SwiftUI
import QRCode
import Combine
import SwiftData

class QRCodeViewModel: ObservableObject {
    @Published var selectedType: QRCodeType = .link
    @Published var qrContent: QRCodeContent
    @Published var qrStyle: QRCodeStyle = QRCodeStyle()
    @Published var savedCodes: [SavedQRCode] = []

    private let savedCodesKey = "SavedQRCodes"
    private var cancellables = Set<AnyCancellable>()

    // SwiftData model context (will be injected)
    var modelContext: ModelContext?

    init() {
        self.qrContent = QRCodeContent(type: .link, data: .link(url: "https://"))

        // Load saved codes from UserDefaults (for backward compatibility)
        loadSavedCodes()

        // Set up observers for automatic content type switching
        $selectedType
            .sink { [weak self] newType in
                self?.updateContentType(to: newType)
            }
            .store(in: &cancellables)
    }

    // Generate QR code with current content and style
    func generateQRCode() -> QRCode.Document {
        return QRCodeGenerator.generateQRCode(from: qrContent, with: qrStyle)
    }

    // Save current QR code to SwiftData
    func saveCurrentQRCode(name: String) {
        guard let modelContext = modelContext else {
            // Fallback to UserDefaults if SwiftData is not available
            saveLegacyQRCode(name: name)
            return
        }

        let qrCodeModel = QRCodeModel(name: name, content: qrContent, style: qrStyle)
        modelContext.insert(qrCodeModel)

        do {
            try modelContext.save()

            // Update the published savedCodes for UI updates
            loadQRCodesFromSwiftData()
        } catch {
            print("Error saving QR code to SwiftData: \(error)")
            // Fallback to UserDefaults
            saveLegacyQRCode(name: name)
        }
    }

    // Load QR codes from SwiftData
    func loadQRCodesFromSwiftData() {
        guard let modelContext = modelContext else { return }

        do {
            let descriptor = FetchDescriptor<QRCodeModel>(sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
            let qrModels = try modelContext.fetch(descriptor)

            // Convert to SavedQRCode objects for compatibility with existing UI
            savedCodes = qrModels.compactMap { $0.toSavedQRCode() }
        } catch {
            print("Error fetching QR codes from SwiftData: \(error)")
        }
    }

    // Delete a saved QR code
    func deleteSavedQRCode(at indexSet: IndexSet) {
        guard let modelContext = modelContext else {
            // Fallback to UserDefaults
            savedCodes.remove(atOffsets: indexSet)
            saveToDisk()
            return
        }

        for index in indexSet {
            let qrCode = savedCodes[index]

            // Find and delete the corresponding SwiftData model
            let descriptor = FetchDescriptor<QRCodeModel>(predicate: #Predicate { $0.id == qrCode.id })
            if let models = try? modelContext.fetch(descriptor), let model = models.first {
                modelContext.delete(model)
                try? modelContext.save()
            }
        }

        // Update the local array for UI
        savedCodes.remove(atOffsets: indexSet)
    }

    // Load a saved QR code into the current editor
    func loadSavedQRCode(_ savedCode: SavedQRCode) {
        qrContent = savedCode.content
        qrStyle = savedCode.style
        selectedType = savedCode.content.typeEnum
    }

    // Export QR code as an image file
    func exportQRCode(as format: QRCodeExportFormat, named fileName: String) -> URL? {
        let qrCode = generateQRCode()
        return QRCodeGenerator.saveQRCodeToFile(qrCode: qrCode, fileName: fileName, fileFormat: format)
    }

    // Update content type when selected type changes
    private func updateContentType(to newType: QRCodeType) {
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
            currentData = .vCard(firstName: "", lastName: "", organization: "", title: "", phone: "", email: "", address: "", website: "", note: "")
        }

        qrContent = QRCodeContent(type: newType, data: currentData)
    }

    // Legacy methods for backward compatibility

    private func saveLegacyQRCode(name: String) {
        let newSavedCode = SavedQRCode(
            name: name,
            content: qrContent,
            style: qrStyle
        )

        savedCodes.append(newSavedCode)
        saveToDisk()
    }

    // Save to UserDefaults
    private func saveToDisk() {
        if let encoded = try? JSONEncoder().encode(savedCodes) {
            UserDefaults.standard.set(encoded, forKey: savedCodesKey)
        }
    }

    // Load from UserDefaults
    private func loadSavedCodes() {
        if let savedData = UserDefaults.standard.data(forKey: savedCodesKey),
           let decodedCodes = try? JSONDecoder().decode([SavedQRCode].self, from: savedData) {
            savedCodes = decodedCodes
        }
    }
}
