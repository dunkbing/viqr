//
//  CreateTabView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI
import QRCode

struct CreateTabView: View {
    @ObservedObject var viewModel: QRCodeViewModel
    @State private var showingContentSheet = false
    @State private var showingStyleSheet = false
    @State private var showingSaveSheet = false
    @State private var qrCodeName = ""

    var body: some View {
        NavigationView {
            VStack {
                // Type Selection
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(QRCodeType.allCases) { type in
                            TypeButton(type: type, selectedType: $viewModel.selectedType)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)

                // Preview
                QRCodePreviewView(viewModel: viewModel)
                    .padding(.horizontal)

                Spacer()

                // Action Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        showingContentSheet = true
                    }) {
                        VStack {
                            Image(systemName: "doc.text")
                                .font(.system(size: 24))
                            Text("Content")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }

                    Button(action: {
                        showingStyleSheet = true
                    }) {
                        VStack {
                            Image(systemName: "paintbrush")
                                .font(.system(size: 24))
                            Text("Style")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(10)
                    }

                    Button(action: {
                        showingSaveSheet = true
                    }) {
                        VStack {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 24))
                            Text("Save")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("QR Studio")
            .sheet(isPresented: $showingContentSheet) {
                NavigationView {
                    iOSEditorView(viewModel: viewModel)
                        .navigationTitle("Edit Content")
//                        .navigationBarItems(trailing: Button("Done") {
//                            showingContentSheet = false
//                        })
                }
            }
            .sheet(isPresented: $showingStyleSheet) {
                NavigationView {
                    iOSStyleEditorView(viewModel: viewModel)
                        .navigationTitle("Edit Style")
//                        .navigationBarItems(trailing: Button("Done") {
//                            showingStyleSheet = false
//                        })
                }
            }
            .sheet(isPresented: $showingSaveSheet) {
                VStack(spacing: 20) {
                    Text("Save QR Code")
                        .font(.headline)

                    TextField("QR Code Name", text: $qrCodeName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    HStack {
                        Button("Cancel") {
                            showingSaveSheet = false
                        }
                        .foregroundColor(.red)

                        Spacer()

                        Button("Save") {
                            viewModel.saveCurrentQRCode(name: qrCodeName)
                            qrCodeName = ""
                            showingSaveSheet = false
                        }
                        .disabled(qrCodeName.isEmpty)
                    }
                    .padding()
                }
                .padding()
                .presentationDetents([.height(200)])
            }
        }
    }
}

struct TypeButton: View {
    let type: QRCodeType
    @Binding var selectedType: QRCodeType

    var body: some View {
        Button(action: {
            selectedType = type
        }) {
            VStack {
                Image(systemName: type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(selectedType == type ? .white : .blue)
                    .frame(width: 50, height: 50)
                    .background(selectedType == type ? Color.blue : Color.blue.opacity(0.1))
                    .cornerRadius(10)

                Text(type.rawValue)
                    .font(.caption)
                    .foregroundColor(selectedType == type ? .blue : .primary)
            }
        }
    }
}

struct iOSEditorView: View {
    @ObservedObject var viewModel: QRCodeViewModel

    var body: some View {
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
            .padding()
        }
    }
}

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
