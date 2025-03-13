//
//  iOSContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI

struct iOSContentView: View {
    @StateObject var viewModel = QRCodeViewModel()

    var body: some View {
        TabView {
            CreateTabView(viewModel: viewModel)
                .tabItem {
                    Label("Create", systemImage: "qrcode")
                }

            SavedTabView(viewModel: viewModel)
                .tabItem {
                    Label("Saved", systemImage: "folder")
                }

            SettingsTabView(viewModel: viewModel)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
