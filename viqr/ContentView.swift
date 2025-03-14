//
//  ContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        #if os(macOS)
            MacOSContentView()
                .frame(minWidth: 1000, minHeight: 600)
                .background(AppColors.appBackground.ignoresSafeArea())
                .environmentObject(themeManager)
        #else
            iOSContentView()
                .environmentObject(themeManager)
                .onAppear {
                    applyThemeToTabBar()
                }
        #endif
    }

    #if os(iOS)
        // Apply theme to the UITabBar
        private func applyThemeToTabBar() {
            let appearance = UITabBarAppearance()
            //        appearance.configureWithOpaluescence()
            appearance.backgroundColor = UIColor(AppColors.appMantle)

            let tabBarItemAppearance = UITabBarItemAppearance()
            tabBarItemAppearance.normal.iconColor = UIColor(AppColors.appSubtitle)
            tabBarItemAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(AppColors.appSubtitle)
            ]
            tabBarItemAppearance.selected.iconColor = UIColor(AppColors.appAccent)
            tabBarItemAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(AppColors.appAccent)
            ]

            appearance.stackedLayoutAppearance = tabBarItemAppearance
            appearance.inlineLayoutAppearance = tabBarItemAppearance
            appearance.compactInlineLayoutAppearance = tabBarItemAppearance

            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    #endif
}

#Preview {
    ContentView()
        .environmentObject(ThemeManager())
}
