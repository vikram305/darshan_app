# Flutter UI & Design Guidelines

> Provide this file alongside `.ai/ARCHITECTURE_PROMPT.md` when generating UI code.

---

## 1. Core Framework: Material 3
This project strictly follows **Material 3 (M3)** design principles. M3 is fully supported natively by Flutter and provides dynamic, out-of-the-box accessibility, responsive components, and automatic dark mode support.

*   Ensure `useMaterial3: true` is enabled in the `ThemeData`.
*   Avoid importing Cupertino widgets unless explicitly building an iOS-only screen. Follow the native Material layout constructs.

## 2. Zero Code Hardcoding (Token-Based Design)
Every padding, margin, font size, and color must come from centrally managed constants or the current Theme context. There should be absolutely **ZERO** raw numbers or raw colors in the Widget tree.

### Spacing & Sizing
Always reference `AppConstants` for layouts.
```dart
// ❌ Bad
SizedBox(height: 16)
Padding(padding: EdgeInsets.all(8))

// ✅ Good
SizedBox(height: AppConstants.spacingXL)
Padding(padding: EdgeInsets.all(AppConstants.spacingS))
```

### Color Scheme Management
*   **Theme Generation:** Themes must be generated using the **Material Theme Builder / Exporter** for Flutter. Export your brand colors to a `color_schemes.g.dart` file and integrate its mathematically accessible light/dark schemes directly into your `app_theme.dart`.
*   **Usage:** Never hardcode a color explicitly (e.g., `Colors.red` or `Color(0xFFE5E5E5)`). All UI must exclusively rely on `Theme.of(context).colorScheme` provided by the exporter.
```dart
// ❌ Bad
Container(color: Colors.blue) 
Text('Error', style: TextStyle(color: Colors.red))

// ✅ Good
Container(color: Theme.of(context).colorScheme.primaryContainer)
Text('Error', style: TextStyle(color: Theme.of(context).colorScheme.error))
```

## 3. Typography
Use the global text theme mapped out in `AppTheme`. Do not declare manual `TextStyle` arrays everywhere.
```dart
// ❌ Bad
Text('Title', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))

// ✅ Good
Text('Title', style: Theme.of(context).textTheme.headlineMedium)
// If you need a specific color override:
Text('Title', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
  color: Theme.of(context).colorScheme.onPrimary,
))
```

## 4. Modern M3 Components
Instead of manually building buttons, dialogs, and cards, use the explicit Material 3 components because they automatically scale text and apply correct elevations natively.

*   **Buttons:** Use `FilledButton`, `OutlinedButton`, `TextButton`, or `ElevatedButton`. Avoid using raw `GestureDetector` wrapped around a Container unless completely custom.
*   **Cards:** Use `Card.filled()`, `Card.outlined()`, or `Card()` along with `AppConstants` rounded corners.
*   **Inputs:** Use `TextFormField` populated by the `InputDecorationTheme` in your main `app_theme.dart`.

## 5. UI Structure & Widgets
- **Separation of Concerns:** Keep your `build()` functions small. If a widget spans more than ~50 lines, extract it into a separate private class in the same file, or move it to the `widgets/` folder if it is reusable.
- **`const` Everything:** Every widget that can be instantiated with `const` must be. This drastically improves the 60/120fps render cycle by telling the Flutter engine not to rebuild it.

---

### M3 Color Roles Quick Reference
When assigning colors, map them to their semantic meaning:
- **`primary` / `onPrimary`**: Main brand color and text on top of it.
- **`primaryContainer` / `onPrimaryContainer`**: Highlight backgrounds (like selected items).
- **`secondary`**: Secondary branding mapped to accents.
- **`surface` / `onSurface`**: Background of the page or general text.
- **`surfaceContainer` / `surfaceContainerHighest`**: Used for cards, bottom sheets, or elevated panels.
- **`error` / `onError`**: Red error states.
