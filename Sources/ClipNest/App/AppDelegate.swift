import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var clipboardManager: ClipboardManager!
    private var hotkeyManager: HotkeyManager!
    private var settingsWindow: NSWindow?
    private var onboardingWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        setupClipboardManager()
        setupHotkeyManager()
        checkOnboarding()

        // Start monitoring accessibility permissions early
        AccessibilityManager.shared.startMonitoring()

        print("ClipNest - Accessibility Status: \(AXIsProcessTrusted())")
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "ClipNest")
            button.action = #selector(statusItemClicked)
            button.target = self
        }

        updateMenu()
    }

    private func updateMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "显示剪切板", action: #selector(showClipboard), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "设置", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "关于", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 400)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: ClipboardPopoverView())

        // Set up callback to close popover when requested by ClipboardPopoverState
        ClipboardPopoverState.shared.onHideRequest = { [weak self] in
            self?.popover.performClose(nil)
        }
    }

    private func setupClipboardManager() {
        clipboardManager = ClipboardManager.shared
    }

    private func setupHotkeyManager() {
        hotkeyManager = HotkeyManager.shared
        hotkeyManager.onHotkeyPressed = { [weak self] in
            self?.showClipboard()
        }
    }

    private func checkOnboarding() {
        let settings = StorageService.shared.loadSettings()
        if !settings.hasCompletedOnboarding {
            showOnboarding()
        }
    }

    @objc private func statusItemClicked() {
        showClipboard()
    }

    @objc private func showClipboard() {
        let popoverState = ClipboardPopoverState.shared

        if popover.isShown {
            popover.performClose(nil)
            popoverState.hide()
        } else {
            popoverState.show()
            popover.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .minY)
        }
    }

    @objc func openSettings() {
        NSApp.activate(ignoringOtherApps: true)

        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)
            let window = NSWindow(contentViewController: hostingController)
            window.title = "ClipNest 设置"
            window.styleMask = [.titled, .closable]
            window.setContentSize(NSSize(width: 400, height: 300))
            window.center()
            window.isReleasedWhenClosed = false
            settingsWindow = window
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
    }

    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = AppVersion.appName
        alert.informativeText = "版本 v\(AppVersion.version)\n\n\(AppVersion.description)"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "好的")
        alert.runModal()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    func showOnboarding() {
        NSApp.activate(ignoringOtherApps: true)

        let onboardingView = OnboardingView { [weak self] in
            self?.onboardingWindow?.close()
            self?.onboardingWindow = nil
        }
        let hostingController = NSHostingController(rootView: onboardingView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "欢迎使用 ClipNest"
        window.styleMask = [.titled, .closable]
        window.setContentSize(NSSize(width: 400, height: 280))
        window.center()
        window.isReleasedWhenClosed = false
        onboardingWindow = window
        onboardingWindow?.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager?.unregisterHotkey()
        ClipboardPopoverState.shared.hide()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
