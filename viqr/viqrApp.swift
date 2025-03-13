//
//  viqrApp.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI
import SwiftData

@main
struct viqrApp: App {
    // Set up SwiftData schema and container
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: QRCodeModel.self)
        } catch {
            fatalError("Failed to create ModelContainer for QRCodeModel: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.modelContext, modelContainer.mainContext)
        }
        .modelContainer(modelContainer)
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
