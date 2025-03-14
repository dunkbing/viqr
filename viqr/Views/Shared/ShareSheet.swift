//
//  ShareSheet.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 14/3/25.
//

import SwiftUI

#if os(iOS)
    import UIKit

    // iOS Share Sheet compatible with iOS 15
    struct ShareSheet: UIViewControllerRepresentable {
        var items: [Any]

        func makeUIViewController(context: Context) -> UIActivityViewController {
            let controller = UIActivityViewController(
                activityItems: items,
                applicationActivities: nil
            )
            return controller
        }

        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context)
        {}
    }
#endif
