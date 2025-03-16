//
//  WhatsappContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI

struct WhatsappContentView: View {
    @Binding var content: QRCodeContent

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WhatsApp Message")
                .font(.headline)

            if case .whatsapp(let number, let message) = content.data {
                Group {
                    TextField(
                        "Phone Number (with country code, e.g., +1 555 123 4567)",
                        text: Binding(
                            get: { number },
                            set: { newValue in
                                content.data = .whatsapp(number: newValue, message: message)
                            }
                        )
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    #if os(iOS)
                        .keyboardType(.phonePad)
                    #endif

                    Text("Pre-filled Message (optional)")
                        .font(.subheadline)

                    #if os(iOS)
                        TextEditor(
                            text: Binding(
                                get: { message },
                                set: { newValue in
                                    content.data = .whatsapp(number: number, message: newValue)
                                }
                            )
                        )
                        .frame(minHeight: 100)
                    #else
                        TextEditor(
                            text: Binding(
                                get: { message },
                                set: { newValue in
                                    content.data = .whatsapp(number: number, message: newValue)
                                }
                            )
                        )
                        .frame(minHeight: 100)
                        .border(Color.gray.opacity(0.2), width: 1)
                    #endif
                }
            }

            Text(
                "When scanned, this QR code will open WhatsApp with this contact and pre-filled message."
            )
            .font(.caption)
            .foregroundColor(.gray)

            Text(
                "Important: Phone number must include country code without spaces or special characters (e.g., +15551234567)."
            )
            .font(.caption)
            .foregroundColor(.orange)
        }
        .padding()
        #if os(iOS)
            .background(Color.appSurface.opacity(0.5))
            .cornerRadius(10)
        #endif
    }
}
