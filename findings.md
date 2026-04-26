# ClipNest 发现与研究

## 技术选型

### SwiftUI vs AppKit
- 决定：纯 SwiftUI
- 原因：现代声明式 UI，开发效率高

### 项目管理
- XcodeGen + SPM
- HotKey 库用于全局快捷键

### 数据存储
- JSON 文件存储在 ~/Library/Application Support/ClipNest/
- 图片存储在 Images 子目录

## macOS 特性

### LSUIElement = YES
菜单栏应用，不显示 Dock 图标

### 辅助功能权限
需要授权才能使用全局快捷键
- 检查方式：AXIsProcessTrustedWithOptions
- 引导用户：打开系统偏好设置

## 快捷键实现

### HotKey 库
- SPM: https://github.com/soffes/HotKey
- 从 v0.2.0 版本
- Key(carbonKeyCode:) 返回可选值，需要 guard 解包

### Carbon 常量
macOS 12+ 使用 lowercase 版本：
- `optionKey` 而非 `OptionKey`
- `controlKey` 而非 `ControlKeyMask`
- `shiftKey` 而非 `ShiftKeyMask`
- `cmdKey` 而非 `CommandKeyMask`

## 图片处理
- 使用 NSPasteboard 监听
- 支持 .png 和 .tiff 格式
- MD5 去重
- 存储在临时目录，可被清理
