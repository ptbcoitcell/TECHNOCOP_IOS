# TECHNOCOP Android app

## Current preview mode

The Android app now opens the dashboard after the logo welcome screen. The main page has three collapsible sections in order: `Dashboard`, `Contacts`, and `Search`. Dashboard displays strength summaries; Contacts shows the grouped directory; Search contains the Unit and Categ filters plus name, rank, or unit search. Contacts are grouped under collapsible `PTB Hqrs`, `Districts`, `Cities`, `Repeaters`, and `Special units` sections. Districts expand by Zone, Range, and Unit. Officers within each unit and Search results are sorted by Batch in ascending numeric order, then by rank and name. Compact alternating cards show name, rank, unit, batch, and mobile, with dialer and WhatsApp actions for valid mobile numbers. Contacts tagged `IT Cell` show a gold `IT` badge. Serial numbers and table column headings are removed. The launcher uses the Tamil Nadu Police emblem and the app label `TECHNOCOP`. This preview is read-only: profile editing and password changes are not available in the app.

**Public-data warning:** The Apps Script web app is deployed with access set to Anyone. Its public read-only actions return officer names, ranks, unit/category values, and mobile numbers to anyone who can reach the endpoint. Do not distribute this APK or endpoint outside the intended audience. Anyone access has been enabled at the user's direction for this preview. Restrict access again before production use.

## Live backend

- Spreadsheet ID: `1sntQHUE8hpwjOykfgJrKMWbBQfSBZKVFi18Wbwct9S4`
- Roster worksheet: `Sheet1`
- Current roster columns A–H: SI No, Unit, Rank, Unit_Categ, Name of the Officer, Mobile Numbers, Batch, Remarks (OD details).
- Apps Script project: `TECHNOCOP`, bound to the spreadsheet.
- Deployment: publish the updated source as a new version of the existing web app; Execute as the spreadsheet owner; access: Anyone.
- Public API actions used by the app: `publicDashboard`, `publicContacts`, and `publicAppUpdate`. The contacts response includes the Unit and Unit_Categ filter values and officer records.
- In-app updates: `App Update` in the navigation drawer checks the published version, downloads its APK, then opens Android's package installer. Android always asks the user to confirm installation; sideloaded apps cannot silently install updates.
- One-time transition: the older APK has no update checker, so install/share this version 2.1 APK to each friend once using the usual method. After that, future releases can be checked from **App Update**.
- Publish an update: build a signed APK with the same signing key as the APK already installed on recipients' phones; upload it to a trusted HTTPS host with direct APK downloads enabled; then in the spreadsheet reload the page and choose **TECHNOCOP Admin → Publish app update**. Enter the APK's version code, version name, and public direct download URL. The app checks `APP_VERSION_CODE`, `APP_VERSION_NAME`, and `APP_DOWNLOAD_URL` stored in Apps Script properties.
- APK signing matters: a new APK signed with a different key cannot update the old installation in place. Recipients would need to uninstall the old app first, which removes app-local data.
- The API endpoint is set in `app/build.gradle.kts` as `API_URL`.

The app read timeout is 90 seconds because recent Apps Script requests took 18-33 seconds. District contacts follow the spreadsheet's Zone and Range fields; City, Repeater, and PTB Hqrs entries are separated into their own groups, and unmatched non-district entries appear under Special units. The type filter matches Communication unit values containing `comm`/`comn`, and IT cell values containing `IT Cell`.

## Backend setup

The existing live Apps Script deployment must be updated to the latest source before the app's update checker can work. Bind the script to the spreadsheet and use `backend/Code.gs`; then deploy a new version of the existing web app deployment (execute as the spreadsheet owner, access Anyone) so `publicAppUpdate` is available. The public read-only dashboard, contacts, and update-check actions do not require login. The older credential, profile-edit, and password API handlers remain in the script but are not exposed in this app's navigation. Do not run account setup or distribute the API URL without administrative approval.

## Build and run

1. In Android Studio, open the extracted `TechnocopAndroid` **folder**, not the ZIP file.
2. Let Gradle sync finish. Install Android SDK Platform 35 and Android SDK Build-Tools 36.0.0 if Android Studio requests them.
3. Choose **Build → Build Bundle(s) / APK(s) → Build APK(s)**. This release is version 3.0 (version code 21).
4. Install the resulting debug APK from `app/build/outputs/apk/debug/app-debug.apk` on an Android 6+ device. Internet access is required to load the live dashboard and contacts.

Project uses Android Gradle Plugin 9.4.1, Gradle 9.6.0, Kotlin 2.2.10, minSdk 23, targetSdk 35.

## Limitations

- This is a public, read-only preview; there is no sign-in, role-based access, or profile editing in the app.
- Google Sheets and Apps Script are not a high-assurance production backend. Public endpoints and phone-number data require careful distribution controls.
- Dashboard counts, category strength, officer lists, and contacts are cached in encrypted app-private files using an AES-GCM key held by Android Keystore. The app loads the last saved data first, then refreshes it from Google Sheets. If the request fails, it keeps showing cached data and its last successful refresh time. The cache is removed when the app is uninstalled or its storage is cleared; background synchronization is not provided.
- Do not use this preview for production police operations without an organization-managed identity provider, access-controlled backend, audit logs, and a security review.
