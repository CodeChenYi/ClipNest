import AppKit
import Carbon
import HotKey
import Combine

class HotkeyManager: ObservableObject {
    static let shared = HotkeyManager()

    @Published var isRecording = false
    @Published var currentHotkeyDescription: String = ""

    private var hotKey: HotKey?
    private let storageService = StorageService.shared
    private var settings: AppSettings
    private var eventMonitor: Any?

    var onHotkeyPressed: (() -> Void)?

    private init() {
        settings = storageService.loadSettings()
        updateHotkeyDescription()
        setupHotKey()
    }

    func setupHotKey() {
        hotKey?.isPaused = true
        hotKey = nil

        guard let key = Key(carbonKeyCode: settings.hotkeyKeyCode) else {
            return
        }
        let modifiers = carbonModifiersToNSEventModifiers(settings.hotkeyModifiers)

        hotKey = HotKey(key: key, modifiers: modifiers)
        hotKey?.keyDownHandler = { [weak self] in
            self?.onHotkeyPressed?()
        }
    }

    private func carbonModifiersToNSEventModifiers(_ carbonModifiers: UInt32) -> NSEvent.ModifierFlags {
        var modifiers: NSEvent.ModifierFlags = []

        if carbonModifiers & UInt32(controlKey << 16) != 0 {
            modifiers.insert(.control)
        }
        if carbonModifiers & UInt32(optionKey << 16) != 0 {
            modifiers.insert(.option)
        }
        if carbonModifiers & UInt32(shiftKey << 16) != 0 {
            modifiers.insert(.shift)
        }
        if carbonModifiers & UInt32(cmdKey << 16) != 0 {
            modifiers.insert(.command)
        }

        return modifiers
    }

    func startRecording() {
        isRecording = true
        startEventMonitor()
    }

    func stopRecording() {
        isRecording = false
        stopEventMonitor()
    }

    private func startEventMonitor() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
            return nil
        }
    }

    private func stopEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    private func handleKeyEvent(_ event: NSEvent) {
        guard isRecording else { return }

        let keyCode = UInt32(event.keyCode)
        var modifiers: UInt32 = 0

        if event.modifierFlags.contains(.control) {
            modifiers |= UInt32(controlKey << 16)
        }
        if event.modifierFlags.contains(.option) {
            modifiers |= UInt32(optionKey << 16)
        }
        if event.modifierFlags.contains(.shift) {
            modifiers |= UInt32(shiftKey << 16)
        }
        if event.modifierFlags.contains(.command) {
            modifiers |= UInt32(cmdKey << 16)
        }

        if keyCode != 0 || modifiers != 0 {
            settings.hotkeyKeyCode = keyCode
            settings.hotkeyModifiers = modifiers
            storageService.saveSettings(settings)
            updateHotkeyDescription()
            setupHotKey()
            stopRecording()

            showConflictAlertIfNeeded(keyCode: keyCode, modifiers: modifiers)
        }
    }

    private func showConflictAlertIfNeeded(keyCode: UInt32, modifiers: UInt32) {
        // Simplified conflict detection - in production would check against system shortcuts
        let alert = NSAlert()
        alert.messageText = "快捷键已更新"
        alert.informativeText = "新的快捷键已设置为: \(currentHotkeyDescription)"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "好的")
        alert.runModal()
    }

    func deleteHotkey() {
        settings.hotkeyKeyCode = 0
        settings.hotkeyModifiers = 0
        storageService.saveSettings(settings)
        updateHotkeyDescription()
        startRecording()
    }

    func unregisterHotkey() {
        hotKey?.isPaused = true
        hotKey = nil
    }

    private func updateHotkeyDescription() {
        currentHotkeyDescription = settings.hotkeyDescription
    }

    func refreshSettings() {
        settings = storageService.loadSettings()
        updateHotkeyDescription()
        setupHotKey()
    }
}
