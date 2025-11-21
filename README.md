# 🌶️ MindSpice

<p align="center">
  <img src="assets/icon/app_icon.png" alt="MindSpice Logo" width="120" height="120" style="border-radius: 20px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);"/>
  <br>
  <b>Your minimal, powerful journaling companion.</b>
  <br>
  <i>Capture thoughts, organize with color, and reflect daily.</i>
</p>

---

## 📖 Overview

**MindSpice** is a modern Flutter journaling application designed for simplicity and focus. Built with a **GitHub-inspired UI**, it offers a clean, distraction-free writing experience. Whether you want to track your daily progress, manage tasks, or just vent, MindSpice keeps your data local, secure, and easy to manage.

It features a robust **Category System**, **Dark/Light Themes**, **Custom Fonts**, and **Data Export** capabilities, giving you full control over your journaling experience.

## ✨ Key Features

### 📝 Journaling
* **Rich Entries:** Create entries with a title, detailed description, and custom date.
* **Search & Filter:** Instantly find notes by keywords or filter by specific categories.
* **Edit & Delete:** Modify your thoughts or remove old entries with undo functionality.

### 🎨 Customization & UI
* **GitHub-Inspired Design:** A clean, flat aesthetic with subtle borders and high contrast, available in both **Light** and **Dark** modes.
* **Typography Control:** Choose from a curated list of fonts including *Roboto, Open Sans, Lato, Oswald,* and the fun *Luckiest Guy* (Clash style!).
* **Color-Coded Categories:** Create custom tags with unique colors to visually organize your life.

### ⚙️ Data & Utilities
* **CSV Export/Import:** Never lose your data. Backup your journal to a CSV file or copy it directly to your clipboard.
* **Daily Reminders:** Set a custom daily notification to build a consistent writing habit.
* **Local Storage:** All data is stored locally on your device for privacy and speed.

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **State Management:** [Riverpod](https://riverpod.dev/)
* **Persistence:** JSON (via `path_provider`)
* **Fonts:** `google_fonts`
* **Notifications:** `flutter_local_notifications`
* **File Handling:** `file_picker`, `csv`

## 📸 Screenshots

| Light Mode | Dark Mode | Settings |
|:---:|:---:|:---:|
| ⬜ | ⬛ | ⚙️ |

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
* An Android/iOS emulator or physical device.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/MiteDyson/mindspice.git](https://github.com/MiteDyson/mindspice.git)
    cd mindspice
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    flutter run
    ```

## 📱 Configuration

### App Icons
This project uses `flutter_launcher_icons` to generate native app icons.
To update the icon, replace `assets/icon/app_icon.png` and run:
```bash
dart run flutter_launcher_icons

## 📂 Project Structure

```text
lib/
├── main.dart              # Entry point & App Theme setup
├── models/                # Data models (Entry, Category)
├── providers/             # Riverpod state notifiers
├── screens/               # UI Screens (Home, Edit, Settings)
├── services/              # Logic for Storage, CSV, Notifications
├── theme/                 # App Colors and Theme Definitions
├── utils/                 # Helper functions (Date formatting)
└── widgets/               # Reusable components
