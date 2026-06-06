# Transport Manager — Flutter + Firebase App

A complete transport management system for drivers and admins, inspired by the provided UI mockup.

---

## 📱 App Features

### Drivers
- Login/Register with role selection
- Dashboard with personal statistics
- Create transport records with all fields
- View personal history with search
- Edit or delete own records

### Admin
- Full dashboard with global statistics:
  - Total deliveries, clients, fuel consumption
  - Pending vouchers (Bons en attente)
  - Pending palettes
- Browse ALL transport records
- Search by destination, client, driver name
- Filter by: Client / Destination / Driver / Date range
- View records grouped by client
- Drill into any record's details

---

## 🗂 Project Structure

```
transport_app/
├── lib/
│   ├── main.dart               # Entry point
│   ├── app.dart                # Root widget + auth routing
│   ├── firebase_options.dart   # Firebase config (replace values)
│   ├── models/
│   │   ├── app_user.dart
│   │   └── transport_record.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── auth_provider.dart
│   │   └── transport_service.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── driver/
│   │   │   ├── driver_dashboard.dart
│   │   │   ├── add_record_screen.dart
│   │   │   ├── driver_history_screen.dart
│   │   │   └── record_detail_screen.dart
│   │   └── admin/
│   │       ├── admin_dashboard.dart
│   │       ├── admin_records_screen.dart
│   │       └── admin_clients_screen.dart
│   ├── widgets/
│   │   ├── stat_card.dart
│   │   └── record_tile.dart
│   └── utils/
│       └── app_theme.dart
├── android/
│   └── app/src/main/AndroidManifest.xml
├── firestore.rules
├── firestore.indexes.json
└── pubspec.yaml
```

---

## 🔥 Firestore Data Structure

```
firestore/
├── users/
│   └── {uid}/
│       ├── uid: string
│       ├── email: string
│       ├── name: string
│       ├── role: "admin" | "driver"
│       └── createdAt: ISO string
│
└── transport_records/
    └── {recordId}/
        ├── driverId: string
        ├── driverName: string
        ├── date: Timestamp
        ├── destination: string
        ├── client: string
        ├── mazotStatus: "nouveauPlein" | "enPlein"
        ├── bonStatus: "enAttente" | "remis"
        ├── paletteStatus: "rendue" | "enAttente"
        ├── fuelConsumption: number
        ├── notes: string
        └── createdAt: Timestamp
```

---

## ⚙️ Firebase Setup

### Step 1 — Create Firebase Project
1. Go to [https://console.firebase.google.com](https://console.firebase.google.com)
2. Click **Add project** → name it (e.g. `transport-manager`)
3. Disable Google Analytics (optional) → **Create project**

### Step 2 — Enable Authentication
1. In Firebase Console: **Build → Authentication → Get started**
2. Click **Email/Password** → Enable it → **Save**

### Step 3 — Create Firestore Database
1. **Build → Firestore Database → Create database**
2. Choose **Start in production mode** → pick your region → **Enable**
3. Go to **Rules** tab → paste contents of `firestore.rules` → **Publish**

### Step 4 — Create Indexes
1. In Firestore, go to **Indexes** tab
2. Click the three dots → **Import indexes**
3. Paste contents of `firestore.indexes.json`
   — OR — let them auto-create on first query (Firestore will prompt you)

### Step 5 — Register Android App
1. In Firebase Console: **Project Overview → Add app → Android**
2. Package name: `com.yourcompany.transportapp`
   (match what you'll use in `build.gradle`)
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`

---

## 💻 Flutter Setup

### Prerequisites
```bash
# Install Flutter SDK (3.16+)
https://docs.flutter.dev/get-started/install

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Install Firebase CLI
npm install -g firebase-tools
firebase login
```

### Configure Firebase (Automatic - Recommended)
```bash
cd transport_app
flutter pub get

# This auto-generates firebase_options.dart
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```
This replaces the placeholder `firebase_options.dart`.

### Configure Firebase (Manual)
Edit `lib/firebase_options.dart` and replace all placeholder values with your actual Firebase config from:
**Firebase Console → Project Settings → Your apps → SDK setup and configuration**

---

## 🏗️ Build Instructions

### Debug APK (for testing)
```bash
cd transport_app
flutter pub get
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK
```bash
# 1. Create a keystore (first time only)
keytool -genkey -v -keystore android/app/transport-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias transport

# 2. Create android/key.properties
echo "storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=transport
storeFile=transport-key.jks" > android/key.properties

# 3. Update android/app/build.gradle to use the keystore
#    (See signing section below)

# 4. Build release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Or build App Bundle for Play Store
flutter build appbundle --release
```

### android/app/build.gradle signing config to add:
```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## 🚀 Running the App

```bash
# Connect an Android device or start emulator
flutter devices

# Run in debug mode
flutter run

# Run on specific device
flutter run -d DEVICE_ID
```

---

## 👤 Creating First Admin Account

After the app is running:
1. Open the app → tap **S'inscrire**
2. Fill in name, email, password
3. Select **Admin** role
4. Register — you'll be logged in as admin

To promote an existing driver to admin:
- In Firebase Console → Firestore → `users` → find the document → change `role` to `"admin"`

---

## 🛠 Dependencies Used

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase initialization |
| `firebase_auth` | Authentication |
| `cloud_firestore` | Database |
| `provider` | State management |
| `google_fonts` | Typography (Poppins) |
| `intl` | Date formatting (French locale) |
| `fl_chart` | Charts (future use) |
| `shimmer` | Loading states |
| `uuid` | Unique ID generation |

---

## 🎨 Design Notes

- Color scheme: Deep navy (`#0D2B45`) + teal (`#1A7A8A`) + orange accent (`#E07B30`)
- Font: Poppins (Google Fonts)
- Material 3 design system
- Responsive cards with subtle shadows
- Bottom navigation for main sections
- Modal filter sheet for admin search

---

## 📋 Troubleshooting

**`google-services.json` not found**
→ Download from Firebase Console → place in `android/app/`

**Firestore permission denied**
→ Check `firestore.rules` is published correctly in Firebase Console

**Build fails on minSdkVersion**
→ In `android/app/build.gradle`, set `minSdkVersion 21`

**`flutterfire configure` not found**
→ Run `dart pub global activate flutterfire_cli` and ensure `~/.pub-cache/bin` is in PATH
