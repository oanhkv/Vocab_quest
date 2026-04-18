# 📚 VocabQuest - App Học Từ Vựng Tiếng Anh Qua Mini Game

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.22-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)
![Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

**Học từ vựng tiếng Anh theo cách thú vị với 3 mini-game sinh động!**

[Tính năng](#-tính-năng-nổi-bật) • [Cài đặt](#-hướng-dẫn-cài-đặt) • [Cấu trúc](#-cấu-trúc-project) • [Công nghệ](#-công-nghệ-sử-dụng)

</div>

---

## 🎯 Giới thiệu

**VocabQuest** là ứng dụng học từ vựng tiếng Anh được thiết kế dành cho người Việt, kết hợp phương pháp học qua chơi (game-based learning) với giao diện hiện đại, thu hút. App giúp người dùng mở rộng vốn từ vựng một cách tự nhiên thông qua các mini-game thú vị.

### 🌟 Tại sao chọn VocabQuest?

- 🎮 **Học qua chơi** - 3 mini-game đa dạng, không nhàm chán
- 🏆 **Hệ thống phần thưởng** - Coin, XP, sao, bảng xếp hạng
- 📊 **Theo dõi tiến độ** - Lịch sử, thống kê chi tiết
- 🎨 **Giao diện đẹp** - Gradient hiện đại, animation mượt mà
- 🌙 **Dark mode** - Bảo vệ mắt khi học buổi tối
- 🔊 **Phát âm chuẩn** - Tích hợp Text-to-Speech

---

## ✨ Tính năng nổi bật

### 🎮 3 Mini-Game Đa Dạng

| Game | Mô tả | Độ khó |
|------|-------|--------|
| 🧩 **Nối từ** | Ghép từ tiếng Anh với nghĩa tiếng Việt trong thời gian giới hạn | ⭐⭐ |
| ❓ **Trắc nghiệm** | 10 câu hỏi, 4 đáp án, có phát âm chuẩn | ⭐⭐⭐ |
| 🔤 **Xếp chữ** | Sắp xếp chữ cái rời thành từ đúng theo nghĩa tiếng Việt | ⭐⭐⭐⭐ |

### 📊 3 Cấp độ Học Tập

- 🟢 **Beginner** - Từ vựng cơ bản hàng ngày (20 từ)
- 🟡 **Intermediate** - Từ vựng trung cấp (20 từ)
- 🔴 **Advanced** - Từ vựng nâng cao (20 từ)

### 🏅 Hệ Thống Thành Tựu

- 💰 **Coin** - Đơn vị tiền tệ trong app, thưởng khi chơi game
- ⚡ **XP (Experience Points)** - Tăng cấp độ người chơi
- ⭐ **Sao** - 1-3 sao mỗi game dựa trên độ chính xác
- 🏆 **Bảng xếp hạng** - Top 100 người chơi với podium top 3

### 🎨 Trải nghiệm Người Dùng

- ✨ Hiệu ứng confetti khi thắng game
- 🎵 Âm thanh sống động (có thể tắt)
- 🌗 Chế độ tối/sáng tùy chọn
- 🔔 Thông báo nhắc nhở học tập
- 🌐 Đa ngôn ngữ (Tiếng Việt/English)

---

## 📸 Screenshots

> 💡 *Thêm ảnh chụp màn hình app tại đây sau khi chạy được*

| Splash | Login | Home |
|--------|-------|------|
| _Splash Screen_ | _Login Screen_ | _Home Screen_ |

| Game | Leaderboard | Profile |
|------|-------------|---------|
| _Quiz Game_ | _Leaderboard_ | _Profile_ |

---

## 🛠 Công nghệ sử dụng

### 📱 Frontend
- **Framework**: [Flutter](https://flutter.dev/) 3.22+
- **Language**: [Dart](https://dart.dev/) 3.0+
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Animation**: [flutter_animate](https://pub.dev/packages/flutter_animate)

### ☁️ Backend (Firebase)
- **Authentication**: Firebase Auth (Email/Password)
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage (optional)

### 🎨 UI & Design
- **Icons**: [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter), [lucide_icons](https://pub.dev/packages/lucide_icons)
- **Fonts**: [google_fonts](https://pub.dev/packages/google_fonts) (Poppins)
- **Charts**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Effects**: [confetti](https://pub.dev/packages/confetti), [shimmer](https://pub.dev/packages/shimmer), [lottie](https://pub.dev/packages/lottie)

### 🔊 Audio
- **TTS**: [flutter_tts](https://pub.dev/packages/flutter_tts) (phát âm từ vựng)
- **Audio Player**: [audioplayers](https://pub.dev/packages/audioplayers)

### 💾 Local Storage
- **Shared Preferences**: Lưu cài đặt người dùng
- **JSON Assets**: Dữ liệu từ vựng local

---

## 📂 Cấu trúc Project

```
vocab_quest/
├── 📂 android/                    # Cấu hình Android
├── 📂 ios/                        # Cấu hình iOS
├── 📂 assets/
│   └── 📂 data/                   # File JSON từ vựng
│       ├── vocab_beginner.json
│       ├── vocab_intermediate.json
│       └── vocab_advanced.json
│
├── 📂 lib/                        # 🔥 Code chính
│   ├── 📄 main.dart               # Entry point
│   ├── 📄 firebase_options.dart   # Firebase config (auto-generated)
│   │
│   ├── 📂 config/                 # Cấu hình app
│   │   ├── theme.dart             # Theme & màu sắc
│   │   └── constants.dart         # Hằng số toàn app
│   │
│   ├── 📂 models/                 # Data models
│   │   ├── user_model.dart
│   │   ├── vocab_model.dart
│   │   ├── game_result_model.dart
│   │   └── level_model.dart
│   │
│   ├── 📂 services/               # Business logic
│   │   ├── auth_service.dart      # Firebase Auth
│   │   ├── firestore_service.dart # Cloud Firestore
│   │   ├── storage_service.dart   # Firebase Storage
│   │   ├── local_storage.dart     # SharedPreferences
│   │   └── json_service.dart      # Load JSON từ vựng
│   │
│   ├── 📂 providers/              # State management
│   │   ├── user_provider.dart
│   │   ├── game_provider.dart
│   │   └── settings_provider.dart
│   │
│   ├── 📂 screens/                # UI screens
│   │   ├── splash_screen.dart
│   │   ├── 📂 auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── 📂 home/
│   │   │   └── home_screen.dart
│   │   ├── 📂 games/              # 3 mini-games
│   │   │   ├── game_menu_screen.dart
│   │   │   ├── matching_game.dart
│   │   │   ├── quiz_game.dart
│   │   │   ├── word_puzzle_game.dart
│   │   │   └── game_result_screen.dart
│   │   ├── 📂 history/
│   │   ├── 📂 leaderboard/
│   │   ├── 📂 profile/
│   │   └── 📂 settings/
│   │
│   ├── 📂 widgets/                # Reusable widgets
│   │   ├── custom_button.dart
│   │   ├── loading_widget.dart
│   │   └── vocab_card.dart
│   │
│   └── 📂 utils/                  # Utilities
│       ├── helpers.dart
│       └── validators.dart
│
├── 📄 firebase.json               # Firebase config
├── 📄 firestore.rules             # Firestore security rules
├── 📄 firestore.indexes.json      # Firestore indexes
├── 📄 storage.rules               # Storage security rules
├── 📄 pubspec.yaml                # Dependencies
└── 📄 README.md                   # File này
```

---

## 🚀 Hướng dẫn cài đặt

### ✅ Yêu cầu hệ thống

- **Flutter SDK**: 3.22.0 trở lên ([Tải về](https://flutter.dev/docs/get-started/install))
- **Dart SDK**: 3.0.0 trở lên (tự động khi cài Flutter)
- **Android Studio**: 2024.1+ ([Tải về](https://developer.android.com/studio))
- **Java JDK**: 17 (kèm Android Studio)
- **Git**: để clone repository
- **Tài khoản Firebase**: miễn phí tại [firebase.google.com](https://firebase.google.com/)

### 📥 Bước 1: Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/vocab_quest.git
cd vocab_quest
```

### 📦 Bước 2: Cài đặt Dependencies

```bash
flutter pub get
```

### 🔥 Bước 3: Cấu hình Firebase

#### 3.1. Tạo Firebase Project

1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Nhấn **Add project** → đặt tên (ví dụ: `vocab-quest-app`)
3. Tắt Google Analytics (không cần cho dev)
4. Nhấn **Create project**

#### 3.2. Bật Authentication

1. Vào **Build** → **Authentication** → **Get started**
2. Tab **Sign-in method** → bật **Email/Password**
3. Save

#### 3.3. Tạo Firestore Database

1. Vào **Build** → **Firestore Database** → **Create database**
2. Chọn **Start in production mode**
3. Chọn location: **asia-southeast1** (Singapore)
4. Nhấn **Enable**

#### 3.4. Kết nối Firebase với Flutter

```bash
# Cài Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Cài FlutterFire CLI
dart pub global activate flutterfire_cli

# Cấu hình project
flutterfire configure
```

Làm theo hướng dẫn:
- Chọn Firebase project vừa tạo
- Chọn platforms: **android** (và iOS nếu muốn)
- Package name: `com.apptienganh.vocab_quest`

Lệnh này sẽ tự động tạo file `lib/firebase_options.dart`.

#### 3.5. Deploy Firestore Rules & Indexes

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### ▶️ Bước 4: Chạy App

#### Chạy trên Android Emulator:

```bash
# Mở emulator từ Android Studio Device Manager, sau đó:
flutter run
```

#### Chạy trên thiết bị Android thật:

1. Bật **Developer Options** (tap Build number 7 lần)
2. Bật **USB Debugging**
3. Kết nối điện thoại qua cáp USB
4. Chọn **File Transfer (MTP)** khi được hỏi
5. Chạy:

```bash
flutter devices  # Kiểm tra đã nhận điện thoại
flutter run      # Chạy trên device
```

---

## 🔐 Firebase Security Rules

### Firestore Rules

Project sử dụng security rules nghiêm ngặt:

- ✅ Users chỉ đọc/ghi profile của chính mình
- ✅ Game results không thể bị sửa/xóa (chống gian lận)
- ✅ Leaderboard ai cũng đọc được (đã login)
- ❌ Từ chối mọi truy cập không hợp lệ

Xem chi tiết trong file `firestore.rules`.

---

## 🎯 Roadmap

### ✅ Đã hoàn thành
- [x] Authentication (Email/Password)
- [x] 3 mini-games (Matching, Quiz, Word Puzzle)
- [x] 3 cấp độ (Beginner, Intermediate, Advanced)
- [x] Hệ thống Coin, XP, Level
- [x] Bảng xếp hạng với podium top 3
- [x] Lịch sử chơi game
- [x] Profile cá nhân với thống kê
- [x] Dark/Light mode
- [x] Text-to-Speech phát âm
- [x] Đa ngôn ngữ (VN/EN)

### 🚧 Đang phát triển
- [ ] Tính năng Streak (học liên tục nhiều ngày)
- [ ] Hearts system (5 mạng như Duolingo)
- [ ] Daily challenges
- [ ] Achievement/Huy hiệu
- [ ] Social login (Google, Facebook)

### 💭 Kế hoạch tương lai
- [ ] Chế độ offline
- [ ] Chia sẻ kết quả lên mạng xã hội
- [ ] Chatbot AI luyện hội thoại
- [ ] Flashcard mode
- [ ] Spaced repetition algorithm
- [ ] Import từ vựng từ file Excel
- [ ] iOS version

---

## 🐛 Troubleshooting

<details>
<summary><b>❌ Lỗi: "FAILED_PRECONDITION: The query requires an index"</b></summary>

**Giải pháp:** Click vào link trong error message, Firebase sẽ tự tạo index. Hoặc chạy:
```bash
firebase deploy --only firestore:indexes
```
</details>

<details>
<summary><b>❌ Lỗi: "Missing or insufficient permissions"</b></summary>

**Giải pháp:**
1. Kiểm tra đã đăng nhập chưa
2. Deploy lại rules: `firebase deploy --only firestore:rules`
</details>

<details>
<summary><b>❌ Lỗi: "PlatformException: no Firebase App"</b></summary>

**Giải pháp:** File `main.dart` phải có:
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```
</details>

<details>
<summary><b>❌ Lỗi: "minSdkVersion" quá thấp</b></summary>

**Giải pháp:** Trong `android/app/build.gradle.kts`, sửa:
```kotlin
minSdk = 23
```
</details>

<details>
<summary><b>❌ App crash khi chạy trên web</b></summary>

**Giải pháp:** App hiện chỉ hỗ trợ Android. Chạy:
```bash
flutter run -d android
```
</details>

---

## 📦 Dependencies chính

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6

  # State management
  provider: ^6.1.1

  # UI & Animation
  google_fonts: ^6.1.0
  flutter_animate: ^4.3.0
  confetti: ^0.7.0
  lottie: ^2.7.0
  shimmer: ^3.0.0
  percent_indicator: ^4.2.3

  # Icons
  font_awesome_flutter: ^10.6.0
  lucide_icons: ^0.257.0

  # Audio
  flutter_tts: ^3.8.5
  audioplayers: ^5.2.1

  # Utils
  shared_preferences: ^2.2.2
  intl: ^0.19.0
```

Xem đầy đủ trong `pubspec.yaml`.

---

## 🤝 Đóng góp

Đóng góp luôn được chào đón! Để đóng góp:

1. **Fork** repository
2. Tạo branch mới: `git checkout -b feature/AmazingFeature`
3. Commit thay đổi: `git commit -m 'Add some AmazingFeature'`
4. Push lên branch: `git push origin feature/AmazingFeature`
5. Mở **Pull Request**

### 📝 Coding Guidelines

- Sử dụng `flutter format` trước khi commit
- Chạy `flutter analyze` để kiểm tra lỗi
- Tên biến/hàm dùng camelCase
- Tên class dùng PascalCase
- Comment tiếng Việt/Anh đều được, nhưng nhất quán

---

## 📄 License

Project này được phân phối dưới MIT License. Xem file `LICENSE` để biết thêm chi tiết.

```
MIT License

Copyright (c) 2026 Kieu Anh

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 👨‍💻 Tác giả

**Kiều Anh**

- 📧 Email: oanhvu1503@gmail.com
- 🐙 GitHub: [@YOUR_USERNAME](https://github.com/YOUR_USERNAME)
- 🌐 Portfolio: *(nếu có)*

---

## 🙏 Lời cảm ơn

- [Flutter Team](https://flutter.dev/) - Framework tuyệt vời
- [Firebase](https://firebase.google.com/) - Backend miễn phí mạnh mẽ
- [Font Awesome](https://fontawesome.com/) - Thư viện icon đẹp
- [Google Fonts](https://fonts.google.com/) - Font miễn phí chất lượng
- Cộng đồng Flutter Việt Nam đã hỗ trợ trong quá trình phát triển

---

## ⭐ Support

Nếu project này hữu ích cho bạn, hãy cho tôi một ⭐ **star** trên GitHub nhé!

[![Star History Chart](https://api.star-history.com/svg?repos=YOUR_USERNAME/vocab_quest&type=Date)](https://star-history.com/#YOUR_USERNAME/vocab_quest&Date)

---

<div align="center">

**Made with ❤️ in Vietnam**

Nếu bạn gặp bug hoặc có ý tưởng, hãy tạo [Issue](https://github.com/YOUR_USERNAME/vocab_quest/issues) nhé!

</div>
