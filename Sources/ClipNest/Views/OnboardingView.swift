import SwiftUI
import AppKit

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var currentPage = 0

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "doc.on.clipboard.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)

            Text("欢迎使用 ClipNest")
                .font(.title)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(
                    icon: "keyboard",
                    title: "全局快捷键",
                    description: "按 Option + V 快速打开剪切板历史"
                )

                FeatureRow(
                    icon: "clock.arrow.circlepath",
                    title: "历史记录",
                    description: "自动保存复制的内容，随时查看和复制"
                )

                FeatureRow(
                    icon: "lock.shield",
                    title: "隐私保护",
                    description: "所有数据保存在本地，不会上传到任何服务器"
                )

                FeatureRow(
                    icon: "gear",
                    title: "辅助功能权限",
                    description: "需要授权才能使用全局快捷键功能"
                )
            }
            .padding(.horizontal, 20)

            Spacer()

            HStack {
                if currentPage > 0 {
                    Button("上一步") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                }

                Spacer()

                ForEach(0..<2) { index in
                    Circle()
                        .fill(index == currentPage ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }

                Spacer()

                if currentPage < 1 {
                    Button("下一步") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("开始使用") {
                        completeOnboarding()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(width: 400, height: 340)
    }

    private func completeOnboarding() {
        var settings = StorageService.shared.loadSettings()
        settings.hasCompletedOnboarding = true
        StorageService.shared.saveSettings(settings)
        onComplete()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
