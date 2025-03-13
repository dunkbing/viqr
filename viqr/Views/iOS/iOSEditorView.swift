//
//  iOSEditorView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 14/3/25.
//

import SwiftUI

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
