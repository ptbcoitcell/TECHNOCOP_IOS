import Foundation

// MARK: - Officer & Session Models

struct Officer: Codable, Equatable, Identifiable {
    var name: String
    var rank: String
    var mobile: String
    var unit: String
    var technicalUnit: String
    var batch: String
    var zone: String
    var range: String
    var doj: String

    var id: String { mobile.isEmpty ? name : mobile }

    init(
        name: String = "",
        rank: String = "",
        mobile: String = "",
        unit: String = "",
        technicalUnit: String = "",
        batch: String = "",
        zone: String = "",
        range: String = "",
        doj: String = ""
    ) {
        self.name = name
        self.rank = rank
        self.mobile = normalizeMobile(mobile)
        self.unit = unit
        self.technicalUnit = technicalUnit
        self.batch = batch
        self.zone = zone
        self.range = range
        self.doj = doj
    }

    enum CodingKeys: String, CodingKey {
        case name, rank, mobile, unit, technicalUnit, batch, zone, range, doj
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        rank = try container.decodeIfPresent(String.self, forKey: .rank) ?? ""
        
        if let rawMobile = try? container.decodeIfPresent(String.self, forKey: .mobile) {
            mobile = normalizeMobile(rawMobile)
        } else if let numMobile = try? container.decodeIfPresent(Double.self, forKey: .mobile) {
            mobile = normalizeMobile(numMobile)
        } else {
            mobile = ""
        }
        
        unit = try container.decodeIfPresent(String.self, forKey: .unit) ?? ""
        technicalUnit = try container.decodeIfPresent(String.self, forKey: .technicalUnit) ?? ""
        batch = try container.decodeIfPresent(String.self, forKey: .batch) ?? ""
        zone = try container.decodeIfPresent(String.self, forKey: .zone) ?? ""
        range = try container.decodeIfPresent(String.self, forKey: .range) ?? ""
        doj = try container.decodeIfPresent(String.self, forKey: .doj) ?? ""
    }
}

struct UserSession: Codable, Equatable {
    let token: String
    let rememberToken: String
    let officer: Officer

    func replacingOfficer(_ updatedOfficer: Officer) -> UserSession {
        UserSession(token: token, rememberToken: rememberToken, officer: updatedOfficer)
    }
}

// MARK: - Roster Contact Models

struct Contact: Codable, Identifiable, Hashable {
    let name: String
    let rank: String
    let mobile: String
    let unit: String
    let unitCategory: String
    let batch: String
    let zone: String
    let range: String

    var id: String { "\(mobile)|\(name)|\(unit)" }

    enum CodingKeys: String, CodingKey {
        case name, rank, mobile, unit, unitCategory, batch, zone, range
    }

    init(
        name: String = "",
        rank: String = "",
        mobile: String = "",
        unit: String = "",
        unitCategory: String = "",
        batch: String = "",
        zone: String = "",
        range: String = ""
    ) {
        self.name = name
        self.rank = rank
        self.mobile = normalizeMobile(mobile)
        self.unit = unit
        self.unitCategory = unitCategory
        self.batch = batch
        self.zone = zone
        self.range = range
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        rank = try container.decodeIfPresent(String.self, forKey: .rank) ?? ""
        
        if let rawMobile = try? container.decodeIfPresent(String.self, forKey: .mobile) {
            mobile = normalizeMobile(rawMobile)
        } else if let numMobile = try? container.decodeIfPresent(Double.self, forKey: .mobile) {
            mobile = normalizeMobile(numMobile)
        } else {
            mobile = ""
        }
        
        unit = try container.decodeIfPresent(String.self, forKey: .unit) ?? ""
        unitCategory = try container.decodeIfPresent(String.self, forKey: .unitCategory) ?? ""
        batch = try container.decodeIfPresent(String.self, forKey: .batch) ?? ""
        zone = try container.decodeIfPresent(String.self, forKey: .zone) ?? ""
        range = try container.decodeIfPresent(String.self, forKey: .range) ?? ""
    }
}

struct ContactDirectory: Codable {
    let contacts: [Contact]
    let units: [String]
    let unitCategories: [String]
}

// MARK: - Dashboard Counts & Hierarchy

struct TechnicalOfficer: Codable, Identifiable, Hashable {
    let name: String
    let unit: String
    let mobile: String

    var id: String { "\(name)|\(mobile)|\(unit)" }

    enum CodingKeys: String, CodingKey { case name, unit, mobile }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
        unit = try c.decodeIfPresent(String.self, forKey: .unit) ?? ""
        if let rawMobile = try? c.decodeIfPresent(String.self, forKey: .mobile) {
            mobile = normalizeMobile(rawMobile)
        } else if let numMobile = try? c.decodeIfPresent(Double.self, forKey: .mobile) {
            mobile = normalizeMobile(numMobile)
        } else {
            mobile = ""
        }
    }

    init(name: String, unit: String, mobile: String) {
        self.name = name
        self.unit = unit
        self.mobile = normalizeMobile(mobile)
    }
}

struct CategoryStrength: Codable, Identifiable, Hashable {
    let category: String
    let count: Int

    var id: String { category }

    enum CodingKeys: String, CodingKey { case category, name, count }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        category = (try? c.decodeIfPresent(String.self, forKey: .category))
            ?? (try? c.decodeIfPresent(String.self, forKey: .name)) ?? ""
        count = try c.decodeIfPresent(Int.self, forKey: .count) ?? 0
    }

    init(category: String, count: Int) {
        self.category = category
        self.count = count
    }
}

struct DistrictStrength: Codable, Identifiable, Hashable {
    let zone: String
    let range: String
    let district: String
    let inspectors: Int
    let si: Int

    var id: String { "\(zone)|\(range)|\(district)" }
}

struct DashboardCounts: Codable {
    let dsps: Int
    let sps: Int
    let addlSps: Int
    let inspectors: Int
    let subInspectors: Int
    let categories: [CategoryStrength]
    let zones: [CategoryStrength]
    let ranges: [CategoryStrength]
    let spOfficers: [TechnicalOfficer]
    let addlSpOfficers: [TechnicalOfficer]
    let dspOfficers: [TechnicalOfficer]
    let inspectorOfficers: [TechnicalOfficer]
    let siOfficers: [TechnicalOfficer]
    let districtStrengths: [DistrictStrength]
}

// MARK: - Profile Options

struct ProfileUnitCategoryChoice: Codable, Hashable {
    let zone: String
    let range: String
    let unit: String
    let category: String
}

struct ProfileOptions: Codable {
    let ranks: [String]
    let unitCategories: [String]
    let batches: [String]
    let zones: [String]
    let ranges: [String]
    let units: [String]
    let dojs: [String]
    let zoneRanges: [[String]]
    let zoneRangeUnits: [[String]]
    let zoneRangeUnitCategories: [ProfileUnitCategoryChoice]

    init(
        ranks: [String] = [],
        unitCategories: [String] = [],
        batches: [String] = [],
        zones: [String] = [],
        ranges: [String] = [],
        units: [String] = [],
        dojs: [String] = [],
        zoneRanges: [[String]] = [],
        zoneRangeUnits: [[String]] = [],
        zoneRangeUnitCategories: [ProfileUnitCategoryChoice] = []
    ) {
        self.ranks = ranks
        self.unitCategories = unitCategories
        self.batches = batches
        self.zones = zones
        self.ranges = ranges
        self.units = units
        self.dojs = dojs
        self.zoneRanges = zoneRanges
        self.zoneRangeUnits = zoneRangeUnits
        self.zoneRangeUnitCategories = zoneRangeUnitCategories
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: DynamicCodingKey.self)
        ranks = try c.decodeIfPresent([String].self, forKey: DynamicCodingKey("ranks")) ?? []
        unitCategories = try c.decodeIfPresent([String].self, forKey: DynamicCodingKey("unitCategories")) ?? []
        batches = try c.decodeIfPresent([String].self, forKey: DynamicCodingKey("batches")) ?? []
        zones = try c.decodeIfPresent([String].self, forKey: DynamicCodingKey("zones")) ?? []
        ranges = try c.decodeIfPresent([String].self, forKey: DynamicCodingKey("ranges")) ?? []
        units = try c.decodeIfPresent([String].self, forKey: DynamicCodingKey("units")) ?? []
        dojs = try c.decodeIfPresent([String].self, forKey: DynamicCodingKey("dojs")) ?? []
        zoneRanges = try c.decodeIfPresent([[String]].self, forKey: DynamicCodingKey("zoneRanges")) ?? []
        zoneRangeUnits = try c.decodeIfPresent([[String]].self, forKey: DynamicCodingKey("zoneRangeUnits")) ?? []
        
        // Handle zoneRangeUnitCategories which can come as array of arrays or array of objects
        if let rawChoices = try? c.decodeIfPresent([[String]].self, forKey: DynamicCodingKey("zoneRangeUnitCategories")) {
            zoneRangeUnitCategories = rawChoices.compactMap { row in
                guard row.count >= 4 else { return nil }
                return ProfileUnitCategoryChoice(zone: row[0], range: row[1], unit: row[2], category: row[3])
            }
        } else if let directChoices = try? c.decodeIfPresent([ProfileUnitCategoryChoice].self, forKey: DynamicCodingKey("zoneRangeUnitCategories")) {
            zoneRangeUnitCategories = directChoices
        } else {
            zoneRangeUnitCategories = []
        }
    }
}

private struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    init(stringValue: String) { self.stringValue = stringValue; self.intValue = nil }
    init?(intValue: Int) { self.stringValue = "\(intValue)"; self.intValue = intValue }
    init(_ key: String) { self.stringValue = key; self.intValue = nil }
}

struct AppUpdate: Codable {
    let versionCode: Int
    let versionName: String
    let downloadUrl: String
}

// MARK: - Rank Strength Calculations

struct RankStrength: Equatable {
    let dsp: Int
    let inspector: Int
    let si: Int

    var total: Int { dsp + inspector + si }
}

func rankOrder(_ rank: String) -> Int {
    let value = rank.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if value.contains("dsp") || value.contains("deputy superintendent") { return 0 }
    if value.contains("inspector") || value.contains("inspr") || value.hasPrefix("insp") { return 1 }
    if value.hasPrefix("si") || value.contains("sub-inspector") || value.contains("sub inspector") { return 2 }
    return 3
}

func rankCounts(for contacts: [Contact]) -> RankStrength {
    RankStrength(
        dsp: contacts.filter { rankOrder($0.rank) == 0 }.count,
        inspector: contacts.filter { rankOrder($0.rank) == 1 }.count,
        si: contacts.filter { rankOrder($0.rank) == 2 }.count
    )
}

// MARK: - Mobile Normalization

func normalizeMobile(_ value: Any?) -> String {
    guard let value else { return "" }
    if let number = value as? NSNumber {
        return String(format: "%.0f", number.doubleValue)
    }
    var str = String(describing: value).trimmingCharacters(in: .whitespacesAndNewlines)
    // Handle scientific notation from spreadsheets (e.g., 9.45E+09)
    if str.range(of: #"[eE][+-]?\d+"#, options: .regularExpression) != nil {
        if let d = Double(str) {
            str = String(format: "%.0f", d)
        }
    }
    return str.filter { $0.isNumber }
}

func whatsAppNumber(for mobile: String) -> String {
    let digits = mobile.filter { $0.isNumber }
    switch digits.count {
    case 10:
        return "91\(digits)"
    case 11 where digits.hasPrefix("0"):
        return "91\(digits.dropFirst())"
    case 12 where digits.hasPrefix("91"):
        return digits
    default:
        return ""
    }
}

func whatsAppURL(for mobile: String) -> URL? {
    let num = whatsAppNumber(for: mobile)
    guard !num.isEmpty else { return nil }
    return URL(string: "https://wa.me/\(num)")
}

func telURL(for mobile: String) -> URL? {
    let digits = mobile.filter { $0.isNumber }
    guard digits.count >= 10 else { return nil }
    return URL(string: "tel:\(digits)")
}

// MARK: - Organization & Location Classifications (Source: Android)

func normalizedOrgLabel(_ value: String) -> String {
    let norm = value.trimmingCharacters(in: .whitespacesAndNewlines)
        .lowercased()
        .replacingOccurrences(of: "police", with: "")
        .filter { $0.isLetter || $0.isNumber }
    
    switch norm {
    case "kpm", "kpmrange":
        return "kancheepuramrange"
    case "tanjavur", "tanjavurrange":
        return "thanjavur" + (norm.hasSuffix("range") ? "range" : "")
    default:
        return norm
    }
}

let ZONE_RANGE_MAP: [String: [String]] = [
    "Central Zone": ["Thanjavur Range", "Trichy Range"],
    "North Zone": ["Kancheepuram Range", "Vellore Range", "Villupuram Range"],
    "South Zone": ["Dindigul Range", "Madurai Range", "Ramnathapuram Range", "Tirunelveli Range"],
    "West Zone": ["Coimbatore Range", "Salem City", "Salem Range", "Tiruppur City"]
]

let CITY_SUMMARY_LOCATIONS = [
    "Avadi city", "Chennai city", "Coimbatore City", "Madurai City", "Salem City",
    "Tambaram City", "Tirunelveli City", "Tiruppur City", "Trichy City"
]

func isPtbHqrsContact(_ contact: Contact) -> Bool {
    let combined = "\(contact.unit) \(contact.unitCategory)"
    return combined.localizedCaseInsensitiveContains("PTB Hqrs") ||
        combined.localizedCaseInsensitiveContains("Headquarters") ||
        contact.unit.trimmingCharacters(in: .whitespaces).uppercased().hasPrefix("PTB")
}

func isMinisterialContact(_ contact: Contact) -> Bool {
    contact.unitCategory.localizedCaseInsensitiveContains("ministerial")
}

func ministerialRankOrder(_ rank: String) -> Int {
    let key = rank.lowercased().filter { $0.isLetter || $0.isNumber }
    if key == "ao" || key.hasPrefix("administrativeofficer") { return 0 }
    if key.hasPrefix("supdt") || key.hasPrefix("superintendent") { return 1 }
    if key.hasPrefix("asst") || key.hasPrefix("assistant") { return 2 }
    if key.hasPrefix("jrass") || key.hasPrefix("juniorassistant") { return 3 }
    if key == "rc" || key.hasPrefix("recordclerk") { return 4 }
    if key.hasPrefix("typist") { return 5 }
    if key == "oa" || key.hasPrefix("officeassistant") { return 6 }
    if key.hasPrefix("sbass") { return 7 }
    if key.hasPrefix("stenotyp") { return 8 }
    return Int.max
}

func ministerialUnitOrder(_ unit: String) -> Int {
    let key = unit.lowercased().filter { $0.isLetter || $0.isNumber }
    let order = ["cctodigcamp", "cctoigpcamp", "aoaccounts", "aoadmin", "asection"]
    if let idx = order.firstIndex(of: key) { return idx }
    return Int.max
}

func isCityContact(_ contact: Contact) -> Bool {
    contact.unit.trimmingCharacters(in: .whitespaces).lowercased().hasSuffix("city")
}

func isRepeaterContact(_ contact: Contact) -> Bool {
    contact.unitCategory.trimmingCharacters(in: .whitespaces).caseInsensitiveCompare("Repeater") == .orderedSame
}

func isBattalionContact(_ contact: Contact) -> Bool {
    contact.unitCategory.localizedCaseInsensitiveContains("battalion") ||
    contact.unit.localizedCaseInsensitiveContains("battalion")
}

func isSpecialUnitContact(_ contact: Contact) -> Bool {
    let cat = contact.unitCategory.trimmingCharacters(in: .whitespaces)
    return (cat.localizedCaseInsensitiveContains("special") ||
            contact.zone.localizedCaseInsensitiveContains("special") ||
            contact.range.localizedCaseInsensitiveContains("special")) &&
           !isBattalionContact(contact)
}

func isDistrictContact(_ contact: Contact) -> Bool {
    !contact.zone.isEmpty && !contact.range.isEmpty &&
    normalizedOrgLabel(contact.unit) != normalizedOrgLabel(contact.zone) &&
    !isPtbHqrsContact(contact) &&
    !isMinisterialContact(contact) &&
    !isCityContact(contact) &&
    !isRepeaterContact(contact) &&
    !isSpecialUnitContact(contact) &&
    !isBattalionContact(contact)
}

func isSpecialDirectoryContact(_ contact: Contact) -> Bool {
    !isPtbHqrsContact(contact) &&
    !isMinisterialContact(contact) &&
    !isDistrictContact(contact) &&
    !isCityContact(contact) &&
    !isRepeaterContact(contact) &&
    !isBattalionContact(contact) &&
    isSpecialUnitContact(contact)
}

// MARK: - Profile Sorters

func profileRankComparator() -> (String, String) -> Bool {
    let preferred = ["SPT", "ADDLSPT", "DSPT", "INSPRT", "SIT"]
    return { a, b in
        let normA = a.filter { $0.isLetter || $0.isNumber }.uppercased()
        let normB = b.filter { $0.isLetter || $0.isNumber }.uppercased()
        let idxA = preferred.firstIndex(of: normA) ?? Int.max
        let idxB = preferred.firstIndex(of: normB) ?? Int.max
        if idxA != idxB { return idxA < idxB }
        return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
    }
}

func profileZoneComparator() -> (String, String) -> Bool {
    let preferred = ["North Zone", "South Zone", "Central Zone", "West Zone", "PTB Hqrs", "Special unit"]
    return { a, b in
        let cityA = a.localizedCaseInsensitiveContains("city")
        let cityB = b.localizedCaseInsensitiveContains("city")
        if cityA && !cityB { return true }
        if !cityA && cityB { return false }
        let idxA = preferred.firstIndex(where: { $0.caseInsensitiveCompare(a) == .orderedSame }) ?? Int.max
        let idxB = preferred.firstIndex(where: { $0.caseInsensitiveCompare(b) == .orderedSame }) ?? Int.max
        if idxA != idxB { return idxA < idxB }
        return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
    }
}

// MARK: - Date Formatting Helpers

func formatDOJDate(_ date: Date) -> String {
    let f = DateFormatter()
    f.dateFormat = "dd/MM/yyyy"
    f.locale = Locale(identifier: "en_GB")
    return f.string(from: date)
}

func parseDOJDate(_ str: String) -> Date? {
    let f = DateFormatter()
    f.dateFormat = "dd/MM/yyyy"
    f.locale = Locale(identifier: "en_GB")
    return f.date(from: str.trimmingCharacters(in: .whitespacesAndNewlines))
}

