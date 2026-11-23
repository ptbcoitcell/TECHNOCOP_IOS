import Foundation

public struct CachedItem<T: Codable>: Codable {
    public let value: T
    public let savedAt: Date

    public init(value: T, savedAt: Date = Date()) {
        self.value = value
        self.savedAt = savedAt
    }
}

public actor SecureLocalCache {
    public static let shared = SecureLocalCache()
    private let fileManager = FileManager.default

    private var cacheDirectory: URL {
        let paths = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let dir = paths[0].appendingPathComponent("TechnocopSecureCache", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: [
                FileAttributeKey.protectionKey: FileProtectionType.complete
            ])
        }
        return dir
    }

    // MARK: - Remembered Login Session

    public func saveSession(_ session: UserSession) {
        let item = CachedItem(value: session, savedAt: Date())
        write(item, to: "session.cache")
    }

    public func loadSession() -> UserSession? {
        read(CachedItem<UserSession>.self, from: "session.cache")?.value
    }

    public func clearSession() {
        delete("session.cache")
    }

    // MARK: - Dashboard Counts

    public func saveDashboard(_ counts: DashboardCounts) {
        let item = CachedItem(value: counts, savedAt: Date())
        write(item, to: "dashboard.cache")
    }

    public func loadDashboard() -> CachedItem<DashboardCounts>? {
        read(CachedItem<DashboardCounts>.self, from: "dashboard.cache")
    }

    // MARK: - Contacts Directory

    public func saveContacts(_ directory: ContactDirectory) {
        let item = CachedItem(value: directory, savedAt: Date())
        write(item, to: "contacts.cache")
    }

    public func loadContacts() -> CachedItem<ContactDirectory>? {
        read(CachedItem<ContactDirectory>.self, from: "contacts.cache")
    }

    // MARK: - Birthdays Cache

    public func saveBirthdays(_ feed: BirthdayFeed) {
        let item = CachedItem(value: feed, savedAt: Date())
        write(item, to: "birthdays.cache")
    }

    public func loadBirthdays() -> CachedItem<BirthdayFeed>? {
        read(CachedItem<BirthdayFeed>.self, from: "birthdays.cache")
    }

    // MARK: - Dashboard Content (Announcements & Digest)

    public func saveDashboardContent(_ content: DashboardContent) {
        let item = CachedItem(value: content, savedAt: Date())
        write(item, to: "content.cache")
    }

    public func loadDashboardContent() -> CachedItem<DashboardContent>? {
        read(CachedItem<DashboardContent>.self, from: "content.cache")
    }

    // MARK: - Retirement Forecast

    public func saveRetirementForecast(_ forecast: RetirementForecast) {
        let item = CachedItem(value: forecast, savedAt: Date())
        write(item, to: "retirement.cache")
    }

    public func loadRetirementForecast() -> CachedItem<RetirementForecast>? {
        read(CachedItem<RetirementForecast>.self, from: "retirement.cache")
    }

    // MARK: - Favourite Officer Mobiles

    public func saveFavorites(_ mobiles: [String]) {
        write(mobiles, to: "favorites.cache")
    }

    public func loadFavorites() -> [String]? {
        read([String].self, from: "favorites.cache")
    }

    // MARK: - Aliases for Dashboard Content & Retirement
    public func saveContent(_ content: DashboardContent) {
        saveDashboardContent(content)
    }

    public func loadContent() -> CachedItem<DashboardContent>? {
        loadDashboardContent()
    }

    public func saveRetirement(_ forecast: RetirementForecast) {
        saveRetirementForecast(forecast)
    }

    public func loadRetirement() -> CachedItem<RetirementForecast>? {
        loadRetirementForecast()
    }

    public func saveFavorites(_ mobiles: Set<String>) {
        write(Array(mobiles), to: "favorites.cache")
    }

    public func loadFavorites() -> Set<String> {
        Set(read([String].self, from: "favorites.cache") ?? [])
    }

    // MARK: - Generic Secure File Helpers

    private func write<T: Codable>(_ object: T, to filename: String) {
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        do {
            let data = try JSONEncoder().encode(object)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
        } catch {
            // Silently handle cache write error to protect stability
        }
    }

    private func read<T: Codable>(_ type: T.Type, from filename: String) -> T? {
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(type, from: data)
        } catch {
            return nil
        }
    }

    private func delete(_ filename: String) {
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        try? fileManager.removeItem(at: fileURL)
    }
}
