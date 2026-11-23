import SwiftUI

struct MainView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var themeManager: TechThemeManager

    @State private var isDrawerOpen = false
    @State private var showAboutDialog = false
    @State private var showUpdateDialog = false
    @State private var showThemeDialog = false
    @State private var showCallerIdDialog = false

    var body: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 0) {
                // Top Header Bar
                topHeaderBar

                // Main Content
                if store.page == "home" && store.dashboardCategory == "knowledge" {
                    KnowledgeCentreView(
                        onBack: { store.dashboardCategory = nil },
                        onOpenDigest: { store.activeModal = .digest }
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            if !store.offlineMessage.isEmpty {
                                HStack {
                                    Image(systemName: "wifi.slash")
                                        .foregroundColor(.orange)
                                    Text(store.offlineMessage)
                                        .font(.system(size: 12 * themeManager.fontScale))
                                        .foregroundColor(themeManager.primaryTextColor)
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(Color.orange.opacity(0.12))
                                .cornerRadius(8)
                            }

                            if store.page == "home" {
                                if let category = store.dashboardCategory {
                                    CategorySubscreenHeaderView(
                                        title: subscreenTitle(category),
                                        onBack: { store.dashboardCategory = nil }
                                    )

                                    switch category {
                                    case "my_unit":
                                        MyUnitSectionView()
                                    case "organization":
                                        OrganizationSectionView()
                                    case "directory":
                                        ContactsSectionView()
                                    case "favourites":
                                        FavouritesSectionView()
                                    case "search":
                                        SearchSectionView()
                                    case "retirement":
                                        RetirementSectionView(
                                            forecast: store.retirementForecast,
                                            contacts: store.contacts,
                                            onRefresh: { Task { await store.refreshData() } }
                                        )
                                    default:
                                        EmptyView()
                                    }
                                } else {
                                    ModernDashboardView()
                                }
                            } else if store.page == "profile" {
                                CategorySubscreenHeaderView(
                                    title: "Officer Profile",
                                    onBack: { store.page = "home" }
                                )
                                ProfileView()
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                    }
                    .background(themeManager.backgroundColor)
                    .refreshable {
                        await store.refreshData()
                    }
                }
            }

            // Side Menu Navigation Drawer
            SideMenuDrawerView(
                isOpen: $isDrawerOpen,
                activePage: $store.page,
                activeCategory: $store.dashboardCategory,
                showAboutDialog: $showAboutDialog,
                showUpdateDialog: $showUpdateDialog,
                showThemeDialog: $showThemeDialog,
                showCallerIdDialog: $showCallerIdDialog,
                onOpenModal: { modal in store.activeModal = modal }
            )

            // Modals & Popups Overlays
            if let activeModal = store.activeModal {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { store.activeModal = nil }

                ModalsHostView(
                    modal: activeModal,
                    birthdayData: store.birthdayData,
                    dashboardContent: store.dashboardContent,
                    retirementForecast: store.retirementForecast,
                    contacts: store.contacts,
                    currentOfficer: store.session?.officer,
                    onDismiss: { store.activeModal = nil },
                    onPostBroadcast: { title, body, priority, target, url, completion in
                        store.postAnnouncement(title: title, message: body, priority: priority, targetGroup: target, url: url, completion: completion)
                    },
                    onUpdateBroadcast: { originalItem, title, body, priority, target, url, completion in
                        store.updateAnnouncement(originalItem: originalItem, title: title, message: body, priority: priority, targetGroup: target, url: url, completion: completion)
                    },
                    onDeleteBroadcast: { item, completion in
                        store.deleteAnnouncement(item: item, completion: completion)
                    }
                )
                .transition(.scale)
            }

            if showThemeDialog {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { showThemeDialog = false }

                ThemeAndAppearanceDialog(onDismiss: { showThemeDialog = false })
                    .transition(.scale)
            }

            if showCallerIdDialog {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { showCallerIdDialog = false }

                SmartCallerIdView(
                    officer: store.session?.officer,
                    contacts: store.contacts,
                    onDismiss: { showCallerIdDialog = false }
                )
                .transition(.scale)
            }

            // Birthday Greetings Popup
            if store.showBirthdayGreetings {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)

                BirthdaysModalView(
                    birthdays: store.birthdayData?.birthdays ?? [],
                    onDismiss: { store.dismissBirthdayPopup() }
                )
            }

            // Priority Broadcast Popup
            if let ann = store.broadcastPopupAnnouncement {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "megaphone.fill")
                            .foregroundColor(Color.red)
                            .font(.system(size: 22))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Official Broadcast")
                                .font(.system(size: 16 * themeManager.fontScale, weight: .bold))
                                .foregroundColor(themeManager.primaryTextColor)
                            Text(BroadcastTarget.fromCode(ann.targetGroup).label)
                                .font(.system(size: 11 * themeManager.fontScale, weight: .semibold))
                                .foregroundColor(themeManager.accentColor)
                        }
                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(ann.title)
                            .font(.system(size: 15 * themeManager.fontScale, weight: .bold))
                            .foregroundColor(themeManager.primaryTextColor)
                        Text(ann.body)
                            .font(.system(size: 13 * themeManager.fontScale))
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    .padding(12)
                    .background(themeManager.lavenderWashColor)
                    .cornerRadius(10)

                    Button(action: { store.dismissBroadcastPopup() }) {
                        Text("Close")
                            .font(.system(size: 14 * themeManager.fontScale, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(themeManager.accentColor)
                            .cornerRadius(8)
                    }
                }
                .padding(16)
                .background(themeManager.surfaceColor)
                .cornerRadius(16)
                .padding(.horizontal, 24)
            }
        }
        .alert("About TECHNOCOP", isPresented: $showAboutDialog) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Version 3.21\nPTB in your fingertips\n\nDesigned and Maintained by\nR.A.Arulkalaiselvan SI(T)\n• 9445797535")
        }
        .alert("App Update", isPresented: $showUpdateDialog) {
            if let update = store.appUpdateInfo, update.versionCode > 42, let url = URL(string: update.downloadUrl) {
                Link("Download", destination: url)
                Button("Later", role: .cancel) { }
            } else {
                Button("OK", role: .cancel) { }
            }
        } message: {
            if store.isCheckingUpdate {
                Text("Checking for updates…")
            } else if let update = store.appUpdateInfo, update.versionCode > 42 {
                Text("Version \(update.versionName) is available.")
            } else {
                Text("You have the latest version (3.21).")
            }
        }
    }

    // MARK: - Header Bar

    private var topHeaderBar: some View {
        HStack(spacing: 8) {
            // Menu Toggle Button
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isDrawerOpen.toggle()
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
            }

            // TechnoCop Logo & Header Text
            HStack(spacing: 8) {
                Image("TechnocopLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 1) {
                    Text("TECHNOCOP")
                        .font(.system(size: 14 * themeManager.fontScale, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text("PTB in your fingertips")
                        .font(.system(size: 9.5 * themeManager.fontScale, weight: .semibold))
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                        .lineLimit(1)

                    if let officer = store.session?.officer {
                        Text("\(officer.name) • \(officer.rank)")
                            .font(.system(size: 8.5 * themeManager.fontScale))
                            .foregroundColor(Color.white.opacity(0.85))
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            // Palette Theme Action
            Button {
                showThemeDialog = true
            } label: {
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
            }

            // Refresh Action
            Button {
                Task { await store.refreshData() }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
            }

            // Home Action
            Button {
                store.page = "home"
                store.dashboardCategory = nil
            } label: {
                Image(systemName: "house.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(themeManager.primaryColor)
    }

    private func subscreenTitle(_ category: String) -> String {
        switch category {
        case "my_unit": return "My Unit"
        case "organization": return "My Organization"
        case "directory": return "Employee Directory"
        case "search": return "Search"
        case "favourites": return "Favourite Contacts"
        case "retirement": return "Retirement Forecast"
        default: return "Dashboard"
        }
    }
}

// -------------------------------------------------------------
// Category Subscreen Header View
// -------------------------------------------------------------
struct CategorySubscreenHeaderView: View {
    let title: String
    let onBack: () -> Void

    @EnvironmentObject var themeManager: TechThemeManager

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(themeManager.primaryTextColor)
                    .padding(4)
            }
            .buttonStyle(PlainButtonStyle())

            Text(title)
                .font(.system(size: 20 * themeManager.fontScale, weight: .bold))
                .foregroundColor(themeManager.primaryTextColor)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
