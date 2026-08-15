# SETUP

Instructions to set up a Flutter (latest stable) Android development environment on Ubuntu using FVM, and to create this project.

Everything here is scoped to this project only. Nothing is set globally (no `fvm global`, no PATH pointing at a specific Flutter version), so your other Flutter project on this machine is unaffected regardless of which SDK version it uses.

## 1. Prerequisites

Install the packages Flutter needs to build and run on Linux/Android:

```bash
sudo apt update
sudo apt install -y curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config
```

FVM is already installed on this machine (`fvm --version` → confirm it works):

```bash
fvm --version
```

If it ever needs reinstalling, the official method is via the Dart pub cache or the install script documented at fvm.app — not covered here since it's already present.

## 2. Cache the latest stable Flutter SDK via FVM

```bash
fvm install stable
```

This downloads and caches the stable release under FVM's version store (`~/fvm/versions/...`). It does **not** change any global default and does not touch your other project — it just makes the version available locally so it can be pinned per-project.

## 3. Install Android toolchain

Flutter needs the Android SDK, command-line tools, and a JDK to build and sign APKs. This part is independent of the Flutter SDK version, so it's safe to share across both projects.

### Option A — Android CLI (used on this machine)

Google's `android` CLI is a newer standalone tool (`developer.android.com/tools/agents/android-cli`) that manages the SDK itself — it replaces the classic manual cmdline-tools zip download and `sdkmanager`. It's already installed here via:

```bash
curl -fsSL https://dl.google.com/android/cli/latest/linux_x86_64/install.sh | bash
```

This puts the `android` binary in `~/.local/bin` (added to `PATH` automatically via `~/.local/bin/env`, sourced from `~/.profile`) and manages the SDK at the standard `~/Android/Sdk` location — confirmed with:

```bash
android info
```

Install the packages Flutter needs:

```bash
android sdk install platform-tools "cmdline-tools/latest" "platforms/android-36" "build-tools/36.0.0"
```

Notes:
- Package names use slashes (`build-tools/36.0.0`, `platforms/android-36`), not the semicolons `sdkmanager` uses.
- `cmdline-tools/latest` is required even though `android` manages the SDK itself — `flutter doctor` specifically looks for the classic `cmdline-tools/latest/` layout (and its bundled `sdkmanager`) and reports `cmdline-tools component is missing` without it.
- Platform/build-tools version 36 (not 34) is required because Flutter's Gradle plugin checks for a minimum `compileSdk` — as of Flutter 3.47, `flutter doctor` reports `Flutter requires Android SDK 36` if only 34 is installed. Check what your installed Flutter version actually requires via `fvm flutter doctor -v` and adjust the version if needed.
- `android sdk list` shows installed/available packages, `android sdk update` updates them.

The ToS is accepted once on first run of `android`, but Flutter's own license check is separate — run this once `cmdline-tools/latest` is installed:

```bash
fvm flutter doctor --android-licenses
```

Accept every prompt with `y`.

### Option B — Android Studio (GUI alternative, includes emulator UI)

1. Download Android Studio from the official site and extract/install it.
2. Launch it and complete the setup wizard — it installs the Android SDK, platform-tools, and a JDK bundled with the IDE.
3. Open **Settings → Languages & Frameworks → Android SDK** and install:
   - Android SDK Platform (latest stable API level)
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android Emulator (if you plan to use a virtual device)

### Set environment variables

Add to `~/.bashrc`:

```bash
export ANDROID_HOME="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin"
```

```bash
source ~/.bashrc
```

This points at the shared Android SDK location, not at a Flutter version, so it's safe to keep global — and matches the location the `android` CLI already uses by default.

If `flutter doctor -v` warns about multiple `adb` binaries (e.g. one at `~/Android/Sdk/platform-tools/adb` and another at `/usr/lib/android-sdk/platform-tools/adb` from an apt package), it's non-fatal — Flutter still works — but you can remove the apt one to silence it: `sudo apt remove android-sdk-platform-tools-common`.

## 4. Pin this project to the FVM stable version

From the project root:

```bash
cd /media/ssd/projects/expense_tracker
fvm use stable
```

This writes a local `.fvmrc` and `.fvm` folder inside this project only, pinning it to the stable version cached in step 2. Your other Flutter project keeps whatever version it's already pinned to (or the plain system `flutter`, if it doesn't use FVM) — this step never touches it.

From now on, run Flutter commands in this project as `fvm flutter ...` / `fvm dart ...` (not bare `flutter`/`dart`), so they always resolve to this project's pinned version rather than whatever might be active elsewhere.

## 5. Verify the setup

```bash
fvm flutter doctor -v
```

Resolve any issues it reports (missing licenses, missing components, etc.) before continuing. All checks relevant to Android development should show a green checkmark. If it still reports missing Android licenses, re-run:

```bash
fvm flutter doctor --android-licenses
```

## 6. Create the Flutter app

Since the project directory currently only has `SPEC.md`, `.gitignore`, `SETUP.md`, and `.git`, generate the Flutter app scaffold in place:

```bash
fvm flutter create --org com.example --platforms android .
```

(Adjust `--org` to your preferred reverse-domain identifier.)

## 7. Run the app

Connect a physical device with USB debugging enabled, or start an emulator.

To use an emulator with the `android` CLI (one-time setup, then start whenever needed):

```bash
android emulator list                # see existing AVDs
android emulator create medium_phone # create one, only needed once
android emulator start medium_phone  # boots it; blocks until the process launches
```

`android emulator start` returns once the emulator *process* launches, not once Android has fully finished booting — give it another 15–20 seconds before it shows up. Check with:

```bash
adb devices    # should show emulator-5554 as "device", not "offline"
```

Then:

```bash
fvm flutter devices
fvm flutter run
```

If more than one device/emulator is connected, `fvm flutter run` will prompt you to pick one. To target the emulator directly instead:

```bash
fvm flutter run -d emulator-5554
```

## 8. Editor setup (optional but recommended)

- **VS Code**: install the *Flutter* and *Dart* extensions. Set `dart.flutterSdkPath` in this workspace's settings (`.vscode/settings.json`) to `.fvm/flutter_sdk` so the editor uses this project's pinned SDK, not whatever's used elsewhere.
- **Android Studio**: install the Flutter plugin, then point the Flutter SDK path to `.fvm/flutter_sdk` in *this project's* settings (Android Studio's Flutter SDK path is per-project, so it won't affect the other project).

Always invoke Flutter through `fvm flutter <command>` (or `fvm dart <command>`) inside this project. Never run a bare `flutter`/`dart` command here, since without a global default set, it would either fail or fall back to an unrelated system install rather than this project's pinned SDK.
