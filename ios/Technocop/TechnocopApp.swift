import SwiftUI

@main
struct TechnocopApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootContentView()
                .environmentObject(store)
                .tint(TechTheme.navy)
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
    @Published var lastRefreshedAt: Date?

    @Published var isLoading = false
    @Published var isRestoring = true
    @Published var errorMessage = ""
    @Published var offlineMessage = ""
    @Published var isCheckingUpdate = false
    @Published var appUpdateInfo: AppUpdate?

    private let api = APIClient()
    private let keychain = SessionKeychain()
    private let cache = SecureLocalCache.shared
    private var refreshTimerTask: Task<Void, Never>? = nil

    // MARK: - Restore Session

    func restoreSession() async {
        isRestoring = true
        defer { isRestoring = false }

        // 1. Immediately populate from local secure cache if available
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
                // If offline but we have cached session, remain logged in
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
        lastRefreshedAt = nil
        offlineMessage = ""
        errorMessage = ""

        keychain.clear()
        await cache.clearSession()

        if let cur = current {
            await api.logout(token: cur.token, rememberToken: cur.rememberToken)
        }
    }

    // MARK: - Data Refresh & Polling

    func refreshData() async {
        guard let currentSession = session else { return }
        offlineMessage = ""

        async let fetchDashboard = api.dashboard(token: currentSession.token)
        async let fetchContacts = api.contacts()

        do {
            let (dash, dir) = try await (fetchDashboard, fetchContacts)
            dashboardData = dash
            contacts = dir.contacts
            units = dir.units
            unitCategories = dir.unitCategories
            let now = Date()
            lastRefreshedAt = now

            await cache.saveDashboard(dash)
            await cache.saveContacts(dir)
        } catch {
            if isOfflineError(error) {
                offlineMessage = "Showing saved data."
            }
        }
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
            appUpdateInfo = try await api.appUpdate()
        } catch {
            appUpdateInfo = nil
        }
    }
}

// MARK: - Root View Container

struct RootContentView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        Group {
            if store.isRestoring {
                ZStack {
                    TechTheme.navy.ignoresSafeArea()
                    ProgressView()
                        .tint(Color.white)
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
