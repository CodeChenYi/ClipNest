import SwiftUI

struct ClipboardPopoverView: View {
    @ObservedObject private var clipboardManager = ClipboardManager.shared
    @State private var selectedItemId: UUID?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("剪切板历史")
                    .font(.headline)
                Spacer()
                Text("\(clipboardManager.history.count) 条")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            if clipboardManager.history.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("暂无历史记录")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("复制一些内容，它们会出现在这里")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            } else {
                ScrollViewReader { proxy in
                    List(clipboardManager.history) { item in
                        ClipboardItemRow(item: item, isSelected: selectedItemId == item.id)
                            .id(item.id)
                            .onTapGesture {
                                copyItem(item)
                            }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .frame(width: 320, height: 400)
    }

    private func copyItem(_ item: ClipboardItem) {
        clipboardManager.copyToClipboard(item)
        NSApp.windows.first { $0.isKeyWindow }?.close()
    }
}

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 10) {
            if item.type == .text {
                Image(systemName: "doc.text")
                    .foregroundColor(.secondary)
                    .frame(width: 20)
            } else {
                if let thumbnail = item.thumbnailImage {
                    Image(nsImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .cornerRadius(4)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .cornerRadius(4)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.secondary)
                        )
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.preview)
                    .font(.system(size: 13))
                    .lineLimit(2)
                    .foregroundColor(.primary)

                Text(formatDate(item.createdAt))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .contentShape(Rectangle())
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
