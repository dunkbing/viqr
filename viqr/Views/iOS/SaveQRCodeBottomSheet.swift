//
//  SaveQRCodeBottomSheet.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 23/3/25.
//

import SwiftUI

struct SaveQRCodeBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var qrCodeName: String
    var onSave: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Save QR Code")
                .font(.headline)
                .foregroundColor(Color.appText)
                .padding(.top, 8)

            // Name input field
            VStack(alignment: .leading, spacing: 8) {
                Text("QR Code Name")
                    .font(.subheadline)
                    .foregroundColor(Color.appSubtitle)

                TextField("Enter a name for your QR code", text: $qrCodeName)
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
                    isPresented = false
                }) {
                    Text("Cancel")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.appRed.opacity(0.1))
                        .foregroundColor(Color.appRed)
                        .cornerRadius(16)
                }

                Button(action: {
                    onSave()
                    isPresented = false
                }) {
                    Text("Save")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            qrCodeName.isEmpty ? Color.appAccent.opacity(0.5) : Color.appAccent
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
