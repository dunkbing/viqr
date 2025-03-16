//
//  CustomEditButton.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 16/3/25.
//

import SwiftUI

struct CustomEditButton: View {
    @Binding var editMode: EditMode

    var body: some View {
        Button(action: {
            withAnimation {
                self.editMode = self.editMode == .active ? .inactive : .active
            }
        }) {
            Text(editMode == .active ? "Done" : "Edit")
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(
                            editMode == .active
                                ? Color.appGreen.opacity(0.2) : Color.appAccent.opacity(0.15))
                )
                .foregroundColor(editMode == .active ? Color.appGreen : Color.appAccent)
        }
    }
}

// Extension to use with binding
extension View {
    func customEditButton(editMode: Binding<EditMode>) -> some View {
        self.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                CustomEditButton(editMode: editMode)
            }
        }
    }
}
