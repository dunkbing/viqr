//
//  iOSContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI
import TikimUI

#if os(iOS)
    struct iOSContentView: View {
        @StateObject var viewModel = QRCodeViewModel()
        @EnvironmentObject var themeManager: ThemeManager
        @State private var selectedTab = 0

        var body: some View {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    CreateTabView(viewModel: viewModel)
                        .environmentObject(themeManager)
                        .tag(0)

                    SavedTabView(viewModel: viewModel)
                        .environmentObject(themeManager)
                        .tag(1)

                    SettingsTabView(viewModel: viewModel)
                        .environmentObject(themeManager)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .edgesIgnoringSafeArea(.bottom)

                // Custom Tab Bar
                CustomTabBar(
                    selectedTab: $selectedTab,
                    items: [
                        (icon: "qrcode", title: "Create"),
                        (icon: "folder", title: "Saved"),
                        (icon: "gear", title: "Settings"),
                    ]
                )
                .padding(.bottom, 4)
            }
            .background(Color.appBackground)
            .onAppear {
                setupNavigationBarAppearance()
            }
        }

        private func setupNavigationBarAppearance() {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.appMantle)
            appearance.titleTextAttributes = [.foregroundColor: UIColor(Color.appText)]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.appText)]

            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().tintColor = UIColor(Color.appAccent)
        }
    }
#endif
