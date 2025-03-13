//
//  QRCodeType.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import Foundation
import SwiftUI

enum QRCodeType: String, CaseIterable, Identifiable {
    case link = "Link"
    case text = "Text"
    case email = "E-mail"
    case phone = "Phone"
    case whatsapp = "Whatsapp"
    case wifi = "Wifi"
    case vCard = "V-Card"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .link:
            return "link"
        case .text:
            return "text.alignleft"
        case .email:
            return "envelope"
        case .phone:
            return "phone"
        case .whatsapp:
            return "message"
        case .wifi:
            return "wifi"
        case .vCard:
            return "person.crop.rectangle"
        }
    }

    var description: String {
        switch self {
        case .link:
            return "Website URL"
        case .text:
            return "Plain text"
        case .email:
            return "Email address"
        case .phone:
            return "Phone number"
        case .whatsapp:
            return "WhatsApp contact"
        case .wifi:
            return "WiFi network"
        case .vCard:
            return "Contact information"
        }
    }
}
