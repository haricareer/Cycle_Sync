# Fix: "Unable to delete directory" (mergeDebugAssets)

This error usually happens because **files in the `build` folder are locked** by another process (running app, OneDrive, or IDE).

---

## Easiest fix: run the app on Windows or Chrome (no Android build)

You can run the project **right away** without fixing the Android lock:

**Option A – Run on Windows**
1. In Cursor, open the Command Palette: `Ctrl+Shift+P`
2. Type: **Flutter: Select Device**
3. Choose **Windows (desktop)**
4. Press **F5** or click **Run** to start the app

Or in a terminal:
```powershell
cd "c:\Users\pc\OneDrive\Desktop\Cycle Sync\cycle_sync"
flutter run -d windows
```

**Option B – Run in Chrome (web)**
```powershell
flutter run -d chrome
```

The app will run the same; only the platform changes. You can fix the Android build later when you need to test on a phone.

---

## If you need to run on Android (phone/emulator)

1. **Stop the app**
   - If the app is running or debugging, stop it (Stop button or Shift+F5 in Cursor/VS Code).

2. **Free the build folder**
   - Close any File Explorer window that has the project or `build` folder open.
   - **OneDrive**: Your project is under OneDrive. OneDrive can lock files. Either:
     - Right-click the OneDrive icon in the taskbar → **Pause syncing** (e.g. 2 hours), then try again, or
     - Move the project to a folder **outside** OneDrive (e.g. `C:\Dev\Cycle Sync`) and open it there.

3. **Clean and rebuild**
   In a terminal (PowerShell or CMD) in the project folder run:
   ```powershell
   cd "c:\Users\pc\OneDrive\Desktop\Cycle Sync\cycle_sync"
   flutter clean
   flutter pub get
   flutter run
   ```

4. **If `flutter clean` still fails**
   - Close Cursor/VS Code completely.
   - In File Explorer, go to `cycle_sync` and delete the **`build`** folder manually.
   - Reopen the project and run `flutter pub get` then `flutter run`.

After that, the build should succeed.
