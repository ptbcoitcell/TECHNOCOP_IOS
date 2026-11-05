# TECHNOCOP for iOS (iPhone & iPad)

Native iOS client for TECHNOCOP, built in SwiftUI and fully aligned with the Android implementation and Google Apps Script backend.

## Architecture & Source of Truth

- **Source of Truth**: The Android codebase (`app/src/main/java/in/tnpolice/technocop/`) and Apps Script backend (`backend/Code.gs`).
- **Data Source**: Google Sheets via Apps Script Web App API (`https://script.google.com/macros/s/AKfycbxU3l4ekdXEzMjXuaI9bD2mVDxxyJ4R5hME0hml5rauActKRcQQ6hJ_0GWNOJKQJsVq/exec`).
- **Authentication**: 10-digit registered mobile number + password authentication. Sessions persist via `rememberToken` stored in the iOS Keychain. Passwords are never stored on device.
- **Security & Caching**: Cached roster, dashboard counts, and session state are stored using iOS Data Protection (`.completeFileProtection`), providing hardware-accelerated AES-256 encryption at rest whenever the device is locked.

## Screen Structure & Behavior

1. **Sign In**:
   - Official Tamil Nadu Police emblem and TECHNOCOP branding with tagline "PTB in your fingertips".
   - Input fields for 10-digit registered mobile number and password, with show/hide password toggle.
   - Non-technical error handling and automatic session restoration.
2. **Main Dashboard**:
   - Navy TECHNOCOP header bar showing logged-in officer name, rank, menu toggle, refresh, and home buttons.
   - Expandable sections matching Android hierarchy:
     1. **My Unit**: Shows officer's unit contacts (or Range contacts for DSP(T)).
     2. **Dashboard**:
        - Batch-wise Strength (Batch, DSP(T), Inspr(T), SI(T), Total; zeros left blank).
        - PTB Hqrs strength.
        - City-wise Strength (Avadi, Chennai, Coimbatore, Madurai, Salem, Tambaram, Tirunelveli, Tiruppur, Trichy).
        - Zone-wise Strength (Central, North, South, West).
        - Range-wise Strength (hierarchical breakdown: Zone -> Range -> District).
        - Special Unit Strength.
        - Ministerial Staff Strength (horizontal scroll with AO, Supdt, Asst, Jr.Asst, RC, Typist, OA, SB Asst, Steno Typist, Total).
     3. **Contacts**:
        - 1. Technical Officers (SP, Addl. SP, DSP, Inspector, SI)
        - 2. PTB Hqrs
        - 3. Districts (Zone -> Range -> Unit)
        - 4. Cities
        - 5. Battalion
        - 6. Repeaters
        - 7. Special units
        - 8. Ministerial Staff
        - Officer card with bold rank, phone number, yellow batch pill badge, IT badge, Phone dialer, and direct WhatsApp chat action (`wa.me`).
     4. **Search**:
        - Local reactive search with Unit and Unit_Categ dropdown filters.
        - Debounced search across Name, Rank, Unit, and Mobile.
3. **Profile & Edit Profile**:
   - Displays Name, Rank, Batch, Zone, Range, Unit, Unit_Categ, DOJ in present unit, and Mobile number.
   - Edit Profile with cascading dependent selections (Zone -> Range -> Unit -> Unit_Categ) and native DatePicker for DOJ (`dd/MM/yyyy`).
   - Verifies backend persistence confirmation (`persisted: true`).
4. **Side Menu Drawer & About**:
   - Officer summary card.
   - Navigation links to Dashboard, Profile, App Update, About, and Sign out.
   - About dialog: *"Designed and Maintained by R.A.Arulkalaiselvan SI(T) • 9445797535"*.

## Project Files (`ios/Technocop/`)

| File | Description |
|---|---|
| `TechnocopApp.swift` | App entry point and `AppStore` central state manager |
| `Models.swift` | Swift models, Codable definitions, mobile normalizer, location maps |
| `TechTheme.swift` | Brand color palette (Navy `#172657`, Saffron `#E9912A`, table & badge colors) |
| `SessionKeychain.swift` | Secure iOS Keychain wrapper for persistent `rememberToken` |
| `SecureLocalCache.swift` | Encrypted local cache with iOS Data Protection (`.completeFileProtection`) |
| `APIClient.swift` | URLSession API client for Google Apps Script backend actions |
| `Components.swift` | ExpandableSection, ContactRowView, CompactStrengthTable, BatchStrengthTable, MinisterialStrengthTable |
| `LoginView.swift` | Login screen with emblem, show-password toggle, and auth validation |
| `MainView.swift` | Main container with top header, side drawer, and 4 expandable sections |
| `DashboardSectionView.swift` | 7 dashboard strength tables matching Android rules |
| `ContactsSectionView.swift` | 8 ordered contact groups and officer cards with WhatsApp actions |
| `SearchSectionView.swift` | Unit/Category filters and debounced local roster search |
| `ProfileView.swift` | Profile details and cascading Edit Profile sheet with date picker |
| `SideMenuDrawerView.swift` | Slide-out navigation menu matching Android drawer |
| `Assets.xcassets` | AppIcon and Tamil Nadu Police emblem image set |
| `Info.plist` | iOS permissions, orientations, and URL schemes (`whatsapp`, `tel`) |
| `Technocop.xcodeproj` | Xcode 14/15/16 project file |

## Building on macOS with Xcode

> **Host Environment Notice**: The current workstation is running Windows. An iOS `.ipa` cannot be built or run on Windows because Apple developer tools (`xcodebuild`, iOS Simulator, iOS toolchain) require macOS.

To build and run the iOS app on a Mac:

1. Copy the `ios/` directory (or the entire repository) to your Mac.
2. Open `ios/Technocop.xcodeproj` in **Xcode 15 or 16**.
3. In the project navigator, select the `Technocop` project, go to the **Signing & Capabilities** tab:
   - Select your **Development Team** (e.g. your Apple Developer account or organization team).
   - Ensure Bundle Identifier is set to `in.tnpolice.technocop` (or your registered App ID).
   - Signing is left unconfigured for automatic provisioning.
4. Select an iPhone simulator (e.g., **iPhone 16 Pro**) from the target destination menu.
5. Press **Cmd + R** (or click the Run button) to build and launch in the iOS Simulator.
6. To build an IPA for ad-hoc or enterprise distribution:
   - Select **Product > Archive**.
   - In the Organizer window, click **Distribute App** and choose your provisioning profile.
