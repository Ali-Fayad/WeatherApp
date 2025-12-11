# 🌤️ WeatherApp (Flutter)

A **mobile weather application** built with Flutter. Shows live weather data, city search, charts 📊, and includes authentication 🔐 + local storage 💾.  

> ⚠️ Note: This app uses a local SQLite database (sqflite) and is **NOT compatible with Flutter Web** builds without modifications — see "Web" section below.

---

## 📋 Contents

- Features ✨
- Requirements 🛠️
- Quick start 🚀
- Run on Android 🤖
- Run on iOS 🍎
- Run on Desktop 💻
- Web 🌐 (NOT supported by default)
- Release builds 📦
- Troubleshooting ⚠️
- Project structure 🗂️
- What's implemented ✅
- License & contact 📧

---

## ✨ Features

- 🔐 Authentication (username/password hashed in SQLite)  
- 📑 Tabbed UI with 3 main tabs: **Currently**, **Weekly**, **Today**  
- 🔍 City search with suggestions  
- 📊 Charts (using `fl_chart`) for weather data  
- ⭐ Favorites screen with full CRUD (SQLite)  
- ⚙️ Settings screen with Dropdown, Switch, Radio, Checkbox  
- ⏳ Loading overlay while calling APIs  
- 💬 SnackBar & AlertDialog error handling (e.g., city not found, permissions)

---

## 🛠️ Requirements

- Flutter SDK (stable) — tested with Flutter 3.x / 4.x (`flutter --version`)  
- Android SDK (for Android builds)  
- Xcode (macOS, for iOS builds)  
- CocoaPods: `sudo gem install cocoapods`  
- Physical iOS device or simulator  
- Note: `sqflite` plugin not supported on web  

**Key dependencies**:  
- geolocator 🌍  
- http 🌐  
- flutter_dotenv  
- fl_chart 📈  
- sqflite, path_provider  
- crypto 🔒  

---

## 🚀 Quick start

1. Clone the repo:  
```bash
git clone https://github.com/Ali-Fayad/WeatherApp.git
cd WeatherApp
