//
//  QRCodeGenerator.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 13/3/25.
//

import Foundation
import QRCode
import SwiftUI

enum QRCodeExportFormat: String, CaseIterable {
    case png
    case svg
    case pdf

    var fileExtension: String {
        return self.rawValue
    }
}

struct QRCodeGenerator {
    static func generateQRCode(from content: QRCodeContent, with style: QRCodeStyle)
        -> QRCode.Document
    {
        let qrContent = content.data.formattedString()

        // Create QR code document with proper error handling
        let doc: QRCode.Document
        do {
            doc = try QRCode.Document(utf8String: qrContent, errorCorrection: .high)
        } catch {
            print("Error creating QR code: \(error)")
            // Return an empty document if there's an error
            return QRCode.Document()
        }

        // Apply styling
        doc.design.backgroundColor(style.backgroundColor.cgColor)
        doc.design.foregroundColor(style.foregroundColor.cgColor)

        // Apply eye and data shapes
        switch style.eyeShape {
        case .square:
            doc.design.shape.eye = QRCode.EyeShape.Square()
        case .circle:
            doc.design.shape.eye = QRCode.EyeShape.Circle()
        case .roundedOuter:
            doc.design.shape.eye = QRCode.EyeShape.RoundedOuter()
        case .roundedRect:
            doc.design.shape.eye = QRCode.EyeShape.RoundedRect()
        case .leaf:
            doc.design.shape.eye = QRCode.EyeShape.Leaf()
        case .squircle:
            doc.design.shape.eye = QRCode.EyeShape.Squircle()
        }

        switch style.dataShape {
        case .square:
            doc.design.shape.onPixels = QRCode.PixelShape.Square()
        case .circle:
            doc.design.shape.onPixels = QRCode.PixelShape.Circle()
        case .roundedPath:
            doc.design.shape.onPixels = QRCode.PixelShape.RoundedPath()
        case .squircle:
            doc.design.shape.onPixels = QRCode.PixelShape.Squircle()
        case .horizontal:
            doc.design.shape.onPixels = QRCode.PixelShape.Horizontal()
        }

        // Apply pupil and border colors if they exist
        if let pupilColor = style.pupilColor {
            doc.design.style.pupil = QRCode.FillStyle.Solid(pupilColor.cgColor)
        }

        if let borderColor = style.borderColor {
            // Using correct style property for eye border
            if let eyeShape = doc.design.shape.eye as? QRCode.EyeShape {
                //                    doc.design.style.eyeBorder = QRCode.FillStyle.Solid(borderColor.cgColor)
            }
        }

        return doc
    }

    static func saveQRCodeToFile(
        qrCode: QRCode.Document, fileName: String, fileFormat: QRCodeExportFormat
    ) -> URL? {
        // For iOS, use the temporary directory for exporting files to be shared
        #if os(iOS)
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(fileName).appendingPathExtension(
                fileFormat.fileExtension)
        #else
            // For macOS, use the documents directory
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            guard let documentsDirectory = paths.first else { return nil }
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
                .appendingPathExtension(
                    fileFormat.fileExtension)
        #endif

        do {
            var data: Data?

            switch fileFormat {
            case .png:
                data = try qrCode.pngData(dimension: 1024)
            case .svg:
                data = try qrCode.svgData(dimension: 1024)
            case .pdf:
                data = try qrCode.pdfData(dimension: 1024)
            }

            if let data = data {
                try data.write(to: fileURL)
                return fileURL
            }
            return nil
        } catch {
            print("Error saving QR code: \(error)")
            return nil
        }
    }
}
