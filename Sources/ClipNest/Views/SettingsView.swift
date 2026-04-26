import SwiftUI
import AppKit

struct SettingsView: View {
    @ObservedObject private var hotkeyManager = HotkeyManager.shared
    @State private var maxHistoryCount: Int = 100
    @State private var accessibilityAuthorized = false
    @State private var showClearConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox("快捷键") {
                HStack {
                    Text("全局快捷键:")
                    Spacer()
                    Text(hotkeyManager.currentHotkeyDescription)
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(4)

                    Button("删除以录制新快捷键") {
                        hotkeyManager.deleteHotkey()
                    }
                    .disabled(hotkeyManager.isRecording)
                }
                .padding(8)

                if hotkeyManager.isRecording {
                    HStack {
                        Image(systemName: "record.circle")
                            .foregroundColor(.red)
                        Text("请按下新的快捷键组合...")
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                }
            }

            GroupBox("历史记录") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("最大记录数:")
                        Spacer()
                        Text("\(maxHistoryCount)")
                            .foregroundColor(.secondary)
                    }

                    Slider(value: Binding(
                        get: { Double(maxHistoryCount) },
                        set: { newValue in
                            maxHistoryCount = Int(newValue)
                            ClipboardManager.shared.updateMaxHistoryCount(Int(newValue))
                            saveSettings()
                        }
                    ), in: 20...500, step: 10)
                }
                .padding(8)
            }

            GroupBox("权限状态") {
                HStack {
                    Image(systemName: accessibilityAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(accessibilityAuthorized ? .green : .red)

                    Text(accessibilityAuthorized ? "已授权" : "未授权")
                        .foregroundColor(accessibilityAuthorized ? .green : .red)

                    Spacer()

                    Button("打开系统设置") {
                        openAccessibilitySettings()
                    }
                }
                .padding(8)
            }

            Spacer()

            HStack {
                Button("清空所有历史记录") {
                    showClearConfirmation = true
                }
                .foregroundColor(.red)

                Spacer()

                Text("版本 v0.0.1")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 400, height: 320)
        .onAppear {
            loadSettings()
            checkAccessibility()
        }
        .alert("确认清空", isPresented: $showClearConfirmation) {
            Button("取消", role: .cancel) {}
            Button("清空", role: .destructive) {
                ClipboardManager.shared.clearHistory()
            }
        } message: {
            Text("确定要清空所有剪切板历史记录吗？此操作不可恢复。")
        }
    }

    private func loadSettings() {
        let settings = StorageService.shared.loadSettings()
        maxHistoryCount = settings.maxHistoryCount
    }

    private func saveSettings() {
        var settings = StorageService.shared.loadSettings()
        settings.maxHistoryCount = maxHistoryCount
        StorageService.shared.saveSettings(settings)
    }

    private func checkAccessibility() {
        accessibilityAuthorized = checkAccessibilityPermission()
    }

    private func checkAccessibilityPermission() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: false] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}
