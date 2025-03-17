//
//  SearchBar.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 17/3/25.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    var onCommit: (() -> Void)? = nil

    // Animation states
    @State private var isFocused: Bool = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isFocused ? Color.appAccent : Color.appSubtitle)
                .animation(.easeInOut(duration: 0.2), value: isFocused)

            TextField(placeholder, text: $text)
                .foregroundColor(Color.appText)
                .font(.system(size: 16))
                .focused($isTextFieldFocused)
                .onChange(of: isTextFieldFocused) { focused in
                    withAnimation {
                        isFocused = focused
                    }
                }
                .submitLabel(.search)
                .onSubmit {
                    onCommit?()
                }

            if !text.isEmpty {
                Button(action: {
                    withAnimation {
                        text = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color.appSubtitle)
                }
                .transition(.opacity)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appSurface2.opacity(isFocused ? 0.15 : 0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isFocused ? Color.appAccent.opacity(0.5) : Color.clear, lineWidth: 1.5)
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.easeInOut(duration: 0.2), value: text)
    }
}

// SearchBar with header
struct SearchHeaderView: View {
    @Binding var searchText: String
    var title: String
    var placeholderText: String = "Search..."
    @Binding var isEditMode: EditMode

    var body: some View {
        VStack(spacing: 16) {
            // Header with title and edit button
            HStack {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.appText)

                Spacer()

                CustomEditButton(editMode: $isEditMode)
            }
            .padding(.horizontal)

            // Search bar
            SearchBar(text: $searchText, placeholder: placeholderText)
                .padding(.horizontal)
        }
        .padding(.top, 10)
    }
}
