import SwiftUI
import Carbon
import ApplicationServices

struct ClipboardPopoverView: View {
    @ObservedObject private var clipboardManager = ClipboardManager.shared
    @ObservedObject private var popoverState = ClipboardPopoverState.shared
    @State private var hoveredItemId: UUID?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.clipboard.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.accentColor)

                        Text("剪切板历史")
                            .font(.system(size: 14, weight: .semibold))

                        Text("\(clipboardManager.history.count)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.accentColor.opacity(0.8))
                            )
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 9))
                        Image(systemName: "arrow.down")
                            .font(.system(size: 9))
                        Text("导航")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: "return")
                            .font(.system(size: 10))
                        Text("粘贴")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.secondary)
                }

                HStack(spacing: 2) {
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(width: 40, height: 3)
                        .cornerRadius(1.5)
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(Color(NSColor.windowBackgroundColor))

            // Content
            if clipboardManager.history.isEmpty {
                emptyStateView
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 2) {
                            ForEach(clipboardManager.history) { item in
                                ClipboardItemRow(
                                    item: item,
                                    isSelected: popoverState.selectedItemId == item.id,
                                    isHovered: hoveredItemId == item.id,
                                    onDelete: {
                                        deleteItem(item)
                                    }
                                )
                                .id(item.id)
                                .onTapGesture {
                                    handleItemTap(item)
                                }
                                .onHover { hovering in
                                    hoveredItemId = hovering ? item.id : nil
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }
                    .onChange(of: popoverState.selectedItemId) { newId in
                        if let id = newId {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                proxy.scrollTo(id, anchor: .center)
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 320, height: 400)
        .onAppear {
            if popoverState.selectedItemId == nil {
                popoverState.selectedItemId = clipboardManager.history.first?.id
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 32))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 4) {
                Text("暂无历史记录")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)

                Text("复制一些内容，它们会出现在这里")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }

    private func handleItemTap(_ item: ClipboardItem) {
        ClipboardManager.shared.copyToClipboard(item)

        popoverState.hide()

        if AXIsProcessTrusted() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                simulatePaste()
            }
        }
    }

    private func deleteItem(_ item: ClipboardItem) {
        let wasSelected = popoverState.selectedItemId == item.id
        ClipboardManager.shared.deleteItem(id: item.id)

        // Update selection to next item or previous
        if wasSelected {
            if let newSelectedId = ClipboardManager.shared.history.first?.id {
                popoverState.selectedItemId = newSelectedId
            } else {
                popoverState.selectedItemId = nil
            }
        }
    }

    private func simulatePaste() {
        guard AXIsProcessTrusted() else { return }

        let source = CGEventSource(stateID: .hidSystemState)

        guard let keyDown = CGEvent(keyboardEventSource: source, virtualKey: UInt16(kVK_ANSI_V), keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: UInt16(kVK_ANSI_V), keyDown: false) else {
            return
        }

        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand

        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }
}

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let isSelected: Bool
    let isHovered: Bool
    var onDelete: (() -> Void)?

    var body: some View {
        HStack(spacing: 10) {
            // Type icon
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(iconBackgroundColor)
                    .frame(width: 36, height: 36)

                if item.type == .text {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                } else {
                    if let thumbnail = item.thumbnailImage {
                        Image(nsImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 36, height: 36)
                            .cornerRadius(6)
                            .clipped()
                    } else {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 16))
                            .foregroundColor(iconColor)
                    }
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 3) {
                Text(item.preview)
                    .font(.system(size: 13))
                    .lineLimit(2)
                    .foregroundColor(.primary)

                HStack(spacing: 4) {
                    Text(formatDate(item.createdAt))
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)

                    if item.type == .image {
                        Text("·")
                            .foregroundColor(.secondary)
                        Text("图片")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // Action hint
            if isSelected {
                HStack(spacing: 4) {
                    Text("↵ 粘贴")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.accentColor.opacity(0.15))
                        )

                    if isHovered || isSelected {
                        Button(action: {
                            onDelete?()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)
                        .help("删除")
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(rowBackgroundColor)
        )
        .contentShape(Rectangle())
        .contextMenu {
            Button(role: .destructive) {
                onDelete?()
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
    }

    private var rowBackgroundColor: Color {
        if isSelected {
            return Color.accentColor.opacity(0.12)
        } else if isHovered {
            return Color.gray.opacity(0.08)
        } else {
            return Color.clear
        }
    }

    private var iconBackgroundColor: Color {
        if item.type == .text {
            return Color.blue.opacity(0.15)
        } else {
            return Color.purple.opacity(0.15)
        }
    }

    private var iconColor: Color {
        if item.type == .text {
            return .blue
        } else {
            return .purple
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    ClipboardPopoverView()
}
