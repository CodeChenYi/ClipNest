import SwiftUI
import AppKit

struct SettingsView: View {
    @ObservedObject private var hotkeyManager = HotkeyManager.shared
    @ObservedObject private var accessibilityManager = AccessibilityManager.shared
    @State private var maxHistoryCount: Int = 100
    @State private var showClearConfirmation = false
    @State private var window: NSWindow?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 4) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)

                Text("设置")
                    .font(.system(size: 20, weight: .bold))
            }
            .padding(.top, 20)
            .padding(.bottom, 16)

            ScrollView {
                VStack(spacing: 16) {
                    // Hotkey Section
                    settingsCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("快捷键", systemImage: "keyboard")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)

                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("全局快捷键")
                                        .font(.system(size: 14, weight: .medium))

                                    Text("按快捷键打开/关闭剪切板")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Text(hotkeyManager.currentHotkeyDescription)
                                    .font(.system(size: 14, design: .monospaced))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(NSColor.textBackgroundColor))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }

                            Button(action: {
                                hotkeyManager.deleteHotkey()
                            }) {
                                HStack {
                                    Image(systemName: "pencil.circle")
                                    Text("重新录制快捷键")
                                }
                                .font(.system(size: 12))
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.accentColor)
                            .disabled(hotkeyManager.isRecording)

                            if hotkeyManager.isRecording {
                                HStack(spacing: 6) {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                    Text("请按下新的快捷键组合...")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }

                    // History Section
                    settingsCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("历史记录", systemImage: "clock.arrow.circlepath")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)

                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("最大保存条数")
                                        .font(.system(size: 14, weight: .medium))

                                    Spacer()

                                    Text("\(maxHistoryCount)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.accentColor)
                                }

                                Slider(value: Binding(
                                    get: { Double(maxHistoryCount) },
                                    set: { newValue in
                                        maxHistoryCount = Int(newValue)
                                        ClipboardManager.shared.updateMaxHistoryCount(Int(newValue))
                                        saveSettings()
                                    }
                                ), in: 20...500, step: 10)
                                .accentColor(.accentColor)

                                HStack {
                                    Text("20")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("500")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }

                    // Permissions Section
                    settingsCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("权限状态", systemImage: "hand.raised.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)

                            HStack {
                                Circle()
                                    .fill(accessibilityManager.isAuthorized ? Color.green : Color.red)
                                    .frame(width: 10, height: 10)

                                Text(accessibilityManager.isAuthorized ? "已获得辅助功能权限" : "需要辅助功能权限")
                                    .font(.system(size: 14, weight: .medium))

                                Spacer()

                                Button(action: {
                                    openAccessibilitySettings()
                                }) {
                                    Text("设置")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(accessibilityManager.isAuthorized ? Color.green : Color.accentColor)
                                        )
                                }
                                .buttonStyle(.plain)
                            }

                            if !accessibilityManager.isAuthorized {
                                Text("需要此权限才能使用全局快捷键和自动粘贴功能")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    // Danger Zone
                    settingsCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("数据管理", systemImage: "trash")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)

                            Button(action: {
                                showClearConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("清空所有历史记录")
                                }
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            // Footer
            HStack {
                Text("ClipNest v0.0.1")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(NSColor.separatorColor).opacity(0.1))
        }
        .frame(width: 380, height: 480)
        .onAppear {
            loadSettings()
            accessibilityManager.forceRefresh()
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

    @ViewBuilder
    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
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

    private func openAccessibilitySettings() {
        // Request permission first (shows dialog if needed), then open system prefs
        accessibilityManager.requestPermission()

        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}

#Preview {
    SettingsView()
}
