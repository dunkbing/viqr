//
//  TextContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI

struct TextContentView: View {
    @Binding var content: QRCodeContent

    #if os(iOS)
        @FocusState private var isEditorFocused: Bool
        @State private var keyboardHeight: CGFloat = 0
        @State private var isKeyboardVisible = false

        private let keyboardPadding: CGFloat = 16
    #endif

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter Text")
                .font(.headline)

            if case .text(let textContent) = content.data {
                #if os(iOS)
                    TextEditor(
                        text: Binding(
                            get: { textContent },
                            set: { content.data = .text(content: $0) }
                        )
                    )
                    .frame(minHeight: 150)
                    .focused($isEditorFocused)
                    .padding(1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                #else
                    TextEditor(
                        text: Binding(
                            get: { textContent },
                            set: { content.data = .text(content: $0) }
                        )
                    )
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
        #if os(iOS)
            .background(Color.appSurface.opacity(0.5))
            .cornerRadius(10)
            .padding(.bottom, isKeyboardVisible ? keyboardHeight - keyboardPadding : 0)
            .animation(.easeOut, value: isKeyboardVisible)
            .onAppear {
                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main
                ) { notification in
                    let keyboardFrame =
                        notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                        ?? .zero
                    keyboardHeight = keyboardFrame.height
                    isKeyboardVisible = true
                }

                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main
                ) { _ in
                    isKeyboardVisible = false
                }
            }
            .onTapGesture {
                if !isEditorFocused {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        #endif
    }

    private var textLength: Int {
        if case .text(let textContent) = content.data {
            return textContent.count
        }
        return 0
    }
}
