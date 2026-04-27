import Foundation
import Carbon
import AppKit
import ApplicationServices

class KeyboardInterceptor: ObservableObject {
    static let shared = KeyboardInterceptor()

    var onUpArrow: (() -> Void)?
    var onDownArrow: (() -> Void)?
    var onReturn: (() -> Void)?
    var onEscape: (() -> Void)?

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isInstalled = false
    private var masks: [CGEventMask] = []

    private init() {}

    func install() {
        guard !isInstalled else { return }

        // Create event mask for key down events
        let keyDownMask: CGEventMask = (1 << CGEventType.keyDown.rawValue)
        let flagsChangedMask: CGEventMask = (1 << CGEventType.flagsChanged.rawValue)

        // Use system-wide event tap at session level
        let eventMask = keyDownMask | flagsChangedMask

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else {
                    return Unmanaged.passRetained(event)
                }

                let interceptor = Unmanaged<KeyboardInterceptor>.fromOpaque(refcon).takeUnretainedValue()

                if type == .keyDown {
                    let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

                    // Check if this is one of our intercepted keys
                    if keyCode == Int64(kVK_UpArrow) ||
                       keyCode == Int64(kVK_DownArrow) ||
                       keyCode == Int64(kVK_Return) ||
                       keyCode == Int64(kVK_Escape) {

                        // Invoke the callback on the main thread
                        DispatchQueue.main.async {
                            switch keyCode {
                            case Int64(kVK_UpArrow):
                                interceptor.onUpArrow?()
                            case Int64(kVK_DownArrow):
                                interceptor.onDownArrow?()
                            case Int64(kVK_Return):
                                interceptor.onReturn?()
                            case Int64(kVK_Escape):
                                interceptor.onEscape?()
                            default:
                                break
                            }
                        }

                        // Return nil to consume the event (prevent it from reaching other apps)
                        return nil
                    }
                }

                // Pass event through for other keys
                return Unmanaged.passRetained(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("KeyboardInterceptor: Failed to create event tap. Check accessibility permissions.")
            return
        }

        eventTap = tap

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            isInstalled = true
            print("KeyboardInterceptor: Successfully installed")
        }
    }

    func uninstall() {
        guard isInstalled else { return }

        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }

        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }

        runLoopSource = nil
        eventTap = nil
        isInstalled = false
        print("KeyboardInterceptor: Uninstalled")
    }

    func isReady() -> Bool {
        return isInstalled && AXIsProcessTrusted()
    }

    deinit {
        uninstall()
    }
}

// MARK: - Accessibility Helper
extension KeyboardInterceptor {
    static func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    static func checkAccessibilityPermission() -> Bool {
        return AXIsProcessTrusted()
    }
}
