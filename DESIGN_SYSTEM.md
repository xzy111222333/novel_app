# 小灵感 - 手绘草稿纸设计系统

本文档是「小灵感」APP 的 UI 设计规范。新增或修改任何页面时，请严格遵循此设计系统。

## 设计理念

手绘草稿纸风格，追求真实的手工质感，拒绝数字化的冰冷精确。
像在草稿纸上用铅笔和彩色圆珠笔画出的 UI，充满随意感和创作氛围。

**核心原则：**
- **没有直线** — 所有边框使用不规则 wobbly 圆角（椭圆不对称），绝不使用标准 `BorderRadius.circular()`
- **硬偏移阴影** — 零模糊，实心偏移 3-4px，营造剪纸拼贴感，绝不使用 `blurRadius`
- **纸张质感** — 暖色纸底 + 圆点网格纹理，模拟草稿纸
- **手写字体** — 标题使用站酷快乐体（ZCOOL KuaiLe），正文使用系统默认字体保证可读性
- **有限色板** — 铅笔黑、旧纸色、红色修正笔、蓝色圆珠笔、便签黄，不引入其他颜色
- **装饰元素** — 胶带条、图钉、虚线边框，强化手绘草稿感
- **轻微旋转** — 装饰性元素可使用 -2deg ~ 2deg 旋转，打破网格的刻板

## 色彩 Token

所有颜色统一定义在 `lib/theme/app_theme.dart`，禁止在页面中硬编码十六进制色值。

| Token | 色值 | 用途 |
|-------|------|------|
| `background` | `#FDFBF7` | 暖纸色，全局背景 |
| `cardBackground` | `#FFFFFF` | 卡片内部填充 |
| `textPrimary` | `#2D2D2D` | 铅笔黑，主要文字和边框 |
| `textSecondary` | `#6B6B6B` | 浅铅笔，次要文字 |
| `textTertiary` | `#ADA89F` | 淡墨，占位文字和禁用态 |
| `muted` | `#E5E0D8` | 旧纸色，未选中背景、分割线 |
| `accent` | `#FF4D4D` | 红色修正笔，强调、收藏星、删除 |
| `accentSoft` | `#FFE5E5` | 淡红，删除按钮背景 |
| `secondary` | `#2D5DA1` | 蓝色圆珠笔，链接、聚焦边框 |
| `postIt` | `#FFF9C4` | 便签黄，特殊卡片 |
| `border` | `#2D2D2D` | 铅笔边框色（= textPrimary） |

### 模块专属色

| Token | 色值 | 用途 |
|-------|------|------|
| `materialColor` / `materialBg` | `#2D5DA1` / `#F0F4FA` | 素材模块 |
| `vocabularyColor` / `vocabularyBg` | `#FF4D4D` / `#FFF0F0` | 词汇模块 |
| `inspirationColor` / `inspirationBg` | `#2D2D2D` / `#FDFBF7` | 灵感模块 |
| `plotColor` / `plotBg` | `#6B8E5A` / `#F5F8F2` | 情节模块 |

## 不规则圆角 (Wobbly Border Radius)

**这是最核心的视觉特征。** 使用椭圆不对称圆角创造有机的手绘边缘。

| 预设 | 用途 | 示例场景 |
|------|------|----------|
| `AppTheme.wobbly` | 超大容器 | 特殊弹窗、全屏卡片 |
| `AppTheme.wobblyMd` | 中型容器 | 卡片、对话框 |
| `AppTheme.wobblySmall` | 小型容器 | 输入框、按钮、小卡片 |
| `AppTheme.wobblyPill` | 胶囊/药丸 | 分类标签、标签芯片 |

```dart
// 正确用法
Container(
  decoration: BoxDecoration(
    borderRadius: AppTheme.wobblySmall,
    border: Border.all(color: AppTheme.border, width: 2),
  ),
)

// 错误用法 — 禁止！
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),  // 不允许
  ),
)
```

## 阴影

硬偏移阴影，零模糊，模拟剪纸层叠效果。

| 预设 | 偏移 | 用途 |
|------|------|------|
| `hardShadow` | 4px 4px | 主要卡片 |
| `hardShadowSmall` | 3px 3px | 小型元素 |
| `hardShadowSubtle` | 3px 3px (10%透明度) | 静态卡片 |
| `hardShadowHover` | 2px 2px | 按下/悬停态 |

```dart
// 按钮按下效果：阴影消失 + 位移
GestureDetector(
  child: Container(
    decoration: BoxDecoration(
      boxShadow: isPressed ? [] : AppTheme.hardShadowSmall,
    ),
    transform: isPressed 
      ? Matrix4.translationValues(3, 3, 0) 
      : Matrix4.identity(),
  ),
)
```

## 字体

| 场景 | 字体 | 调用方式 |
|------|------|----------|
| 标题 | ZCOOL KuaiLe (站酷快乐体) | `AppTheme.headingStyleWith(fontSize: 20)` |
| 正文 | 系统默认 | `TextStyle(fontSize: 14, color: AppTheme.textPrimary)` |
| 占位 | 系统默认 | `TextStyle(color: AppTheme.textPrimary.withAlpha(100))` |

**注意：** `headingStyleWith()` 是方法调用，不能放在 `const` 表达式中。
```dart
// 正确
Text('标题', style: AppTheme.headingStyleWith(fontSize: 18))

// 错误 — const 内不能有方法调用
const Text('标题', style: AppTheme.headingStyleWith(fontSize: 18))
```

## 预置装饰 (BoxDecoration)

| 预设 | 用途 |
|------|------|
| `AppTheme.cardDecoration` | 标准卡片（白底 + wobblyMd + 2px边框 + 淡阴影） |
| `AppTheme.smallCardDecoration` | 小卡片（白底 + wobblySmall + 2px边框 + 淡阴影） |
| `AppTheme.postItDecoration` | 便签卡片（黄底 + wobblyMd + 2px边框） |
| `AppTheme.outlinedCircleDecoration()` | 圆形按钮（白底 + 圆形 + 2px边框 + 小阴影） |

## 装饰元素

```dart
// 胶带条 — 放在卡片顶部居中
AppTheme.tapeDecoration(width: 60, rotation: -0.05)

// 图钉 — 放在卡片顶部
AppTheme.tackDecoration(color: AppTheme.accent)
```

## 纸张纹理背景

全局纸张纹理在 `lib/main.dart` 中通过 `_PaperTexturePainter` 实现，
以 24px 间距绘制淡色圆点网格。所有页面 Scaffold 使用 `backgroundColor: Colors.transparent` 来显示底层纹理。

## 新建页面模板

新建页面时，遵循以下结构：

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NewScreen extends StatelessWidget {
  const NewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 透明，显示底层纸张纹理
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        // 暖纸色，与背景一致
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, 
            color: AppTheme.textSecondary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        // 标题使用手写体
        title: Text('页面标题', 
          style: AppTheme.headingStyleWith(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // 卡片容器
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 区块标题
                Text('区块标题', 
                  style: AppTheme.headingStyleWith(fontSize: 14)),
                const SizedBox(height: 12),
                // 内容...
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## 表单页模板

新建表单（全屏编辑页）时：

```dart
Scaffold(
  backgroundColor: AppTheme.background,
  appBar: AppBar(
    backgroundColor: AppTheme.background,
    elevation: 0,
    leadingWidth: 70,
    leading: TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('取消', 
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
    ),
    title: Text('新建XX', 
      style: AppTheme.headingStyleWith(fontSize: 18)),
    centerTitle: true,
    actions: [
      TextButton(
        onPressed: _submit,
        child: const Text('完成',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600)),
      ),
    ],
  ),
  body: Column(
    children: [
      // 内容区
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 输入框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: AppTheme.wobblySmall,
                    border: Border.all(
                      color: AppTheme.border, width: 2),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '请输入...',
                      hintStyle: TextStyle(
                        color: AppTheme.textPrimary.withAlpha(100)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
              // 分类药丸
              // 标签药丸
            ],
          ),
        ),
      ),
      // 底部工具栏
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppTheme.background,
          border: Border(
            top: BorderSide(color: AppTheme.muted, width: 1.5)),
        ),
        child: Row(
          children: [
            // 日期药丸
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.muted,
                borderRadius: AppTheme.wobblyPill,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_outlined,
                    size: 13, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text('日期', style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            const Spacer(),
            // 收藏、删除按钮...
          ],
        ),
      ),
    ],
  ),
)
```

## 分类药丸样式

```dart
// 选中态
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: AppTheme.textPrimary,
    borderRadius: AppTheme.wobblyPill,
    border: Border.all(color: AppTheme.border, width: 1.5),
  ),
  child: Text('分类名', style: TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
)

// 未选中态
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: AppTheme.muted,
    borderRadius: AppTheme.wobblyPill,
    border: Border.all(color: AppTheme.border.withAlpha(60), width: 1),
  ),
  child: Text('分类名', style: TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
)
```

## 标签芯片样式

```dart
Container(
  height: 30,
  padding: const EdgeInsets.symmetric(horizontal: 10),
  decoration: BoxDecoration(
    color: AppTheme.muted,
    borderRadius: AppTheme.wobblyPill,
    border: Border.all(color: AppTheme.border.withAlpha(60), width: 1),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(tag, style: const TextStyle(
        fontSize: 12, color: AppTheme.textPrimary)),
      const SizedBox(width: 4),
      GestureDetector(
        onTap: () => _removeTag(tag),
        child: const Icon(Icons.close, 
          size: 14, color: AppTheme.textSecondary),
      ),
    ],
  ),
)
```

## 对话框样式

```dart
showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    backgroundColor: AppTheme.cardBackground,
    shape: RoundedRectangleBorder(borderRadius: AppTheme.wobblySmall),
    title: Text('标题', style: AppTheme.headingStyleWith(fontSize: 18)),
    content: TextField(
      decoration: InputDecoration(
        hintText: '请输入',
        hintStyle: TextStyle(color: AppTheme.textPrimary.withAlpha(100)),
        border: OutlineInputBorder(
          borderRadius: AppTheme.wobblySmall,
          borderSide: const BorderSide(color: AppTheme.border, width: 2)),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTheme.wobblySmall,
          borderSide: const BorderSide(color: AppTheme.border, width: 2)),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppTheme.wobblySmall,
          borderSide: const BorderSide(color: AppTheme.secondary, width: 2)),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: const Text('取消', 
          style: TextStyle(color: AppTheme.textSecondary))),
      TextButton(
        onPressed: () { /* ... */ },
        child: const Text('确定', 
          style: TextStyle(
            color: AppTheme.textPrimary, fontWeight: FontWeight.bold))),
    ],
  ),
);
```

## 删除按钮样式

```dart
Container(
  width: 38, height: 38,
  decoration: BoxDecoration(
    color: AppTheme.accentSoft,
    borderRadius: AppTheme.wobblySmall,
    border: Border.all(color: AppTheme.accent, width: 1.5),
  ),
  child: const Icon(Icons.delete_outline, 
    size: 18, color: AppTheme.accent),
)
```

## 禁止事项

1. **禁止** 使用 `BorderRadius.circular()` — 全部换成 wobbly 变体
2. **禁止** 使用带 `blurRadius` 的 `BoxShadow` — 只用硬偏移阴影
3. **禁止** 硬编码颜色 — 全部通过 `AppTheme.xxx` 引用
4. **禁止** 使用 `Colors.white` 作为 Scaffold 背景 — 用 `Colors.transparent`（显示纸张纹理）或 `AppTheme.background`（表单页）
5. **禁止** 在 `const` 表达式中调用 `headingStyleWith()` 或 `withAlpha()`
6. **禁止** 引入设计系统色板以外的颜色

## 相关文件

- 设计 Token：`lib/theme/app_theme.dart`
- 纸张纹理：`lib/main.dart` (`_PaperTexturePainter`)
- 核心组件：`lib/widgets/` (底部导航、搜索框、分类药丸、区块标题)
- 字体依赖：`pubspec.yaml` (`google_fonts: ^6.2.1`)
