# ✨ Daily Quote App

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Riverpod-0553B1?style=for-the-badge&logo=flutter&logoColor=white" alt="Riverpod">
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart">
</p>

<p align="center">
  <b>A gorgeous, glassmorphic Flutter app for daily inspiration</b><br>
  <i>Built with AI-assisted development • Powered by ZenQuotes API</i>
</p>

---

## 🌟 Features

| Feature | Description |
|---------|-------------|
| 📜 **Random Quotes** | Fresh inspiration with every tap |
| ❤️ **Favorites** | Save and revisit your best quotes |
| 📤 **Share** | Spread positivity via any app |
| 🎨 **Glassmorphism** | Modern, translucent UI design |
| ⚡ **Instant Refresh** | Cache-busting ensures new quotes |

---

## 🎨 Design

**Figma Prototype**: [View Design](https://snow-code-03854369.figma.site/)

> Aesthetic highlights:
> - 💜 Purple-to-Indigo gradient background
> - 🪟 Frosted glass cards & buttons
> - ✒️ Playfair Display for elegant quotes
> - 🔤 Inter for crisp UI text

---

## 🛠️ Tech Stack

```
Flutter          →  Cross-platform framework
Riverpod         →  State management (StateNotifier)
ZenQuotes API    →  Quote source
SharedPreferences→  Local persistence
Google Fonts     →  Typography (Playfair, Inter)
```

---

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/Sharelove123/brewapps_Daily_Quote_App.git
cd brewapps_Daily_Quote_App

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

---

## 📂 Project Structure

```
lib/
├── main.dart                 # Entry point + ProviderScope
├── models/
│   └── quote.dart            # Quote data model
├── providers/
│   └── app_provider.dart     # Riverpod StateNotifier
├── screens/
│   ├── home_screen.dart      # Quote display + actions
│   ├── favorites_screen.dart # Saved quotes list
│   └── main_container.dart   # Navigation wrapper
├── services/
│   ├── quote_service.dart    # API integration
│   └── storage_service.dart  # Local persistence
├── utils/
│   ├── app_theme.dart        # Colors, gradients, fonts
│   └── constants.dart        # API URLs
└── widgets/
    └── glass_action_button.dart # Reusable glass button
```

---

## 🤖 AI-Assisted Development

This project was built using **Claude Code (Antigravity)** as a pair programmer.

### Workflow
1. 🔍 **Design Analysis** — Browser automation extracted Figma specs
2. 📝 **Planning** — Detailed implementation plan before coding
3. 🧱 **Modular Build** — Models → Services → Providers → UI
4. 🐛 **Iterative Fixes** — AI identified and resolved issues

### Key Prompts Used
```
"Migrate this Provider app to Riverpod with StateNotifier"
"Fix deprecated withOpacity() for Flutter 3.10+"
"Create a glassmorphic button matching this Figma design"
```

### Iterations
- ✅ Refactored from Provider to Riverpod per user preference
- ✅ Fixed missing `uiTextStyle` reference
- ✅ Updated deprecated APIs (`withOpacity` → `withValues`)
- ✅ Added cache-busting for reliable quote refreshes

---

## 📱 Screenshots

> ![Screenshot_20260112_193004](https://github.com/user-attachments/assets/3e3a6921-fe43-47c4-ae7c-08f5c60abb8e)
![Screenshot_20260112_193008](https://github.com/user-attachments/assets/f90d5395-ec55-4868-8f3c-b14ad0a5f1f8)


---

## 📄 License

This project is for **demonstration purposes** only.

---

<p align="center">
  Made with ❤️ and AI
</p>
