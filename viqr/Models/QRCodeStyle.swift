//
//  QRCodeStyle.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import Foundation
import SwiftUI

enum QREyeShape: String, Codable, CaseIterable, Identifiable {
    case square
    case circle
    case roundedOuter
    case roundedRect
    case leaf
    case squircle

    var id: String { self.rawValue }
}

enum QRDataShape: String, Codable, CaseIterable, Identifiable {
    case square
    case circle
    case roundedPath
    case squircle
    case horizontal

    var id: String { self.rawValue }
}

struct QRCodeStyle: Codable, Identifiable {
    var id = UUID()
    var backgroundColor: ColorComponents = ColorComponents(r: 255, g: 255, b: 255, a: 1)
    var foregroundColor: ColorComponents = ColorComponents(r: 0, g: 0, b: 0, a: 1)
    var eyeShape: QREyeShape = .square
    var dataShape: QRDataShape = .square
    var pupilColor: ColorComponents? = nil
    var borderColor: ColorComponents? = nil
}

struct ColorComponents: Codable, Equatable {
    var r: Double
    var g: Double
    var b: Double
    var a: Double

    var color: Color {
        Color(red: r / 255, green: g / 255, blue: b / 255, opacity: a)
    }

    var cgColor: CGColor {
        #if canImport(UIKit)
            return UIColor(red: r / 255, green: g / 255, blue: b / 255, alpha: a).cgColor
        #else
            return NSColor(red: r / 255, green: g / 255, blue: b / 255, alpha: a).cgColor
        #endif
    }

    init(r: Double, g: Double, b: Double, a: Double) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }

    init(color: Color) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        #if canImport(UIKit)
            let uiColor = UIColor(color)
            let cgColor = uiColor.cgColor
            let components = cgColor.components ?? [0, 0, 0, 0]
            if components.count == 4 {
                red = components[0]
                green = components[1]
                blue = components[2]
                alpha = components[3]
            } else if components.count == 2 {
                // Grayscale
                red = components[0]
                green = components[0]
                blue = components[0]
                alpha = components[1]
            }
        #else
            let color = NSColor(color)
            red = color.redComponent
            green = color.greenComponent
            blue = color.blueComponent
            alpha = color.alphaComponent
        #endif

        self.r = Double(red * 255)
        self.g = Double(green * 255)
        self.b = Double(blue * 255)
        self.a = Double(alpha)
    }
}
