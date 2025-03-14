//
//  LinkContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI

struct LinkContentView: View {
    @Binding var content: QRCodeContent

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter URL")
                .font(.headline)

            if case .link(let url) = content.data {
                TextField(
                    "https://example.com",
                    text: Binding(
                        get: { url },
                        set: { content.data = .link(url: $0) }
                    )
                )
                .textFieldStyle(RoundedBorderTextFieldStyle())
                //                .autocapitalization(.none)
                .disableAutocorrection(true)
                //                .keyboardType(.URL)
            }

            Text("Tip: Include 'https://' for proper linking.")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}
