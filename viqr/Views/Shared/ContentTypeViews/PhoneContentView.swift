//
//  PhoneContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI

struct PhoneContentView: View {
    @Binding var content: QRCodeContent

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Phone Number")
                .font(.headline)

            if case .phone(let number) = content.data {
                TextField(
                    "Phone Number (e.g., +1 555 123 4567)",
                    text: Binding(
                        get: { number },
                        set: { content.data = .phone(number: $0) }
                    )
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                //                .keyboardType(.phonePad)
            }

            Text("Include the country code for international numbers (e.g., +1 for USA).")
                .font(.caption)
                .foregroundColor(.gray)

            Text("Scanning this QR code will prompt to call this number.")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}
