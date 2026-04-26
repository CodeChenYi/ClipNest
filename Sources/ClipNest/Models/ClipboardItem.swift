import Foundation
import AppKit

enum ClipboardItemType: Codable, Equatable {
    case text
    case image
}

struct ClipboardItem: Identifiable, Codable, Equatable {
    let id: UUID
    let type: ClipboardItemType
    let content: String
    let imagePath: String?
    let createdAt: Date

    init(type: ClipboardItemType, content: String, imagePath: String? = nil) {
        self.id = UUID()
        self.type = type
        self.content = content
        self.imagePath = imagePath
        self.createdAt = Date()
    }

    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        switch (lhs.type, rhs.type) {
        case (.text, .text):
            return lhs.content == rhs.content
        case (.image, .image):
            return lhs.imagePath == rhs.imagePath && lhs.content == rhs.content
        default:
            return false
        }
    }

    var preview: String {
        switch type {
        case .text:
            let text = content.trimmingCharacters(in: .whitespacesAndNewlines)
            if text.count <= 30 {
                return text
            }
            return String(text.prefix(30)) + "..."
        case .image:
            return "[图片]"
        }
    }

    var thumbnailImage: NSImage? {
        guard type == .image, let imagePath = imagePath else { return nil }
        return NSImage(contentsOfFile: imagePath)
    }
}
