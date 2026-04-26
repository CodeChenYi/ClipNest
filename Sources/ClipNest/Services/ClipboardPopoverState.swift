import SwiftUI
import Carbon
import ApplicationServices

class ClipboardPopoverState: ObservableObject {
    static let shared = ClipboardPopoverState()

    @Published var isPopoverShown = false
    @Published var selectedItemId: UUID?

    var onHideRequest: (() -> Void)?

    private var interceptor: KeyboardInterceptor?

    func show() {
        isPopoverShown = true
        selectedItemId = ClipboardManager.shared.history.first?.id
        installInterceptor()
    }

    func hide() {
        isPopoverShown = false
        uninstallInterceptor()
        onHideRequest?()
    }

    func installInterceptor() {
        guard AXIsProcessTrusted() else { return }

        interceptor = KeyboardInterceptor.shared

        interceptor?.onUpArrow = { [weak self] in
            DispatchQueue.main.async {
                self?.handleUpArrow()
            }
        }

        interceptor?.onDownArrow = { [weak self] in
            DispatchQueue.main.async {
                self?.handleDownArrow()
            }
        }

        interceptor?.onReturn = { [weak self] in
            DispatchQueue.main.async {
                self?.handleReturn()
            }
        }

        interceptor?.install()
    }

    func uninstallInterceptor() {
        interceptor?.uninstall()
        interceptor = nil
    }

    private func handleUpArrow() {
        let history = ClipboardManager.shared.history
        guard let currentId = selectedItemId,
              let currentIndex = history.firstIndex(where: { $0.id == currentId }) else {
            selectedItemId = history.last?.id
            return
        }
        let newIndex = currentIndex > 0 ? currentIndex - 1 : history.count - 1
        selectedItemId = history[newIndex].id
    }

    private func handleDownArrow() {
        let history = ClipboardManager.shared.history
        guard let currentId = selectedItemId,
              let currentIndex = history.firstIndex(where: { $0.id == currentId }) else {
            selectedItemId = history.first?.id
            return
        }
        let newIndex = currentIndex < history.count - 1 ? currentIndex + 1 : 0
        selectedItemId = history[newIndex].id
    }

    private func handleReturn() {
        if let selectedId = selectedItemId,
           let item = ClipboardManager.shared.history.first(where: { $0.id == selectedId }) {
            ClipboardManager.shared.copyToClipboard(item)

            if AXIsProcessTrusted() {
                closePopoverAndPaste()
            } else {
                closePopover()
            }
        }
    }

    private func closePopoverAndPaste() {
        hide()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.simulatePaste()
        }
    }

    private func closePopover() {
        hide()
    }

    private func simulatePaste() {
        guard AXIsProcessTrusted() else { return }

        let source = CGEventSource(stateID: .hidSystemState)

        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: UInt16(kVK_ANSI_V), keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: UInt16(kVK_ANSI_V), keyDown: false) else {
            return
        }

        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand

        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }
}
