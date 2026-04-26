import SwiftUI
import AppKit
import ApplicationServices

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var currentPage = 0
    @ObservedObject private var accessibilityManager = AccessibilityManager.shared

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "doc.on.clipboard.fill",
            iconColor: .blue,
            title: "欢迎使用 ClipNest",
            subtitle: "您的智能剪切板历史管理器",
            description: "简洁、高效、注重隐私"
        ),
        OnboardingPage(
            icon: "keyboard.fill",
            iconColor: .purple,
            title: "全局快捷键",
            subtitle: "Option + V",
            description: "在任何应用中快速呼出剪切板历史"
        ),
        OnboardingPage(
            icon: "clock.arrow.circlepath",
            iconColor: .orange,
            title: "历史记录",
            subtitle: "自动保存",
            description: "文本和图片历史永久保存，随时查看和复制"
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            iconColor: .green,
            title: "隐私保护",
            subtitle: "本地存储",
            description: "所有数据仅保存在您本地，不上传到任何服务器"
        ),
        OnboardingPage(
            icon: "hand.raised.fill",
            iconColor: .red,
            title: "需要权限",
            subtitle: "辅助功能",
            description: "需要辅助功能权限才能使用全局快捷键和自动粘贴功能"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Page content
            ZStack {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    if index == currentPage {
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [page.iconColor.opacity(0.3), page.iconColor.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)

                                Image(systemName: page.icon)
                                    .font(.system(size: 50))
                                    .foregroundColor(page.iconColor)
                            }

                            VStack(spacing: 8) {
                                Text(page.title)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)

                                Text(page.subtitle)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(page.iconColor)

                                Text(page.description)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                }
            }
            .frame(height: 320)

            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                }
            }
            .padding(.bottom, 24)

            // Navigation buttons
            HStack(spacing: 16) {
                if currentPage > 0 {
                    Button("上一步") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                }

                Spacer()

                if currentPage < pages.count - 1 {
                    Button("下一步") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .buttonStyle(.nextButtonStyle)
                } else if currentPage == pages.count - 1 {
                    // Permission page - show request permission button
                    Button("授予权限") {
                        AccessibilityManager.shared.requestPermission()
                    }
                    .buttonStyle(.primaryButtonStyle)

                    Button("跳过") {
                        completeOnboarding()
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                } else {
                    Button("开始使用") {
                        completeOnboarding()
                    }
                    .buttonStyle(.primaryButtonStyle)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .frame(width: 400, height: 420)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.95))
    }

    private func completeOnboarding() {
        var settings = StorageService.shared.loadSettings()
        settings.hasCompletedOnboarding = true
        StorageService.shared.saveSettings(settings)
        onComplete()
    }
}

struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let description: String
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accentColor)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct NextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.accentColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accentColor, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primaryButtonStyle: PrimaryButtonStyle { PrimaryButtonStyle() }
}

extension ButtonStyle where Self == NextButtonStyle {
    static var nextButtonStyle: NextButtonStyle { NextButtonStyle() }
}

#Preview {
    OnboardingView(onComplete: {})
}
