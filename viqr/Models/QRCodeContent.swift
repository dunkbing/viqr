//
//  QRCodeContent.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import Foundation

struct QRCodeContent: Codable, Identifiable {
    var id = UUID()
    var type: String // Using String instead of QRCodeType for Codable
    var title: String = ""
    var data: ContentData

    var typeEnum: QRCodeType {
        return QRCodeType(rawValue: type) ?? .text
    }

    init(type: QRCodeType, data: ContentData = .link(url: "")) {
        self.type = type.rawValue
        self.data = data
    }
}

enum ContentData: Codable, Equatable {
    case link(url: String)
    case text(content: String)
    case email(address: String, subject: String, body: String)
    case phone(number: String)
    case whatsapp(number: String, message: String)
    case wifi(ssid: String, password: String, isHidden: Bool, security: WiFiSecurity)
    case vCard(firstName: String, lastName: String, organization: String, title: String, phone: String, email: String, address: String, website: String, note: String)

    // Helper method to get the formatted content string for QR code generation
    func formattedString() -> String {
        switch self {
        case .link(let url):
            return url
        case .text(let content):
            return content
        case .email(let address, let subject, let body):
            var emailString = "mailto:\(address)"
            if !subject.isEmpty || !body.isEmpty {
                emailString += "?"
                if !subject.isEmpty {
                    emailString += "subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                }
                if !body.isEmpty {
                    emailString += subject.isEmpty ? "" : "&"
                    emailString += "body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                }
            }
            return emailString
        case .phone(let number):
            return "tel:\(number)"
        case .whatsapp(let number, let message):
            return "https://wa.me/\(number.replacingOccurrences(of: "+", with: "").replacingOccurrences(of: " ", with: ""))?text=\(message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        case .wifi(let ssid, let password, let isHidden, let security):
            let securityStr = security == .nopass ? "nopass" : security.rawValue
            var wifiString = "WIFI:S:\(ssid);"
            if security != .nopass {
                wifiString += "P:\(password);"
            }
            wifiString += "T:\(securityStr);"
            if isHidden {
                wifiString += "H:true;"
            }
            wifiString += ";"
            return wifiString
        case .vCard(let firstName, let lastName, let organization, let title, let phone, let email, let address, let website, let note):
            var vCardString = "BEGIN:VCARD\nVERSION:3.0\n"
            vCardString += "N:\(lastName);\(firstName);;;\n"
            vCardString += "FN:\(firstName) \(lastName)\n"
            if !organization.isEmpty {
                vCardString += "ORG:\(organization)\n"
            }
            if !title.isEmpty {
                vCardString += "TITLE:\(title)\n"
            }
            if !phone.isEmpty {
                vCardString += "TEL;TYPE=CELL:\(phone)\n"
            }
            if !email.isEmpty {
                vCardString += "EMAIL:\(email)\n"
            }
            if !address.isEmpty {
                vCardString += "ADR:;;\(address);;;;\n"
            }
            if !website.isEmpty {
                vCardString += "URL:\(website)\n"
            }
            if !note.isEmpty {
                vCardString += "NOTE:\(note)\n"
            }
            vCardString += "END:VCARD"
            return vCardString
        }
    }

    // Private enum for coding/decoding
    private enum CodingKeys: String, CodingKey {
        case type, url, content, address, subject, body, number, message, ssid, password, isHidden, security
        case firstName, lastName, organization, title, phone, email, address_vcard, website, note
    }

    // Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .link(let url):
            try container.encode("link", forKey: .type)
            try container.encode(url, forKey: .url)
        case .text(let content):
            try container.encode("text", forKey: .type)
            try container.encode(content, forKey: .content)
        case .email(let address, let subject, let body):
            try container.encode("email", forKey: .type)
            try container.encode(address, forKey: .address)
            try container.encode(subject, forKey: .subject)
            try container.encode(body, forKey: .body)
        case .phone(let number):
            try container.encode("phone", forKey: .type)
            try container.encode(number, forKey: .number)
        case .whatsapp(let number, let message):
            try container.encode("whatsapp", forKey: .type)
            try container.encode(number, forKey: .number)
            try container.encode(message, forKey: .message)
        case .wifi(let ssid, let password, let isHidden, let security):
            try container.encode("wifi", forKey: .type)
            try container.encode(ssid, forKey: .ssid)
            try container.encode(password, forKey: .password)
            try container.encode(isHidden, forKey: .isHidden)
            try container.encode(security.rawValue, forKey: .security)
        case .vCard(let firstName, let lastName, let organization, let title, let phone, let email, let address, let website, let note):
            try container.encode("vCard", forKey: .type)
            try container.encode(firstName, forKey: .firstName)
            try container.encode(lastName, forKey: .lastName)
            try container.encode(organization, forKey: .organization)
            try container.encode(title, forKey: .title)
            try container.encode(phone, forKey: .phone)
            try container.encode(email, forKey: .email)
            try container.encode(address, forKey: .address_vcard)
            try container.encode(website, forKey: .website)
            try container.encode(note, forKey: .note)
        }
    }

    // Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "link":
            let url = try container.decode(String.self, forKey: .url)
            self = .link(url: url)
        case "text":
            let content = try container.decode(String.self, forKey: .content)
            self = .text(content: content)
        case "email":
            let address = try container.decode(String.self, forKey: .address)
            let subject = try container.decode(String.self, forKey: .subject)
            let body = try container.decode(String.self, forKey: .body)
            self = .email(address: address, subject: subject, body: body)
        case "phone":
            let number = try container.decode(String.self, forKey: .number)
            self = .phone(number: number)
        case "whatsapp":
            let number = try container.decode(String.self, forKey: .number)
            let message = try container.decode(String.self, forKey: .message)
            self = .whatsapp(number: number, message: message)
        case "wifi":
            let ssid = try container.decode(String.self, forKey: .ssid)
            let password = try container.decode(String.self, forKey: .password)
            let isHidden = try container.decode(Bool.self, forKey: .isHidden)
            let securityStr = try container.decode(String.self, forKey: .security)
            let security = WiFiSecurity(rawValue: securityStr) ?? .WPA
            self = .wifi(ssid: ssid, password: password, isHidden: isHidden, security: security)
        case "vCard":
            let firstName = try container.decode(String.self, forKey: .firstName)
            let lastName = try container.decode(String.self, forKey: .lastName)
            let organization = try container.decode(String.self, forKey: .organization)
            let title = try container.decode(String.self, forKey: .title)
            let phone = try container.decode(String.self, forKey: .phone)
            let email = try container.decode(String.self, forKey: .email)
            let address = try container.decode(String.self, forKey: .address_vcard)
            let website = try container.decode(String.self, forKey: .website)
            let note = try container.decode(String.self, forKey: .note)
            self = .vCard(firstName: firstName, lastName: lastName, organization: organization, title: title, phone: phone, email: email, address: address, website: website, note: note)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown content type")
        }
    }
}

enum WiFiSecurity: String, Codable, CaseIterable {
    case WPA = "WPA"
    case WEP = "WEP"
    case nopass = "nopass"

    var description: String {
        switch self {
        case .WPA:
            return "WPA/WPA2"
        case .WEP:
            return "WEP"
        case .nopass:
            return "No Password"
        }
    }
}
