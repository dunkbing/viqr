//
//  QRCodeModel.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class QRCodeModel {
    var id: UUID
    var name: String
    var dateCreated: Date
    var type: String
    var contentData: Data
    var styleData: Data

    init(name: String, content: QRCodeContent, style: QRCodeStyle) {
        self.id = UUID()
        self.name = name
        self.dateCreated = Date()
        self.type = content.type

        // Encode content and style to Data
        let encoder = JSONEncoder()
        self.contentData = (try? encoder.encode(content)) ?? Data()
        self.styleData = (try? encoder.encode(style)) ?? Data()
    }

    // Helper functions to decode content and style
    func getContent() -> QRCodeContent? {
        let decoder = JSONDecoder()
        return try? decoder.decode(QRCodeContent.self, from: contentData)
    }

    func getStyle() -> QRCodeStyle? {
        let decoder = JSONDecoder()
        return try? decoder.decode(QRCodeStyle.self, from: styleData)
    }

    // Convert to SavedQRCode for backward compatibility
    func toSavedQRCode() -> SavedQRCode? {
        guard let content = getContent(), let style = getStyle() else { return nil }
        var savedCode = SavedQRCode(name: name, content: content, style: style)
        savedCode.id = id
        savedCode.dateCreated = dateCreated
        return savedCode
    }
}
