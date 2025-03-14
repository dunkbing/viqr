//
//  iOSContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI

struct iOSContentView: View {
    @StateObject var viewModel = QRCodeViewModel()
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        TabView {
            CreateTabView(viewModel: viewModel)
                .tabItem {
                    Label("Create", systemImage: "qrcode")
                }
                .environmentObject(themeManager)

            SavedTabView(viewModel: viewModel)
                .tabItem {
                    Label("Saved", systemImage: "folder")
                }
                .environmentObject(themeManager)

            SettingsTabView(viewModel: viewModel)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .environmentObject(themeManager)
        }
        .accentColor(AppColors.appAccent)
        .onAppear {
            setupNavigationBarAppearance()
        }
    }

    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.appMantle)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(AppColors.appText)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppColors.appText)]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(AppColors.appAccent)
    }
}
