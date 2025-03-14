//
//  viqrApp.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI

@main
struct viqrApp: App {
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
        #if os(macOS)
            .windowStyle(HiddenTitleBarWindowStyle())
            .commands {
                CommandGroup(replacing: .newItem) {
                    Button("New QR Code") {
                        // This would reset to default state
                        // but we'd need to access the view model from here
                    }
                    .keyboardShortcut("n")
                }

                SidebarCommands()
            }
        #endif
    }
}
