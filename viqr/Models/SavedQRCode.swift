//
//  SavedQRCode.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import Foundation

struct SavedQRCode: Identifiable, Codable {
    var id = UUID()
    var name: String
    var dateCreated: Date
    var content: QRCodeContent
    var style: QRCodeStyle

    init(name: String, content: QRCodeContent, style: QRCodeStyle) {
        self.name = name
        self.dateCreated = Date()
        self.content = content
        self.style = style
    }
}
