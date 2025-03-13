//
//  ContentView.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
#if os(macOS)
           MacOSContentView()
               .frame(minWidth: 1000, minHeight: 600)
           #else
           iOSContentView()
           #endif
    }
}

#Preview {
    ContentView()
}
