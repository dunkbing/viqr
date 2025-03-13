//
//  iOSContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI
import SwiftData

struct iOSContentView: View {
    @StateObject var viewModel = QRCodeViewModel()

    init(modelContext: ModelContext) {
        // Initialize the view model (must use _viewModel for StateObject)
        let vm = QRCodeViewModel()
        vm.modelContext = modelContext

        // Load data from SwiftData on initialization
        vm.loadQRCodesFromSwiftData()

        _viewModel = StateObject(wrappedValue: vm)
    }

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
