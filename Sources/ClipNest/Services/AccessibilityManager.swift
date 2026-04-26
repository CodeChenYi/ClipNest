import Foundation
import AppKit
import Combine
import ApplicationServices

class AccessibilityManager: ObservableObject {
    static let shared = AccessibilityManager()

    @Published var isAuthorized: Bool = false
    @Published var needsToCheck: Bool = true

    private var checkTimer: Timer?
    private var permissionRequestInProgress = false

    private init() {}

    func startMonitoring() {
        // Initial check after app launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.checkAndUpdate()
        }

        // Schedule periodic checks to handle system delay after permission changes
        checkTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkAndUpdate()
        }
    }

    func stopPeriodicCheck() {
        checkTimer?.invalidate()
        checkTimer = nil
    }

    func checkAndUpdate() {
        let newStatus = AXIsProcessTrusted()

        DispatchQueue.main.async { [weak self] in
            self?.isAuthorized = newStatus
        }

        // If authorized, stop periodic checking
        if newStatus {
            stopPeriodicCheck()
            permissionRequestInProgress = false
        }
    }

    func forceRefresh() {
        checkAndUpdate()
    }

    func requestPermission() {
        // Prevent multiple simultaneous permission requests
        guard !permissionRequestInProgress else { return }

        permissionRequestInProgress = true

        // This will show the system authorization dialog
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)

        // Check status after a delay to catch user's choice
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.permissionRequestInProgress = false
            self?.checkAndUpdate()
        }
    }

    deinit {
        stopPeriodicCheck()
    }
}
