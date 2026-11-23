import Foundation

public enum APIError: LocalizedError {
    case message(String)
    case unconfirmedUpdate
    case offline

    public var errorDescription: String? {
        switch self {
        case .message(let text):
            return text
        case .unconfirmedUpdate:
            return "The server did not confirm the Google Sheet update. Check that the roster is editable, then submit again."
        case .offline:
            return "Network connection unavailable."
        }
    }
}

public func isOfflineError(_ error: Error) -> Bool {
    var current: NSError? = error as NSError
    while let cause = current {
        if cause.domain == NSURLErrorDomain {
            let offlineCodes: Set<Int> = [
                URLError.notConnectedToInternet.rawValue,
                URLError.cannotFindHost.rawValue,
                URLError.dnsLookupFailed.rawValue,
                URLError.networkConnectionLost.rawValue,
                URLError.cannotConnectToHost.rawValue,
                URLError.timedOut.rawValue,
                URLError.dataNotAllowed.rawValue
            ]
            if offlineCodes.contains(cause.code) { return true }
        }
        let message = cause.localizedDescription.lowercased()
        if [
            "unable to resolve host",
            "no address associated with hostname",
            "network is unreachable",
            "internet connection appears to be offline",
            "could not connect to the server",
            "the request timed out"
        ].contains(where: { message.contains($0) }) {
            return true
        }
        current = cause.userInfo[NSUnderlyingErrorKey] as? NSError
    }
    return false
}

public struct APIClient {
    // Production Google Apps Script Web App Endpoint
    private let endpoint = URL(string: "https://script.google.com/macros/s/AKfycbxU3l4ekdXEzMjXuaI9bD2mVDxxyJ4R5hME0hml5rauActKRcQQ6hJ_0GWNOJKQJsVq/exec")!

    private var urlSession: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 45
        configuration.timeoutIntervalForResource = 60
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }

    public init() {}

    // MARK: - Auth & Session

    public func login(mobile: String, password: String) async throws -> UserSession {
        let cleanMobile = normalizeMobile(mobile)
        let result = try await post("login", ["mobile": cleanMobile, "password": password])
        guard let token = result["token"] as? String,
              let remember = result["rememberToken"] as? String else {
            throw APIError.message("Unable to sign in. Please try again.")
        }
        let officer = try decodeOfficer(result)
        return UserSession(token: token, rememberToken: remember, officer: officer)
    }

    public func resume(rememberToken: String) async throws -> UserSession {
        let result = try await post("resume", ["rememberToken": rememberToken])
        guard let token = result["token"] as? String,
              let remember = result["rememberToken"] as? String else {
            throw APIError.message("Saved sign-in has expired. Sign in again.")
        }
        let officer = try decodeOfficer(result)
        return UserSession(token: token, rememberToken: remember, officer: officer)
    }

    public func logout(token: String, rememberToken: String) async {
        _ = try? await post("logout", ["token": token, "rememberToken": rememberToken])
    }

    // MARK: - Dashboard & Contacts

    public func dashboard(token: String = "") async throws -> DashboardCounts {
        let params = token.isEmpty ? [String: String]() : ["token": token]
        let result = try await post("publicDashboard", params)
        let data = try JSONSerialization.data(withJSONObject: result)
        let decoder = JSONDecoder()
        return try decoder.decode(DashboardCounts.self, from: data)
    }

    public func contacts(token: String = "", since: Int64 = 0) async throws -> ContactDirectory {
        var params = [String: String]()
        if !token.isEmpty { params["token"] = token }
        if since > 0 { params["since"] = "\(since)" }
        let result = try await post("publicContacts", params)
        let data = try JSONSerialization.data(withJSONObject: result)
        let decoder = JSONDecoder()
        return try decoder.decode(ContactDirectory.self, from: data)
    }

    // MARK: - Profile & Password

    public func profile(token: String) async throws -> Officer {
        let result = try await post("profile", ["token": token])
        return try decodeOfficer(result)
    }

    public func profileOptions(token: String) async throws -> ProfileOptions {
        let result = try await post("profileOptions", ["token": token])
        let data = try JSONSerialization.data(withJSONObject: result)
        return try JSONDecoder().decode(ProfileOptions.self, from: data)
    }

    public func updateProfile(token: String, officer: Officer) async throws -> Officer {
        let fields: [String: String] = [
            "token": token,
            "name": officer.name.trimmingCharacters(in: .whitespacesAndNewlines),
            "rank": officer.rank.trimmingCharacters(in: .whitespacesAndNewlines),
            "mobile": normalizeMobile(officer.mobile),
            "unit": officer.unit.trimmingCharacters(in: .whitespacesAndNewlines),
            "technicalUnit": officer.technicalUnit.trimmingCharacters(in: .whitespacesAndNewlines),
            "batch": officer.batch.trimmingCharacters(in: .whitespacesAndNewlines),
            "zone": officer.zone.trimmingCharacters(in: .whitespacesAndNewlines),
            "range": officer.range.trimmingCharacters(in: .whitespacesAndNewlines),
            "doj": officer.doj.trimmingCharacters(in: .whitespacesAndNewlines),
            "ifhrmsNo": officer.ifhrmsNo.trimmingCharacters(in: .whitespacesAndNewlines),
            "dob": officer.dob.trimmingCharacters(in: .whitespacesAndNewlines),
            "doe": officer.doe.trimmingCharacters(in: .whitespacesAndNewlines),
            "dor": officer.dor.trimmingCharacters(in: .whitespacesAndNewlines)
        ]
        let result = try await post("updateProfile", fields)
        guard result["persisted"] as? Bool == true else {
            throw APIError.unconfirmedUpdate
        }
        var updated = try decodeOfficer(result)
        if !officer.ifhrmsNo.isEmpty {
            updated.ifhrmsNo = officer.ifhrmsNo
        }
        return updated
    }

    public func changePassword(token: String, old: String, new: String) async throws {
        _ = try await post("changePassword", ["token": token, "oldPassword": old, "newPassword": new])
    }

    // MARK: - Birthdays, Content & Retirements (Matching Android Api.kt)

    public func birthdays(token: String) async throws -> BirthdayFeed {
        let j = try await post("birthdays", ["token": token])
        let available = j["available"] as? Bool ?? false
        var persons: [BirthdayPerson] = []
        if let rawBirthdays = j["birthdays"] as? [[String: Any]] {
            for b in rawBirthdays {
                persons.append(BirthdayPerson(
                    name: b["name"] as? String ?? "",
                    rank: b["rank"] as? String ?? "",
                    unit: b["unit"] as? String ?? "",
                    isSelf: b["isSelf"] as? Bool ?? false,
                    mobile: b["mobile"] as? String ?? ""
                ))
            }
        }
        return BirthdayFeed(available: available, birthdays: persons)
    }

    public func dashboardContent(token: String) async throws -> DashboardContent {
        let j = try await post("dashboardContent", ["token": token])

        func parseFeed(_ key: String) -> ContentFeed {
            guard let dict = j[key] as? [String: Any] else { return ContentFeed() }
            let avail = dict["available"] as? Bool ?? false
            var items: [ContentItem] = []
            if let arr = dict["items"] as? [[String: Any]] {
                for it in arr {
                    items.append(ContentItem(
                        title: it["title"] as? String ?? "",
                        body: it["body"] as? String ?? "",
                        date: it["date"] as? String ?? "",
                        priority: it["priority"] as? String ?? "NORMAL",
                        url: it["url"] as? String ?? "",
                        targetGroup: it["targetGroup"] as? String ?? "ALL"
                    ))
                }
            }
            return ContentFeed(available: avail, items: items)
        }

        return DashboardContent(
            announcements: parseFeed("announcements"),
            digest: parseFeed("digest")
        )
    }

    public func createAnnouncement(
        token: String,
        title: String,
        message: String,
        priority: String,
        targetGroup: String,
        url: String = ""
    ) async throws -> Bool {
        let j = try await post("createAnnouncement", [
            "token": token,
            "title": title,
            "message": message,
            "priority": priority,
            "targetGroup": targetGroup,
            "url": url
        ])
        return j["ok"] as? Bool ?? true
    }

    public func retirementForecast(token: String = "") async throws -> RetirementForecast {
        let params = token.isEmpty ? [String: String]() : ["token": token]
        let j = try await post("retirementForecast", params)
        let available = j["available"] as? Bool ?? false
        var years: [RetirementYear] = []
        if let rawYears = j["years"] as? [[String: Any]] {
            for y in rawYears {
                let yr = y["year"] as? Int ?? 0
                let count = y["count"] as? Int ?? 0
                var officers: [RetirementOfficer] = []
                let rawOfficers = (y["officers"] as? [[String: Any]])
                    ?? (y["members"] as? [[String: Any]])
                    ?? (y["staff"] as? [[String: Any]])
                    ?? []
                for o in rawOfficers {
                    officers.append(RetirementOfficer(
                        name: o["name"] as? String ?? "",
                        rank: o["rank"] as? String ?? "",
                        unit: o["unit"] as? String ?? "",
                        dor: o["dor"] as? String ?? "",
                        batch: o["batch"] as? String ?? "",
                        category: o["category"] as? String ?? ""
                    ))
                }
                years.append(RetirementYear(year: yr, count: count, officers: officers))
            }
        }
        return RetirementForecast(available: available, years: years)
    }

    // MARK: - App Update Check via GitHub Releases API

    public func latestRelease(platform: String = "ios") async throws -> AppUpdate? {
        guard let url = URL(string: "https://api.github.com/repos/ptbcoitcell/TECHNOCOP-Downloads/releases?per_page=100") else { return nil }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        req.setValue("TECHNOCOP-iOS", forHTTPHeaderField: "User-Agent")
        req.timeoutInterval = 15

        let (data, resp) = try await urlSession.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            return nil
        }
        guard let releases = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return nil
        }

        let extensionTarget = ".ipa"
        for release in releases {
            if release["draft"] as? Bool == true || release["prerelease"] as? Bool == true { continue }
            guard let assets = release["assets"] as? [[String: Any]] else { continue }
            let candidate = assets.first { asset in
                let name = (asset["name"] as? String ?? "").lowercased()
                return name.hasSuffix(extensionTarget)
            } ?? assets.first // Fallback to first asset if releases share page

            guard let asset = candidate else { continue }
            let tagName = release["tag_name"] as? String ?? release["name"] as? String ?? ""
            let assetName = asset["name"] as? String ?? ""
            let downloadUrl = asset["browser_download_url"] as? String ?? ""
            let body = release["body"] as? String ?? ""

            let versionPattern = #"(?<!\d)(\d+(?:\.\d+)+)(?!\d)"#
            var version = ""
            if let range = tagName.range(of: versionPattern, options: .regularExpression) {
                version = String(tagName[range])
            } else if let range = assetName.range(of: versionPattern, options: .regularExpression) {
                version = String(assetName[range])
            }

            if !version.isEmpty && !downloadUrl.isEmpty {
                return AppUpdate(versionName: version, downloadUrl: downloadUrl, releaseNotes: body)
            }
        }
        return nil
    }

    // MARK: - HTTP Transport Helper

    private func decodeOfficer(_ json: [String: Any]) throws -> Officer {
        let data = try JSONSerialization.data(withJSONObject: json)
        return try JSONDecoder().decode(Officer.self, from: data)
    }

    private func post(_ action: String, _ fields: [String: String]) async throws -> [String: Any] {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("keep-alive", forHTTPHeaderField: "Connection")

        var body = fields
        body["action"] = action
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            if isOfflineError(error) {
                throw APIError.offline
            }
            throw APIError.message("Unable to connect to server. Please check your connection.")
        }

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw APIError.message("Unable to communicate with the server. Please try again.")
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw APIError.message("Invalid response received from server.")
        }

        if json["ok"] as? Bool != true {
            let errorMsg = json["error"] as? String ?? "Request failed."
            throw APIError.message(errorMsg)
        }

        return json
    }
}
