import Foundation

class StorageService {
    static let shared = StorageService()

    private let fileManager = FileManager.default
    private let appSupportDirectory: URL
    private let historyFileURL: URL
    private let settingsFileURL: URL
    private let tempImageDirectory: URL

    private init() {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        appSupportDirectory = appSupport.appendingPathComponent("ClipNest", isDirectory: true)
        historyFileURL = appSupportDirectory.appendingPathComponent("clipboard_history.json")
        settingsFileURL = appSupportDirectory.appendingPathComponent("settings.json")
        tempImageDirectory = appSupportDirectory.appendingPathComponent("Images", isDirectory: true)

        createDirectoriesIfNeeded()
    }

    private func createDirectoriesIfNeeded() {
        try? fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: tempImageDirectory, withIntermediateDirectories: true)
    }

    func loadHistory() -> [ClipboardItem] {
        guard fileManager.fileExists(atPath: historyFileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: historyFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            var items = try decoder.decode([ClipboardItem].self, from: data)

            items = items.filter { item in
                if item.type == .image, let imagePath = item.imagePath {
                    return fileManager.fileExists(atPath: imagePath)
                }
                return true
            }

            try? saveHistory(items)
            return items
        } catch {
            print("Failed to load history: \(error)")
            return []
        }
    }

    func saveHistory(_ items: [ClipboardItem]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(items)
            try data.write(to: historyFileURL, options: .atomic)
        } catch {
            print("Failed to save history: \(error)")
        }
    }

    func loadSettings() -> AppSettings {
        guard fileManager.fileExists(atPath: settingsFileURL.path) else {
            return .default
        }

        do {
            let data = try Data(contentsOf: settingsFileURL)
            let decoder = JSONDecoder()
            return try decoder.decode(AppSettings.self, from: data)
        } catch {
            print("Failed to load settings: \(error)")
            return .default
        }
    }

    func saveSettings(_ settings: AppSettings) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(settings)
            try data.write(to: settingsFileURL, options: .atomic)
        } catch {
            print("Failed to save settings: \(error)")
        }
    }

    func saveImage(_ imageData: Data) -> String? {
        let fileName = UUID().uuidString + ".png"
        let fileURL = tempImageDirectory.appendingPathComponent(fileName)

        do {
            try imageData.write(to: fileURL, options: .atomic)
            return fileURL.path
        } catch {
            print("Failed to save image: \(error)")
            return nil
        }
    }

    func deleteImage(at path: String) {
        try? fileManager.removeItem(atPath: path)
    }

    func clearAllData() {
        try? fileManager.removeItem(at: historyFileURL)
        try? fileManager.removeItem(at: tempImageDirectory)
        createDirectoriesIfNeeded()
    }

    var appSupportPath: String {
        return appSupportDirectory.path
    }
}
