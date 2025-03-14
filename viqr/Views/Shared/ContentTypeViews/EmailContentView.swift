//
//  EmailContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI

struct EmailContentView: View {
    @Binding var content: QRCodeContent

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Email Information")
                .font(.headline)

            if case .email(let address, let subject, let body) = content.data {
                Group {
                    TextField(
                        "Email Address",
                        text: Binding(
                            get: { address },
                            set: { newValue in
                                content.data = .email(
                                    address: newValue, subject: subject, body: body)
                            }
                        )
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    //                    .keyboardType(.emailAddress)
                    //                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                    TextField(
                        "Subject (optional)",
                        text: Binding(
                            get: { subject },
                            set: { newValue in
                                content.data = .email(
                                    address: address, subject: newValue, body: body)
                            }
                        )
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    Text("Email Body (optional)")
                        .font(.subheadline)

                    #if os(iOS)
                        TextEditor(
                            text: Binding(
                                get: { body },
                                set: { newValue in
                                    content.data = .email(
                                        address: address, subject: subject, body: newValue)
                                }
                            )
                        )
                        .frame(minHeight: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    #else
                        TextEditor(
                            text: Binding(
                                get: { body },
                                set: { newValue in
                                    content.data = .email(
                                        address: address, subject: subject, body: newValue)
                                }
                            )
                        )
                        .frame(minHeight: 100)
                        .border(Color.gray.opacity(0.2), width: 1)
                    #endif
                }
            }

            Text("The QR code will open the default email client with these details pre-filled.")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}
