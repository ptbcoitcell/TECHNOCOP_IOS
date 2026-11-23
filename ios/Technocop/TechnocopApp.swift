import SwiftUI

@main
struct TechnocopApp: App {
    @StateObject private var store = AppStore()
    @StateObject private var themeManager = TechThemeManager()

    var body: some Scene {
        WindowGroup {
            RootContentView()
                .environmentObject(store)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.preferredColorScheme)
                .task {
                    await store.restoreSession()
                }
        }
    }
}

// MARK: - AppStore State Management

@MainActor
final class AppStore: ObservableObject {
    @Published var session: UserSession?
    @Published var contacts: [Contact] = []
    @Published var units: [String] = []
    @Published var unitCategories: [String] = []
    @Published var dashboardData: DashboardCounts?
    @Published var birthdayData: BirthdayFeed?
    @Published var dashboardContent: DashboardContent?
    @Published var retirementForecast: RetirementForecast?
    @Published var favoriteNumbers: Set<String> = []
    @Published var lastRefreshedAt: Date?

    @Published var page: String = "home"
    @Published var dashboardCategory: String? = nil
    @Published var activeModal: DashboardModalType? = nil

    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var isRestoring = true
    @Published var errorMessage = ""
    @Published var offlineMessage = ""
    @Published var dashboardError = ""
    @Published var contactsError = ""

    // Dialog & Popup triggers matching Android
    @Published var showBirthdayGreetings = false
    @Published var broadcastPopupAnnouncement: Announcement? = nil
    @Published var autoUpdateAvailable: AppUpdate? = nil
    @Published var isCheckingUpdate = false
    @Published var appUpdateInfo: AppUpdate? = nil

    private let api = APIClient()
    private let keychain = SessionKeychain()
    private let cache = SecureLocalCache.shared
    private var refreshTimerTask: Task<Void, Never>? = nil

    // MARK: - Restore Session

    func restoreSession() async {
        isRestoring = true
        defer { isRestoring = false }

        // 1. Immediately load local secure caches
        if let cachedSession = await cache.loadSession() {
            session = cachedSession
        }
        if let cachedDashboard = await cache.loadDashboard() {
            dashboardData = cachedDashboard.value
            lastRefreshedAt = cachedDashboard.savedAt
        }
        if let cachedContacts = await cache.loadContacts() {
            contacts = cachedContacts.value.contacts
            units = cachedContacts.value.units
            unitCategories = cachedContacts.value.unitCategories
            lastRefreshedAt = cachedContacts.savedAt
        }
        if let cachedBirthdays = await cache.loadBirthdays() {
            birthdayData = cachedBirthdays.value
        }
        if let cachedContent = await cache.loadContent() {
            var val = cachedContent.value
            let deletedIds = Set(UserDefaults.standard.stringArray(forKey: "technocop_deleted_announcements") ?? [])
            val.announcements.items.removeAll { deletedIds.contains($0.id) }
            dashboardContent = val
        }
        if let cachedRetirement = await cache.loadRetirement() {
            retirementForecast = cachedRetirement.value
        }
        favoriteNumbers = await cache.loadFavorites()

        // 2. Check Keychain token
        guard let savedRememberToken = keychain.read(), !savedRememberToken.isEmpty else {
            return
        }

        // 3. Renew session with Apps Script backend
        do {
            let renewed = try await api.resume(rememberToken: savedRememberToken)
            session = renewed
            keychain.save(renewed.rememberToken)
            await cache.saveSession(renewed)
            startPeriodicRefresh()
            await refreshData()
        } catch {
            let desc = error.localizedDescription.lowercased()
            if desc.contains("expired") || desc.contains("unsupported") {
                keychain.clear()
                await cache.clearSession()
                session = nil
                errorMessage = "Sign in again to reconnect your account."
            } else if session != nil {
                offlineMessage = "Network unavailable. Showing saved data."
            }
        }
    }

    // MARK: - Sign In

    func signIn(mobile: String, password: String) async {
        isLoading = true
        errorMessage = ""
        offlineMessage = ""
        defer { isLoading = false }

        do {
            let signedIn = try await api.login(mobile: mobile, password: password)
            session = signedIn
            if !signedIn.rememberToken.isEmpty {
                keychain.save(signedIn.rememberToken)
            }
            await cache.saveSession(signedIn)
            startPeriodicRefresh()
            await refreshData()
        } catch {
            let desc = error.localizedDescription
            if isOfflineError(error) {
                errorMessage = "Network is unavailable. Please check your connection."
            } else if desc.contains("Too many attempts") {
                errorMessage = "Too many attempts. Try again later."
            } else {
                errorMessage = "Unable to sign in. Please try again."
            }
        }
    }

    // MARK: - Sign Out

    func signOut() async {
        refreshTimerTask?.cancel()
        refreshTimerTask = nil

        let current = session
        session = nil
        contacts = []
        units = []
        unitCategories = []
        dashboardData = nil
        birthdayData = nil
        dashboardContent = nil
        retirementForecast = nil
        lastRefreshedAt = nil
        offlineMessage = ""
        errorMessage = ""
        page = "home"
        dashboardCategory = nil
        activeModal = nil

        keychain.clear()
        await cache.clearSession()

        if let cur = current {
            await api.logout(token: cur.token, rememberToken: cur.rememberToken)
        }
    }

    // MARK: - Refresh Data

    func refreshData() async {
        guard let currentSession = session else { return }
        isRefreshing = true
        offlineMessage = ""
        dashboardError = ""
        contactsError = ""
        defer { isRefreshing = false }

        let userMobile = currentSession.officer.mobile

        async let fetchDashboard = api.dashboard(token: currentSession.token)
        async let fetchContacts = api.contacts()
        async let fetchBirthdays = api.birthdays(token: currentSession.token, mobile: userMobile)
        async let fetchContent = api.dashboardContent(token: currentSession.token)
        async let fetchRetirement = api.retirementForecast(token: currentSession.token)

        do {
            let dash = try await fetchDashboard
            dashboardData = dash
            await cache.saveDashboard(dash)
        } catch {
            dashboardError = "Dashboard details unavailable."
        }

        do {
            let dir = try await fetchContacts
            contacts = dir.contacts
            units = dir.units
            unitCategories = dir.unitCategories
            await cache.saveContacts(dir)
        } catch {
            contactsError = "Contacts directory unavailable."
        }

        do {
            let bdays = try await fetchBirthdays
            birthdayData = bdays
            await cache.saveBirthdays(bdays)
            evaluateBirthdayPopup(bdays)
        } catch { }

        do {
            var cont = try await fetchContent
            let deletedIds = Set(UserDefaults.standard.stringArray(forKey: "technocop_deleted_announcements") ?? [])
            cont.announcements.items.removeAll { deletedIds.contains($0.id) }
            dashboardContent = cont
            await cache.saveContent(cont)
            evaluateBroadcastPopup(cont)
        } catch { }

        do {
            let ret = try await fetchRetirement
            let enriched = enrichRetirementForecast(forecast: ret, contacts: contacts)
            retirementForecast = enriched
            await cache.saveRetirement(enriched)
        } catch {
            if !contacts.isEmpty {
                let computed = computeRetirementForecastFromContacts(contacts)
                retirementForecast = computed
                await cache.saveRetirement(computed)
            }
        }

        lastRefreshedAt = Date()
    }

    private func startPeriodicRefresh() {
        refreshTimerTask?.cancel()
        refreshTimerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5 * 60 * 1_000_000_000) // 5 minutes
                guard let self else { break }
                await self.refreshData()
            }
        }
    }

    // MARK: - Popups & Dialogs Evaluation

    private func evaluateBirthdayPopup(_ feed: BirthdayFeed) {
        guard !feed.birthdays.isEmpty else { return }
        let todayStr = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let lastShown = UserDefaults.standard.string(forKey: "last_birthday_popup_date")
        if lastShown != todayStr {
            showBirthdayGreetings = true
            UserDefaults.standard.set(todayStr, forKey: "last_birthday_popup_date")
        }
    }

    private func evaluateBroadcastPopup(_ content: DashboardContent) {
        guard let officer = session?.officer else { return }
        let announcements = content.announcements.items
        for ann in announcements {
            let isUrgent = ann.priority.localizedCaseInsensitiveContains("URGENT") || ann.priority.localizedCaseInsensitiveContains("HIGH")
            if isUrgent && matchesBroadcastAudience(ann.targetGroup, officer) {
                let seenKey = "seen_broadcast_\(ann.id)"
                if !UserDefaults.standard.bool(forKey: seenKey) {
                    broadcastPopupAnnouncement = ann
                    UserDefaults.standard.set(true, forKey: seenKey)
                    break
                }
            }
        }
    }

    func dismissBirthdayPopup() {
        showBirthdayGreetings = false
    }

    func dismissBroadcastPopup() {
        broadcastPopupAnnouncement = nil
    }

    func selectCategory(_ category: String) {
        dashboardCategory = category
    }

    func navigateToPage(_ p: String) {
        page = p
    }

    func openModal(_ modal: DashboardModalType) {
        activeModal = modal
    }

    // MARK: - Favorites

    func toggleFavorite(_ contact: Contact) {
        toggleFavorite(contact.mobile)
    }

    func toggleFavorite(_ mobile: String) {
        let clean = mobile.filter { $0.isNumber }
        let key = String(clean.suffix(10))
        guard !key.isEmpty else { return }
        if favoriteNumbers.contains(key) {
            favoriteNumbers.remove(key)
        } else {
            favoriteNumbers.insert(key)
        }
        Task {
            await cache.saveFavorites(favoriteNumbers)
        }
    }

    // MARK: - Profile

    func loadProfileOptions() async throws -> ProfileOptions {
        guard let cur = session else { throw APIError.message("Please sign in again.") }
        return try await api.profileOptions(token: cur.token)
    }

    func updateProfile(_ officer: Officer) async throws {
        guard let cur = session else { throw APIError.message("Please sign in again.") }
        let updated = try await api.updateProfile(token: cur.token, officer: officer)
        let newSession = cur.replacingOfficer(updated)
        session = newSession
        await cache.saveSession(newSession)
        await refreshData()
    }

    // MARK: - App Update

    func checkForAppUpdate() async {
        isCheckingUpdate = true
        appUpdateInfo = nil
        defer { isCheckingUpdate = false }

        do {
            appUpdateInfo = try await api.latestRelease()
        } catch {
            appUpdateInfo = nil
        }
    }

    // MARK: - Post / Edit / Delete Announcement

    func postAnnouncement(title: String, message: String, priority: String, targetGroup: String, url: String, completion: @escaping () -> Void) {
        guard let cur = session else { return }
        Task {
            _ = try? await api.createAnnouncement(
                token: cur.token,
                title: title,
                message: message,
                priority: priority,
                targetGroup: targetGroup,
                url: url
            )
            await refreshData()
            completion()
        }
    }

    func updateAnnouncement(originalItem: Announcement, title: String, message: String, priority: String, targetGroup: String, url: String, completion: @escaping () -> Void) {
        guard let cur = session else { return }
        Task {
            _ = try? await api.updateAnnouncement(
                token: cur.token,
                originalTitle: originalItem.title,
                title: title,
                message: message,
                priority: priority,
                targetGroup: targetGroup,
                url: url
            )
            // Immediately update locally in memory & persistent cache
            let updatedItem = ContentItem(
                title: title,
                body: message,
                date: originalItem.date.isEmpty ? "Updated" : originalItem.date,
                priority: priority,
                url: url,
                targetGroup: targetGroup
            )
            if var content = self.dashboardContent {
                if let idx = content.announcements.items.firstIndex(where: { $0.id == originalItem.id }) {
                    content.announcements.items[idx] = updatedItem
                } else {
                    content.announcements.items.insert(updatedItem, at: 0)
                }
                self.dashboardContent = content
                await self.cache.saveContent(content)
            }
            completion()
        }
    }

    func deleteAnnouncement(item: Announcement, completion: @escaping () -> Void) {
        guard let cur = session else { return }
        Task {
            _ = try? await api.deleteAnnouncement(
                token: cur.token,
                title: item.title,
                date: item.date,
                priority: item.priority
            )
            // Save to persistent blacklist so it never reappears even after refresh
            var deletedIds = UserDefaults.standard.stringArray(forKey: "technocop_deleted_announcements") ?? []
            if !deletedIds.contains(item.id) {
                deletedIds.append(item.id)
                UserDefaults.standard.set(deletedIds, forKey: "technocop_deleted_announcements")
            }
            // Immediately remove from in-memory feed & persistent cache
            if var content = self.dashboardContent {
                content.announcements.items.removeAll { $0.id == item.id }
                self.dashboardContent = content
                await self.cache.saveContent(content)
            }
            completion()
        }
    }
}

// MARK: - Root View Container

struct RootContentView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var themeManager: TechThemeManager

    var body: some View {
        Group {
            if store.isRestoring {
                ZStack {
                    themeManager.primaryColor.ignoresSafeArea()
                    VStack(spacing: 12) {
                        Image("TechnocopLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        ProgressView()
                            .tint(Color.white)
                    }
                }
            } else if store.session == nil {
                LoginView()
            } else {
                MainView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: store.session?.token)
    }
}
