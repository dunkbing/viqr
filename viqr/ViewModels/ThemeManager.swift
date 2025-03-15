//
//  ColorTheme.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 14/3/25.
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

// Global app theme manager
class ThemeManager: ObservableObject {
    @Published var theme: AppTheme {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: "appTheme")
            applyTheme()
        }
    }

    init() {
        // Initialize with saved theme or use system default
        let savedTheme =
            UserDefaults.standard.string(forKey: "appTheme") ?? AppTheme.system.rawValue
        self.theme = AppTheme(rawValue: savedTheme) ?? .system
        applyTheme()
    }

    private func applyTheme() {
        #if os(iOS)
            // Set the UIKit user interface style - only works on iOS
            let scenes = UIApplication.shared.connectedScenes
            if let windowScene = scenes.first as? UIWindowScene,
                let window = windowScene.windows.first
            {
                window.overrideUserInterfaceStyle = userInterfaceStyle
            }
        #endif
    }

    #if os(iOS)
        var userInterfaceStyle: UIUserInterfaceStyle {
            switch theme {
            case .system:
                return .unspecified
            case .light:
                return .light
            case .dark:
                return .dark
            }
        }
    #endif

    var colorScheme: ColorScheme? {
        switch theme {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
