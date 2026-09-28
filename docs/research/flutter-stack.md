# ValVN: Flutter stack and build pipeline (Flutter 3.47.x, late 2026)

Research date: **2026-09-28**. Toolchain in the container: **Flutter 3.47.5** (framework `6a19cca564`, 2026-09-17), **Dart 3.13.4**, OpenJDK 21.0.10, Android SDK at `/opt/android-sdk`.

This doc picks the packages and platform settings for ValVN (a ValBuddy clone with a Vietnamese UI) and gives the snippets for them. Riot auth details are in `riot-auth.md`. Riot endpoints are in `riot-endpoints.md`. valorant-api.com is covered in `content-api.md`.

## Evidence labels

| Label | Meaning |
|---|---|
| **[BUILT]** | Reproduced in this container. I made a scratch project with the recommended `pubspec.yaml`, `build.gradle.kts` and `AndroidManifest.xml`, then ran `flutter build apk --release` (split and single-ABI). I also ran `flutter analyze`, `dart analyze` and `flutter test`. |
| **[SRC]** | Read in the package source under `~/.pub-cache` (exact version given) or in `/opt/flutter/packages/flutter_tools`. |
| **[PUB]** | `curl https://pub.dev/api/packages/<name>` on 2026-09-28. |
| **[DOC]** | Official docs or blog: docs.flutter.dev, riverpod.dev, GitHub runner-images, package docs. |
| **[LIVE]** | Real HTTP request made from this container on 2026-09-28. |
| **[UNVERIFIED]** | Not reproduced here. Most of these are iOS or Xcode items, because there is no macOS in the container. |

All Dart snippets in sections 6–17 (`lib/snip/*.dart`) got **"No issues found"** from `flutter analyze` with the `analysis_options.yaml` in section 20. The Riverpod and mocktail tests in section 20 pass **[BUILT]**. Swift, YAML and Xcode steps could not be run here.

---

## 0. Decisions at a glance

| Concern | Choice (exact version) | Why / key gotcha |
|---|---|---|
| UI library | **`material_ui` 1.4.0** (+ `cupertino_ui` 1.1.1), **not** `package:flutter/material.dart` | Flutter 3.47 moved Material out of the SDK. `go_router` 18 and `cached_network_image` 4 already import `material_ui`. With a legacy `MaterialApp`, go_router 18 falls back to `NoTransitionPage`, so there are **no page transitions**. See §2. |
| WebView | **`flutter_inappwebview` 6.2.0-beta.3**, with the platform packages pinned via `dependency_overrides` | Stable 6.1.5 (2024-10) **fails to build on AGP 9**: `getDefaultProguardFile('proguard-android.txt') is no longer supported` **[BUILT]**. |
| HTTP | **`dio` 5.11.1** | `followRedirects:false` returns the 303 and its `Location` **[LIVE]**. Use a `QueuedInterceptor` for single-flight refresh on **401 or 400 `BAD_CLAIMS`** (PD/GLZ report an expired token as 400 BAD_CLAIMS, not 401). |
| Secure storage | **`flutter_secure_storage` 11.2.0** | v11 **removed** `encryptedSharedPreferences` and `sharedPreferencesName`. Use `storageNamespace`. iOS needs `first_unlock_this_device` so background tasks can read it. |
| State | **`flutter_riverpod` 3.4.3**, no codegen | Riverpod 3 **auto-retries failed providers**, so turn that off for "login required". Family providers keyed by `puuid` handle account switching. |
| Routing | **`go_router` 18.0.1** | `StatefulShellRoute.indexedStack` for the **5** ValBuddy tabs (Cửa hàng · Battle Pass · Bộ sưu tập · Hồ sơ · Cài đặt; see `valbuddy-features.md` §6). *(Corrected by the SUMMARY review: an earlier draft had 4 tabs.)* |
| Images | **`cached_network_image` 4.0.2** + **`flutter_cache_manager` 3.4.5** | Uses a custom long-lived `CacheManager` for valorant-api media. |
| Video | **`video_player` 2.14.0** | Stream the mp4s straight from `valorant.dyn.riotcdn.net` (~28 MB each, `Accept-Ranges: bytes`) **[LIVE]**. |
| Charts | **`fl_chart` 1.2.0** | Still imports legacy Material, so it needs the compatibility bridge (§2). |
| Notifications | **`flutter_local_notifications` 22.3.1** + **`timezone` 0.11.1** + **`flutter_timezone` 5.1.0** | Named-parameter API since v20. Needs core-library desugaring. Use `inexactAllowWhileIdle`, which needs no exact-alarm permission. |
| Background | **`workmanager` 0.10.10** | Android is reliable within about 15 min to hours. iOS is best-effort `BGAppRefreshTask`, maybe once a day. |
| Home widget | **`home_widget` 0.10.0** (**optional**) | Android is easy. iOS needs a Swift WidgetKit extension plus an App Group, which needs a paid Apple account (see §14). |
| l10n | `flutter_localizations` + **`intl` 0.20.3** + gen-l10n (`app_vi.arb`) | Don't use the generated `AppLocalizations.localizationsDelegates`: it pulls in the legacy Material delegates. |
| Fonts | **Be Vietnam Pro** (body) + **Anton** (display), bundled TTFs | Bebas Neue has **no Vietnamese** subset. |
| Cache | JSON files in `getApplicationSupportDirectory()` + **`shared_preferences` 2.5.5** | Fetch `/v1/weapons` (3.65 MB, includes skins + weapon relation; see `content-api.md` §0) and key the cache on `/v1/version` **`manifestId`** + language + schema version. Parse in `Isolate.run`. Skip Hive unless needed (§16). |
| XMPP (friends/chat/presence) | `dart:io` `SecureSocket` + **`xml` 7.1.0** | No XMPP package needed; `xml` parses buffered stanzas. Resolves with this stack, `flutter analyze` clean **[BUILT, SUMMARY review]**. |
| Share (export session log) | **`share_plus` 13.3.0** | Uses `flutter.compileSdkVersion` (no compileSdk 37 creep) **[SRC, SUMMARY review]**. |
| Lints | **`flutter_lints` 6.0.0** + extra rules. Optional **`riverpod_lint` 3.1.9** via `plugins:` | `riverpod_lint` only reports through **`dart analyze`**, not `flutter analyze` **[BUILT]**. |
| Tests | `flutter_test`, **`mocktail` 1.0.5**, `ProviderContainer.test`. Optional goldens: **`alchemist` 0.14.0** | `golden_toolkit` is dead (Dart <3). |
| Android toolchain | AGP **9.1.0**, Gradle **9.3.1**, KGP **2.4.0**, Java 17 target (JDK 21 OK), **compileSdk 36** (37 only if a plugin requires it), minSdk **24**, targetSdk **36**, NDK **28.2.13676358**, CMake **3.22.1** | Release manifest has **no INTERNET permission** unless you add it **[BUILT]**. |
| iOS toolchain | Deployment target **15.0**, **Swift Package Manager on by default**, UIScene lifecycle, Xcode **26.6** on `macos-26` | CocoaPods is only a fallback. |
| CI | `ubuntu-24.04` + JDK 21 for the APK; `macos-26` (arm64, Xcode 26.6) for the unsigned IPA | Full YAML in §19. |

Do **not** add `permission_handler` 13.0.2. Its Android part (14.1.0) needs `compileSdk 37` and breaks a default build (§4.6). We don't need it: `flutter_local_notifications` already exposes `requestNotificationsPermission()` / `requestPermissions()`.

---

## 1. Verified toolchain baseline (Flutter 3.47.5)

Taken from `flutter_tools` source **[SRC]** and the repo's generated `android/` files:

| Item | Value | Source |
|---|---|---|
| Android Gradle Plugin (template) | `9.1.0` | `gradle_utils.dart: templateAndroidGradlePluginVersion`, `android/settings.gradle.kts` |
| Gradle wrapper (template) | `9.3.1` (`gradle-9.3.1-all.zip`) | `templateDefaultGradleVersion` |
| Kotlin Gradle Plugin (template) | `2.4.0` | `templateKotlinGradlePluginVersion` |
| Support policy: error below / warn below | Gradle 8.14 / 9.1.0; AGP 8.11.1 / 9.0.1; KGP 2.2.20 / 2.3.20; Java 17 / 17 | `DependencyVersionChecker.kt` |
| `flutter.compileSdkVersion` / `targetSdkVersion` / `minSdkVersion` | `36` / `36` / `24` | `FlutterExtension.kt` |
| `flutter.ndkVersion` | `28.2.13676358` | `FlutterExtension.kt` |
| Min build-tools | `28.0.3` (36.0.0 installed and used) | `gradle_utils.dart` |
| Java | Needs ≥17. JDK 21 builds fine **[BUILT]**. Gradle 9.3.1 runs on JDK 17–25. | `gradle_utils.dart` |
| `gradle.properties` flags added by the template | `android.newDsl=false`, `android.builtInKotlin=false` | repo `android/gradle.properties` |
| iOS deployment target (template) | `IPHONEOS_DEPLOYMENT_TARGET = 15.0` | repo `project.pbxproj` |
| iOS lifecycle | UIScene (`SceneDelegate: FlutterSceneDelegate`, `AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate`) | repo `ios/Runner/*.swift` |
| Swift Package Manager | **enabled by default on stable** (`enabledByDefault: true`) | `features.dart` |

About `android.builtInKotlin`: keep `false`. The build prints this **[BUILT]**:

```
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP): flutter_timezone, home_widget, workmanager_android
Future versions of Flutter will fail to build if your app uses plugins that apply KGP.
```

- Flutter 3.44 added temporary KGP-on-AGP-9 support via `android.builtInKotlin=false`. Flutter 3.47 lets you set it to `true` once **every** plugin has migrated **[DOC]**.
- AGP 10 will drop both opt-outs **[DOC]**. Re-check the list with each Flutter upgrade.

Android SDK packages a clean machine or CI needs:

```
platforms;android-36  build-tools;36.0.0  ndk;28.2.13676358  cmake;3.22.1  platform-tools
```

- **CMake 3.22.1**: `path_provider_android` 2.3.1 now depends on `package:jni` 1.0.3, which has a CMake native build. AGP auto-installed CMake 3.22.1 during the first build **[BUILT]**.
- The GitHub `ubuntu-24.04` image ships CMake 3.31.5 and 4.1.2, not 3.22.1. Pre-install it, or make sure `$ANDROID_HOME` is writable so AGP can download it.
- Add `platforms;android-37.0` only if a plugin forces `compileSdk 37`.

---

## 2. Flutter 3.47's Material split: use `material_ui` (verified)

In Flutter 3.47, Material and Cupertino ship as standalone packages: `material_ui` 1.4.0 and `cupertino_ui` 1.1.1, both requiring `flutter: >=3.47.0` **[PUB]**. The in-SDK `package:flutter/material.dart` still works, but it is a **separate copy with distinct types** **[SRC]**. Flutter plans to deprecate it in the November 2026 stable **[DOC]**.

The package ecosystem is split **[SRC, scanned `.dart_tool/package_config.json`]**:

| Uses `material_ui` | Still imports `package:flutter/material.dart` |
|---|---|
| go_router 18.0.1, cached_network_image 4.0.2, hive_ce_flutter (partly) | fl_chart 1.2.0 (41 files), video_player 2.14.0, flutter_inappwebview 6.2.0-beta.3, flutter_riverpod 3.4.3 (one import), home_widget 0.10.0, octo_image |

Experiments **[BUILT, flutter test]**:

1. Legacy `MaterialApp.router` + go_router 18 → go_router builds **`NoTransitionPage<void>`**, so there are no push animations and no swipe-back. go_router 18 checks `findAncestorWidgetOfExactType<MaterialApp>()` against the **`material_ui`** type.
2. `material_ui` `MaterialApp.router` + go_router 18 → **`MaterialPage<void>`** ✔. Vietnamese Material strings work: `cancelButtonLabel == "Huỷ"`.
3. In case 2, legacy lookups (`legacy.Theme.of`, `legacy.MaterialLocalizations`) return the **default light theme** and **null localizations**.
4. Wrapping with `MaterialUiCompatibilityBridge` in `MaterialApp.builder` fixes case 3: legacy code then sees `brightness=dark` and localizations present.

**Decision**

- App code imports `package:material_ui/material_ui.dart`. Do **not** mix in `package:flutter/material.dart`.
- Keep the bridge until fl_chart, video_player and inappwebview migrate.
- The bridge is `@Deprecated` (by design, as a temporary utility), so put `// ignore: deprecated_member_use` on that one line.
- Migrate an existing file with `dart fix --apply --code=migrate_design_widgets`. Plain `dart fix --apply` does **not** do it. The fix then writes `material_ui: any` into pubspec; pin it to `^1.4.0` **[BUILT]**.
- `CupertinoPageTransitionsBuilder` is only exported from `cupertino_ui`, so import it from there **[BUILT]**.

```dart
// lib/app.dart (excerpt) - verified
import 'package:material_ui/material_ui.dart';
import 'l10n/app_localizations.dart';

MaterialApp.router(
  locale: const Locale('vi'),
  supportedLocales: AppLocalizations.supportedLocales,
  // NOT AppLocalizations.localizationsDelegates (that list uses flutter_localizations' legacy delegates)
  localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
  // ignore: deprecated_member_use
  builder: (context, child) => MaterialUiCompatibilityBridge(child: child!),
  routerConfig: router,
);
```

---

## 3. `pubspec.yaml` (complete)

```yaml
name: valvn
description: "ValVN - Ứng dụng đồng hành Valorant tiếng Việt"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.13.4
  flutter: ">=3.47.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:        # still needed: gen-l10n output imports it
    sdk: flutter
  material_ui: ^1.4.0
  cupertino_ui: ^1.1.1          # only for CupertinoPageTransitionsBuilder etc.
  cupertino_icons: ^1.0.8

  # state / routing
  flutter_riverpod: ^3.4.3
  go_router: ^18.0.1

  # network / auth
  dio: ^5.11.1
  flutter_inappwebview: 6.2.0-beta.3   # exact pin: stable 6.1.5 breaks on AGP 9
  flutter_secure_storage: ^11.2.0

  # storage / cache
  shared_preferences: ^2.5.5
  path_provider: ^2.1.6
  cached_network_image: ^4.0.2
  flutter_cache_manager: ^3.4.5

  # media / charts
  video_player: ^2.14.0
  fl_chart: ^1.2.0

  # notifications / background / widgets
  flutter_local_notifications: ^22.3.1
  timezone: ^0.11.1
  flutter_timezone: ^5.1.0
  workmanager: ^0.10.10
  home_widget: ^0.10.0          # optional (see §14)

  # misc
  intl: ^0.20.3
  collection: ^1.19.1
  url_launcher: ^6.3.2
  package_info_plus: ^10.2.1
  xml: ^7.1.0                   # XMPP stanza parsing (friends/chat/presence); added by SUMMARY review
  share_plus: ^13.3.0           # "Xuất nhật ký phiên" (export session log); added by SUMMARY review

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  mocktail: ^1.0.5
  # alchemist: ^0.14.0          # optional golden tests

# flutter_inappwebview 6.2.0-beta.3 depends on the 1.1.x platform packages via caret
# ranges that don't select prereleases; pin the whole family to the self-consistent beta line.
dependency_overrides:
  flutter_inappwebview_android: 1.2.0-beta.3
  flutter_inappwebview_ios: 1.2.0-beta.3
  flutter_inappwebview_macos: 1.2.0-beta.3
  flutter_inappwebview_web: 1.2.0-beta.3
  flutter_inappwebview_windows: 0.7.0-beta.3
  flutter_inappwebview_platform_interface: 1.4.0-beta.3

flutter:
  uses-material-design: true
  generate: true                # gen-l10n on `flutter pub get` / build
  assets:
    - assets/images/
  fonts:
    - family: BeVietnamPro
      fonts:
        - asset: assets/fonts/BeVietnamPro-Regular.ttf
        - asset: assets/fonts/BeVietnamPro-Medium.ttf
          weight: 500
        - asset: assets/fonts/BeVietnamPro-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/BeVietnamPro-Bold.ttf
          weight: 700
    - family: Anton
      fonts:
        - asset: assets/fonts/Anton-Regular.ttf
```

Notes:

- Everything above resolves together on Flutter 3.47.5 **[BUILT]**. The resolved set includes `intl` 0.20.3, `jni` 1.0.3 and `objective_c` 9.5.0.
- The `dependency_overrides` block is what the reporter of flutter_inappwebview issue #2887 used. It builds cleanly **[BUILT]**.
- Remove the overrides as soon as a stable `flutter_inappwebview` ≥6.2.0 ships.
- **Name clash:** `flutter_inappwebview` and `flutter_secure_storage` both export `AndroidOptions`. It shows up as an `ambiguous_import` compile error **[BUILT]**. Import the WebView library with `hide AndroidOptions`, or import one of them with a prefix. `IOSOptions` does not clash.
- Hive (`hive_ce` 2.20.1 / `hive_ce_flutter` 2.4.0), `freezed` 4.0.2, `json_serializable` 6.14.1, `riverpod_generator` 4.0.9 and `build_runner` 2.16.1 all resolve with this set **[BUILT]**. They are deliberately **not** recommended for v1: no codegen means faster CI and fewer moving parts. Hand-written defensive `fromJson` fits the CLAUDE.md rule anyway.

---

## 4. Android setup

### 4.1 `android/settings.gradle.kts` and `android/build.gradle.kts`

Keep them as generated: AGP 9.1.0 and KGP 2.4.0 in `settings.gradle.kts`. No changes are needed.

### 4.2 `android/gradle.properties`

```properties
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=1G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
# Added by the Flutter 3.47 template; keep until every plugin supports built-in Kotlin (AGP 10 removes these)
android.newDsl=false
android.builtInKotlin=false
```

The template ships `-Xmx8G`. GitHub's `ubuntu-24.04` runners have 16 GB, so 4 G is safer when Gradle and the Kotlin daemon run in parallel.

### 4.3 `android/app/build.gradle.kts` (complete)

Verified with and without `key.properties` **[BUILT]**:

- With the file present, `apksigner` shows `CN=ValVN…`.
- Without it, the release falls back to `C=US, O=Android, CN=Android Debug`.
- Final re-check: this exact file, with `compileSdk = flutter.compileSdkVersion` (36) and the §3 dependency set (no `permission_handler`), gave `✓ Built app-release.apk (21.7MB)` for arm64 in 101 s.

```kotlin
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing: android/key.properties (gitignored) OR env vars from CI.
// If neither exists, fall back to the DEBUG key so `flutter build apk --release`
// always yields an installable APK (CI artifacts, sideload testers).
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) FileInputStream(f).use { load(it) }
}
fun signingValue(propKey: String, envKey: String): String? =
    (keystoreProperties.getProperty(propKey) ?: System.getenv(envKey))?.takeIf { it.isNotBlank() }

val releaseStoreFile = signingValue("storeFile", "ANDROID_KEYSTORE_PATH")
val hasReleaseKeystore = releaseStoreFile != null && file(releaseStoreFile).exists()

android {
    namespace = "vn.valvn.valvn"
    compileSdk = flutter.compileSdkVersion   // 36; set 37 only if a plugin demands it (see 4.6)
    ndkVersion = flutter.ndkVersion          // 28.2.13676358

    compileOptions {
        isCoreLibraryDesugaringEnabled = true // required by flutter_local_notifications
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "vn.valvn.valvn"
        minSdk = flutter.minSdkVersion       // 24
        targetSdk = flutter.targetSdkVersion // 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(releaseStoreFile!!)   // relative to android/app/
                storePassword = signingValue("storePassword", "ANDROID_KEYSTORE_PASSWORD")
                keyAlias = signingValue("keyAlias", "ANDROID_KEY_ALIAS")
                keyPassword = signingValue("keyPassword", "ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                logger.warn("ValVN: no release keystore -> signing release with the DEBUG key")
                signingConfigs.getByName("debug")
            }
            // R8 minify/shrink are on by default for Flutter release builds; plugins ship their own rules.
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5") // latest on Google Maven (2025-02)
}

flutter {
    source = "../.."
}
```

`android/key.properties` (never commit it; add `android/key.properties`, `*.jks` and `*.keystore` to `.gitignore`):

```properties
storePassword=********
keyPassword=********
keyAlias=upload
storeFile=upload-keystore.jks
```

Here `storeFile` resolves relative to `android/app/`. Create the keystore once:

```bash
keytool -genkeypair -v -keystore android/app/upload-keystore.jks -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload \
  -dname "CN=ValVN, OU=Mobile, O=ValVN, L=Ho Chi Minh, C=VN"
base64 -w0 android/app/upload-keystore.jks > keystore.b64   # -> GitHub secret ANDROID_KEYSTORE_BASE64
```

### 4.4 `android/app/src/main/AndroidManifest.xml` (complete, **[BUILT]**)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <!-- Release builds get NO network without this (Flutter only adds it to debug/profile). -->
    <uses-permission android:name="android.permission.INTERNET" />
    <!-- Android 13+ runtime permission (also merged from the plugins; declared for clarity). -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <!-- Re-schedule notifications after reboot/app update. -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <!-- We only use inexact alarms: make sure no library sneaks exact-alarm permissions in. -->
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" tools:node="remove" />
    <uses-permission android:name="android.permission.USE_EXACT_ALARM" tools:node="remove" />

    <application
        android:label="ValVN"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:allowBackup="false"
        android:fullBackupContent="false"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:enableOnBackInvokedCallback="true"
        tools:replace="android:allowBackup">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme" />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- flutter_local_notifications: required for zonedSchedule -->
        <receiver android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>

        <!-- OPTIONAL home widget (§14): <receiver android:name=".ShopWidgetProvider" ...> -->

        <meta-data android:name="flutterEmbedding" android:value="2" />
    </application>

    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
        <!-- url_launcher: open https links (Android 11+ package visibility) -->
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="https" />
        </intent>
    </queries>
</manifest>
```

`android/app/src/main/res/xml/data_extraction_rules.xml`:

- `flutter_secure_storage` wraps its keys with the Android Keystore. Restoring that data from a backup on a new device fails with `InvalidKeyException: Failed to unwrap key` (README "Disabling Auto Backup" **[SRC]**).
- Excluding everything from backup avoids that.

```xml
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <exclude domain="root" />
        <exclude domain="file" />
        <exclude domain="database" />
        <exclude domain="sharedpref" />
        <exclude domain="external" />
    </cloud-backup>
    <device-transfer>
        <exclude domain="root" />
        <exclude domain="file" />
        <exclude domain="database" />
        <exclude domain="sharedpref" />
        <exclude domain="external" />
    </device-transfer>
</data-extraction-rules>
```

Merged release permissions in the probe build **[BUILT]**: INTERNET, POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED, VIBRATE, FOREGROUND_SERVICE, FOREGROUND_SERVICE_SHORT_SERVICE, WAKE_LOCK, ACCESS_NETWORK_STATE. The last four come from WorkManager.

`workmanager_android` 0.10.9 deliberately does **not** declare `FOREGROUND_SERVICE_DATA_SYNC`. That permission would trigger a Play Console declaration. It is opt-in via `workmanager.enableDataSyncForegroundService=true` **[SRC]**, and we don't need it.

### 4.5 Build commands (Linux)

```bash
export PATH=/opt/flutter/bin:$PATH ANDROID_HOME=/opt/android-sdk
flutter pub get
flutter build apk --release --split-per-abi   # armeabi-v7a 18.6 MB, arm64-v8a 21.2 MB, x86_64 22.7 MB [BUILT, probe app]
flutter build apk --release                   # universal ("fat") APK
# outputs: build/app/outputs/flutter-apk/app-<abi>-release.apk | app-release.apk
```

Measured timings **[BUILT]**:

- First build: about 4.5 min, including SDK component downloads.
- Incremental single-ABI release build: about 80 s.

**Split APK versionCode gotcha.** With `--split-per-abi`, Flutter sets `versionCode = ABI*1000 + versionCode` (armeabi-v7a=1, arm64-v8a=2, x86_64=4) **[SRC `FlutterPluginConstants.ABI_VERSION`]**.

- A user who installed `app-arm64-v8a-release.apk` (e.g. code 2005) cannot "upgrade" to a universal `app-release.apk` (code 5). Android treats that as a downgrade.
- Pick one channel for users; universal is simplest. Or pass `-P force-version-code-ignoring-abi=true` so all variants share the same code.

### 4.6 Plugins that force `compileSdk 37`

- `permission_handler_android` 14.1.0 pins `compileSdk = 37`. With the app on `flutter.compileSdkVersion` (36), the build fails **[BUILT]**:
  `Failed to find target with hash string 'android-37'` (first run, while AGP was auto-installing `platforms;android-37.0`). Otherwise it fails with `Dependency ... requires ... compile against version 37 or later` (checkAarMetadata).
- `flutter_secure_storage` 11.0.0 had the same bug. 11.1.0 fixed it by going back to `flutter.compileSdkVersion` **[SRC CHANGELOG]**.
- Setting `compileSdk = 37` in the app and installing `platforms;android-37.0` makes it build **[BUILT]**. `targetSdk` can stay 36.
- **Recommendation:** avoid such plugins. If one is unavoidable, set `compileSdk = 37` and add `platforms;android-37.0` to CI.

---

## 5. iOS setup

### 5.1 Project settings

- Deployment target: **15.0** (template default). All iOS plugins in the stack declare lower minimums in their `Package.swift`:

  | Plugin | Minimum iOS |
  |---|---|
  | inappwebview | 12 |
  | local_notifications | 13 |
  | secure_storage_darwin | 13 |
  | home_widget | 14 |
  | workmanager_apple | 14 |

- **SwiftPM:** every iOS plugin in the stack ships a `Package.swift` **[SRC]**. `path_provider_foundation` 2.6.0 is pure FFI (`objective_c` native assets), so it needs no Xcode integration at all. No Podfile is needed. The `macos-26` runner still has CocoaPods 1.17.0 as a fallback.
- **UIScene:** already migrated in the repo. Xcode 27 builds **crash on launch without UIScene** **[DOC]**.
  - Plugins that must register launch handlers before `didFinishLaunching` returns need explicit calls, because plugin registration now happens later, during scene connection. `workmanager`'s `registerLaunchHandlers()` is one example.

### 5.2 `ios/Runner/Info.plist` additions

```xml
<!-- Vietnamese as the development/only language: system UI (permission prompts, share sheet) in vi -->
<key>CFBundleDevelopmentRegion</key>
<string>vi</string>
<key>CFBundleLocalizations</key>
<array>
  <string>vi</string>
</array>
<key>CFBundleDisplayName</key>
<string>ValVN</string>

<!-- workmanager (BGAppRefreshTask). Identifier MUST equal the Dart uniqueName. -->
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
</array>
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
  <string>vn.valvn.app.wishlistCheck</string>
</array>

<!-- Only for App Store/TestFlight uploads; harmless otherwise -->
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

Also add "Vietnamese" under Runner → Project → Info → Localizations in Xcode. That creates `vi.lproj`, which the App Store uses to list languages **[DOC]**.

No ATS exceptions are needed: every endpoint (Riot, valorant-api, riotcdn) is HTTPS.

### 5.3 `ios/Runner/AppDelegate.swift`

Not compiled here: no macOS **[UNVERIFIED]**. The code follows the plugin READMEs **[SRC]**.

```swift
import Flutter
import UIKit
import flutter_local_notifications
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // flutter_local_notifications: foreground presentation + tap handling
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate

    // workmanager: BGTaskScheduler handlers MUST be registered before this method returns.
    // With UIScene, plugins register later, so do it here explicitly.
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "vn.valvn.app.wishlistCheck",
      earliestBeginInSeconds: NSNumber(value: 6 * 60 * 60))
    WorkmanagerPlugin.registerLaunchHandlers()
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // background isolate for notification actions
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
```

API names checked in the source:

- `workmanager_apple` 0.9.11: `registerPeriodicTask(withIdentifier:earliestBeginInSeconds:)`. The `frequency:` variant is **deprecated**. `registerLaunchHandlers()` is documented as required for UIScene apps.
- `flutter_local_notifications` 22.3.1 README: the UIScene variant registers in `didInitializeImplicitFlutterEngine`.

---

## 6. WebView with full cookie access: `flutter_inappwebview` 6.2.0-beta.3

Facts from the platform sources **[SRC]**:

- **iOS**
  - `CookieManager` uses `WKWebsiteDataStore.default().httpCookieStore.getAllCookies`.
  - The URL filter is `urlHost.hasSuffix(cookie.domain)`, so parent-domain cookies such as `tdid` on `.riotgames.com` are included.
  - `isHTTPOnly` cookies are **included** (native store, not JavaScript).
  - Consequence: **never set `incognito: true` on iOS**. The WebView would use a non-persistent store, and `CookieManager` could not see its cookies.
  - `deleteAllCookies()` calls `WKWebsiteDataStore.default().removeData(ofTypes:[Cookies], modifiedSince: 1970)`.
- **Android**
  - `getCookies` uses `CookieManagerCompat.getCookieInfo` when the `GET_COOKIE_INFO` WebView feature exists, which gives full attributes. It falls back to `CookieManager.getCookie(url)`, which returns only `name=value` pairs.
  - HttpOnly cookies are returned in both cases, because this is native `android.webkit.CookieManager`.
- `shouldOverrideUrlLoading` is only called when `useShouldOverrideUrlLoading: true`.
- Some redirect or fragment-only navigations surface only in `onLoadStart` / `onUpdateVisitedHistory`. Funnel all three callbacks into one idempotent handler.
- WebKit's cookie store can lag slightly behind the navigation event. Wait about 300 ms before reading, or retry once, after the callback fires. This is widely reported, not reproduced here **[UNVERIFIED]**.

The login page below analyzes cleanly **[BUILT]** (re-checked after the SUMMARY review added the strict callback regex and the mobile-browser `userAgent`; `flutter analyze`: no issues). Social-login popups: if a provider uses `window.open`, handle `onCreateWindow` by loading `createWindowAction.request.url` in the same WebView **[UNVERIFIED]**. Main-frame navigation must be allowed to the identity providers listed in `riot-auth.md` §1.3:

```dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter_inappwebview/flutter_inappwebview.dart' hide AndroidOptions; // clashes with flutter_secure_storage
import 'package:material_ui/material_ui.dart';

class LoginResult {
  const LoginResult({required this.fragment, required this.cookies});
  final Map<String, String> fragment; // access_token, id_token, expires_in, state...
  final Map<String, String> cookies; // name -> value for auth.riotgames.com (incl. HttpOnly ssid)
}

/// Riot login inside the app. Pops with a [LoginResult] or null.
class RiotLoginPage extends StatefulWidget {
  const RiotLoginPage({super.key});
  @override
  State<RiotLoginPage> createState() => _RiotLoginPageState();
}

class _RiotLoginPageState extends State<RiotLoginPage> {
  final _state = _rand();
  final _nonce = _rand();
  bool _done = false;
  bool _ready = false;
  double _progress = 0;

  static String get _mobileBrowserUserAgent => defaultTargetPlatform == TargetPlatform.iOS
      ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Mobile/15E148 Safari/604.1'
      : 'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36';

  static String _rand() {
    final r = Random.secure();
    return List.generate(32, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  late final WebUri _authorizeUrl = WebUri.uri(Uri.https('auth.riotgames.com', '/authorize', {
    'redirect_uri': 'https://playvalorant.com/opt_in',
    'client_id': 'play-valorant-web-prod',
    'response_type': 'token id_token',
    'scope': 'account openid',
    'nonce': _nonce,
    'state': _state,
    'ui_locales': 'vi',
  }));

  @override
  void initState() {
    super.initState();
    // Start every login from a clean cookie store so a second account does not
    // silently reuse the first account's SSO session.
    unawaited(CookieManager.instance().deleteAllCookies().whenComplete(() {
      if (mounted) setState(() => _ready = true);
    }));
  }

  static final _callbackPath = RegExp(r'^/(?:[a-z]{2}-[a-z]{2}/)?opt_in/?$', caseSensitive: false);

  // Strict match (riot-auth.md §1.3): https, playvalorant.com, /opt_in or /{locale}/opt_in.
  // (SUMMARY review: the earlier `host.endsWith(...) && path.contains(...)` check was too loose.)
  bool _isCallback(WebUri? url) =>
      url != null &&
      url.scheme == 'https' &&
      (url.host == 'playvalorant.com' || url.host == 'www.playvalorant.com') &&
      _callbackPath.hasMatch(url.path);

  /// Called from several callbacks; idempotent.
  Future<bool> _maybeFinish(WebUri? url) async {
    if (_done || !_isCallback(url)) return false;
    final frag = Uri.splitQueryString(url!.fragment.isNotEmpty ? url.fragment : url.query);
    if (!frag.containsKey('access_token') && !frag.containsKey('error')) return false;
    _done = true;
    if (frag['state'] != _state) {
      if (mounted) Navigator.of(context).pop();
      return true;
    }
    // iOS: WKHTTPCookieStore can lag a few ms behind the navigation.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final list = await CookieManager.instance().getCookies(url: WebUri('https://auth.riotgames.com/'));
    final cookies = {for (final c in list) c.name: '${c.value}'};
    if (mounted) Navigator.of(context).pop(LoginResult(fragment: frag, cookies: cookies));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập Riot')), // real app: AppLocalizations
      body: !_ready
          ? const Center(child: CircularProgressIndicator())
          : Stack(children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: _authorizeUrl),
                initialSettings: InAppWebViewSettings(
                  useShouldOverrideUrlLoading: true, // REQUIRED or the callback never fires
                  javaScriptEnabled: true,
                  thirdPartyCookiesEnabled: true, // Android
                  sharedCookiesEnabled: true, // iOS
                  incognito: false, // iOS incognito = non-persistent store -> CookieManager can't read it
                  supportZoom: false,
                  // Plain mobile-browser UA (no "wv"/WKWebView marker) so Google sign-in is not refused with
                  // disallowed_useragent. Same approach as Fantsry (Flutter) and GinzaTech/Vshop in 2026. UNVERIFIED policy-wise.
                  userAgent: _mobileBrowserUserAgent,
                ),
                shouldOverrideUrlLoading: (controller, action) async {
                  if (await _maybeFinish(action.request.url)) return NavigationActionPolicy.CANCEL;
                  return NavigationActionPolicy.ALLOW;
                },
                // Fallbacks: some redirects/fragment changes only surface here.
                onLoadStart: (controller, url) => _maybeFinish(url),
                onUpdateVisitedHistory: (controller, url, isReload) => _maybeFinish(url),
                onProgressChanged: (controller, p) => setState(() => _progress = p / 100),
              ),
              if (_progress < 1) LinearProgressIndicator(value: _progress),
            ]),
    );
  }
}
```

Platform notes:

- **Android:** no manifest changes beyond `INTERNET`. On AGP 9, `flutter_inappwebview_android` 1.1.3 (the stable line) fails at configuration time. 1.2.0-beta.3 builds **[BUILT]**.
- **iOS:** no Info.plist keys needed. WKWebView cookies persist in the app container and survive restarts. To switch accounts, call `deleteAllCookies()` before each new login, then keep **our own** per-account copy in secure storage (§8).
- `clearCache` in `InAppWebViewSettings` is **deprecated** in 6.2 **[BUILT: `deprecated_member_use`]**. Use `InAppWebViewController.clearAllCache()` if needed.
- Social logins (Google, Apple, Facebook) inside an embedded WebView may be blocked by the identity provider (Google's `disallowed_useragent` policy). Riot ID with username and password works. See `riot-auth.md` §1.5 **[UNVERIFIED for Riot's current flow]**.

---

## 7. HTTP: dio vs package:http vs dart:io

| Need | `dio` 5.11.1 | `http` 1.6.0 | `dart:io HttpClient` |
|---|---|---|---|
| Don't follow redirects, read `Location` | `followRedirects:false` + `validateStatus` **[LIVE]** | `Request..followRedirects=false` + `send()` (only `IOClient`) | `request.followRedirects=false` |
| Multiple `Set-Cookie` headers | `res.headers.map['set-cookie']` (List) **[LIVE]** | **Folded into one comma-joined string**, painful for cookies with `Expires=Thu, 01 Jan…` | `response.cookies` / `headers['set-cookie']` |
| Interceptors / single-flight 401 retry | built-in (`QueuedInterceptor`) | wrap yourself | wrap yourself |
| Cancel on provider dispose | `CancelToken` | no | `abort()` |
| gzip | automatic (`autoUncompress`) | automatic | automatic |

**Recommendation: `dio`.** Verified against Riot **[LIVE]**, with a GET to `/authorize?...&prompt=none`, `followRedirects:false` and no cookies:

```
status=303 isRedirect=true
location=https://playvalorant.com/opt_in#error=interaction_required&iss=https%3A%2F%2Fauth.riotgames.com&error_description=login_required
set-cookie count=3  (ccid, clid, __cf_bm)
```

This analyzes cleanly **[BUILT]** (`lib/core/net/riot_http.dart`):

```dart
import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Minimal name->value cookie jar for *.riotgames.com, persisted per account
/// in secure storage. We deliberately do NOT use cookie_jar's PersistCookieJar
/// (it writes plain files).
class RiotCookieJar {
  RiotCookieJar(this._map);
  factory RiotCookieJar.decode(String? json) => RiotCookieJar(
        json == null ? <String, String>{} : Map<String, String>.from(jsonDecode(json) as Map),
      );

  final Map<String, String> _map;

  String encode() => jsonEncode(_map);
  bool get isEmpty => _map.isEmpty;
  String get header => _map.entries.map((e) => '${e.key}=${e.value}').join('; ');

  /// Merge `Set-Cookie` headers from a response. Expired/empty values delete.
  void mergeSetCookie(List<String>? setCookies) {
    for (final raw in setCookies ?? const <String>[]) {
      final first = raw.split(';').first;
      final eq = first.indexOf('=');
      if (eq <= 0) continue;
      final name = first.substring(0, eq).trim();
      final value = first.substring(eq + 1).trim();
      final lower = raw.toLowerCase();
      final expired = value.isEmpty || lower.contains('max-age=0') || lower.contains('expires=thu, 01 jan 1970');
      if (expired) {
        _map.remove(name);
      } else {
        _map[name] = value;
      }
    }
  }
}

class RiotTokens {
  const RiotTokens({required this.accessToken, required this.idToken, required this.expiresAt});
  final String accessToken;
  final String idToken;
  final DateTime expiresAt;
  bool get isExpiringSoon => DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 5)));
}

sealed class ReauthResult {}

class ReauthOk extends ReauthResult {
  ReauthOk(this.tokens);
  final RiotTokens tokens;
}

/// Cookies are dead -> user must log in again in the WebView.
class ReauthNeedsLogin extends ReauthResult {}

/// 403 (Cloudflare) / 429 / network -> keep session, retry later.
class ReauthTransient extends ReauthResult {
  ReauthTransient(this.reason);
  final String reason;
}

/// Silent re-auth: GET /authorize?prompt=none with the stored cookies,
/// DO NOT follow redirects, read tokens from the Location fragment.
class RiotReauthClient {
  RiotReauthClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                followRedirects: false, // <- essential: we need the 303 Location
                maxRedirects: 0,
                validateStatus: (s) => s != null && s < 500, // 3xx/4xx are data, not errors
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                responseType: ResponseType.plain,
              ),
            );

  final Dio _dio;

  static final Uri authorizeUri = Uri.https('auth.riotgames.com', '/authorize', {
    'redirect_uri': 'https://playvalorant.com/opt_in',
    'client_id': 'play-valorant-web-prod',
    'response_type': 'token id_token',
    'scope': 'account openid',
    'nonce': '1',
    'prompt': 'none',
  });

  Future<ReauthResult> reauth(RiotCookieJar jar) async {
    if (jar.isEmpty) return ReauthNeedsLogin();
    final Response<String> res;
    try {
      res = await _dio.getUri<String>(
        authorizeUri,
        options: Options(headers: {'Cookie': jar.header}),
      );
    } on DioException catch (e) {
      return ReauthTransient(e.type.name);
    }
    jar.mergeSetCookie(res.headers.map['set-cookie']); // cookies rotate: persist after every call
    final status = res.statusCode ?? 0;
    if (status == 403 || status == 429) return ReauthTransient('http $status');
    final location = res.headers.value('location');
    if (location == null) return ReauthTransient('no location ($status)');
    final params = Uri.splitQueryString(Uri.parse(location).fragment);
    if (params['error'] != null) return ReauthNeedsLogin(); // e.g. interaction_required / login_required
    final at = params['access_token'];
    final id = params['id_token'];
    if (at == null || id == null) return ReauthTransient('no token in location');
    final expiresIn = int.tryParse(params['expires_in'] ?? '') ?? 3600;
    return ReauthOk(RiotTokens(
      accessToken: at,
      idToken: id,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
    ));
  }
}

/// Supplies (and refreshes) auth headers for one account.
abstract interface class RiotSession {
  Future<Map<String, String>> authHeaders();

  /// Force a refresh (single-flight inside the implementation).
  Future<bool> refresh();
}

/// Adds Riot headers and retries once on 401 / 400 BAD_CLAIMS after a single-flight refresh.
/// QueuedInterceptor serialises onRequest/onError so concurrent 401s
/// trigger ONE refresh, not N.
class RiotAuthInterceptor extends QueuedInterceptor {
  RiotAuthInterceptor(this._session, this._dio);
  final RiotSession _session;
  final Dio _dio; // same Dio instance, used for the retry

  static const _retriedKey = 'valvn_retried';

  /// Riot PD/GLZ answer an expired/invalid token with 400 {"errorCode":"BAD_CLAIMS"}
  /// (not 401); auth hosts use 401. Treat both as "refresh and retry once".
  /// (SUMMARY review fix; the first draft only handled 401.)
  static bool _isAuthFailure(Response<dynamic>? res) {
    final status = res?.statusCode;
    if (status == 401) return true;
    final data = res?.data;
    return status == 400 && data is Map && data['errorCode'] == 'BAD_CLAIMS';
  }

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      options.headers.addAll(await _session.authHeaders());
      handler.next(options);
    } on Object catch (e) {
      handler.reject(DioException(requestOptions: options, error: e));
    }
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final res = err.response;
    final alreadyRetried = err.requestOptions.extra[_retriedKey] == true;
    if (!_isAuthFailure(res) || alreadyRetried) return handler.next(err);
    final ok = await _session.refresh();
    if (!ok) return handler.next(err);
    try {
      final opts = err.requestOptions
        ..extra[_retriedKey] = true
        ..headers.addAll(await _session.authHeaders());
      handler.resolve(await _dio.fetch<dynamic>(opts));
    } on DioException catch (e) {
      handler.next(e);
    }
  }
}
```

Gotchas:

- Do **not** use `cookie_jar`'s `PersistCookieJar` with `dio_cookie_manager` 3.5.0 for Riot cookies. It writes cookies as **plain files** in app storage. Keep the tiny jar above and persist it in secure storage.
- `ssid` and other cookies are re-issued on reauth. **Merge `Set-Cookie` and write the jar back after every `/authorize` call.** Otherwise the stored cookies go stale.
- `validateStatus` must accept 3xx. Otherwise dio throws `DioExceptionType.badResponse` on the 303.
- *(SUMMARY review additions)* Send a `User-Agent` on `/authorize`, entitlements and PD/GLZ calls, e.g. `RiotClient/{riotClientBuild} rso-auth (Windows;10;;Professional, x64)` with `riotClientBuild` from valorant-api `/v1/version` (SkinPeek, Fantsry and DailyStore all send a Riot-client UA; DailyStore notes "Riot has blocked third-party apps by User-Agent before"). Keep it in one remotely overridable constant.
- Keep the **previous** cookie jar as a fallback and retry once with it if the rotated jar is rejected (covers a crash between receiving and persisting rotated cookies; DailyStore 2026).
- If `GET /authorize?prompt=none` gives no token but also no `error`, a fallback is `POST https://auth.riotgames.com/api/v1/authorization` with the same cookies and body `{"client_id":"play-valorant-web-prod","nonce":"1","redirect_uri":"https://playvalorant.com/opt_in","response_type":"token id_token","scope":"account openid"}`; success = `{"type":"response","response":{"parameters":{"uri":"https://playvalorant.com/opt_in#access_token=…"}}}`, dead session = `{"type":"auth",…}` (**[LIVE]** 2026-09-28 for the dead case; Fantsry and GinzaTech/Vshop use it in 2026). See `SUMMARY.md` §3.
- The dart:io TLS/HTTP fingerprint differs from a browser's. Riot and Cloudflare may answer 403 to non-browser clients. Treat 403 and 429 as **transient** (keep the session), never as "logged out". Details are in `riot-auth.md`.
- Parse the 3.6 MB `weapons/skins` JSON off the UI thread with `Isolate.run` (§16). dio decodes JSON on the calling isolate by default.

---

## 8. Secure storage per account: `flutter_secure_storage` 11.2.0

Breaking changes in 11.0.0 (2026-08-06) **[SRC CHANGELOG]**:

- `encryptedSharedPreferences` is **removed**. The Jetpack Security backend is gone; data was migrated in v10.
- `sharedPreferencesName` is **removed**; use `storageNamespace`.
- Legacy RSA-PKCS1 and AES-CBC ciphers are removed. The Android defaults are RSA-OAEP key wrapping + AES-GCM, and minSdk is 24.
- Old tutorials showing `AndroidOptions(encryptedSharedPreferences: true)` **no longer compile**.

```dart
const storage = FlutterSecureStorage(
  aOptions: AndroidOptions(storageNamespace: 'valvn_secure'),
  iOptions: IOSOptions(
    // Background tasks (BGAppRefreshTask) run while the phone is locked:
    // the default `unlocked` would make keychain reads fail there.
    accessibility: KeychainAccessibility.first_unlock_this_device,
    // synchronizable: false (default) -> never leaves the device via iCloud Keychain
  ),
);
```

Key schema (one namespace; the key is prefixed by `puuid`):

| Key | Value |
|---|---|
| `acct.<puuid>.cookies` | JSON `{name: value}` for `auth.riotgames.com` (incl. `ssid`, `tdid`, `clid`, `csid`, …) |
| `acct.<puuid>.access` / `.id` / `.entitlements` / `.expiry` | Current tokens. They are optional to persist; they can always be rebuilt from cookies. |

Account metadata (puuid, Riot ID, shard, avatar) is **not secret**. Keep it in `shared_preferences` so listing accounts doesn't hit the Keystore or Keychain.

API used (11.2.0): `read/write/delete/readAll/deleteAll({required String key, ...})` **[SRC]**. Wrapper:

```dart
class SecureVault {
  SecureVault([FlutterSecureStorage? storage]) : _s = storage ?? _default;

  static const _default = FlutterSecureStorage(
    aOptions: AndroidOptions(storageNamespace: 'valvn_secure'),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  final FlutterSecureStorage _s;

  Future<RiotCookieJar> readCookies(String puuid) async =>
      RiotCookieJar.decode(await _s.read(key: 'acct.$puuid.cookies'));
  Future<void> writeCookies(String puuid, RiotCookieJar jar) =>
      _s.write(key: 'acct.$puuid.cookies', value: jar.encode());
  Future<void> deleteAccount(String puuid) async {
    for (final k in ['cookies', 'access', 'id', 'entitlements', 'expiry']) {
      await _s.delete(key: 'acct.$puuid.$k');
    }
  }
}
```

Gotchas:

- **iOS Keychain items survive app uninstall.** On first launch after a reinstall (detect it with a `shared_preferences` flag), call `deleteAll()` so stale accounts don't reappear.
- **Android:** keep backup disabled (§4.4). 11.2.0 also changed `deleteAll` to delete only its own prefix, not the whole file **[SRC]**.
- Never log values. The CLAUDE.md rule applies.

---

## 9. State management: Riverpod 3 (`flutter_riverpod` 3.4.3), no codegen

Why Riverpod 3 without `riverpod_generator`:

- Riverpod 3 unified `Ref`.
- `Notifier` and `AsyncNotifier` cover everything, and family arguments are passed through the constructor.
- `ProviderContainer.test` exists.
- Codegen would add `build_runner` to every CI run for little gain.

Riverpod 3 behaviors to know **[DOC riverpod.dev/docs/whats_new, SRC 3.4.3]**:

- **Automatic retry.** A provider that throws is retried with exponential backoff (200 ms, doubling up to 6.4 s). The signature is `typedef Retry = Duration? Function(int retryCount, Object error)`, set per provider (`retry:`) or globally (`ProviderScope(retry: …)`). Return `null` to stop. **Without this, a "cookies expired" error would hammer Riot.**
- **Paused listeners.** Providers are paused when the widgets listening to them are not visible (`TickerMode`). Background tabs in `StatefulShellRoute.indexedStack` stop refreshing.
- **`ref.mounted`.** Check it after every `await` in notifier methods.
- **`AsyncValue.valueOrNull` was renamed to `.value`.** `AsyncValue` is sealed, so use exhaustive `switch`.
- `StateProvider` and `StateNotifierProvider` moved to `package:flutter_riverpod/legacy.dart`. Don't use them.
- The experimental `Mutation` and offline `persist()` APIs exist. Skip them for v1.

Account switching pattern: data providers are **families keyed by `puuid`**.

- Switching accounts just watches another family member. The previous account's data stays cached while it has listeners, and `autoDispose` cleans it up afterwards. No global invalidation is needed.
- On logout, invalidate that `puuid`'s members.

This analyzes cleanly, and its tests pass **[BUILT]**:

```dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'riot_http.dart';

// ---------- 1. Infrastructure (overridden in main() and in tests) ----------
final sharedPrefsProvider = Provider<SharedPreferencesWithCache>(
  (ref) => throw UnimplementedError('override in main()'),
);
final vaultProvider = Provider<SecureVault>((ref) => SecureVault());
final reauthClientProvider = Provider<RiotReauthClient>((ref) => RiotReauthClient());

// ---------- 2. Accounts ----------
class Account {
  const Account({required this.puuid, required this.gameName, required this.tagLine, required this.shard});
  final String puuid;
  final String gameName;
  final String tagLine;
  final String shard; // ap / na / eu / kr ...
}

/// List of signed-in accounts (max 10, ValBuddy 2.1.0 parity). Metadata only; secrets live in SecureVault.
class AccountsNotifier extends AsyncNotifier<List<Account>> {
  @override
  Future<List<Account>> build() async {
    // load persisted metadata (JSON in shared_preferences) - omitted
    return const [];
  }

  Future<void> add(Account a) async {
    final current = await future;
    state = AsyncData([...current.where((x) => x.puuid != a.puuid), a]);
    // persist...
  }

  Future<void> remove(String puuid) async {
    await ref.read(vaultProvider).deleteAccount(puuid);
    if (!ref.mounted) return; // Riverpod 3: provider may be disposed after an await
    final current = await future;
    state = AsyncData(current.where((x) => x.puuid != puuid).toList());
    if (ref.read(activeAccountIdProvider) == puuid) {
      ref.read(activeAccountIdProvider.notifier).select(null);
    }
    // drop every cached per-account value for that puuid
    ref
      ..invalidate(sessionProvider(puuid))
      ..invalidate(storefrontProvider(puuid));
  }
}

final accountsProvider = AsyncNotifierProvider<AccountsNotifier, List<Account>>(AccountsNotifier.new);

/// Which account is shown. Persisted so the app reopens on the same account.
class ActiveAccountId extends Notifier<String?> {
  static const _key = 'active_puuid';
  @override
  String? build() => ref.watch(sharedPrefsProvider).getString(_key);

  void select(String? puuid) {
    final prefs = ref.read(sharedPrefsProvider);
    unawaited(puuid == null ? prefs.remove(_key) : prefs.setString(_key, puuid));
    state = puuid;
  }
}

final activeAccountIdProvider = NotifierProvider<ActiveAccountId, String?>(ActiveAccountId.new);

// ---------- 3. Per-account session (family keyed by puuid) ----------
/// Riverpod 3: family notifiers receive the argument through the constructor.
class SessionNotifier extends AsyncNotifier<RiotTokens> implements RiotSession {
  SessionNotifier(this.puuid);
  final String puuid;
  Completer<bool>? _refreshing;

  @override
  Future<RiotTokens> build() async {
    final jar = await ref.read(vaultProvider).readCookies(puuid);
    final r = await ref.read(reauthClientProvider).reauth(jar);
    await ref.read(vaultProvider).writeCookies(puuid, jar);
    return switch (r) {
      ReauthOk(:final tokens) => tokens,
      ReauthNeedsLogin() => throw const NeedsLoginException(),
      ReauthTransient(:final reason) => throw TransientAuthException(reason),
    };
  }

  @override
  Future<Map<String, String>> authHeaders() async {
    var t = await future;
    if (t.isExpiringSoon && await refresh()) t = await future;
    return {'Authorization': 'Bearer ${t.accessToken}'};
    // + X-Riot-Entitlements-JWT, X-Riot-ClientPlatform, X-Riot-ClientVersion (see riot-endpoints.md)
  }

  /// Single-flight refresh.
  @override
  Future<bool> refresh() {
    final inFlight = _refreshing;
    if (inFlight != null) return inFlight.future;
    final c = _refreshing = Completer<bool>();
    ref.invalidateSelf();
    unawaited(
      future.then((_) => c.complete(true), onError: (Object _) => c.complete(false)).whenComplete(() => _refreshing = null),
    );
    return c.future;
  }
}

class NeedsLoginException implements Exception {
  const NeedsLoginException();
}

class TransientAuthException implements Exception {
  const TransientAuthException(this.reason);
  final String reason;
}

final sessionProvider = AsyncNotifierProvider.family<SessionNotifier, RiotTokens, String>(
  SessionNotifier.new,
  // Riverpod 3 retries failed providers automatically; never retry "log in again".
  retry: (count, error) {
    if (error is NeedsLoginException) return null;
    if (count >= 3) return null;
    return Duration(seconds: 2 << count);
  },
);

/// One Dio per account, with the 401-retry interceptor bound to that account's session.
final pdDioProvider = Provider.family<Dio, String>((ref, puuid) {
  final dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 15)));
  dio.interceptors.add(RiotAuthInterceptor(ref.watch(sessionProvider(puuid).notifier), dio));
  ref.onDispose(dio.close);
  return dio;
});

// ---------- 4. Data providers keyed by puuid ----------
class Storefront {
  const Storefront(this.offerIds, this.remaining);
  final List<String> offerIds;
  final Duration remaining;
}

final storefrontProvider = FutureProvider.autoDispose.family<Storefront, String>((ref, puuid) async {
  final dio = ref.watch(pdDioProvider(puuid));
  final cancel = CancelToken();
  ref.onDispose(cancel.cancel);
  final res = await dio.post<Map<String, dynamic>>(
    'https://pd.ap.a.pvp.net/store/v3/storefront/$puuid', // shard from Account; see riot-endpoints.md
    data: <String, dynamic>{},
    cancelToken: cancel,
  );
  final panel = (res.data?['SkinsPanelLayout'] as Map?) ?? const {};
  return Storefront(
    ((panel['SingleItemOffers'] as List?) ?? const []).whereType<String>().toList(),
    Duration(seconds: (panel['SingleItemOffersRemainingDurationInSeconds'] as num?)?.toInt() ?? 0),
  );
});

/// Convenience for screens: "the storefront of whoever is active".
final activeStorefrontProvider = FutureProvider.autoDispose<Storefront?>((ref) {
  final puuid = ref.watch(activeAccountIdProvider);
  if (puuid == null) return null;
  return ref.watch(storefrontProvider(puuid).future);
});
```

UI consumption (Riverpod 3 `AsyncValue` is sealed):

```dart
class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(activeStorefrontProvider);
    return switch (store) {
      AsyncData(:final value) when value != null => StoreGrid(value),
      AsyncData() => const SignInPrompt(),
      AsyncError(:final error) when error is NeedsLoginException => const ReLoginBanner(),
      AsyncError(:final error) => ErrorView(error, onRetry: () => ref.invalidate(activeStorefrontProvider)),
      _ => const StoreSkeleton(),
    };
  }
}
// Pull-to-refresh: RefreshIndicator(onRefresh: () => ref.refresh(storefrontProvider(puuid).future), ...)
```

Two things observed in tests **[BUILT]**:

- `container.read(p.future)` completes with the **original** exception type (`NeedsLoginException`), so `when error is ...` works.
- With `retry` returning `null`, `reauth()` was called exactly once.

---

## 10. Routing: `go_router` 18.0.1 with `StatefulShellRoute`

Relevant changes: 18.0.0 migrated go_router to `material_ui` (Flutter ≥3.44). 17.0.0 made shell routes notify observers (`notifyRootObserver`) **[SRC CHANGELOG]**. The router below analyzes cleanly **[BUILT]** (re-checked with the 5 ValBuddy tabs after the SUMMARY review; the first draft had 4 tabs named "Kho đồ"/"Sự nghiệp", which do not match `valbuddy-features.md` §6):

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'login_page.dart';
import 'providers.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Bridges Riverpod -> go_router refresh without rebuilding the router.
class _RouterRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref
    ..listen(activeAccountIdProvider, (_, _) => refresh.ping())
    ..onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/store',
    refreshListenable: refresh,
    redirect: (context, state) {
      final hasAccount = ref.read(activeAccountIdProvider) != null;
      final atWelcome = state.matchedLocation == '/welcome';
      if (!hasAccount && !atWelcome) return '/welcome';
      if (hasAccount && atWelcome) return '/store';
      return null;
    },
    routes: [
      GoRoute(path: '/welcome', builder: (_, _) => const _Placeholder('Chào mừng')),
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootKey, // full-screen, above the tab bar
        builder: (_, _) => const RiotLoginPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _TabScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/store',
              builder: (_, _) => const _Placeholder('Cửa hàng'),
              routes: [
                GoRoute(
                  path: 'skin/:uuid', // /store/skin/<uuid>
                  builder: (_, s) => _Placeholder('Skin ${s.pathParameters['uuid']}'),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [GoRoute(path: '/battlepass', builder: (_, _) => const _Placeholder('Battle Pass'))]),
          StatefulShellBranch(routes: [GoRoute(path: '/collection', builder: (_, _) => const _Placeholder('Bộ sưu tập'))]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, _) => const _Placeholder('Hồ sơ'))]),
          StatefulShellBranch(routes: [GoRoute(path: '/settings', builder: (_, _) => const _Placeholder('Cài đặt'))]),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class _TabScaffold extends StatelessWidget {
  const _TabScaffold({required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          // tapping the active tab pops that branch to its root
          onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Cửa hàng'),
            NavigationDestination(icon: Icon(Icons.military_tech_outlined), selectedIcon: Icon(Icons.military_tech), label: 'Battle Pass'),
            NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Bộ sưu tập'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Hồ sơ'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Cài đặt'),
          ],
        ),
      );
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)));
}
```

Tips:

- Create the `GoRouter` **once**, in a provider that never rebuilds, and drive re-evaluation with `refreshListenable`. Rebuilding the router resets navigation state.
- The login result comes back through `final r = await context.push<LoginResult>('/login');`.
- Tab labels are hard-coded above only to keep the snippet compact. Real code uses `AppLocalizations.of(context)`.

---

## 11. Images, video, charts

Snippets analyze cleanly **[BUILT]**.

```dart
// valorant-api media URLs are content-addressed (uuid in path) -> cache long.
final valMediaCache = CacheManager(Config(
  'valMedia',
  stalePeriod: const Duration(days: 30),
  maxNrOfCacheObjects: 3000,
));

Widget skinImage(String url, {double? height}) => CachedNetworkImage(
      imageUrl: url,
      cacheManager: valMediaCache,
      height: height,
      fit: BoxFit.contain,
      memCacheHeight: height == null ? null : (height * 3).round(), // decode small in grids
      fadeInDuration: const Duration(milliseconds: 120),
      placeholder: (_, _) => const SizedBox.shrink(),
      errorWidget: (_, _, _) => const Icon(Icons.broken_image_outlined),
    );
```

- `cached_network_image` 4.0.0 (2026-08-25) is a major bump only for the `material_ui` switch and Flutter ≥3.44. The API is unchanged from 3.4.x **[SRC CHANGELOG]**.
- Skin preview videos: `streamedVideo` URLs look like `https://valorant.dyn.riotcdn.net/x/videos/release-13.06/<uuid>_default_universal.mp4`. They are `video/mp4`, ~28 MB, with `Accept-Ranges: bytes` **[LIVE]**.
  - **Stream, don't pre-download.** Use one controller per visible video, muted and looping.
  - The URL contains the patch (`release-13.06`), so don't persist it beyond the content-cache version.

```dart
class SkinVideo extends StatefulWidget {
  const SkinVideo({required this.url, super.key});
  final String url;
  @override
  State<SkinVideo> createState() => _SkinVideoState();
}

class _SkinVideoState extends State<SkinVideo> {
  late final VideoPlayerController _c = VideoPlayerController.networkUrl(
    Uri.parse(widget.url),
    videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true), // don't stop the user's music
  );

  @override
  void initState() {
    super.initState();
    unawaited(_c.initialize().then((_) async {
      await _c.setLooping(true);
      await _c.setVolume(0);
      await _c.play();
      if (mounted) setState(() {});
    }));
  }

  @override
  void dispose() {
    unawaited(_c.dispose()); // ALWAYS dispose: each controller holds a native decoder
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _c.value.isInitialized
      ? AspectRatio(aspectRatio: _c.value.aspectRatio, child: VideoPlayer(_c))
      : const AspectRatio(aspectRatio: 16 / 9, child: Center(child: CircularProgressIndicator()));
}
```

- `video_player` 2.14.0 needs no Info.plist or manifest keys for HTTPS. It uses ExoPlayer on Android and AVPlayer on iOS. `chewie` 1.17.2 is available if you want controls; we don't.

RR history chart (`fl_chart` 1.2.0):

```dart
class RrHistoryChart extends StatelessWidget {
  const RrHistoryChart({required this.rrChanges, super.key}); // oldest -> newest
  final List<int> rrChanges;

  @override
  Widget build(BuildContext context) {
    var total = 0;
    final spots = <FlSpot>[
      for (var i = 0; i < rrChanges.length; i++) FlSpot(i.toDouble(), (total += rrChanges[i]).toDouble()),
    ];
    return AspectRatio(
      aspectRatio: 1.8,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(
            topTitles: AxisTitles(),
            rightTitles: AxisTitles(),
            bottomTitles: AxisTitles(),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    '${rrChanges[s.x.toInt()] >= 0 ? '+' : ''}${rrChanges[s.x.toInt()]} RR',
                    const TextStyle(color: ValColors.bone, fontWeight: FontWeight.w700),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: true,
              color: ValColors.red,
              barWidth: 3,
              dotData: FlDotData(
                getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                  radius: 3,
                  color: rrChanges[spot.x.toInt()] >= 0 ? ValColors.teal : ValColors.red,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(show: true, color: ValColors.red.withValues(alpha: 0.12)),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 12. Local notifications at shop reset

The API is `flutter_local_notifications` 22.3.1 **[SRC]**. Since v20, **all parameters are named**: `initialize(settings:)`, `show(id:)`, `zonedSchedule(id:, scheduledDate:, notificationDetails:, androidScheduleMode:, matchDateTimeComponents:)`, `cancel(id:)`. v21 bumped the minimums: Android API 24, iOS 13, compileSdk 36.

Android requirements:

- **Core library desugaring** (`desugar_jdk_libs` 2.1.4+; we use 2.1.5).
- The two receivers in the manifest.
- `POST_NOTIFICATIONS` is merged in automatically, but it still needs the **runtime** request on Android 13+.

Exact alarms:

- On Android 14+, `SCHEDULE_EXACT_ALARM` is **denied by default** for new installs.
- `USE_EXACT_ALARM` is restricted by Play policy to alarm and calendar apps.
- ValVN uses **`AndroidScheduleMode.inexactAllowWhileIdle`**, which needs no permission, and strips both exact-alarm permissions with `tools:node="remove"`. Inexact delivery may be minutes late in Doze. That is acceptable for "shop refreshed".

iOS:

- Permission is requested explicitly (the initialization settings set `request*Permission: false`, so there's no prompt at launch).
- At most 64 pending notifications. A daily repeat using `DateTimeComponents.time` takes only one slot.

This service analyzes cleanly **[BUILT]**:

```dart
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class ShopNotifications {
  ShopNotifications._();
  static final instance = ShopNotifications._();

  final _plugin = FlutterLocalNotificationsPlugin();
  static const _dailyId = 1000;
  static const _channel = AndroidNotificationDetails(
    'shop_reset', // channel id (never change after release)
    'Làm mới cửa hàng', // channel name shown in Android settings
    channelDescription: 'Nhắc khi cửa hàng hằng ngày làm mới',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  /// Call once from main() (and from the background isolate before showing).
  Future<void> init() async {
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone(); // flutter_timezone 5.x returns TimezoneInfo
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } on Object {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_stat_valvn'), // monochrome small icon
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {/* deep link: r.payload e.g. '/store' */},
    );
  }

  /// Returns true if the user allowed notifications.
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false; // Android 13+ runtime dialog
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
  }

  /// [nextReset] = now + storefront.SkinsPanelLayout.SingleItemOffersRemainingDurationInSeconds.
  Future<void> scheduleDailyReset(DateTime nextReset) async {
    await _plugin.cancel(id: _dailyId);
    final at = tz.TZDateTime.from(nextReset.add(const Duration(minutes: 1)), tz.local);
    await _plugin.zonedSchedule(
      id: _dailyId,
      title: 'Cửa hàng đã làm mới',
      body: 'Xem 4 skin hôm nay của bạn',
      scheduledDate: at,
      notificationDetails: const NotificationDetails(android: _channel, iOS: DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle, // no exact-alarm permission
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily at this local time
      payload: '/store',
    );
  }

  Future<void> showWishlistHit(String skinName) => _plugin.show(
        id: skinName.hashCode & 0x7fffffff,
        title: 'Skin trong danh sách ước có trong cửa hàng!',
        body: skinName,
        notificationDetails: const NotificationDetails(android: _channel, iOS: DarwinNotificationDetails()),
        payload: '/store',
      );

  Future<void> cancelAll() => _plugin.cancelAll();
}
```

Notes:

- **Reset time:** compute it from the storefront's `SingleItemOffersRemainingDurationInSeconds` rather than hard-coding 00:00 UTC (07:00 in Vietnam). Re-schedule after every storefront fetch. The constant fallback 00:00 UTC is confirmed for an AP account in 2026 (DailyStore, see `SUMMARY.md`) but still **[UNVERIFIED for every shard]**; see `riot-endpoints.md`.
- `@drawable/ic_stat_valvn` must exist: a white-on-transparent PNG or vector in `android/app/src/main/res/drawable*/`. Otherwise the plugin throws `invalid_icon`. Use `@mipmap/ic_launcher` until the icon exists.
- Also offer `openAppNotificationSettings()` (added in 22.3.0) as a "turn on in Settings" button once the user has denied the permission **[SRC]**.

---

## 13. Background wishlist check: `workmanager` 0.10.10

Feasibility:

| | Android (WorkManager) | iOS (BGAppRefreshTask) |
|---|---|---|
| Min interval | 15 min | "earliest begin" hint only; iOS decides |
| Realistic cadence | every few hours, reliable-ish (OEM battery killers: Xiaomi/Oppo/Vivo can stop it) | **0–few times/day**, depends on how often the user opens the app; never if the user force-quits the app or Low Power Mode is on |
| Time budget | ~10 min | **~30 s** |
| Debug | `adb shell cmd jobscheduler run -f vn.valvn.valvn <jobId>` | Xcode LLDB: `e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"vn.valvn.app.wishlistCheck"]` |

Conclusion:

- **Android:** background wishlist alerts are a real feature.
- **iOS:** best effort only. Tell users in the UI ("iOS quyết định thời điểm chạy nền").
- The daily reset notification (§12) does **not** depend on background work.
- `background_fetch` 1.7.0 (Transistorsoft) is an alternative with the same iOS limits and was not build-tested here. Pick one, not both.

The dispatcher analyzes cleanly **[BUILT]**:

```dart
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'notifications.dart';

/// MUST match: Info.plist BGTaskSchedulerPermittedIdentifiers + AppDelegate.
const kWishlistTask = 'vn.valvn.app.wishlistCheck';

@pragma('vm:entry-point') // keep it through tree-shaking; runs in a NEW isolate
void callbackDispatcher() {
  Workmanager().executeTask((task, input) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    try {
      // No Riverpod ProviderScope here: build plain services by hand.
      final prefs = SharedPreferencesAsync(); // reads straight from disk, isolate-safe
      final wishlist = await prefs.getStringList('wishlist') ?? const <String>[];
      if (wishlist.isEmpty) return true;
      await ShopNotifications.instance.init();
      // 1. read cookies from SecureVault (keychain item must be first_unlock*)
      // 2. RiotReauthClient.reauth -> tokens -> entitlements
      // 3. POST storefront v3, intersect SingleItemOffers with wishlist
      // 4. ShopNotifications.instance.showWishlistHit(name) for each hit;
      //    remember "notified for reset X" in prefs to avoid duplicates
      return true;
    } on Object {
      return false; // Android: retried with backoff; iOS: ignored
    }
  });
}

Future<void> registerBackgroundWork() async {
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    kWishlistTask, // uniqueName (Android) == identifier (iOS)
    kWishlistTask, // taskName
    frequency: const Duration(hours: 6), // Android min 15 min; iOS treats as a hint
    initialDelay: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
  );
}
```

Gotchas:

- The task name in Dart must **exactly** match the Info.plist and AppDelegate identifier. A mismatch gives `BGTaskSchedulerErrorDomain Code 3` **[DOC workmanager]**.
- The background isolate has **no ProviderScope** and no UI state. Reuse the plain classes (`SecureVault`, `RiotReauthClient`, `ContentCache`) directly. This is why the business logic must not live only inside providers.
- Don't use the cached `SharedPreferencesWithCache` across isolates. In the background use `SharedPreferencesAsync`. The same applies to Hive: plain `Hive` is not multi-isolate safe; `hive_ce` has `IsolatedHive` for that.
- On iOS, reading the Keychain while the device is locked needs `first_unlock*` accessibility (§8).
- `workmanager` 0.10 on Android declares `FOREGROUND_SERVICE_SHORT_SERVICE` for expedited work, which needs no Play declaration **[SRC]**.

---

## 14. Home-screen widgets: `home_widget` 0.10.0 (OPTIONAL)

Feasibility and cost:

- **Android: easy.** No paid account; a `RemoteViews` XML layout plus a Kotlin provider.
- **iOS: needs a WidgetKit extension in Swift** and an **App Group** shared by the app and the extension.
  - Adding App Groups needs a **paid Apple Developer account**, according to the home_widget iOS setup docs **[DOC]**.
  - **Sideloading:** each app extension uses an extra App ID. A free Apple ID gets 10 App IDs per 7 days and 3 active apps, so the widget shrinks the user's sideload budget **[DOC AltStore FAQ]**.
  - Whether AltStore or Sideloadly remap `group.` entitlements for free accounts is **[UNVERIFIED]**.
  - Suggestion: ship v1 **without** the iOS extension. Optionally produce a second IPA variant with the extension later.
- 0.10.0 has breaking changes for its *generated* widgets feature (custom fonts/icons, widget previews). Classic `saveWidgetData` / `updateWidget` is unchanged. 0.9.3 added UIScene support; 0.9.2 added AGP 9 support **[SRC CHANGELOG]**.

Dart side (both platforms):

```dart
const kAppGroup = 'group.vn.valvn.valvn';           // iOS only; must match both targets' entitlements
Future<void> pushShopToWidget(List<String> skinNames, Duration remaining) async {
  await HomeWidget.setAppGroupId(kAppGroup);
  await HomeWidget.saveWidgetData<String>('shop_title', 'Cửa hàng • còn ${remaining.inHours} giờ');
  await HomeWidget.saveWidgetData<String>('shop_items', skinNames.join('\n'));
  await HomeWidget.updateWidget(
    iOSName: 'ShopWidget',                                   // WidgetKit `kind`
    qualifiedAndroidName: 'vn.valvn.valvn.ShopWidgetProvider', // avoids namespace/applicationId ambiguity
  );
}
```

Android (minimal):

1. `android/app/src/main/kotlin/vn/valvn/valvn/ShopWidgetProvider.kt`:

   ```kotlin
   package vn.valvn.valvn

   import android.appwidget.AppWidgetManager
   import android.content.Context
   import android.content.SharedPreferences
   import android.widget.RemoteViews
   import es.antonborri.home_widget.HomeWidgetProvider

   class ShopWidgetProvider : HomeWidgetProvider() {
       override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager,
                             appWidgetIds: IntArray, widgetData: SharedPreferences) {
           appWidgetIds.forEach { id ->
               val views = RemoteViews(context.packageName, R.layout.shop_widget).apply {
                   setTextViewText(R.id.shop_title, widgetData.getString("shop_title", "Cửa hàng hôm nay"))
                   setTextViewText(R.id.shop_items, widgetData.getString("shop_items", "Mở ValVN để tải"))
               }
               appWidgetManager.updateAppWidget(id, views)
           }
       }
   }
   ```

2. `res/layout/shop_widget.xml`: a `LinearLayout` with two `TextView`s (`@+id/shop_title`, `@+id/shop_items`), background `#0F1923`.
3. `res/xml/shop_widget_info.xml`:

   ```xml
   <appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
       android:minWidth="180dp" android:minHeight="110dp"
       android:updatePeriodMillis="0"
       android:initialLayout="@layout/shop_widget"
       android:resizeMode="horizontal|vertical"
       android:widgetCategory="home_screen" />
   ```

4. Manifest, inside `<application>`:

   ```xml
   <receiver android:name=".ShopWidgetProvider" android:exported="true">
       <intent-filter><action android:name="android.appwidget.action.APPWIDGET_UPDATE" /></intent-filter>
       <meta-data android:name="android.appwidget.provider" android:resource="@xml/shop_widget_info" />
   </receiver>
   ```

iOS (minimal; needs Xcode on a Mac; **[UNVERIFIED]** here):

1. Xcode → File → New → Target → **Widget Extension**, name `ShopWidget`. Untick "Include Configuration App Intent" and "Include Live Activity".
2. Set the extension's deployment target to **17.0**, which allows `.containerBackground`. The app stays at 15.0; the widget simply isn't offered on iOS 15–16.
3. Add **App Groups** capability `group.vn.valvn.valvn` to **both** Runner and ShopWidget. This needs a paid team, as noted above.
4. **Avoid the "Cycle inside Runner" build error:** in Runner → Build Phases, drag **"Embed Foundation Extensions"** above **"Thin Binary"** / "Run Script". This is a classic Flutter + extension issue.
5. Replace the generated Swift with:

   ```swift
   import WidgetKit
   import SwiftUI

   private let appGroup = "group.vn.valvn.valvn"

   struct ShopEntry: TimelineEntry { let date: Date; let title: String; let items: [String] }

   struct Provider: TimelineProvider {
     func placeholder(in context: Context) -> ShopEntry { ShopEntry(date: .now, title: "Cửa hàng", items: []) }
     func getSnapshot(in context: Context, completion: @escaping (ShopEntry) -> Void) { completion(load()) }
     func getTimeline(in context: Context, completion: @escaping (Timeline<ShopEntry>) -> Void) {
       completion(Timeline(entries: [load()], policy: .after(.now.addingTimeInterval(3600))))
     }
     private func load() -> ShopEntry {
       let d = UserDefaults(suiteName: appGroup)
       return ShopEntry(date: .now,
                        title: d?.string(forKey: "shop_title") ?? "Cửa hàng hôm nay",
                        items: (d?.string(forKey: "shop_items") ?? "").split(separator: "\n").map(String.init))
     }
   }

   struct ShopWidgetView: View {
     let entry: ShopEntry
     var body: some View {
       VStack(alignment: .leading, spacing: 4) {
         Text(entry.title).font(.caption).bold().foregroundStyle(Color(red: 1, green: 0.27, blue: 0.33))
         ForEach(entry.items.prefix(4), id: \.self) { Text($0).font(.caption2).lineLimit(1) }
       }.foregroundStyle(.white)
     }
   }

   @main
   struct ShopWidget: Widget {
     let kind = "ShopWidget"   // == iOSName in Dart
     var body: some WidgetConfiguration {
       StaticConfiguration(kind: kind, provider: Provider()) { entry in
         ShopWidgetView(entry: entry).containerBackground(Color(red: 0.06, green: 0.1, blue: 0.14), for: .widget)
       }
       .configurationDisplayName("Cửa hàng ValVN")
       .description("4 skin trong cửa hàng hôm nay")
       .supportedFamilies([.systemSmall, .systemMedium])
     }
   }
   ```

6. With `--no-codesign` the extension ends up in `Runner.app/PlugIns/ShopWidget.appex`. Sideloading tools re-sign it along with the app.

---

## 15. Localization (vi only), formatting, fonts

`l10n.yaml` (tested with `flutter gen-l10n` **[BUILT]**):

```yaml
arb-dir: lib/l10n
template-arb-file: app_vi.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
preferred-supported-locales: [vi]
nullable-getter: false          # AppLocalizations.of(context) is non-null
```

- The generated files go to `lib/l10n/` and are imported as `import 'l10n/app_localizations.dart';`. The synthetic `package:flutter_gen` is gone.
- Exclude them from analysis (§20) or commit them. `flutter pub get` regenerates them because of `generate: true`.

`lib/l10n/app_vi.arb` example:

```json
{
  "@@locale": "vi",
  "appTitle": "ValVN",
  "storeResetIn": "Làm mới sau {duration}",
  "@storeResetIn": { "placeholders": { "duration": { "type": "String" } } },
  "vpAmount": "{amount} VP",
  "@vpAmount": { "placeholders": { "amount": { "type": "int", "format": "decimalPattern" } } },
  "matchCount": "{count, plural, =0{Chưa có trận nào} other{{count} trận}}",
  "@matchCount": { "placeholders": { "count": { "type": "int" } } },
  "lastPlayed": "Chơi lần cuối {date}",
  "@lastPlayed": { "placeholders": { "date": { "type": "DateTime", "format": "yMMMMd" } } }
}
```

Vietnamese has only the `other` plural category, but `=0` still works. Typed placeholders generate `NumberFormat.decimalPattern(localeName)` and `DateFormat.yMMMMd(localeName)` **[BUILT]**.

`intl` 0.20.3 output for `vi`, with `initializeDateFormatting('vi')` **[BUILT]**:

| Call | Output |
|---|---|
| `NumberFormat.decimalPattern('vi').format(1234567)` | `1.234.567` |
| `NumberFormat.compact(locale:'vi').format(1234567)` | `1,23 Tr` |
| `NumberFormat.percentPattern('vi').format(0.256)` | `26%` |
| `DateFormat.yMMMMEEEEd('vi')` | `Thứ Hai, 28 tháng 9, 2026` |
| `DateFormat.yMd('vi').add_Hm()` | `28/9/2026 0:00` |
| `DateFormat('EEEE, dd/MM/yyyy HH:mm', 'vi')` | `Thứ Hai, 28/09/2026 00:00` |
| `DateFormat.MMMd('vi')` | `28 thg 9` |

Rules:

- Set `Intl.defaultLocale = 'vi'` in `main()`.
- In the **background isolate**, call `await initializeDateFormatting('vi')` (from `package:intl/date_symbol_data_local.dart`) before formatting. `GlobalMaterialLocalizations` does it for the UI isolate only.
- Don't use `NumberFormat.compact` for VP ("1,23 Tr" looks odd for currency). Use `decimalPattern`.

Fonts (bundled, never fetched at runtime; `google_fonts` 8.2.1 is **not** used):

```bash
mkdir -p assets/fonts && cd assets/fonts
for w in Regular Medium SemiBold Bold; do
  curl -fsSLO https://raw.githubusercontent.com/google/fonts/main/ofl/bevietnampro/BeVietnamPro-$w.ttf
done
curl -fsSLO https://raw.githubusercontent.com/google/fonts/main/ofl/anton/Anton-Regular.ttf
# also commit OFL.txt (SIL Open Font License) next to them
```

- All five URLs returned 200 **[LIVE]**; each Be Vietnam Pro file is ~133–140 KB.
- Vietnamese glyph coverage (Google Fonts `METADATA.pb` subsets **[LIVE]**):
  - Have `vietnamese`: Anton, Oswald, Barlow Condensed, Saira Condensed, Chakra Petch.
  - Missing it (so they break on "Ư/ơ/ạ…"): **Bebas Neue** and **Teko**.
- Valorant's real display font (DIN Next / "Tungsten") is proprietary. Do not bundle it.

---

## 16. Caching valorant-api.com content

Measurements **[LIVE]**, `?language=vi-VN`, gzip on the wire:

| Endpoint | Download (gzip) | Uncompressed |
|---|---|---|
| `weapons/skins` | ~503 KB | **3.6 MB** (use `/v1/weapons` instead: same size, and it also carries the weapon→skin relation; see `content-api.md` §2.3) |
| `weapons/skinlevels` | 184 KB | |
| `weapons/skinchromas` | 211 KB | |
| `sprays` | 113 KB | |
| `contracts` | 85 KB | |
| `playercards` | 79 KB | |
| `agents` | 24 KB | |
| `competitivetiers` | 3.4 KB | |

- Response headers: `cache-control: public, max-age=14400`.
- `/v1/version` returns `version: "13.06.00.5435758"`, `riotClientVersion: "release-13.06-shipping-13-5435758"`, `buildDate: 2026-09-03T00:14:05Z`.

Design (no database needed):

- **Big content JSON:** files in `getApplicationSupportDirectory()/content/vi-VN/<endpoint>.<version>.json`, keyed by the `/v1/version` **`manifestId`** (SUMMARY review: `content-api.md` §2 keys on `manifestId` + language + schema version; `version` also works but `manifestId` is what SkinPeek uses). On launch, GET `/v1/version` (tiny). If the version changed, re-download lazily and delete the old files. Decode in `Isolate.run`.
- **Settings, wishlist, account metadata, last storefront snapshot:** `shared_preferences` 2.5.5.
  - UI: `SharedPreferencesWithCache` (synchronous reads after `create()`).
  - Background isolate: `SharedPreferencesAsync`.
  - The legacy `SharedPreferences.getInstance()` API still works but is discouraged.
- **Images:** `flutter_cache_manager` (§11).
- **Hive:** `hive_ce` 2.20.1 / `hive_ce_flutter` 2.4.0 are healthy (published 2026-09-27) if structured offline queries are needed later, e.g. match history. Use `IsolatedHive` if the background isolate must touch it. Don't use the original `hive` package (unmaintained).

This analyzes cleanly **[BUILT]**:

```dart
class ContentCache {
  ContentCache(this._dio);
  final Dio _dio;
  static const _base = 'https://valorant-api.com/v1';

  Future<Directory> _dir() async {
    final d = Directory('${(await getApplicationSupportDirectory()).path}/content/vi-VN');
    return d.create(recursive: true);
  }

  /// e.g. "67AF51413C6922AE" from /v1/version (data.manifestId) - the cache key.
  Future<String?> remoteVersion() async {
    final r = await _dio.get<Map<String, dynamic>>('$_base/version');
    return (r.data?['data'] as Map?)?['manifestId'] as String?;
  }

  /// Returns the decoded `data` of `/v1/{endpoint}?language=vi-VN`.
  /// Parsing (skins = ~3.6 MB) happens off the UI isolate.
  Future<List<dynamic>> load(String endpoint, {required String version}) async {
    final dir = await _dir();
    final safe = endpoint.replaceAll('/', '_');
    final file = File('${dir.path}/$safe.$version.json');
    if (!file.existsSync()) {
      final r = await _dio.get<String>(
        '$_base/$endpoint',
        queryParameters: {'language': 'vi-VN'},
        options: Options(responseType: ResponseType.plain),
      );
      await file.writeAsString(r.data!, flush: true);
      await for (final f in dir.list()) {           // delete older versions of this endpoint
        if (f is File && f.path.contains('/$safe.') && f.path != file.path) await f.delete();
      }
    }
    final path = file.path;
    return Isolate.run(() {
      final m = jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
      return (m['data'] as List?) ?? const [];
    });
  }
}
```

In production, map the JSON to lean model objects **inside** `Isolate.run` and return those (e.g. `Map<String uuid, SkinLite>`). Keeping 3.6 MB of raw maps in memory is wasteful.

---

## 17. Theming: dark Valorant-style Material 3

This analyzes cleanly **[BUILT]**. It uses `material_ui`, plus `cupertino_ui` for the iOS transition builder.

```dart
import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoPageTransitionsBuilder;
import 'package:material_ui/material_ui.dart';

abstract final class ValColors {
  static const red = Color(0xFFFF4655);     // Valorant red
  static const navy = Color(0xFF0F1923);    // background
  static const surface = Color(0xFF1B2733);
  static const surfaceHigh = Color(0xFF243140);
  static const bone = Color(0xFFECE8E1);    // text
  static const teal = Color(0xFF17E5B3);    // win / +RR
  static const muted = Color(0xFF8B978F);
}

ThemeData buildValTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: ValColors.red, brightness: Brightness.dark).copyWith(
    primary: ValColors.red,
    onPrimary: Colors.white,
    secondary: ValColors.teal,
    surface: ValColors.navy,
    onSurface: ValColors.bone,
    surfaceContainer: ValColors.surface,
    surfaceContainerHigh: ValColors.surfaceHigh,
    error: const Color(0xFFFF5A5F),
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: 'BeVietnamPro');
  return base.copyWith(
    scaffoldBackgroundColor: ValColors.navy,
    textTheme: base.textTheme.copyWith(
      headlineLarge: base.textTheme.headlineLarge?.copyWith(fontFamily: 'Anton', letterSpacing: 1),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(fontFamily: 'Anton', letterSpacing: 1),
      titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(backgroundColor: ValColors.navy, centerTitle: false, scrolledUnderElevation: 0),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ValColors.surface,
      indicatorColor: ValColors.red.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(fontSize: 12, fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500),
      ),
    ),
    cardTheme: CardThemeData(
      color: ValColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // sharp, Valorant-like
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ValColors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: PredictiveBackPageTransitionsBuilder(), // + enableOnBackInvokedCallback in manifest
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }),
  );
}
// MaterialApp.router(theme: buildValTheme(), darkTheme: buildValTheme(), themeMode: ThemeMode.dark, ...)
```

Tier and rarity colors come from valorant-api (`contenttiers[].highlightColor`, `competitivetiers[].tiers[].color`) as `RRGGBBAA` hex. Parse them defensively:

```dart
Color parseRgba(String? hex) {
  if (hex == null || hex.length < 6) return ValColors.muted;
  final rgb = int.tryParse(hex.substring(0, 6), radix: 16);
  final a = hex.length >= 8 ? int.tryParse(hex.substring(6, 8), radix: 16) ?? 255 : 255;
  return rgb == null ? ValColors.muted : Color((a << 24) | rgb);
}
```

---

## 18. Local build recipe (Linux container)

```bash
export PATH=/opt/flutter/bin:$PATH ANDROID_HOME=/opt/android-sdk
flutter pub get                       # also runs gen-l10n (generate: true)
flutter analyze                       # must be 0 issues (fatal-infos is the default)
dart analyze                          # only needed if riverpod_lint is enabled (see §20)
flutter test
flutter build apk --release --split-per-abi
ls build/app/outputs/flutter-apk/
```

- If `android/key.properties` is absent, the APK is signed with the debug key and Gradle prints `ValVN: no release keystore -> signing release with the DEBUG key` **[BUILT]**.
- IPA builds need macOS (§19.2).

---

## 19. CI: GitHub Actions (complete YAML)

Versions resolved on 2026-09-28 via `git ls-remote --tags`:

| Action | Tag |
|---|---|
| `actions/checkout` | **v7** (7.0.1) |
| `actions/setup-java` | **v6** (6.0.1) |
| `actions/upload-artifact` | **v7** (7.0.1) |
| `actions/cache` | v6 (6.1.0) |
| `subosito/flutter-action` | **v2** (2.23.0) |
| `softprops/action-gh-release` | **v3** (3.0.3) |
| `maxim-lobanov/setup-xcode` | v1 (1.7.0) |

Runner images (actions/runner-images README **[DOC]**):

- `ubuntu-latest` = `ubuntu-24.04`. It has JDK 17 (default), 21 and 25; Android build-tools 34–37; platforms 34…37.2; NDK 27.3 (default), **28.2.13676358** and 29.0; CMake 3.31.5 and 4.1.2.
- `macos-latest` = **`macos-26`** (arm64): macOS 26.6.2, **Xcode 26.6 default** (26.0.1–26.6 installed), CocoaPods 1.17.0.
- An `xcode-27` preview label exists. Don't use it for release builds yet.

The YAML below is **[UNVERIFIED]**: GitHub Actions can't run here. Every command in it was checked locally where possible.

### 19.1 `.github/workflows/android.yml`

```yaml
name: Android APK

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:
  workflow_dispatch:

permissions:
  contents: write          # needed to create a GitHub Release on tags

concurrency:
  group: android-${{ github.ref }}
  cancel-in-progress: true

env:
  FLUTTER_VERSION: '3.47.5'

jobs:
  build:
    runs-on: ubuntu-24.04
    timeout-minutes: 45
    env:
      HAS_KEYSTORE: ${{ secrets.ANDROID_KEYSTORE_BASE64 != '' }}
    steps:
      - uses: actions/checkout@v7

      - uses: actions/setup-java@v6
        with:
          distribution: temurin
          java-version: '21'
          cache: gradle

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Android SDK components
        run: |
          SDKM="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
          yes | "$SDKM" --licenses > /dev/null || true
          "$SDKM" --install "platforms;android-36" "build-tools;36.0.0" \
                            "ndk;28.2.13676358" "cmake;3.22.1" > /dev/null

      - name: Version info
        id: ver
        run: |
          if [[ "$GITHUB_REF" == refs/tags/v* ]]; then NAME="${GITHUB_REF_NAME#v}"; else NAME="$(grep '^version:' pubspec.yaml | sed 's/version: *//; s/+.*//')"; fi
          echo "name=$NAME" >> "$GITHUB_OUTPUT"
          echo "number=${{ github.run_number }}" >> "$GITHUB_OUTPUT"

      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test

      - name: Decode release keystore
        if: env.HAS_KEYSTORE == 'true'
        env:
          KS_B64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
          KS_PASS: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
          KEY_PASS: ${{ secrets.ANDROID_KEY_PASSWORD }}
        run: |
          echo "$KS_B64" | base64 --decode > android/app/upload-keystore.jks
          cat > android/key.properties <<EOF
          storePassword=$KS_PASS
          keyPassword=$KEY_PASS
          keyAlias=$KEY_ALIAS
          storeFile=upload-keystore.jks
          EOF

      - name: Build APKs (universal + per-ABI)
        run: |
          flutter build apk --release \
            --build-name=${{ steps.ver.outputs.name }} --build-number=${{ steps.ver.outputs.number }}
          mkdir -p dist
          cp build/app/outputs/flutter-apk/app-release.apk "dist/ValVN-${{ steps.ver.outputs.name }}-universal.apk"
          flutter build apk --release --split-per-abi \
            --build-name=${{ steps.ver.outputs.name }} --build-number=${{ steps.ver.outputs.number }}
          for abi in arm64-v8a armeabi-v7a x86_64; do
            cp "build/app/outputs/flutter-apk/app-$abi-release.apk" "dist/ValVN-${{ steps.ver.outputs.name }}-$abi.apk"
          done
          (cd dist && sha256sum *.apk > SHA256SUMS.txt)
          if [ "$HAS_KEYSTORE" != "true" ]; then echo "::warning::APKs are signed with the DEBUG key (no ANDROID_KEYSTORE_BASE64 secret)"; fi

      - uses: actions/upload-artifact@v7
        with:
          name: ValVN-android-${{ steps.ver.outputs.name }}+${{ steps.ver.outputs.number }}
          path: dist/*
          if-no-files-found: error
          retention-days: 30

      - name: GitHub Release
        if: startsWith(github.ref, 'refs/tags/v')
        uses: softprops/action-gh-release@v3
        with:
          files: dist/*
          generate_release_notes: true
          prerelease: ${{ contains(github.ref_name, '-') }}

      - name: Clean secrets
        if: always()
        run: rm -f android/key.properties android/app/upload-keystore.jks
```

Secrets: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`. All are optional; the build falls back to debug signing.

- Secrets can't be referenced in a step `if:` directly. That's why the job-level `HAS_KEYSTORE` env is used.
- Keep the same keystore forever. APKs signed with a different key cannot update each other.

### 19.2 `.github/workflows/ios.yml`

This builds an unsigned IPA (for AltStore, SideStore or Sideloadly), plus an optional signed IPA.

```yaml
name: iOS IPA

on:
  push:
    branches: [main]
    tags: ['v*']
  workflow_dispatch:

permissions:
  contents: write

concurrency:
  group: ios-${{ github.ref }}
  cancel-in-progress: true

env:
  FLUTTER_VERSION: '3.47.5'
  XCODE_VERSION: '26.6'

jobs:
  ipa:
    runs-on: macos-26            # arm64; macos-latest also points here since mid-2026
    timeout-minutes: 60
    env:
      HAS_SIGNING: ${{ secrets.IOS_CERT_P12_BASE64 != '' && secrets.IOS_PROFILE_BASE64 != '' }}
    steps:
      - uses: actions/checkout@v7

      - uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: ${{ env.XCODE_VERSION }}

      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true

      - name: Version info
        id: ver
        run: |
          if [[ "$GITHUB_REF" == refs/tags/v* ]]; then NAME="${GITHUB_REF_NAME#v}"; else NAME="$(grep '^version:' pubspec.yaml | sed 's/version: *//; s/+.*//')"; fi
          echo "name=$NAME" >> "$GITHUB_OUTPUT"
          echo "number=${{ github.run_number }}" >> "$GITHUB_OUTPUT"

      - run: flutter --version && xcodebuild -version
      - run: flutter pub get
      - run: flutter test

      # ---------- Unsigned IPA (always) ----------
      - name: Build iOS app (no codesign)
        run: |
          flutter build ios --release --no-codesign \
            --build-name=${{ steps.ver.outputs.name }} --build-number=${{ steps.ver.outputs.number }}

      - name: Package unsigned IPA
        run: |
          set -euo pipefail
          mkdir -p dist build/ipa/Payload
          cp -R build/ios/iphoneos/Runner.app build/ipa/Payload/
          (cd build/ipa && zip -qry "../../dist/ValVN-${{ steps.ver.outputs.name }}-unsigned.ipa" Payload)  # -y keeps framework symlinks
          ls -lh dist

      # ---------- Optional signed IPA ----------
      - name: Install signing certificate and provisioning profile
        if: env.HAS_SIGNING == 'true'
        env:
          P12_BASE64: ${{ secrets.IOS_CERT_P12_BASE64 }}
          P12_PASSWORD: ${{ secrets.IOS_CERT_PASSWORD }}
          PROFILE_BASE64: ${{ secrets.IOS_PROFILE_BASE64 }}
          KEYCHAIN_PASSWORD: ${{ secrets.IOS_KEYCHAIN_PASSWORD }}
        run: |
          set -euo pipefail
          CERT="$RUNNER_TEMP/cert.p12"; PROFILE="$RUNNER_TEMP/profile.mobileprovision"
          KC="$RUNNER_TEMP/app-signing.keychain-db"; KCPW="${KEYCHAIN_PASSWORD:-$(uuidgen)}"
          echo -n "$P12_BASE64" | base64 --decode -o "$CERT"
          echo -n "$PROFILE_BASE64" | base64 --decode -o "$PROFILE"
          security create-keychain -p "$KCPW" "$KC"
          security set-keychain-settings -lut 21600 "$KC"
          security unlock-keychain -p "$KCPW" "$KC"
          security import "$CERT" -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k "$KC"
          security set-key-partition-list -S apple-tool:,apple: -k "$KCPW" "$KC"
          security list-keychain -d user -s "$KC"
          PLIST="$(security cms -D -i "$PROFILE")"
          UUID=$(/usr/libexec/PlistBuddy -c "Print UUID" /dev/stdin <<< "$PLIST")
          NAME=$(/usr/libexec/PlistBuddy -c "Print Name" /dev/stdin <<< "$PLIST")
          # Xcode 16+ reads profiles from UserData; keep the legacy path too.
          for d in "$HOME/Library/Developer/Xcode/UserData/Provisioning Profiles" "$HOME/Library/MobileDevice/Provisioning Profiles"; do
            mkdir -p "$d"; cp "$PROFILE" "$d/$UUID.mobileprovision"
          done
          echo "PROFILE_NAME=$NAME" >> "$GITHUB_ENV"

      - name: Build signed IPA
        if: env.HAS_SIGNING == 'true'
        env:
          TEAM_ID: ${{ secrets.IOS_TEAM_ID }}
          BUNDLE_ID: vn.valvn.valvn
          EXPORT_METHOD: ${{ vars.IOS_EXPORT_METHOD || 'release-testing' }}   # release-testing (ad-hoc) | debugging | app-store-connect
        run: |
          set -euo pipefail
          cat > "$RUNNER_TEMP/ExportOptions.plist" <<EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
          <plist version="1.0"><dict>
            <key>method</key><string>${EXPORT_METHOD}</string>
            <key>teamID</key><string>${TEAM_ID}</string>
            <key>signingStyle</key><string>manual</string>
            <key>provisioningProfiles</key><dict><key>${BUNDLE_ID}</key><string>${PROFILE_NAME}</string></dict>
            <key>stripSwiftSymbols</key><true/>
          </dict></plist>
          EOF
          # FLUTTER_XCODE_* env vars are forwarded to xcodebuild as build settings (flutter_tools xcodeproj.dart).
          # NOTE: they apply to ALL targets - with a widget extension, configure per-target signing in Xcode instead.
          FLUTTER_XCODE_CODE_SIGN_STYLE=Manual \
          FLUTTER_XCODE_DEVELOPMENT_TEAM="$TEAM_ID" \
          FLUTTER_XCODE_PROVISIONING_PROFILE_SPECIFIER="$PROFILE_NAME" \
          FLUTTER_XCODE_CODE_SIGN_IDENTITY="Apple Distribution" \
          flutter build ipa --release \
            --export-options-plist="$RUNNER_TEMP/ExportOptions.plist" \
            --build-name=${{ steps.ver.outputs.name }} --build-number=${{ steps.ver.outputs.number }}
          cp build/ios/ipa/*.ipa "dist/ValVN-${{ steps.ver.outputs.name }}-signed.ipa"

      - uses: actions/upload-artifact@v7
        with:
          name: ValVN-ios-${{ steps.ver.outputs.name }}+${{ steps.ver.outputs.number }}
          path: dist/*.ipa
          if-no-files-found: error
          retention-days: 30

      - name: GitHub Release
        if: startsWith(github.ref, 'refs/tags/v')
        uses: softprops/action-gh-release@v3
        with:
          files: dist/*.ipa
          prerelease: ${{ contains(github.ref_name, '-') }}

      - name: Remove keychain
        if: always() && env.HAS_SIGNING == 'true'
        run: security delete-keychain "$RUNNER_TEMP/app-signing.keychain-db" || true
```

iOS CI notes:

- `flutter build ipa --no-codesign` only produces `build/ios/archive/Runner.xcarchive` and prints "Codesigning disabled with --no-codesign, skipping IPA." **[SRC build_ios.dart]**. That's why the unsigned path uses `build ios` plus manual `Payload/` zipping.
  - Equivalent alternative: zip `Runner.xcarchive/Products/Applications/Runner.app`.
- Export method names: Xcode ≥15.4 renamed `ad-hoc` to `release-testing`, `development` to `debugging`, and `app-store` to `app-store-connect`. Flutter maps them automatically only for `--export-method`, not inside a custom plist **[SRC]**.
- SwiftPM package resolution happens inside `xcodebuild`. Nothing special is needed. CocoaPods (1.17.0 on the image) is only used if a plugin lacks `Package.swift`.
- Secrets for the signed path: `IOS_CERT_P12_BASE64`, `IOS_CERT_PASSWORD`, `IOS_PROFILE_BASE64`, `IOS_TEAM_ID`, optional `IOS_KEYCHAIN_PASSWORD`, plus a repo variable `IOS_EXPORT_METHOD`.

---

## 20. Testing and static analysis

### `analysis_options.yaml` (recommended)

With this config, all `lib/snip/*.dart` files give "No issues found" **[BUILT]**.

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - build/**
    - android/**
    - ios/**
    - lib/l10n/app_localizations*.dart
  language:
    strict-casts: true
    strict-raw-types: true
    strict-inference: true

linter:
  rules:
    - always_declare_return_types
    - avoid_dynamic_calls          # forces defensive JSON parsing
    - cancel_subscriptions
    - discarded_futures
    - prefer_final_locals
    - prefer_single_quotes
    - unawaited_futures
    - use_build_context_synchronously

# Optional: riverpod_lint 3.1.9 uses the new analysis_server_plugin system (no custom_lint).
# plugins:
#   riverpod_lint: ^3.1.9
```

- **`riverpod_lint`** reported `missing_provider_scope` under **`dart analyze`** but **not** under `flutter analyze` **[BUILT]**. If you enable it, run `dart analyze --fatal-infos` in CI as well.
  - `riverpod_lint` 3.1.9 requires Dart `>=3.13.0-0` and `analysis_server_plugin ^0.3.0`.
  - It doesn't go in `dev_dependencies`: the `plugins:` entry is enough.
- **`very_good_analysis`** 11.0.0 (Dart ^3.13) works, but it is much stricter. The probe produced 14 infos (`document_ignores`, `always_use_package_imports`, `sort_pub_dependencies`, …). With the CLAUDE.md "0 issues" rule, start from `flutter_lints` 6.0.0 plus the rules above.
- `flutter analyze` treats infos as fatal by default (`--fatal-infos` defaults to true) **[SRC]**.

### Unit tests with mocktail + `ProviderContainer.test`

These pass **[BUILT]**:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/net/riot_http.dart';
import 'package:valvn/state/providers.dart';

class MockVault extends Mock implements SecureVault {}
class MockReauth extends Mock implements RiotReauthClient {}

void main() {
  setUpAll(() => registerFallbackValue(RiotCookieJar({})));

  late MockVault vault;
  late MockReauth reauth;

  setUp(() {
    vault = MockVault();
    reauth = MockReauth();
    when(() => vault.readCookies(any())).thenAnswer((_) async => RiotCookieJar({'ssid': 'x'}));
    when(() => vault.writeCookies(any(), any())).thenAnswer((_) async {});
  });

  ProviderContainer makeContainer() => ProviderContainer.test(   // auto-disposed after the test
        overrides: [
          vaultProvider.overrideWithValue(vault),
          reauthClientProvider.overrideWithValue(reauth),
        ],
      );

  test('session loads tokens via cookie reauth', () async {
    when(() => reauth.reauth(any())).thenAnswer(
      (_) async => ReauthOk(RiotTokens(accessToken: 'a', idToken: 'i', expiresAt: DateTime.now().add(const Duration(hours: 1)))),
    );
    final c = makeContainer();
    expect((await c.read(sessionProvider('puuid-1').future)).accessToken, 'a');
    verify(() => vault.writeCookies('puuid-1', any())).called(1);
  });

  test('dead cookies -> NeedsLoginException, no automatic retry', () async {
    when(() => reauth.reauth(any())).thenAnswer((_) async => ReauthNeedsLogin());
    final c = makeContainer();
    final sub = c.listen(sessionProvider('p'), (_, _) {});
    await expectLater(c.read(sessionProvider('p').future), throwsA(isA<NeedsLoginException>()));
    await Future<void>.delayed(const Duration(seconds: 1));
    verify(() => reauth.reauth(any())).called(1);
    expect(sub.read().error, isA<NeedsLoginException>());
  });
}
```

### Widget tests

- Pump `MaterialApp(localizationsDelegates: [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates], locale: Locale('vi'))`, wrapped in `ProviderScope(overrides: …)`.
- The §2 experiment itself is a good regression test. Assert that go_router builds `MaterialPage` and not `NoTransitionPage`.

### Golden tests (optional)

- Use `alchemist` 0.14.0 (Flutter ≥3.32). `golden_toolkit` 0.15.0 is abandoned (Dart <3).
- Goldens render with the Ahem test font unless you load the real fonts. Call `FontLoader('BeVietnamPro')..addFont(rootBundle.load('assets/fonts/BeVietnamPro-Regular.ttf'))` in `flutter_test_config.dart`.
- Run goldens on one OS only (Linux CI), because text rendering differs between platforms.

### Test pure logic without Flutter

Test these directly: cookie merging, fragment parsing, JSON mappers, and RR math. Keep them free of Flutter imports so the background isolate can reuse them.

---

## 21. Open risks and UNVERIFIED items

1. **flutter_inappwebview on a beta line.** 6.2.0-beta.3 (2026-02) plus overrides is required for AGP 9. Stable 6.1.5 does not build. Risks: beta bugs, and a future stable with different APIs. Track pichillilorenzo/flutter_inappwebview issues #2765 and #2887.
2. **Material split churn.** Flutter's November 2026 stable deprecates `package:flutter/material.dart`. Watch for:
   - fl_chart, video_player and inappwebview migrating (then remove `MaterialUiCompatibilityBridge`);
   - analyzer `deprecated_member_use` infos breaking the zero-issue rule.
3. **KGP opt-out is temporary.** `android.builtInKotlin=false` is required today because `flutter_timezone`, `home_widget` and `workmanager_android` still apply KGP. AGP 10 or a future Flutter drops the opt-out.
4. **compileSdk 37 creep.** Plugins are starting to pin `compileSdk 37` (permission_handler_android 14.1.0; flutter_secure_storage 11.0.0 did too, then reverted). Keep `platforms;android-37.0` installable in CI.
5. **iOS toolchain unverified.** None of the iOS steps could run here: SwiftPM resolution, AppDelegate code, the widget extension, and the unsigned or signed IPA jobs. Run the iOS workflow early. Signed builds using `FLUTTER_XCODE_*` break once a widget extension exists (per-target profiles).
6. **iOS background work is unreliable** by design. The wishlist alert on iOS is best-effort.
7. **iOS widget and sideloading.** App Groups need a paid Apple account. Whether AltStore or Sideloadly handle app-group entitlements for free IDs is **[UNVERIFIED]**. An extension uses extra App IDs under the free-account limits.
8. **Riot/Cloudflare may reject dart:io clients** (TLS fingerprint) with 403 on `/authorize` or the PD endpoints. My probe got a proper 303 without cookies, but cookie-bearing reauth at scale is untested. Mitigation ideas are in `riot-auth.md`.
9. **WKHTTPCookieStore propagation delay** after the callback navigation. The 300 ms delay is a heuristic **[UNVERIFIED]**.
10. **Shop reset time.** Always derive it from the storefront's remaining seconds. A fixed 00:00 UTC is **[UNVERIFIED]** for all shards.
11. **The debug-key fallback** means CI APKs built without secrets can't be upgraded by properly signed APKs (signature mismatch). Set up the keystore secret before the first public release.
12. **Riverpod 3 auto-retry** can amplify request storms if a provider forgets `retry:`. Consider a global `ProviderScope(retry: …)` that never retries auth or HTTP 4xx errors.

## 22. Sources

- Flutter 3.47.5 SDK sources: `packages/flutter_tools/gradle/src/main/kotlin/{FlutterExtension,DependencyVersionChecker,FlutterPluginConstants,FlutterPlugin,FlutterPluginUtils}.kt`, `lib/src/android/gradle_utils.dart`, `lib/src/features.dart`, `lib/src/commands/{build_ios,analyze}.dart`, `lib/src/ios/{xcodeproj,code_signing}.dart`.
- Package sources in `~/.pub-cache/hosted/pub.dev/`: flutter_inappwebview(_android/_ios/_platform_interface) 6.2.0-beta.3/1.2.0-beta.3/1.4.0-beta.3, flutter_secure_storage 11.2.0, flutter_local_notifications 22.3.1, workmanager 0.10.10 / workmanager_apple 0.9.11 / workmanager_android 0.10.9, home_widget 0.10.0, go_router 18.0.1, material_ui 1.4.0, cupertino_ui 1.1.1, riverpod 3.4.3, riverpod_lint 3.1.9, dio 5.11.1, cached_network_image 4.0.2, video_player 2.14.0, fl_chart 1.2.0, hive_ce 2.20.1, permission_handler_android 14.1.0, jni 1.0.3.
- pub.dev API (`/api/packages/<name>`) for every version listed in §0 and §3.
- [What's new in Flutter 3.47](https://flutter.dev/blog/whats-new-in-flutter-3-47) · [Flutter 3.47.0 release notes](https://docs.flutter.dev/release/release-notes/release-notes-3.47.0) · [Built-in Kotlin migration for app developers](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers) · [UIScene migration](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate) · [Flutter internationalization](https://docs.flutter.dev/ui/internationalization) · [Flutter 3.47: what actually breaks (DartWay)](https://dartway.dev/blog/flutter-3-47-what-breaks)
- flutter_inappwebview issues [#2887](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2887), [#2765](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2765) · flutter_secure_storage issue [#1224](https://github.com/juliansteenbakker/flutter_secure_storage/issues/1224)
- [Riverpod 3.0 what's new](https://riverpod.dev/docs/whats_new) · [workmanager quickstart](https://docs.page/fluttercommunity/flutter_workmanager/quickstart) · [home_widget iOS setup](https://docs.page/ABausG/home_widget/setup/ios)
- [actions/runner-images README](https://github.com/actions/runner-images) + `images/macos/macos-26-arm64-Readme.md` + `images/ubuntu/Ubuntu2404-Readme.md` · issues [#14167 (macos-latest → 26)](https://github.com/actions/runner-images/issues/14167), [#14344 (Xcode 26.6 default)](https://github.com/actions/runner-images/issues/14344), [#14404 (Xcode 27 preview)](https://github.com/actions/runner-images/issues/14404)
- [AltStore FAQ: App IDs](https://faq.altstore.io/altstore-classic/app-ids)
- Google Fonts repo `ofl/bevietnampro`, `ofl/anton` (+ METADATA.pb subsets) · Google Maven `com.android.tools:desugar_jdk_libs` metadata
- Reference Flutter Valorant app: github.com/Fantsry/store-checkerval (pubspec, gradle config)
- Live requests: `valorant-api.com/v1/version`, `/v1/weapons/skins?language=vi-VN` (+ other endpoints), `auth.riotgames.com/authorize?prompt=none` via dio, `valorant.dyn.riotcdn.net` video HEAD.
