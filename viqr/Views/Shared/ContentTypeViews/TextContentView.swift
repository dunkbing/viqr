//
//  TextContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI

struct TextContentView: View {
    @Binding var content: QRCodeContent

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter Text")
                .font(.headline)

            if case .text(let textContent) = content.data {
                #if os(iOS)
                TextEditor(text: Binding(
                    get: { textContent },
                    set: { content.data = .text(content: $0) }
                ))
                .frame(minHeight: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                #else
                TextEditor(text: Binding(
                    get: { textContent },
                    set: { content.data = .text(content: $0) }
                ))
                .frame(minHeight: 150)
                .border(Color.gray.opacity(0.2), width: 1)
                #endif
            }

            Text("Character count: \(textLength)")
                .font(.caption)
                .foregroundColor(textLength > 500 ? .red : .gray)

            if textLength > 500 {
                Text("Warning: Long text may be difficult to scan.")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }

    private var textLength: Int {
        if case .text(let textContent) = content.data {
            return textContent.count
        }
        return 0
    }
}
