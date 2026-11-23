import SwiftUI

struct SideMenuDrawerView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var themeManager: TechThemeManager
    @Binding var isOpen: Bool
    @Binding var activePage: String
    @Binding var activeCategory: String?
    @Binding var showAboutDialog: Bool
    @Binding var showUpdateDialog: Bool
    @Binding var showThemeDialog: Bool
    @Binding var showCallerIdDialog: Bool
    let onOpenModal: (DashboardModalType) -> Void

    var body: some View {
        ZStack(alignment: .leading) {
            // Scrim dimming background
            if isOpen {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isOpen = false
                        }
                    }
            }

            // Drawer Sheet
            if isOpen {
                VStack(alignment: .leading, spacing: 0) {
                    // Header with Logo and Officer Details
                    if let officer = store.session?.officer {
                        HStack(spacing: 12) {
                            Image("TechnocopLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 58, height: 58)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1.5))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("TECHNOCOP")
                                    .font(.system(size: 18 * themeManager.fontScale, weight: .bold))
                                    .foregroundColor(.white)

                                Text("PTB in your fingertips")
                                    .font(.system(size: 11 * themeManager.fontScale, weight: .semibold))
                                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))

                                Spacer().frame(height: 2)

                                Text(officer.name)
                                    .font(.system(size: 13.5 * themeManager.fontScale, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                let meta = [
                                    officer.rank,
                                    !officer.batch.isEmpty ? "Batch \(officer.batch)" : nil
                                ].compactMap { $0 }.joined(separator: " • ")

                                if !meta.isEmpty {
                                    Text(meta)
                                        .font(.system(size: 11 * themeManager.fontScale))
                                        .foregroundColor(Color.white.opacity(0.8))
                                        .lineLimit(1)
                                }

                                Text(officer.mobile)
                                    .font(.system(size: 11 * themeManager.fontScale))
                                    .foregroundColor(Color.white.opacity(0.8))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [themeManager.primaryColor, themeManager.accentColor]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    }

                    // Scrollable Drawer Menu
                    ScrollView {
                        VStack(alignment: .leading, spacing: 2) {
                            // 1. Dashboard
                            drawerItem(title: "Dashboard", icon: "square.grid.2x2.fill", isSelected: activePage == "home" && activeCategory == nil) {
                                activePage = "home"
                                activeCategory = nil
                                closeDrawer()
                            }

                            // 2. Profile
                            drawerItem(title: "Profile", icon: "person.crop.circle.fill", isSelected: activePage == "profile") {
                                activePage = "profile"
                                closeDrawer()
                            }

                            // 3. Favourite Contacts
                            drawerItem(title: "Favourite Contacts (\(store.favoriteNumbers.count))", icon: "heart.fill", iconColor: Color(red: 0.88, green: 0.11, blue: 0.28), isSelected: activePage == "home" && activeCategory == "favourites") {
                                activePage = "home"
                                activeCategory = "favourites"
                                closeDrawer()
                            }

                            // 4. Tech-Knowledge Base
                            drawerItem(title: "Tech-Knowledge Base", icon: "book.fill", iconColor: Color(red: 0.22, green: 0.74, blue: 0.97), isSelected: activePage == "home" && activeCategory == "knowledge") {
                                activePage = "home"
                                activeCategory = "knowledge"
                                closeDrawer()
                            }

                            // 5. Daily TECHNOCOP Digest
                            drawerItem(title: "Daily TECHNOCOP Digest", icon: "newspaper.fill", iconColor: Color(red: 1.0, green: 0.84, blue: 0.0)) {
                                closeDrawer()
                                onOpenModal(.digest)
                            }

                            // 6. Special Days Calendar
                            drawerItem(title: "Special Days Calendar", icon: "party.popper.fill", iconColor: Color(red: 1.0, green: 0.84, blue: 0.0)) {
                                closeDrawer()
                                onOpenModal(.specialDays)
                            }

                            // 7. Display & Theme
                            drawerItem(title: "Display & Theme", icon: "paintpalette.fill") {
                                closeDrawer()
                                showThemeDialog = true
                            }

                            // 8. App Update
                            drawerItem(title: "App Update", icon: "arrow.triangle.2.circlepath") {
                                closeDrawer()
                                showUpdateDialog = true
                                Task { await store.checkForAppUpdate() }
                            }

                            // 9. Smart Caller ID
                            drawerItem(title: "Smart Caller ID (Active)", icon: "phone.fill") {
                                closeDrawer()
                                showCallerIdDialog = true
                            }

                            // 10. About
                            drawerItem(title: "About", icon: "info.circle.fill") {
                                closeDrawer()
                                showAboutDialog = true
                            }

                            // 11. Close directory / Logout
                            drawerItem(title: "Close directory", icon: "rectangle.portrait.and.arrow.right", isDestructive: true) {
                                closeDrawer()
                                Task { await store.signOut() }
                            }

                            Divider()
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)

                            // EMPLOYEE SERVICES Section
                            Text("EMPLOYEE SERVICES")
                                .font(.system(size: 11 * themeManager.fontScale, weight: .bold))
                                .foregroundColor(themeManager.accentColor)
                                .tracking(1)
                                .padding(.leading, 18)
                                .padding(.vertical, 4)

                            // 12. My Unit
                            drawerItem(title: "My Unit", icon: "building.2.fill", isSelected: activePage == "home" && activeCategory == "my_unit") {
                                activePage = "home"
                                activeCategory = "my_unit"
                                closeDrawer()
                            }

                            // 13. Employee Directory
                            drawerItem(title: "Employee Directory", icon: "person.3.fill", isSelected: activePage == "home" && activeCategory == "directory") {
                                activePage = "home"
                                activeCategory = "directory"
                                closeDrawer()
                            }

                            // 14. Favourite Contacts
                            drawerItem(title: "Favourite Contacts", icon: "heart.fill", iconColor: Color(red: 0.88, green: 0.11, blue: 0.28), isSelected: activePage == "home" && activeCategory == "favourites") {
                                activePage = "home"
                                activeCategory = "favourites"
                                closeDrawer()
                            }

                            // 15. Search
                            drawerItem(title: "Search", icon: "magnifyingglass", isSelected: activePage == "home" && activeCategory == "search") {
                                activePage = "home"
                                activeCategory = "search"
                                closeDrawer()
                            }

                            // 16. My Organization
                            drawerItem(title: "My Organization", icon: "building.columns.fill", isSelected: activePage == "home" && activeCategory == "organization") {
                                activePage = "home"
                                activeCategory = "organization"
                                closeDrawer()
                            }

                            // 17. Retirement Forecast
                            drawerItem(title: "Retirement Forecast", icon: "calendar", isSelected: activePage == "home" && activeCategory == "retirement") {
                                activePage = "home"
                                activeCategory = "retirement"
                                closeDrawer()
                            }

                            // 18. Birthday Wishes
                            drawerItem(title: "Birthday Wishes", icon: "gift.fill") {
                                closeDrawer()
                                onOpenModal(.birthdays)
                            }

                            // 19. Official Announcements
                            drawerItem(title: "Official Announcements", icon: "megaphone.fill") {
                                closeDrawer()
                                onOpenModal(.announcements)
                            }

                            // 20. Daily TechnoCop Digest
                            drawerItem(title: "Daily TechnoCop Digest", icon: "doc.text.fill") {
                                closeDrawer()
                                onOpenModal(.digest)
                            }
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 24)
                    }

                    Spacer()
                }
                .frame(width: 295)
                .background(themeManager.surfaceColor)
                .ignoresSafeArea(edges: .vertical)
                .transition(.move(edge: .leading))
            }
        }
    }

    private func drawerItem(
        title: String,
        icon: String,
        iconColor: Color? = nil,
        isSelected: Bool = false,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isDestructive ? Color.red : (iconColor ?? (isSelected ? themeManager.primaryColor : themeManager.secondaryTextColor)))
                    .frame(width: 22)

                Text(title)
                    .font(.system(size: 14 * themeManager.fontScale, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isDestructive ? Color.red : (isSelected ? themeManager.primaryColor : themeManager.primaryTextColor))

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(isSelected ? themeManager.lavenderWashColor : Color.clear)
            .cornerRadius(8)
            .padding(.horizontal, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func closeDrawer() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isOpen = false
        }
    }
}
