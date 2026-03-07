# Listrik App - Developer Setup Guide

## Prerequisites Status
| Tool | Status | Download Link |
|------|--------|--------------|
| Git | ✅ Installed (v2.52) | - |
| XAMPP/MySQL | ✅ Installed | - |
| Composer | ✅ Installed (v2.9.5) | - |
| PHP 8.3 | ❌ Need upgrade (have 8.0) | See Step 1 |
| Flutter | ❌ Not installed | See Step 2 |
| Android Studio | ❓ Check | See Step 3 |

---

## Step 1: Upgrade PHP to 8.3

1. Go to: https://windows.php.net/download/
2. Download: **VS16 x64 Thread Safe** zip (latest 8.3.x)
3. Extract to `C:\php8.3`
4. Copy `php.ini-development` → rename it to `php.ini`
5. Open `php.ini`, uncomment these lines (remove the `;`):
   ```
   extension=curl
   extension=fileinfo
   extension=mbstring
   extension=openssl
   extension=pdo_mysql
   extension=zip
   extension_dir = "ext"
   ```
6. Update `extension_dir` to: `extension_dir = "C:\php8.3\ext"`
7. Add PHP 8.3 to PATH:
   - Search "Environment Variables" in Windows
   - Edit `Path` under System Variables
   - Add: `C:\php8.3`
   - Move it ABOVE `C:\xampp\php` in the list
8. Open a NEW terminal and run: `php --version` → should show 8.3.x ✅

---

## Step 2: Install Flutter

1. Go to: https://docs.flutter.dev/get-started/install/windows/mobile
2. Download the Flutter SDK zip (~1 GB)
3. Extract to: `C:\src\flutter` (make sure no spaces in path!)
4. Add `C:\src\flutter\bin` to your System PATH
5. Open a new terminal and run:
   ```bash
   flutter doctor
   ```
   This will show you what's missing.

---

## Step 3: Install Android Studio

1. Go to: https://developer.android.com/studio
2. Install Android Studio
3. On first launch: complete the setup wizard (installs Android SDK)
4. Go to SDK Manager → install:
   - Android 14 (API 34)
   - Android Emulator
5. Create a Virtual Device (AVD):
   - Go to Device Manager → Create Device
   - Pick Pixel 7, API 34
6. Run `flutter doctor` again — should show Android ✅

---

## Step 4: Create Laravel Backend

After PHP 8.3 is working, run:
```bash
cd C:\Users\faeyz\.gemini\antigravity\scratch\listrik-app
composer create-project laravel/laravel listrik-app-backend
cd listrik-app-backend
php artisan serve
```
Open: http://localhost:8000 → should see Laravel welcome page ✅

---

## Step 5: Create Flutter App

```bash
cd C:\Users\faeyz\.gemini\antigravity\scratch\listrik-app
flutter create listrik_app_mobile
cd listrik_app_mobile
flutter run
```

---

## Step 6: VS Code Extensions to Install

Open VS Code → Extensions (Ctrl+Shift+X) → Search and install:
- `Flutter` (by Dart Code)
- `Dart` (by Dart Code)
- `PHP Intelephense` (by Ben Mewburn)
- `Laravel Blade Snippets` (by Winnie Lin)
- `Thunder Client` (by Ranga Vadhineni)
- `GitLens` (by GitKraken)

---

## Step 7: Configure Database

1. Start XAMPP → Start **MySQL**
2. Open **phpMyAdmin**: http://localhost/phpmyadmin
3. Create database: `listrik_app`
4. Edit `.env` in the Laravel project:
   ```
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=listrik_app
   DB_USERNAME=root
   DB_PASSWORD=
   ```
5. Run migrations:
   ```bash
   php artisan migrate
   ```
