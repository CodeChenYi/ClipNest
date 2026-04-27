import AppKit
import Combine

class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()

    @Published var history: [ClipboardItem] = []

    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let storageService = StorageService.shared
    private var maxHistoryCount: Int = 100

    private init() {
        loadHistory()
        startMonitoring()
    }

    private func loadHistory() {
        history = storageService.loadHistory()
        maxHistoryCount = storageService.loadSettings().maxHistoryCount
        lastChangeCount = NSPasteboard.general.changeCount
    }

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let currentChangeCount = pasteboard.changeCount

        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount

        if let string = pasteboard.string(forType: .string), !string.isEmpty {
            addTextItem(string)
        } else if let imageData = pasteboard.data(forType: .png) {
            addImageItem(imageData)
        } else if let imageData = pasteboard.data(forType: .tiff) {
            addImageItem(imageData)
        }
    }

    private func addTextItem(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        if let existingIndex = history.firstIndex(where: { $0.type == .text && $0.content == trimmedText }) {
            let existingItem = history.remove(at: existingIndex)
            history.insert(existingItem, at: 0)
        } else {
            let newItem = ClipboardItem(type: .text, content: trimmedText)
            history.insert(newItem, at: 0)
        }

        trimHistory()
        saveHistory()
    }

    private func addImageItem(_ imageData: Data) {
        guard let imagePath = storageService.saveImage(imageData) else { return }

        let imageHash = computeMD5(imageData)

        if let existingIndex = history.firstIndex(where: { $0.type == .image && $0.content == imageHash }) {
            let existingItem = history.remove(at: existingIndex)
            history.insert(existingItem, at: 0)
        } else {
            let newItem = ClipboardItem(type: .image, content: imageHash, imagePath: imagePath)
            history.insert(newItem, at: 0)
        }

        trimHistory()
        saveHistory()
    }

    private func computeMD5(_ data: Data) -> String {
        var digest = [UInt8](repeating: 0, count: 16)
        _ = data.withUnsafeBytes { buffer in
            CC_MD5(buffer.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func trimHistory() {
        if history.count > maxHistoryCount {
            let removedItems = history.suffix(from: maxHistoryCount)
            for item in removedItems {
                if item.type == .image, let imagePath = item.imagePath {
                    storageService.deleteImage(at: imagePath)
                }
            }
            history = Array(history.prefix(maxHistoryCount))
        }
    }

    private func saveHistory() {
        storageService.saveHistory(history)
    }

    func copyToClipboard(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.type {
        case .text:
            pasteboard.setString(item.content, forType: .string)
        case .image:
            if let imagePath = item.imagePath,
               let image = NSImage(contentsOfFile: imagePath),
               let tiffData = image.tiffRepresentation {
                pasteboard.setData(tiffData, forType: .tiff)
            }
        }

        lastChangeCount = pasteboard.changeCount
    }

    func clearHistory() {
        for item in history {
            if item.type == .image, let imagePath = item.imagePath {
                storageService.deleteImage(at: imagePath)
            }
        }
        history.removeAll()
        saveHistory()
    }

    func updateMaxHistoryCount(_ count: Int) {
        maxHistoryCount = count
        trimHistory()
        saveHistory()
    }

    func deleteItem(id: UUID) {
        if let index = history.firstIndex(where: { $0.id == id }) {
            let item = history[index]
            if item.type == .image, let imagePath = item.imagePath {
                storageService.deleteImage(at: imagePath)
            }
            history.remove(at: index)
            saveHistory()
        }
    }

    func moveToTop(id: UUID) {
        guard let index = history.firstIndex(where: { $0.id == id }) else { return }
        let item = history.remove(at: index)
        history.insert(item, at: 0)
        saveHistory()
    }
}

import CommonCrypto
