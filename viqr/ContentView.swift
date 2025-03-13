//
//  ContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
#if os(macOS)
        MacOSContentView(modelContext: modelContext)
            .frame(minWidth: 1000, minHeight: 600)
#else
        iOSContentView(modelContext: modelContext)
#endif
    }
}

#Preview {
    ContentView()
}
