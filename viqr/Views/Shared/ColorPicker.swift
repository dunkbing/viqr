//
//  ColorPicker.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI

struct CustomColorPicker: View {
    @Binding var colorComponents: ColorComponents
    var title: String

    var body: some View {
        HStack {
            Text(title)
                .frame(width: 100, alignment: .leading)

            RoundedRectangle(cornerRadius: 4)
                .fill(colorComponents.color)
                .frame(width: 30, height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray, lineWidth: 1)
                )

            #if os(iOS)
                ColorPicker(
                    "",
                    selection: Binding(
                        get: { colorComponents.color },
                        set: { newColor in
                            colorComponents = ColorComponents(color: newColor)
                        }
                    )
                )
                .labelsHidden()
            #else
                MacColorPickerButton(colorComponents: $colorComponents)
            #endif
        }
        .padding(.vertical, 4)
    }
}

#if os(macOS)
    struct MacColorPickerButton: View {
        @Binding var colorComponents: ColorComponents
        @State private var showingColorPanel = false

        var body: some View {
            Button(action: {
                let panel = NSColorPanel.shared
                panel.color = NSColor(
                    red: CGFloat(colorComponents.r / 255),
                    green: CGFloat(colorComponents.g / 255),
                    blue: CGFloat(colorComponents.b / 255),
                    alpha: CGFloat(colorComponents.a)
                )
                panel.setTarget(self)
                panel.makeKeyAndOrderFront(nil)
                showingColorPanel = true

                NotificationCenter.default.addObserver(
                    forName: NSColorPanel.colorDidChangeNotification,
                    object: panel,
                    queue: nil
                ) { _ in
                    let color = panel.color
                    colorComponents = ColorComponents(
                        r: Double(color.redComponent * 255),
                        g: Double(color.greenComponent * 255),
                        b: Double(color.blueComponent * 255),
                        a: Double(color.alphaComponent)
                    )
                }
            }) {
                Text("Choose...")
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
            .onDisappear {
                if showingColorPanel {
                    NSColorPanel.shared.close()
                    NotificationCenter.default.removeObserver(self)
                    showingColorPanel = false
                }
            }
        }
    }
#endif
