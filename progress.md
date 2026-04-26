# ClipNest 开发进度

## 2026-04-26

### 项目初始化
- 创建项目目录结构
- 配置 XcodeGen (project.yml)
- 添加 HotKey SPM 依赖
- 生成 Xcode 项目

### 核心代码实现
- main.swift - 应用入口
- AppDelegate.swift - 菜单栏 + 弹出窗口管理
- ClipboardItem.swift - 数据模型
- AppSettings.swift - 设置模型（含快捷键描述）
- StorageService.swift - JSON 存储
- ClipboardManager.swift - 剪切板监控 + 去重
- HotkeyManager.swift - 全局快捷键
- ClipboardPopoverView.swift - 历史列表 UI
- MenuBarView.swift - 菜单栏视图
- SettingsView.swift - 设置窗口
- OnboardingView.swift - 首次引导

### Git 提交
- 初始提交: 8998f09
- Tag: v0.0.1

### 构建状态
- ✅ BUILD SUCCEEDED

### 修复的问题
1. Carbon 常量名称修正 (OptionKey → optionKey)
2. Key(carbonKeyCode:) 可选值处理
3. GENERATE_INFOPLIST_FILE 设置

## 2026-04-26 (续)

### 会话恢复
- 从上下文压缩恢复
- 运行 session-catchup.py - 无未同步上下文
- 规划文件状态确认

### 当前状态
- 项目构建成功 (v0.0.1)
- 核心功能实现完成
- 等待功能测试

### Bug 修复
1. 快捷键回调未连接 - 添加 `onHotkeyPressed` 回调连接
2. 快捷键切换功能 - 按下显示/隐藏切换
3. 弹窗不抢夺焦点 - 移除 `NSApp.activate` 和 `makeKey()` 调用，保持光标位置

### 新增功能
- 键盘导航: 上下键选择剪切板条目
- 快速粘贴: 回车键复制并粘贴到当前光标位置
- CGEvent 模拟 Cmd+V 实现自动粘贴
- CGEvent Tap 全局键盘拦截 - 使用 KeyboardInterceptor 实现真正的全局键盘监控，上下键和回车键被拦截后不会发送到其他应用

### UI 现代化优化
- OnboardingView: 4页引导流程，渐变图标，卡片布局，平滑过渡动画
- SettingsView: 现代卡片设计，分组布局，彩色标签，状态指示器
- ClipboardPopoverView: 图标类型区分，悬停效果，选中高亮，导航提示

## 下一步
- 功能测试
- 用户验证
- 发布 v1.0.0

## 2026-04-26 (续)

### Bug 修复 - 键盘拦截功能

#### 权限状态实时刷新
- 在 SettingsView 中添加定时器，每秒检查 `AXIsProcessTrusted()` 状态
- 修复前：权限状态只在窗口出现时检查一次
- 修复后：每秒自动刷新，授权状态变化实时更新 UI

#### 键盘拦截架构重构
问题分析：
- `NSPopover` 的 `behavior = .transient` 会缓存视图，`onAppear` 只在首次出现时调用
- `NSHostingController<ClipboardPopoverView>` 每次访问 `.rootView` 返回的是值类型副本

解决方案 - 重构为 ObservableObject 模式：
1. 新增 `ClipboardPopoverState` 集中管理状态和键盘拦截
   - `isPopoverShown` - 显示状态
   - `selectedItemId` - 选中项
   - `onHideRequest` 回调 - 关闭弹窗
   - `handleUpArrow()` / `handleDownArrow()` / `handleReturn()` 处理按键
2. `ClipboardPopoverView` 使用 `@ObservedObject` 观察状态
3. `AppDelegate` 设置 `onHideRequest` 回调并调用 `popover.performClose(nil)`

#### 回车关闭弹窗修复
- `ClipboardPopoverState.handleReturn()` → `closePopoverAndPaste()` → `hide()`
- `hide()` 调用 `onHideRequest` 回调 → `popover.performClose(nil)` 真正关闭弹窗
- 延迟 0.15 秒后模拟 Cmd+V 粘贴

### 当前状态
- ✅ 键盘上下键导航功能
- ✅ 回车键粘贴并关闭弹窗
- ✅ 权限状态实时刷新
- ✅ 每次打开/关闭弹窗时正确安装/卸载键盘拦截器

### 待测试
- [ ] 键盘导航和回车粘贴功能验证
- [ ] 多次打开/关闭弹窗稳定性
- [ ] 辅助功能权限检测准确性

## 2026-04-26 (续)

### Bug 修复 - 辅助功能权限重启后丢失

**问题**：在当前会话中辅助功能权限显示正确，但重启应用后显示为未授权。

**根本原因**：
1. Xcode 重新编译后应用使用新的 ad-hoc 签名
2. macOS 辅助功能权限基于代码签名，不同签名 = 不同应用 = 权限丢失
3. `AXIsProcessTrusted()` 只检查不触发授权流程

**解决方案**：
1. `AccessibilityManager` 新增 `requestPermission()` 方法
   - 调用 `AXIsProcessTrustedWithOptions` 并设置 `prompt: true`
   - 这会弹出系统授权对话框，引导用户重新授权
2. `SettingsView` 点击"设置"按钮时调用 `requestPermission()`
3. 持续监控权限状态变化

**新增文件**：
- `Sources/ClipNest/Services/AccessibilityManager.swift`

**验证**：
- ✅ BUILD SUCCEEDED

## 2026-04-26 (续)

### 新功能 - 单个删除剪切板条目

**实现方式**：
1. 在 `ClipboardManager` 添加 `deleteItem(id: UUID)` 方法
2. 在 `ClipboardItemRow` 添加：
   - 删除按钮（选中项悬停时显示 x 图标）
   - 右键菜单（"删除"选项）
3. 删除后自动更新选中项到下一项

**修改的文件**：
- `ClipboardManager.swift` - 添加 `deleteItem()` 方法
- `ClipboardPopoverView.swift` - 添加删除 UI 和回调

**验证**：
- ✅ BUILD SUCCEEDED

### Bug 修复 - 图标居中调整

**问题**：图标视觉上看起来太靠近左下角。

**解决方案**：
- 重新生成图标，将剪贴板图案 Y 坐标上移 2%
- 构建成功，图标居中显示

### 新功能 - 使用 SF Symbol 生成图标

**问题**：自定义绘图图标位置不正。

**解决方案**：
- 直接使用 SF Symbol `doc.on.clipboard.fill`
- 蓝色渐变背景 + 居中的 SF Symbol
- 图标自动完美居中

### 新增 README.md

**内容**：
- 项目简介和核心功能
- AI Vibe Coding 说明
- 系统要求和安装方式
- 权限说明（辅助功能和屏幕录制）
- 使用方法
- 技术架构和项目结构
- MIT 开源协议全文
- 作者：晨奕

### 新功能 - 引导界面添加权限请求

**问题**：首次启动时需要引导用户授予辅助功能权限。

**解决方案**：
- 在 OnboardingView 最后一页添加权限请求页面
- 包含"授予权限"按钮调用 `AccessibilityManager.shared.requestPermission()`
- 用户可选择授予权限或跳过
- 添加 `import ApplicationServices` 确保 AccessibilityManager 可用

**设计概念**：
- 堆叠的剪贴板表示剪切板历史
- 蓝色渐变背景，体现现代感
- 右上角绿色对勾徽章，表示应用正常运行
- 白色纸张和灰色线条细节

**图标尺寸**：
- 16x16, 32x32, 64x64, 128x128, 256x256, 512x512, 1024x1024

**生成方式**：
- Swift 脚本使用 AppKit 绘图生成
- 渐变背景、堆叠效果、徽章等元素

**验证**：
- ✅ BUILD SUCCEEDED
