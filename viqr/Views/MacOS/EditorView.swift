//
//  EditorView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import QRCode
import SwiftUI

struct EditorView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    @State private var selectedTab = 0

    var body: some View {
        VStack {
            HStack {
                Text("Customize your QR code")
                    .font(.headline)
                Spacer()
            }
            .padding([.horizontal, .top])

            TabView(selection: $selectedTab) {
                contentView
                    .tabItem {
                        Label("Content", systemImage: "doc.text")
                    }
                    .tag(0)

                styleView
                    .tabItem {
                        Label("Style", systemImage: "paintbrush")
                    }
                    .tag(1)
            }
            .padding()
        }
    }

    private var contentView: some View {
        VStack(alignment: .leading) {
            Picker("QR Code Type", selection: $viewModel.selectedType) {
                ForEach(QRCodeType.allCases) { type in
                    HStack {
                        Image(systemName: type.icon)
                        Text(type.rawValue)
                    }
                    .tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.bottom)

            ScrollView {
                VStack {
                    switch viewModel.selectedType {
                    case .link:
                        LinkContentView(content: $viewModel.qrContent)
                    case .text:
                        TextContentView(content: $viewModel.qrContent)
                    case .email:
                        EmailContentView(content: $viewModel.qrContent)
                    case .phone:
                        PhoneContentView(content: $viewModel.qrContent)
                    case .whatsapp:
                        WhatsappContentView(content: $viewModel.qrContent)
                    case .wifi:
                        WiFiContentView(content: $viewModel.qrContent)
                    case .vCard:
                        VCardContentView(content: $viewModel.qrContent)
                    }
                }
                .animation(.default, value: viewModel.selectedType)
            }
        }
    }

    private var styleView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    VStack(alignment: .leading) {
                        Text("Colors")
                            .font(.headline)
                            .padding(.bottom, 5)

                        CustomColorPicker(
                            colorComponents: $viewModel.qrStyle.backgroundColor, title: "Background"
                        )
                        CustomColorPicker(
                            colorComponents: $viewModel.qrStyle.foregroundColor, title: "Foreground"
                        )
                    }

                    Divider()

                    VStack(alignment: .leading) {
                        Text("QR Code Eye Style")
                            .font(.headline)
                            .padding(.bottom, 5)

                        eyeStylePicker

                        CustomColorPicker(
                            colorComponents: Binding(
                                get: {
                                    viewModel.qrStyle.pupilColor
                                        ?? viewModel.qrStyle.foregroundColor
                                },
                                set: { viewModel.qrStyle.pupilColor = $0 }
                            ),
                            title: "Pupil Color"
                        )

                        CustomColorPicker(
                            colorComponents: Binding(
                                get: {
                                    viewModel.qrStyle.borderColor
                                        ?? viewModel.qrStyle.foregroundColor
                                },
                                set: { viewModel.qrStyle.borderColor = $0 }
                            ),
                            title: "Border Color"
                        )
                    }

                    Divider()

                    VStack(alignment: .leading) {
                        Text("QR Code Pixel Style")
                            .font(.headline)
                            .padding(.bottom, 5)

                        dataShapePicker
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }

    private var eyeStylePicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
            ForEach(QREyeShape.allCases) { eyeShape in
                eyeStyleButton(eyeShape, iconName(for: eyeShape))
            }
        }
        .padding(.bottom)
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
                .frame(width: 44, height: 44)
                .background(
                    viewModel.qrStyle.eyeShape == style ? Color.blue.opacity(0.2) : Color.clear
                )
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var dataShapePicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 8) {
            ForEach(QRDataShape.allCases) { dataShape in
                dataShapeButton(dataShape, iconName(for: dataShape))
            }
        }
        .padding(.bottom)
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
                .frame(width: 44, height: 44)
                .background(
                    viewModel.qrStyle.dataShape == style ? Color.blue.opacity(0.2) : Color.clear
                )
                .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
