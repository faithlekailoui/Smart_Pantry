# Sous-Chef AI - running and building

## 1. First time on a new machine
```
flutter pub get
flutter analyze
flutter test
```

## 2. Run on your phone (USB debugging on)
```
flutter devices
flutter run -d <device-id> --dart-define=GEMINI_API_KEY=YOUR_KEY
```
Without `--dart-define=GEMINI_API_KEY=...` the app still works; the Alchemist
screen simply shows the offline rule-based recipe and says so.

## 3. Installable APK
```
flutter build apk --release --dart-define=GEMINI_API_KEY=YOUR_KEY
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

## 4. Measure real startup time (for the documentation)
With the app fully closed:
```
adb shell am start -W -n com.example.smart_pantry/.MainActivity
```
Use the `TotalTime` line. Repeat 5-10 times and report the average. The app
also prints `Startup: first frame after N ms` in the debug console.

## Notes
- SQLite runs on Android/iOS only (not in a web browser).
- Never commit a real API key. It is passed at build time, not stored in code.
