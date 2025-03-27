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
        @State private var previousTab = 0
        @State private var showTabBar = true
        @State private var isScannerActive = false

        var body: some View {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    NavigationView {
                        CreateTabView(viewModel: viewModel)
                            .environmentObject(themeManager)
                            .onAppear { showTabBar = true }
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tag(0)

                    NavigationView {
                        SavedTabView(viewModel: viewModel)
                            .environmentObject(themeManager)
                            .onDisappear { showTabBar = false }
                            .onAppear { showTabBar = true }
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tag(1)

                    NavigationView {
                        QRScanTabView(
                            viewModel: viewModel,
                            isScannerActive: $isScannerActive
                        )
                        .environmentObject(themeManager)
                        .onAppear {
                            showTabBar = true
                            isScannerActive = selectedTab == 2
                        }
                        .onDisappear {
                            if selectedTab != 2 {
                                isScannerActive = false
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tag(2)

                    NavigationView {
                        SettingsTabView(viewModel: viewModel)
                            .environmentObject(themeManager)
                            .onAppear { showTabBar = true }
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .edgesIgnoringSafeArea(.bottom)

                // Custom Tab Bar - Only show when not in detail view
                if showTabBar {
                    CustomTabBar(
                        selectedTab: $selectedTab,
                        items: [
                            (icon: "qrcode", title: "Create"),
                            (icon: "folder", title: "Saved"),
                            (icon: "qrcode.viewfinder", title: "Scan"),
                            (icon: "gear", title: "Settings"),
                        ]
                    )
                    .padding(.bottom, 4)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.3), value: showTabBar)
                }
            }
            .background(Color.appBackground)
            .onAppear {
                setupNavigationBarAppearance()
                setupTabBarVisibilityNotification()
            }
            .onChange(of: selectedTab) { newTab in
                // If switching to the Create tab, reset the viewModel for a new QR code
                if newTab == 0 && previousTab != newTab {
                    viewModel.resetForNewQRCode()
                }
                isScannerActive = newTab == 2
                previousTab = newTab
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

        private func setupTabBarVisibilityNotification() {
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("TabBarVisibility"),
                object: nil,
                queue: .main
            ) { notification in
                if let userInfo = notification.userInfo as? [String: Bool],
                    let isVisible = userInfo["isVisible"]
                {
                    withAnimation {
                        showTabBar = isVisible
                    }
                }
            }
        }
    }
#endif
