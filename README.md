# MaizeGuard | Standalone AI Disease Diagnostics

MaizeGuard is a premium, standalone Flutter application designed for high-precision maize disease detection and agricultural guidance.

## 🚀 Key Features
- **Standalone Architecture**: No backend server required. All AI logic and storage happen on the device.
- **Gemini 1.5 Flash Integration**: Uses direct Dart SDK integration for state-of-the-art leaf analysis and conversational support.
- **Local Diagnostic Engine**: Provides instant identification of common maize diseases.
- **Premium Glassmorphic UI**: A world-class user experience with smooth transitions and staggered animations.
- **Local History**: All scans are stored securely on your device using a local SQLite database.

## 🛠 Tech Stack
- **Framework**: Flutter (Mobile & Web)
- **AI Core**: Google Gemini 1.5 Flash (vision & chat)
- **Storage**: SQLite (sqflite)
- **UI Architecture**: Provider Pattern

## 📦 Getting Started
1. Navigate to the `maizeguard_flutter` directory.
2. Run `flutter pub get`.
3. Open `lib/providers/scan_provider.dart` and `lib/screens/chat/chat_screen.dart` to verify your Gemini API key.
4. Run `flutter run`.

## 📂 Project Structure
- `maizeguard_flutter/`: The primary Flutter application.
- `dataset/`: Training data and raw samples.
- `models/`: Historical model files (optional reference).

---
&copy; 2026 MaizeGuard Research Project
