<img src="https://images.microcms-assets.io/assets/973fc097984b400db8729642ddff5938/c7e60e4a663b491ea8e29432d2298d0a/agnestachyon_icon.png" width="128" height="128" >

# UmaCam
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?logo=Flutter&logoColor=white)
[![Build APK](https://github.com/Wiesmak/UmaCam/actions/workflows/build.yaml/badge.svg)](https://github.com/Wiesmak/UmaCam/actions/workflows/build.yaml)
![GitHub Release](https://img.shields.io/github/v/release/wiesmak/umacam)

*An experimental apparatus for capturing test subjects within the framework of a Support Card.*

UmaCam is a photo booth application that photographs the subject and composites them into an Uma Musume: Pretty Derby SSR support card template. The result is a shareable support card featuring your unwitting— or willing— participant.

This is my creation. I trust you'll handle it with the appropriate level of scientific curiosity.

---

## tl;dr

Download the latest CI build:

[![Download zip](https://custom-icon-badges.demolab.com/badge/-Download-blue?style=for-the-badge&logo=download&logoColor=white "Download APK")](https://github.com/wiesmak/umacam/releases/latest/download/app-release.apk)


---

## Table of Contents

- [Features](#features)
- [Supported Platforms](#supported-platforms)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Building](#building)
- [Project Structure](#project-structure)
- [Adding Support Card Templates](#adding-support-card-templates)
- [License](#license)

---

## Features

- Camera capture using the device's available cameras
- Overlay the captured photo onto SSR support card templates
- Multiple template types corresponding to training stats:
  - **SPD** (Speed)
  - **STA** (Stamina)
  - **PWR** (Power)
  - **GUTS** (Guts)
  - **WIT** (Wisdom)
  - **PAL** (Pal / Friend)
- Share the resulting support card image

---

## Supported Platforms

| Platform | Status        |
|----------|---------------|
| Android  | ✅ Tested      |
| Windows  | ⚠️ Untested   |
| Web      | ⚠️ Untested   |
| iOS      | ❌ Unsupported |
| Linux    | ❌ Unsupported |
| macOS    | ❌ Unsupported |

Android is the primary test target. The others may work— or they may not. That's an experiment for another day.

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- [Dart SDK](https://dart.dev/get-dart) (bundled with Flutter)
- [Android Studio](https://developer.android.com/studio) or [IntelliJ IDEA](https://www.jetbrains.com/idea/) with Flutter/Dart plugins
- Android SDK with a minimum API level as configured in `android/app/build.gradle.kts`
- For Windows builds: Visual Studio with C++ desktop development workload
- A physical device or emulator with a camera (for full functionality)

---

## Getting Started

1. **Clone the repository:**

   ```bash
   git clone https://github.com/Wiesmak/UmaCam.git
   cd UmaCam
   ```

2. **Install dependencies:**

   ```bash
   flutter pub get
    ```

3. Generate launcher icons and splash screens (optional):
  
   ```bash
   flutter pub run flutter_launcher_icons
   flutter pub run flutter_native_splash:create
   ```

4. **List available devices:**

   ```bash
    flutter devices
    ```

5. **Run the application:**

   ```bash
    flutter run --device-id <device_id>
    ```

---

## Building

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store distribution)
flutter build appbundle --releas
    
```

The output apk will be located in the `build/app/outputs/flutter-apk/` directory.

The bundle will be located in the `build/app/outputs/bundle/release/` directory.

### Windows

```bash
flutter build windows --release
```

The output will be located in the `build/windows/runner/Release/` directory.

## Web

```bash
flutter build web --release
```

The output will be located in the `build/web/` directory.

> **Note:** Web and Windows builds are untested. Camera functionality may behave differently or not at all on these platforms.

---

## Project Structure
```
`
UmaCam/
├── assets/
│   ├── background.png
│   ├── nice_nature_clip.png
│   ├── nice_nature_crop.png
│   ├── nice_nature.png
│   ├── UmaMusumeTemplate.psd          # Source PSD for template editing
│   └── ssr_template/
│       ├── UmaMusumeTemplateGUTS.png
│       ├── UmaMusumeTemplatePAL.png
│       ├── UmaMusumeTemplatePWR.png
│       ├── UmaMusumeTemplateSPD.png
│       ├── UmaMusumeTemplateSTA.png
│       └── UmaMusumeTemplateWIT.png
├── lib/
│   ├── main.dart                       # Application entry point
│   ├── app.dart                        # App widget configuration
│   └── pages/                          # Page widgets
├── test/
│   └── widget_test.dart                # Widget tests
├── android/                            # Android platform files
├── windows/                            # Windows platform files
├── web/                                # Web platform files
├── pubspec.yaml                        # Flutter dependencies & asset declarations
├── flutter_launcher_icons.yaml         # Launcher icon configuration
├── flutter_native_splash.yaml          # Native splash screen configuration
└── analysis_options.yaml               # Dart analysis rule
```

---

## Adding Support Card Templates

The SSR support card templates are stored as PNG files in the `assets/ssr_template/` directory.

To add a new template:

1. **Create the template image** using `assets/UmaMusumeTemplate.psd` as a reference for dimensions and layout.
Export the resulting image as a PNG file with transparency where the subject photo should be visible beneath the overlay.
2. **Place the PNG file** in the `assets/ssr_template/` directory following the naming convention `UmaMusumeTemplate<TYPE>.png`,
where `<TYPE>` is a short identifier (e.g., `SPD`, `STA`, `PWR`).
3. **Update the code** to recognize the new template.
Open `lib/pages/picture.dart` and add a new entry to the `_Overlay` enum. Follow the pattern of existing entries.

Without step 3, the application will not recognize the new template.

---

## Dependencies

Dependencies are declared in `pubspec.yaml`. Run `flutter pub get` to resolve them.

Key dependencies include:
- `camera`: For accessing device cameras
- `image`: For image manipulation and compositing
- `flutter_hooks`: For state management in Flutter
- `flutter_launcher_icons`: For generating app icons'
- `flutter_native_splash`: For generating native splash screens
- `dynamic_color`: For dynamic theming based on the device's color scheme
- `share_plus`: For sharing the resulting support card images

Refer to `pubspec.yaml` for the full and pinned dependency list.

---

### License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.