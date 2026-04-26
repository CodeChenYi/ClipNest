import SwiftUI
import AppKit

struct MenuBarView: View {
    @ObservedObject private var clipboardManager = ClipboardManager.shared

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 14))
                Text("ClipNest")
                    .font(.system(size: 13, weight: .medium))
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            if clipboardManager.history.isEmpty {
                VStack(spacing: 8) {
                    Text("暂无历史记录")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(clipboardManager.history.prefix(10)) { item in
                            MenuBarItemRow(item: item) {
                                clipboardManager.copyToClipboard(item)
                            }
                            Divider()
                        }
                    }
                }
                .frame(maxHeight: 300)
            }
        }
        .frame(width: 280)
    }
}

struct MenuBarItemRow: View {
    let item: ClipboardItem
    let onCopy: () -> Void

    var body: some View {
        Button(action: onCopy) {
            HStack(spacing: 8) {
                if item.type == .text {
                    Image(systemName: "doc.text")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(width: 16)
                } else {
                    if let thumbnail = item.thumbnailImage {
                        Image(nsImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 24, height: 24)
                            .cornerRadius(3)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 24, height: 24)
                            .cornerRadius(3)
                    }
                }

                Text(item.preview)
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}
