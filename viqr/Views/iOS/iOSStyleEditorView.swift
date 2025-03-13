//
//  iOSStyleEditorView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 14/3/25.
//

import SwiftUI

struct iOSStyleEditorView: View {
    @ObservedObject var viewModel: QRCodeViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Section(header: Text("Colors").font(.headline)) {
                        CustomColorPicker(colorComponents: $viewModel.qrStyle.backgroundColor, title: "Background")
                        CustomColorPicker(colorComponents: $viewModel.qrStyle.foregroundColor, title: "Foreground")
                    }

                    Divider()

                    Section(header: Text("QR Code Eye Style").font(.headline)) {
                        eyeStylePicker

                        CustomColorPicker(
                            colorComponents: Binding(
                                get: { viewModel.qrStyle.pupilColor ?? viewModel.qrStyle.foregroundColor },
                                set: { viewModel.qrStyle.pupilColor = $0 }
                            ),
                            title: "Pupil Color"
                        )

                        CustomColorPicker(
                            colorComponents: Binding(
                                get: { viewModel.qrStyle.borderColor ?? viewModel.qrStyle.foregroundColor },
                                set: { viewModel.qrStyle.borderColor = $0 }
                            ),
                            title: "Border Color"
                        )
                    }

                    Divider()

                    Section(header: Text("QR Code Pixel Style").font(.headline)) {
                        dataShapePicker
                    }
                }
            }
            .padding()
        }
    }

    private var eyeStylePicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
            ForEach(QREyeShape.allCases) { eyeShape in
                eyeStyleButton(eyeShape, iconName(for: eyeShape))
            }
        }
        .padding(.vertical)
    }

    private func iconName(for eyeShape: QREyeShape) -> String {
        switch eyeShape {
        case .square: return "square"
        case .circle: return "circle"
        case .roundedOuter: return "square.dashed"
        case .roundedRect: return "squareshape"
        case .leaf: return "leaf"
        case .squircle: return "app"
        }
    }

    private func eyeStyleButton(_ style: QREyeShape, _ iconName: String) -> some View {
        Button(action: {
            viewModel.qrStyle.eyeShape = style
        }) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(viewModel.qrStyle.eyeShape == style ? .white : .primary)
                .frame(width: 60, height: 60)
                .background(viewModel.qrStyle.eyeShape == style ? Color.blue : Color.gray.opacity(0.2))
                .cornerRadius(10)
        }
    }

    private var dataShapePicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
            ForEach(QRDataShape.allCases) { dataShape in
                dataShapeButton(dataShape, iconName(for: dataShape))
            }
        }
        .padding(.vertical)
    }

    private func iconName(for dataShape: QRDataShape) -> String {
        switch dataShape {
        case .square: return "square.fill"
        case .circle: return "circle.fill"
        case .roundedPath: return "seal.fill"
        case .squircle: return "app.fill"
        case .horizontal: return "rectangle.fill"
        }
    }

    private func dataShapeButton(_ style: QRDataShape, _ iconName: String) -> some View {
        Button(action: {
            viewModel.qrStyle.dataShape = style
        }) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(viewModel.qrStyle.dataShape == style ? .white : .primary)
                .frame(width: 60, height: 60)
                .background(viewModel.qrStyle.dataShape == style ? Color.blue : Color.gray.opacity(0.2))
                .cornerRadius(10)
        }
    }
}
