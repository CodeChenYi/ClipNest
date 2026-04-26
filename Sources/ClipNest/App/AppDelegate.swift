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
    }

    private func setupClipboardManager() {
        clipboardManager = ClipboardManager.shared
    }

    private func setupHotkeyManager() {
        hotkeyManager = HotkeyManager.shared
    }

    private func checkOnboarding() {
        let settings = StorageService.shared.loadSettings()
        if !settings.hasCompletedOnboarding {
            showOnboarding()
        }
    }

    @objc private func statusItemClicked() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }

    @objc private func showClipboard() {
        NSApp.activate(ignoringOtherApps: true)
        if let button = statusItem.button {
            if !popover.isShown {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
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
        alert.messageText = "ClipNest"
        alert.informativeText = "版本 v0.0.1\n\n一个简洁的 macOS 剪切板历史管理工具。"
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
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
