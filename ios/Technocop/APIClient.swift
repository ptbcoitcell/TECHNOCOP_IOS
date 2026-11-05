import Foundation

enum APIError: LocalizedError {
    case message(String)
    case unconfirmedUpdate
    case offline

    var errorDescription: String? {
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

func isOfflineError(_ error: Error) -> Bool {
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

struct APIClient {
    // Production Google Apps Script Web App Endpoint
    private let endpoint = URL(string: "https://script.google.com/macros/s/AKfycbxU3l4ekdXEzMjXuaI9bD2mVDxxyJ4R5hME0hml5rauActKRcQQ6hJ_0GWNOJKQJsVq/exec")!
    
    private var urlSession: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 45
        configuration.timeoutIntervalForResource = 60
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }

    // MARK: - Auth & Session

    func login(mobile: String, password: String) async throws -> UserSession {
        let cleanMobile = normalizeMobile(mobile)
        let result = try await post("login", ["mobile": cleanMobile, "password": password])
        guard let token = result["token"] as? String,
              let remember = result["rememberToken"] as? String else {
            throw APIError.message("Unable to sign in. Please try again.")
        }
        let officer = try decodeOfficer(result)
        return UserSession(token: token, rememberToken: remember, officer: officer)
    }

    func resume(rememberToken: String) async throws -> UserSession {
        let result = try await post("resume", ["rememberToken": rememberToken])
        guard let token = result["token"] as? String,
              let remember = result["rememberToken"] as? String else {
            throw APIError.message("Saved sign-in has expired. Sign in again.")
        }
        let officer = try decodeOfficer(result)
        return UserSession(token: token, rememberToken: remember, officer: officer)
    }

    func logout(token: String, rememberToken: String) async {
        _ = try? await post("logout", ["token": token, "rememberToken": rememberToken])
    }

    // MARK: - Dashboard & Contacts

    func dashboard(token: String) async throws -> DashboardCounts {
        let result = try await post("publicDashboard", [:])
        let data = try JSONSerialization.data(withJSONObject: result)
        let decoder = JSONDecoder()
        return try decoder.decode(DashboardCounts.self, from: data)
    }

    func contacts() async throws -> ContactDirectory {
        let result = try await post("publicContacts", [:])
        let data = try JSONSerialization.data(withJSONObject: result)
        let decoder = JSONDecoder()
        return try decoder.decode(ContactDirectory.self, from: data)
    }

    // MARK: - Profile

    func profileOptions(token: String) async throws -> ProfileOptions {
        let result = try await post("profileOptions", ["token": token])
        let data = try JSONSerialization.data(withJSONObject: result)
        return try JSONDecoder().decode(ProfileOptions.self, from: data)
    }

    func updateProfile(token: String, officer: Officer) async throws -> Officer {
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
            "doj": officer.doj.trimmingCharacters(in: .whitespacesAndNewlines)
        ]
        let result = try await post("updateProfile", fields)
        guard result["persisted"] as? Bool == true else {
            throw APIError.unconfirmedUpdate
        }
        return try decodeOfficer(result)
    }

    // MARK: - App Update

    func appUpdate() async throws -> AppUpdate {
        let result = try await post("publicAppUpdate", [:])
        let data = try JSONSerialization.data(withJSONObject: result)
        return try JSONDecoder().decode(AppUpdate.self, from: data)
    }

    // MARK: - HTTP Helper

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
