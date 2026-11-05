import Foundation

struct CachedItem<T: Codable>: Codable {
    let value: T
    let savedAt: Date
}

actor SecureLocalCache {
    static let shared = SecureLocalCache()
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

    func saveSession(_ session: UserSession) {
        let item = CachedItem(value: session, savedAt: Date())
        write(item, to: "session.cache")
    }

    func loadSession() -> UserSession? {
        read(CachedItem<UserSession>.self, from: "session.cache")?.value
    }

    func clearSession() {
        delete("session.cache")
    }

    // MARK: - Dashboard Counts

    func saveDashboard(_ counts: DashboardCounts) {
        let item = CachedItem(value: counts, savedAt: Date())
        write(item, to: "dashboard.cache")
    }

    func loadDashboard() -> CachedItem<DashboardCounts>? {
        read(CachedItem<DashboardCounts>.self, from: "dashboard.cache")
    }

    // MARK: - Contacts Directory

    func saveContacts(_ directory: ContactDirectory) {
        let item = CachedItem(value: directory, savedAt: Date())
        write(item, to: "contacts.cache")
    }

    func loadContacts() -> CachedItem<ContactDirectory>? {
        read(CachedItem<ContactDirectory>.self, from: "contacts.cache")
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

