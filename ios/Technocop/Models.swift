import Foundation
import SwiftUI

// MARK: - Officer & User Session Models

public struct Officer: Codable, Equatable, Identifiable {
    public var name: String
    public var rank: String
    public var mobile: String
    public var unit: String
    public var technicalUnit: String
    public var batch: String
    public var zone: String
    public var range: String
    public var doj: String
    public var ifhrmsNo: String
    public var dob: String
    public var doe: String
    public var dor: String

    public var id: String { mobile.isEmpty ? name : mobile }

    public init(
        name: String = "",
        rank: String = "",
        mobile: String = "",
        unit: String = "",
        technicalUnit: String = "",
        batch: String = "",
        zone: String = "",
        range: String = "",
        doj: String = "",
        ifhrmsNo: String = "",
        dob: String = "",
        doe: String = "",
        dor: String = ""
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
        self.ifhrmsNo = ifhrmsNo
        self.dob = dob
        self.doe = doe
        self.dor = dor
    }

    enum CodingKeys: String, CodingKey {
        case name, rank, mobile, unit, technicalUnit, batch, zone, range, doj
        case ifhrmsNo, dob, doe, dor
    }

    public init(from decoder: Decoder) throws {
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
        ifhrmsNo = try container.decodeIfPresent(String.self, forKey: .ifhrmsNo) ?? ""
        dob = try container.decodeIfPresent(String.self, forKey: .dob) ?? ""
        doe = try container.decodeIfPresent(String.self, forKey: .doe) ?? ""
        dor = try container.decodeIfPresent(String.self, forKey: .dor) ?? ""
    }
}

public struct UserSession: Codable, Equatable {
    public let token: String
    public let rememberToken: String
    public let officer: Officer

    public func replacingOfficer(_ updatedOfficer: Officer) -> UserSession {
        UserSession(token: token, rememberToken: rememberToken, officer: updatedOfficer)
    }
}

// MARK: - Roster Contact Models

public struct Contact: Codable, Identifiable, Hashable {
    public let name: String
    public let rank: String
    public let mobile: String
    public let unit: String
    public let unitCategory: String
    public let batch: String
    public let zone: String
    public let range: String
    public let dor: String

    public var id: String { "\(mobile)|\(name)|\(unit)" }

    enum CodingKeys: String, CodingKey {
        case name, rank, mobile, unit, unitCategory, batch, zone, range, dor
    }

    public init(
        name: String = "",
        rank: String = "",
        mobile: String = "",
        unit: String = "",
        unitCategory: String = "",
        batch: String = "",
        zone: String = "",
        range: String = "",
        dor: String = ""
    ) {
        self.name = name
        self.rank = rank
        self.mobile = normalizeMobile(mobile)
        self.unit = unit
        self.unitCategory = unitCategory
        self.batch = batch
        self.zone = zone
        self.range = range
        self.dor = dor
    }

    public init(from decoder: Decoder) throws {
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
        dor = try container.decodeIfPresent(String.self, forKey: .dor) ?? ""
    }
}

public struct ContactDirectory: Codable {
    public let contacts: [Contact]
    public let units: [String]
    public let unitCategories: [String]

    public init(contacts: [Contact], units: [String], unitCategories: [String]) {
        self.contacts = contacts
        self.units = units
        self.unitCategories = unitCategories
    }
}

// MARK: - Dashboard Counts & Hierarchy

public struct TechnicalOfficer: Codable, Identifiable, Hashable {
    public let name: String
    public let unit: String
    public let mobile: String

    public var id: String { "\(name)|\(mobile)|\(unit)" }

    enum CodingKeys: String, CodingKey { case name, unit, mobile }

    public init(from decoder: Decoder) throws {
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

    public init(name: String, unit: String, mobile: String) {
        self.name = name
        self.unit = unit
        self.mobile = normalizeMobile(mobile)
    }
}

public struct CategoryStrength: Codable, Identifiable, Hashable {
    public let category: String
    public let count: Int

    public var id: String { category }

    enum CodingKeys: String, CodingKey { case category, name, count }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        category = (try? c.decodeIfPresent(String.self, forKey: .category))
            ?? (try? c.decodeIfPresent(String.self, forKey: .name)) ?? ""
        count = try c.decodeIfPresent(Int.self, forKey: .count) ?? 0
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(category, forKey: .category)
        try container.encode(count, forKey: .count)
    }

    public init(category: String, count: Int) {
        self.category = category
        self.count = count
    }
}

public struct DistrictStrength: Codable, Identifiable, Hashable {
    public let zone: String
    public let range: String
    public let district: String
    public let inspectors: Int
    public let si: Int

    public var id: String { "\(zone)|\(range)|\(district)" }

    public init(zone: String, range: String, district: String, inspectors: Int, si: Int) {
        self.zone = zone
        self.range = range
        self.district = district
        self.inspectors = inspectors
        self.si = si
    }
}

public struct DashboardCounts: Codable {
    public let dsps: Int
    public let sps: Int
    public let addlSps: Int
    public let inspectors: Int
    public let subInspectors: Int
    public let categories: [CategoryStrength]
    public let zones: [CategoryStrength]
    public let ranges: [CategoryStrength]
    public let spOfficers: [TechnicalOfficer]
    public let addlSpOfficers: [TechnicalOfficer]
    public let dspOfficers: [TechnicalOfficer]
    public let inspectorOfficers: [TechnicalOfficer]
    public let siOfficers: [TechnicalOfficer]
    public let districtStrengths: [DistrictStrength]

    public init(
        dsps: Int = 0,
        sps: Int = 0,
        addlSps: Int = 0,
        inspectors: Int = 0,
        subInspectors: Int = 0,
        categories: [CategoryStrength] = [],
        zones: [CategoryStrength] = [],
        ranges: [CategoryStrength] = [],
        spOfficers: [TechnicalOfficer] = [],
        addlSpOfficers: [TechnicalOfficer] = [],
        dspOfficers: [TechnicalOfficer] = [],
        inspectorOfficers: [TechnicalOfficer] = [],
        siOfficers: [TechnicalOfficer] = [],
        districtStrengths: [DistrictStrength] = []
    ) {
        self.dsps = dsps
        self.sps = sps
        self.addlSps = addlSps
        self.inspectors = inspectors
        self.subInspectors = subInspectors
        self.categories = categories
        self.zones = zones
        self.ranges = ranges
        self.spOfficers = spOfficers
        self.addlSpOfficers = addlSpOfficers
        self.dspOfficers = dspOfficers
        self.inspectorOfficers = inspectorOfficers
        self.siOfficers = siOfficers
        self.districtStrengths = districtStrengths
    }
}

// MARK: - Birthday Models

public struct BirthdayPerson: Codable, Identifiable, Hashable {
    public let name: String
    public let rank: String
    public let unit: String
    public let isSelf: Bool
    public let mobile: String

    public var id: String { "\(name)|\(mobile)|\(unit)" }

    public init(name: String, rank: String, unit: String, isSelf: Bool = false, mobile: String = "") {
        self.name = name
        self.rank = rank
        self.unit = unit
        self.isSelf = isSelf
        self.mobile = normalizeMobile(mobile)
    }
}

public struct BirthdayFeed: Codable {
    public let available: Bool
    public let birthdays: [BirthdayPerson]

    public init(available: Bool = false, birthdays: [BirthdayPerson] = []) {
        self.available = available
        self.birthdays = birthdays
    }
}

// MARK: - Official Content & Announcement Models

public typealias Announcement = ContentItem

public struct ContentItem: Codable, Identifiable, Hashable {
    public let title: String
    public let body: String
    public let date: String
    public let priority: String // "URGENT", "HIGH", "NORMAL"
    public let url: String
    public let targetGroup: String // "ALL", "TECHNICAL", "CITIES", "DISTRICTS", "IT_CELL"

    public var id: String { "\(title)|\(date)|\(priority)" }

    public init(
        title: String = "",
        body: String = "",
        date: String = "",
        priority: String = "NORMAL",
        url: String = "",
        targetGroup: String = "ALL"
    ) {
        self.title = title
        self.body = body
        self.date = date
        self.priority = priority
        self.url = url
        self.targetGroup = targetGroup.isEmpty ? "ALL" : targetGroup
    }
}

public struct ContentFeed: Codable {
    public let available: Bool
    public let items: [ContentItem]

    public init(available: Bool = false, items: [ContentItem] = []) {
        self.available = available
        self.items = items
    }
}

public struct DashboardContent: Codable {
    public let announcements: ContentFeed
    public let digest: ContentFeed

    public init(announcements: ContentFeed = ContentFeed(), digest: ContentFeed = ContentFeed()) {
        self.announcements = announcements
        self.digest = digest
    }
}

// MARK: - Retirement Forecast Analytics

public struct RetirementOfficer: Codable, Identifiable, Hashable {
    public let name: String
    public let rank: String
    public let unit: String
    public let dor: String
    public let batch: String
    public let category: String

    public var id: String { "\(name)|\(dor)|\(unit)" }

    public init(name: String, rank: String, unit: String = "", dor: String = "", batch: String = "", category: String = "") {
        self.name = name
        self.rank = rank
        self.unit = unit
        self.dor = dor
        self.batch = batch
        self.category = category
    }
}

public struct RetirementYear: Codable, Identifiable, Hashable {
    public let year: Int
    public let count: Int
    public let officers: [RetirementOfficer]

    public var id: Int { year }

    public init(year: Int, count: Int, officers: [RetirementOfficer] = []) {
        self.year = year
        self.count = count
        self.officers = officers
    }
}

public struct RetirementForecast: Codable {
    public let available: Bool
    public let years: [RetirementYear]

    public init(available: Bool = false, years: [RetirementYear] = []) {
        self.available = available
        self.years = years
    }
}

// MARK: - Dashboard Quick Stats

public struct DashboardQuickStats: Equatable {
    public let totalRosterCount: Int
    public let totalTechnicalOfficers: Int
    public let myUnitCount: Int
    public let birthdayCount: Int
    public let announcementCount: Int
    public let upcomingRetirementsCount: Int

    public init(
        totalRosterCount: Int = 0,
        totalTechnicalOfficers: Int = 0,
        myUnitCount: Int = 0,
        birthdayCount: Int = 0,
        announcementCount: Int = 0,
        upcomingRetirementsCount: Int = 0
    ) {
        self.totalRosterCount = totalRosterCount
        self.totalTechnicalOfficers = totalTechnicalOfficers
        self.myUnitCount = myUnitCount
        self.birthdayCount = birthdayCount
        self.announcementCount = announcementCount
        self.upcomingRetirementsCount = upcomingRetirementsCount
    }
}

// MARK: - Profile Options

public struct ProfileUnitCategoryChoice: Codable, Hashable {
    public let zone: String
    public let range: String
    public let unit: String
    public let category: String

    public init(zone: String, range: String, unit: String, category: String) {
        self.zone = zone
        self.range = range
        self.unit = unit
        self.category = category
    }
}

public struct ProfileOptions: Codable {
    public let ranks: [String]
    public let unitCategories: [String]
    public let batches: [String]
    public let zones: [String]
    public let ranges: [String]
    public let units: [String]
    public let dojs: [String]
    public let zoneRanges: [[String]]
    public let zoneRangeUnits: [[String]]
    public let zoneRangeUnitCategories: [ProfileUnitCategoryChoice]

    public init(
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

    public init(from decoder: Decoder) throws {
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

public struct AppUpdate: Codable {
    public let versionName: String
    public let downloadUrl: String
    public let releaseNotes: String

    public init(versionName: String, downloadUrl: String, releaseNotes: String = "") {
        self.versionName = versionName
        self.downloadUrl = downloadUrl
        self.releaseNotes = releaseNotes
    }
}

// MARK: - Rank Strength Calculations

public struct RankStrength: Equatable {
    public let dsp: Int
    public let inspector: Int
    public let si: Int

    public var total: Int { dsp + inspector + si }

    public init(dsp: Int, inspector: Int, si: Int) {
        self.dsp = dsp
        self.inspector = inspector
        self.si = si
    }
}

public struct StrengthTableRowItem: Identifiable, Equatable {
    public let id: String
    public let label: String
    public let strength: RankStrength
    public let depth: Int

    public init(label: String, strength: RankStrength, depth: Int = 0) {
        self.id = "\(label)_\(depth)_\(strength.total)"
        self.label = label
        self.strength = strength
        self.depth = depth
    }
}

public struct BatchStrengthRowItem: Identifiable, Equatable {
    public var id: String { batch }
    public let batch: String
    public let strength: RankStrength

    public init(batch: String, strength: RankStrength) {
        self.batch = batch
        self.strength = strength
    }
}

// MARK: - Domain Logic & Ranking (Source of truth: Android TechnocopDomain.kt)

public let ZONE_RANGE_MAP: [String: [String]] = [
    "Central Zone": ["Thanjavur Range", "Trichy Range"],
    "North Zone": ["Kancheepuram Range", "Vellore Range", "Villupuram Range"],
    "South Zone": ["Dindigul Range", "Madurai Range", "Ramnathapuram Range", "Tirunelveli Range"],
    "West Zone": ["Coimbatore Range", "Salem City", "Salem Range", "Tiruppur City"]
]

public let CITY_SUMMARY_LOCATIONS = [
    "Avadi city", "Chennai city", "Coimbatore City", "Madurai City", "Salem City",
    "Tambaram City", "Tirunelveli City", "Tiruppur City", "Trichy City"
]

public func greetingForHour(_ hour: Int) -> String {
    switch hour {
    case 5...11: return "Good morning"
    case 12...16: return "Good afternoon"
    default: return "Good evening"
    }
}

public func officerInitials(_ name: String) -> String {
    let parts = name.trimmingCharacters(in: .whitespacesAndNewlines)
        .components(separatedBy: .whitespacesAndNewlines)
        .filter { !$0.isEmpty }
    let initials = parts.prefix(2).compactMap { $0.first?.uppercased() }.joined()
    return initials.isEmpty ? "TC" : initials
}

public func normalizedOrgLabel(_ value: String) -> String {
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

public func rankOrder(_ rank: String) -> Int {
    let value = rank.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if value.contains("dsp") || value.contains("deputy superintendent") || value.contains("acp") { return 0 }
    if value.contains("inspector") || value.contains("inspr") || value.hasPrefix("insp") { return 1 }
    if value.hasPrefix("si") || value.contains("sub-inspector") || value.contains("sub inspector") { return 2 }
    return 3
}

public func technicalRankOrder(_ rank: String) -> Int {
    let key = rank.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().filter { $0.isLetter || $0.isNumber }
    if key.hasPrefix("addlsp") || key.hasPrefix("additionalsp") || key.hasPrefix("additionalsuperintendent") { return 1 }
    if key == "sp" || key.hasPrefix("spt") || (key.hasPrefix("superintendent") && !key.hasPrefix("additionalsuperintendent")) { return 0 }
    if key.hasPrefix("dsp") || key.hasPrefix("deputysuperintendent") || key.hasPrefix("dysuperintendent") || key.hasPrefix("acp") { return 2 }
    if key.hasPrefix("winspr") || key.hasPrefix("winsp") || key.hasPrefix("womeninspector") { return 4 }
    if key.hasPrefix("inspr") || key.hasPrefix("insp") || key.hasPrefix("inspector") { return 3 }
    if key.hasPrefix("wsi") || key.hasPrefix("womensubinspector") { return 6 }
    if key.hasPrefix("si") || key.hasPrefix("subinspector") { return 5 }
    if key.hasPrefix("wssi") || key.hasPrefix("womenspecialsub") { return 8 }
    if key.hasPrefix("ssi") || key.hasPrefix("specialsub") { return 7 }
    if key.hasPrefix("whc") || key.hasPrefix("womenheadconstable") { return 10 }
    if key.hasPrefix("hc") || key.hasPrefix("headconstable") { return 9 }
    if key.hasPrefix("wgripc") || key.hasPrefix("wgr1pc") { return 12 }
    if key.hasPrefix("gripc") || key.hasPrefix("gr1pc") || key.contains("gri") || key.contains("gr1") { return 11 }
    if key.hasPrefix("wpc") || key.hasPrefix("womenconstable") { return 14 }
    if key.hasPrefix("pc") || key.hasPrefix("constable") { return 13 }
    return 100
}

public func retirementRankOrder(_ rank: String) -> Int {
    let key = rank.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().filter { $0.isLetter || $0.isNumber }
    if key.hasPrefix("addlsp") || key.hasPrefix("additionalsp") || key.hasPrefix("additionalsuperintendent") { return 1 }
    if key == "sp" || key.hasPrefix("spt") || key.hasPrefix("superintendentofpolice") { return 0 }
    if key.hasPrefix("dsp") || key.hasPrefix("deputysuperintendent") || key.hasPrefix("dysuperintendent") { return 2 }
    if key.hasPrefix("winspr") || key.hasPrefix("winsp") { return 4 }
    if key.hasPrefix("inspr") || key.hasPrefix("insp") || key.hasPrefix("inspector") { return 3 }
    if key.hasPrefix("wsi") || key.hasPrefix("womensubinspector") { return 6 }
    if key.hasPrefix("si") || key.hasPrefix("subinspector") { return 5 }
    if key.hasPrefix("wssi") { return 8 }
    if key.hasPrefix("ssi") { return 7 }
    if key.hasPrefix("whc") { return 10 }
    if key.hasPrefix("hc") { return 9 }
    if key.hasPrefix("wgripc") || key.hasPrefix("wgr1pc") { return 12 }
    if key.hasPrefix("gripc") || key.hasPrefix("gr1pc") || key.contains("gri") || key.contains("gr1") { return 11 }
    if key.hasPrefix("wpc") { return 14 }
    if key.hasPrefix("pc") { return 13 }
    let minOrd = ministerialRankOrder(rank)
    if minOrd != Int.max { return 20 + minOrd }
    return 100
}

public func executiveRankOrder(_ rank: String) -> Int {
    let key = rank.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().filter { $0.isLetter || $0.isNumber }
    if key.hasPrefix("dgp") { return 0 }
    if key.hasPrefix("adgp") { return 1 }
    if key.hasPrefix("ig") { return 2 }
    if key.hasPrefix("dig") { return 3 }
    if key.hasPrefix("sp") || key.hasPrefix("superintendent") { return 4 }
    if key.hasPrefix("addlsp") || key.hasPrefix("additionalsp") { return 5 }
    if key.hasPrefix("dsp") || key.hasPrefix("deputy") || key.hasPrefix("acp") { return 6 }
    if key.hasPrefix("winspr") || key.hasPrefix("winsp") { return 11 }
    if key.hasPrefix("inspr") || key.hasPrefix("insp") || key.hasPrefix("inspector") { return 10 }
    if key.hasPrefix("wsi") || key.hasPrefix("womensubinspector") { return 21 }
    if key.hasPrefix("si") || key.hasPrefix("subinspector") { return 20 }
    if key.hasPrefix("wssi") { return 31 }
    if key.hasPrefix("ssi") { return 30 }
    if key.hasPrefix("whc") { return 41 }
    if key.hasPrefix("hc") { return 40 }
    if key.hasPrefix("wgripc") || key.hasPrefix("wgr1pc") { return 51 }
    if key.hasPrefix("gripc") || key.hasPrefix("gr1pc") || key.contains("gri") || key.contains("gr1") { return 50 }
    if key.hasPrefix("wpc") { return 61 }
    if key.hasPrefix("pc") { return 60 }
    return 100
}

public func ministerialRankOrder(_ rank: String) -> Int {
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

public func ministerialUnitOrder(_ unit: String) -> Int {
    let key = unit.lowercased().filter { $0.isLetter || $0.isNumber }
    let order = ["cctodigcamp", "cctoigpcamp", "aoaccounts", "aoadmin", "asection"]
    if let idx = order.firstIndex(of: key) { return idx }
    return Int.max
}

public func parseDorSortKey(_ dor: String) -> Int64 {
    let s = dor.trimmingCharacters(in: .whitespacesAndNewlines)
    if s.isEmpty { return Int64.max }

    // Match DD/MM/YYYY
    let dmyPattern = #"^(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})"#
    if let match = s.range(of: dmyPattern, options: .regularExpression) {
        let sub = String(s[match])
        let parts = sub.components(separatedBy: CharacterSet(charactersIn: "/-."))
        if parts.count >= 3, let d = Int64(parts[0]), let m = Int64(parts[1]), let y = Int64(parts[2]) {
            return y * 10000 + m * 100 + d
        }
    }
    // Match YYYY/MM/DD
    let ymdPattern = #"^(\d{4})[/\-.](\d{1,2})[/\-.](\d{1,2})"#
    if let match = s.range(of: ymdPattern, options: .regularExpression) {
        let sub = String(s[match])
        let parts = sub.components(separatedBy: CharacterSet(charactersIn: "/-."))
        if parts.count >= 3, let y = Int64(parts[0]), let m = Int64(parts[1]), let d = Int64(parts[2]) {
            return y * 10000 + m * 100 + d
        }
    }
    return Int64.max
}

public func parseBatchSortKey(_ batch: String) -> Int {
    let digits = batch.filter { $0.isNumber }
    return Int(digits) ?? Int.max
}

public func sortRetirementOfficers(_ officers: [RetirementOfficer]) -> [RetirementOfficer] {
    officers.sorted { a, b in
        let batchA = parseBatchSortKey(a.batch)
        let batchB = parseBatchSortKey(b.batch)
        if batchA != batchB { return batchA < batchB }

        let dorA = parseDorSortKey(a.dor)
        let dorB = parseDorSortKey(b.dor)
        if dorA != dorB { return dorA < dorB }

        return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
    }
}

public func rankCounts(for contacts: [Contact]) -> RankStrength {
    RankStrength(
        dsp: contacts.filter { rankOrder($0.rank) == 0 }.count,
        inspector: contacts.filter { rankOrder($0.rank) == 1 }.count,
        si: contacts.filter { rankOrder($0.rank) == 2 }.count
    )
}

public func isPtbHqrsContact(_ contact: Contact) -> Bool {
    guard !isExecutiveContact(contact) else { return false }
    let combined = "\(contact.unit) \(contact.unitCategory)"
    return combined.localizedCaseInsensitiveContains("PTB Hqrs") ||
        combined.localizedCaseInsensitiveContains("Headquarters") ||
        contact.unit.trimmingCharacters(in: .whitespaces).uppercased().hasPrefix("PTB")
}

public func isMinisterialContact(_ contact: Contact) -> Bool {
    contact.unitCategory.localizedCaseInsensitiveContains("ministerial")
}

public func isExecutiveContact(_ contact: Contact) -> Bool {
    let cat = contact.unitCategory.trimmingCharacters(in: .whitespaces)
    let r = contact.rank.trimmingCharacters(in: .whitespaces)
    return cat.caseInsensitiveCompare("EXECUTIVE") == .orderedSame ||
        cat.localizedCaseInsensitiveContains("executive") ||
        r.localizedCaseInsensitiveContains("executive") ||
        r.localizedCaseInsensitiveContains("(E)")
}

public func isExecutiveOrMinisterialOfficer(_ officer: Officer?) -> Bool {
    guard let officer else { return false }
    let category = "\(officer.technicalUnit) \(officer.unit)"
    return category.localizedCaseInsensitiveContains("EXECUTIVE") ||
        category.localizedCaseInsensitiveContains("Ministerial")
}

public func isCityContact(_ contact: Contact) -> Bool {
    !isExecutiveContact(contact) &&
    contact.unit.trimmingCharacters(in: .whitespaces).lowercased().hasSuffix("city")
}

public func isRepeaterContact(_ contact: Contact) -> Bool {
    !isExecutiveContact(contact) &&
    contact.unitCategory.trimmingCharacters(in: .whitespaces).caseInsensitiveCompare("Repeater") == .orderedSame
}

public func isBattalionContact(_ contact: Contact) -> Bool {
    !isExecutiveContact(contact) &&
    (contact.unitCategory.localizedCaseInsensitiveContains("battalion") ||
     contact.unit.localizedCaseInsensitiveContains("battalion"))
}

public func isSpecialUnitContact(_ contact: Contact) -> Bool {
    let cat = contact.unitCategory.trimmingCharacters(in: .whitespaces)
    return !isExecutiveContact(contact) &&
        (cat.localizedCaseInsensitiveContains("special") ||
         contact.zone.localizedCaseInsensitiveContains("special") ||
         contact.range.localizedCaseInsensitiveContains("special")) &&
        !isBattalionContact(contact)
}

public func isDistrictContact(_ contact: Contact) -> Bool {
    !contact.zone.isEmpty && !contact.range.isEmpty &&
    normalizedOrgLabel(contact.unit) != normalizedOrgLabel(contact.zone) &&
    !isPtbHqrsContact(contact) &&
    !isMinisterialContact(contact) &&
    !isExecutiveContact(contact) &&
    !isCityContact(contact) &&
    !isRepeaterContact(contact) &&
    !isSpecialUnitContact(contact) &&
    !isBattalionContact(contact)
}

public func isSpecialDirectoryContact(_ contact: Contact) -> Bool {
    !isPtbHqrsContact(contact) &&
    !isMinisterialContact(contact) &&
    !isExecutiveContact(contact) &&
    !isDistrictContact(contact) &&
    !isCityContact(contact) &&
    !isRepeaterContact(contact) &&
    !isBattalionContact(contact) &&
    isSpecialUnitContact(contact)
}

public func sortContactsStandard(_ contacts: [Contact]) -> [Contact] {
    contacts.sorted { a, b in
        let batchA = Int(a.batch.filter { $0.isNumber }) ?? Int.max
        let batchB = Int(b.batch.filter { $0.isNumber }) ?? Int.max
        if batchA != batchB { return batchA < batchB }
        let rankA = isExecutiveContact(a) ? executiveRankOrder(a.rank) : rankOrder(a.rank)
        let rankB = isExecutiveContact(b) ? executiveRankOrder(b.rank) : rankOrder(b.rank)
        if rankA != rankB { return rankA < rankB }
        return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
    }
}

public func sortContactsMinisterial(_ contacts: [Contact]) -> [Contact] {
    contacts.sorted { a, b in
        let ordA = ministerialRankOrder(a.rank)
        let ordB = ministerialRankOrder(b.rank)
        if ordA != ordB { return ordA < ordB }
        return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
    }
}

public func isRangeDspRank(_ rank: String) -> Bool {
    rank.filter { $0.isLetter || $0.isNumber }.caseInsensitiveCompare("DSPT") == .orderedSame
}

public func myUnitContacts(for officer: Officer, in contacts: [Contact]) -> [Contact] {
    let rangeDSP = isRangeDspRank(officer.rank)
    return contacts.filter { contact in
        if rangeDSP {
            return !officer.range.isEmpty &&
                contact.range.trimmingCharacters(in: .whitespaces).caseInsensitiveCompare(officer.range.trimmingCharacters(in: .whitespaces)) == .orderedSame
        } else {
            return !officer.unit.isEmpty &&
                contact.unit.trimmingCharacters(in: .whitespaces).caseInsensitiveCompare(officer.unit.trimmingCharacters(in: .whitespaces)) == .orderedSame
        }
    }
}

public func computeQuickStats(
    officer: Officer,
    counts: DashboardCounts?,
    contacts: [Contact],
    birthdayCount: Int,
    announcementCount: Int,
    upcomingRetirementsCount: Int
) -> DashboardQuickStats {
    let technicalSum = counts != nil
        ? (counts!.sps + counts!.addlSps + counts!.dsps + counts!.inspectors + counts!.subInspectors)
        : contacts.filter { rankOrder($0.rank) <= 2 }.count

    return DashboardQuickStats(
        totalRosterCount: contacts.count,
        totalTechnicalOfficers: technicalSum,
        myUnitCount: myUnitContacts(for: officer, in: contacts).count,
        birthdayCount: birthdayCount,
        announcementCount: announcementCount,
        upcomingRetirementsCount: upcomingRetirementsCount
    )
}

public func computeRetirementForecastFromContacts(_ contacts: [Contact]) -> RetirementForecast {
    let currentYear = Calendar.current.component(.year, from: Date())
    var yearMap: [Int: [RetirementOfficer]] = [:]

    for c in contacts {
        guard !c.dor.isEmpty else { continue }
        let dorKey = parseDorSortKey(c.dor)
        guard dorKey != Int64.max else { continue }
        let year = Int(dorKey / 10000)
        guard year >= currentYear && year <= currentYear + 15 else { continue }

        let category: String
        if isExecutiveContact(c) { category = "executive" }
        else if isMinisterialContact(c) { category = "ministerial" }
        else { category = "technical" }

        let officer = RetirementOfficer(
            name: c.name,
            rank: c.rank,
            unit: c.unit,
            dor: c.dor,
            batch: c.batch,
            category: category
        )
        yearMap[year, default: []].append(officer)
    }

    let years = yearMap.keys.sorted().map { y in
        let officers = sortRetirementOfficers(yearMap[y] ?? [])
        return RetirementYear(year: y, count: officers.count, officers: officers)
    }

    return RetirementForecast(available: !years.isEmpty, years: years)
}

public func enrichRetirementForecast(forecast: RetirementForecast, contacts: [Contact]) -> RetirementForecast {
    enrichRetirementForecast(forecast, contacts: contacts)
}

public func enrichRetirementForecast(_ forecast: RetirementForecast, contacts: [Contact]) -> RetirementForecast {
    let enrichedYears = forecast.years.map { yearItem in
        var enrichedOfficers: [RetirementOfficer] = []
        for o in yearItem.officers {
            if let matching = contacts.first(where: {
                $0.name.caseInsensitiveCompare(o.name) == .orderedSame ||
                (!o.dor.isEmpty && $0.dor == o.dor && $0.unit.caseInsensitiveCompare(o.unit) == .orderedSame)
            }) {
                let category: String
                if isExecutiveContact(matching) { category = "executive" }
                else if isMinisterialContact(matching) { category = "ministerial" }
                else { category = "technical" }

                enrichedOfficers.append(RetirementOfficer(
                    name: matching.name,
                    rank: matching.rank,
                    unit: matching.unit,
                    dor: matching.dor.isEmpty ? o.dor : matching.dor,
                    batch: matching.batch.isEmpty ? o.batch : matching.batch,
                    category: category
                ))
            } else {
                enrichedOfficers.append(o)
            }
        }
        return RetirementYear(year: yearItem.year, count: max(yearItem.count, enrichedOfficers.count), officers: sortRetirementOfficers(enrichedOfficers))
    }
    return RetirementForecast(available: true, years: enrichedYears)
}

public func filterSearchContacts(
    contacts: [Contact],
    unit: String,
    unitCategory: String,
    query: String
) -> [Contact] {
    let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
    let mobileQuery = q.filter { $0.isNumber }

    let filtered = contacts.filter { officer in
        let matchesUnit = (unit == "All units" || officer.unit.caseInsensitiveCompare(unit) == .orderedSame)
        let matchesCategory = (unitCategory == "All categories" || officer.unitCategory.caseInsensitiveCompare(unitCategory) == .orderedSame)
        let matchesQuery = q.isEmpty ||
            officer.name.localizedCaseInsensitiveContains(q) ||
            officer.rank.localizedCaseInsensitiveContains(q) ||
            officer.unit.localizedCaseInsensitiveContains(q) ||
            (!mobileQuery.isEmpty && officer.mobile.contains(mobileQuery))

        return matchesUnit && matchesCategory && matchesQuery
    }
    return sortContactsStandard(filtered)
}

public func matchesBroadcastAudience(_ targetGroup: String, _ officer: Officer) -> Bool {
    let code = targetGroup.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    if code.isEmpty || code == "ALL" { return true }
    let isExecOrMin = isExecutiveOrMinisterialOfficer(officer)
    switch code {
    case "TECHNICAL": return !isExecOrMin
    case "CITIES": return officer.unit.lowercased().hasSuffix("city")
    case "DISTRICTS": return !officer.zone.isEmpty && !officer.range.isEmpty && !officer.unit.lowercased().hasSuffix("city")
    case "IT_CELL": return officer.technicalUnit.localizedCaseInsensitiveContains("it cell") || officer.unit.localizedCaseInsensitiveContains("it cell")
    default: return true
    }
}

public func compareReleaseVersions(_ left: String, _ right: String) -> Int {
    func parts(_ raw: String) -> [Int] {
        let pattern = #"\d+(?:\.\d+)*"#
        guard let range = raw.range(of: pattern, options: .regularExpression) else { return [] }
        return String(raw[range]).components(separatedBy: ".").compactMap { Int($0) }
    }
    let a = parts(left)
    let b = parts(right)
    let count = max(a.count, b.count)
    for i in 0..<count {
        let valA = i < a.count ? a[i] : 0
        let valB = i < b.count ? b[i] : 0
        if valA < valB { return -1 }
        if valA > valB { return 1 }
    }
    return 0
}

// MARK: - Mobile Normalization & Communication URLs

public func normalizeMobile(_ value: Any?) -> String {
    guard let value else { return "" }
    if let number = value as? NSNumber {
        return String(format: "%.0f", number.doubleValue)
    }
    var str = String(describing: value).trimmingCharacters(in: .whitespacesAndNewlines)
    if str.range(of: #"[eE][+-]?\d+"#, options: .regularExpression) != nil {
        if let d = Double(str) {
            str = String(format: "%.0f", d)
        }
    }
    return str.filter { $0.isNumber }
}

public func whatsAppNumber(for mobile: String) -> String {
    let digits = mobile.filter { $0.isNumber }
    switch digits.count {
    case 10: return "91\(digits)"
    case 11 where digits.hasPrefix("0"): return "91\(digits.dropFirst())"
    case 12 where digits.hasPrefix("91"): return digits
    default: return ""
    }
}

public func whatsAppURL(for mobile: String) -> URL? {
    let num = whatsAppNumber(for: mobile)
    guard !num.isEmpty else { return nil }
    return URL(string: "https://wa.me/\(num)")
}

public func telURL(for mobile: String) -> URL? {
    let digits = mobile.filter { $0.isNumber }
    guard digits.count >= 10 else { return nil }
    return URL(string: "tel:\(digits)")
}

public func profileRankComparator() -> (String, String) -> Bool {
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

public func profileZoneComparator() -> (String, String) -> Bool {
    let preferred = ["North Zone", "South Zone", "Central Zone", "West Zone", "PTB Hqrs", "Special unit"]
    return { a, b in
        if a.localizedCaseInsensitiveContains("city") && !b.localizedCaseInsensitiveContains("city") { return true }
        if !a.localizedCaseInsensitiveContains("city") && b.localizedCaseInsensitiveContains("city") { return false }
        let idxA = preferred.firstIndex(where: { $0.caseInsensitiveCompare(a) == .orderedSame }) ?? Int.max
        let idxB = preferred.firstIndex(where: { $0.caseInsensitiveCompare(b) == .orderedSame }) ?? Int.max
        if idxA != idxB { return idxA < idxB }
        return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
    }
}

// MARK: - Daily Thirukkural Repository (Source: Android Thirukkural.kt)

public struct Thirukkural: Identifiable, Equatable {
    public var id: Int { number }
    public let number: Int
    public let section: String        // பால்
    public let chapter: String        // அதிகாரம்
    public let line1: String          // முதல் அடி
    public let line2: String          // இரண்டாம் அடி
    public let explanationTamil: String
    public let explanationEnglish: String

    public init(number: Int, section: String, chapter: String, line1: String, line2: String, explanationTamil: String, explanationEnglish: String) {
        self.number = number
        self.section = section
        self.chapter = chapter
        self.line1 = line1
        self.line2 = line2
        self.explanationTamil = explanationTamil
        self.explanationEnglish = explanationEnglish
    }
}

public struct ThirukkuralRepository {
    public static let kurals: [Thirukkural] = [
        Thirukkural(
            number: 595,
            section: "பொருட்பால்",
            chapter: "ஊக்கமுடைமை",
            line1: "வெள்ளத் தனைய மலர்நீட்டம் மாந்தர்தம்",
            line2: "உள்ளத் தனையது உயர்வு.",
            explanationTamil: "நீரின் உயரத்திற்கு ஏற்ப நீர்மலர் வளரும்; அதுபோல மனிதரின் உள்ளத்து ஊக்கத்தின் அளவிற்கு ஏற்ப அவர் உயர்வடைவார்.",
            explanationEnglish: "With rising flood the lotus flower its stem will elongate; / As measure of their spirit, men rise to be truly great."
        ),
        Thirukkural(
            number: 1,
            section: "அறத்துப்பால்",
            chapter: "கடவுள் வாழ்த்து",
            line1: "அகர முதல எழுத்தெல்லாம் ஆதி",
            line2: "பகவன் முதற்றே உலகு.",
            explanationTamil: "எழுத்துக்கள் எல்லாம் 'அ' கரத்தை முதலாகக் கொண்டுள்ளன; அதுபோல உலக உயிர்கள் எல்லாம் ஆதிபகவனை முதலாகக் கொண்டுள்ளன.",
            explanationEnglish: "As the letter 'A' is the first of all letters, so is the Eternal God first in the world."
        ),
        Thirukkural(
            number: 131,
            section: "அறத்துப்பால்",
            chapter: "ஒழுக்கமுடைமை",
            line1: "ஒழுக்கம் விழுப்பந் தரலான் ஒழுக்கம்",
            line2: "உயிரினும் ஓம்பப் படும்.",
            explanationTamil: "ஒழுக்கமே அனைவருக்கும் மேன்மையைத் தரும்; ஆதலால் அந்த ஒழுக்கத்தை உயிரை விடச் சிறந்ததாகக் கருதி காக்க வேண்டும்.",
            explanationEnglish: "Virtue and discipline give nobility to life; therefore, discipline must be guarded even more sacredly than life itself."
        ),
        Thirukkural(
            number: 391,
            section: "பொருட்பால்",
            chapter: "கல்வி",
            line1: "கற்க கசடறக் கற்பவை கற்றபின்",
            line2: "நிற்க அதற்குத் தக.",
            explanationTamil: "கற்கத் தகுந்த நூல்களைக் குற்றமறக் கற்க வேண்டும்; அவ்வாறு கற்ற பிறகு, கற்ற கல்விக்கு ஏற்ப நல்வழியில் நடக்க வேண்டும்.",
            explanationEnglish: "Learn with flawless clarity whatever you learn; then conduct your life strictly in accordance with what you have learned."
        ),
        Thirukkural(
            number: 421,
            section: "பொருட்பால்",
            chapter: "அறிவுடைமை",
            line1: "அறிவற்றங் காக்கும் கருவி செறுவார்க்கும்",
            line2: "உள்ளழிக்க லாகா அரண்.",
            explanationTamil: "அறிவு என்பது அழிவு வராமல் காக்கும் கருவியாகும்; பகைவராலும் அழிக்க முடியாத சிறந்த கோட்டையாகும்.",
            explanationEnglish: "Wisdom is an inner weapon that wards off destruction; it is an impenetrable fortress that enemies cannot breach."
        ),
        Thirukkural(
            number: 484,
            section: "பொருட்பால்",
            chapter: "காலமறிதல்",
            line1: "காலமறிந்து இடத்தோடு இயங்கின் நிலம்படைத்த",
            line2: "வெல்லாதது ஏதும் இல.",
            explanationTamil: "தகுந்த காலத்தை அறிந்து, ஏற்ற இடத்தோடு பொருந்தி செயல்பட்டால், உலகத்தையே வெல்ல நினைத்தாலும் வெல்ல முடியும்.",
            explanationEnglish: "Act with discerning knowledge of right timing and right ground; then there is nothing on earth impossible to conquer."
        ),
        Thirukkural(
            number: 591,
            section: "பொருட்பால்",
            chapter: "ஊக்கமுடைமை",
            line1: "உடையர் எனப்படுவது ஊக்கம் அஃதில்லார்",
            line2: "உடையது உடையரோ மற்று.",
            explanationTamil: "ஊக்கமுடையவரே உண்மையில் எதையும் உடையவர் ஆவார்; ஊக்கம் இல்லாதவர் பிற பொருட்களை உடையவராக இருந்தாலும் எதையும் இல்லாதவரே.",
            explanationEnglish: "True wealth is energy and dedication of mind; those devoid of zeal possess nothing of true value though they own riches."
        ),
        Thirukkural(
            number: 611,
            section: "பொருட்பால்",
            chapter: "ஆள்வினையுடைமை",
            line1: "அருமை உடைத்தென்று அசாவாமை வேண்டும்",
            line2: "பெருமை முயற்சி தரும்.",
            explanationTamil: "இச்செயல் முடிப்பதற்கு மிகவும் கடினம் என்று எண்ணி தளரக் கூடாது; தளராமல் செய்யும் இடைவிடாத முயற்சியே பெருமை தரும்.",
            explanationEnglish: "Yield not to despair thinking a duty is arduous; persistent, tireless labor unfailingly yields high honor and success."
        ),
        Thirukkural(
            number: 619,
            section: "பொருட்பால்",
            chapter: "ஆள்வினையுடைமை",
            line1: "தெய்வத்தான் ஆகா தெனினும் முயற்சிதன்",
            line2: "மெய்வருத்தக் கூலி தரும்.",
            explanationTamil: "விதியால் ஒரு காரியம் நிறைவேறாமல் போனாலும், உடலை வருத்திச் செய்த முயற்சிக்குத் தக்க பலன் நிச்சயமாகக் கிடைக்கும்.",
            explanationEnglish: "Though adverse fate should bar the way, labor will never fail to yield the just wages of resolute bodily endeavor."
        ),
        Thirukkural(
            number: 666,
            section: "பொருட்பால்",
            chapter: "வினைத்திட்பம்",
            line1: "எண்ணிய எண்ணியாங்கு எய்துப எண்ணியார்",
            line2: "திண்ணியர் ஆகப் பெறின்.",
            explanationTamil: "செயலைத் தொடங்கியவர்கள் மனஉறுதி உடையவர்களாக இருந்தால், அவர்கள் எண்ணிய செயல்களை எண்ணியவாறே நிறைவேற்றுவர்.",
            explanationEnglish: "Those who undertake an enterprise will achieve exactly what they envisioned, provided their resolve remains steadfast."
        ),
        Thirukkural(
            number: 761,
            section: "பொருட்பால்",
            chapter: "படைமாட்சி",
            line1: "உறுப்பமைந்து ஊறஞ்சா வெல்படை வேந்தன்",
            line2: "வெறுக்கையுள் எல்லாம் தலை.",
            explanationTamil: "அனைத்து அங்கங்களும் நிறைந்து, போர்க்களத் துன்பங்களுக்கு அஞ்சாமல் வெற்றி பெறும் படையே ஓர் அரசினுடைய செல்வங்களில் தலையாயது.",
            explanationEnglish: "A force complete in every technical discipline, undaunted by hardship, is the crown jewel of all sovereign defense."
        ),
        Thirukkural(
            number: 1021,
            section: "பொருட்பால்",
            chapter: "குடிசெயல்வகை",
            line1: "கருமஞ்செய் ஒருவன் கைதூவேன் என்னும்",
            line2: "பெருமையின் பீடுடையது இல்.",
            explanationTamil: "என் குடி மற்றும் நாட்டின் நற்பணிகளை ஓயாமல் செய்வேன் என்று ஒருவன் கொண்டுள்ள உறுதிப்பாட்டை விடப் பெருமையானது வேறொன்றும் இல்லை.",
            explanationEnglish: "There is no dignity higher on earth than that of one who pledges: 'I will never rest from serving my society and people.'"
        )
    ]

    public static func getTodayKural(offsetDays: Int = 0) -> Thirukkural {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Kolkata") ?? .current
        let dayOfYear = cal.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let year = cal.component(.year, from: Date())
        let combined = dayOfYear + (year - 2026) * 365 + offsetDays
        let index = ((combined % kurals.count) + kurals.count) % kurals.count
        return kurals[index]
    }
}

// MARK: - Daily Motivational Quotes (Source: Android MotivationalQuotes.kt)

public struct MotivationalQuote: Identifiable, Equatable {
    public let id: String
    public let quote: String
    public let author: String
    public let designationOrField: String
    public let category: String

    public init(id: String, quote: String, author: String, designationOrField: String, category: String) {
        self.id = id
        self.quote = quote
        self.author = author
        self.designationOrField = designationOrField
        self.category = category
    }
}

public struct MotivationalQuotesRepository {
    public static let quotes: [MotivationalQuote] = [
        MotivationalQuote(
            id: "Q-001",
            quote: "You have to dream before your dreams can come true. Single-minded devotion to your goal is the secret of success.",
            author: "Dr. A.P.J. Abdul Kalam",
            designationOrField: "Former President of India & Scientist",
            category: "Vision & Excellence"
        ),
        MotivationalQuote(
            id: "Q-002",
            quote: "Arise, awake, and stop not until the goal is reached. All power is within you; you can do anything and everything.",
            author: "Swami Vivekananda",
            designationOrField: "Philosopher & Spiritual Leader",
            category: "Inner Strength"
        ),
        MotivationalQuote(
            id: "Q-003",
            quote: "Manpower without unity is not a strength unless it is harmonized and united properly, then it becomes a liberation force.",
            author: "Sardar Vallabhbhai Patel",
            designationOrField: "Iron Man of India",
            category: "Unity & Duty"
        ),
        MotivationalQuote(
            id: "Q-004",
            quote: "The future depends on what you do today. In the realm of duty, dedication is the greatest armor.",
            author: "Mahatma Gandhi",
            designationOrField: "Father of the Nation",
            category: "Dedication"
        ),
        MotivationalQuote(
            id: "Q-005",
            quote: "It always seems impossible until it's done. Resolute action transforms vision into reality.",
            author: "Nelson Mandela",
            designationOrField: "Global Statesman & Leader",
            category: "Perseverance"
        ),
        MotivationalQuote(
            id: "Q-006",
            quote: "In the middle of difficulty lies opportunity. Technical mastery turns challenges into solutions.",
            author: "Albert Einstein",
            designationOrField: "Theoretical Physicist",
            category: "Innovation"
        ),
        MotivationalQuote(
            id: "Q-007",
            quote: "Technology is only an enabler; the true power resides in the disciplined minds that wield it.",
            author: "Police Technical Wing Motto",
            designationOrField: "Tamil Nadu Police Technical Services",
            category: "Professional Pride"
        ),
        MotivationalQuote(
            id: "Q-008",
            quote: "Discipline is the bridge between goals and accomplishment. A disciplined force is invincible.",
            author: "Jim Rohn",
            designationOrField: "Author & Motivational Speaker",
            category: "Discipline"
        )
    ]

    public static func getTodayQuote(offsetDays: Int = 0) -> MotivationalQuote {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Kolkata") ?? .current
        let dayOfYear = cal.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let year = cal.component(.year, from: Date())
        let combined = dayOfYear + (year - 2026) * 365 + offsetDays
        let index = ((combined % quotes.count) + quotes.count) % quotes.count
        return quotes[index]
    }
}

// MARK: - Daily Observance Days (Source: Android SpecialDays.kt)

public struct DailyObservance: Identifiable, Equatable {
    public var id: String { "\(date)_\(name)" }
    public let date: String        // "MM-DD" e.g. "11-23"
    public let name: String
    public let category: String
    public let description: String

    public init(date: String, name: String, category: String, description: String) {
        self.date = date
        self.name = name
        self.category = category
        self.description = description
    }
}

public struct DailyObservancesRepository {
    public static let observances: [DailyObservance] = [
        DailyObservance(date: "01-12", name: "National Youth Day", category: "India", description: "Celebrates the birth anniversary of Swami Vivekananda and inspires young people."),
        DailyObservance(date: "01-15", name: "Thiruvalluvar Day & Army Day", category: "India", description: "Remembering the timeless ethical maxims of Saint Thiruvalluvar and saluting our brave soldiers."),
        DailyObservance(date: "01-26", name: "Republic Day", category: "India", description: "Celebrates the adoption of the Constitution of India in 1950."),
        DailyObservance(date: "02-28", name: "National Science Day", category: "India", description: "Commemorates C.V. Raman's discovery of the Raman Effect."),
        DailyObservance(date: "03-08", name: "International Women's Day", category: "Women", description: "Recognises women's achievements and promotes gender equality."),
        DailyObservance(date: "05-11", name: "National Technology Day", category: "India", description: "Recognises India's achievements in science, technology and innovation."),
        DailyObservance(date: "05-17", name: "World Telecommunication Day", category: "Technology", description: "Raises awareness about information and communication technologies in modern society."),
        DailyObservance(date: "06-05", name: "World Environment Day", category: "Environment", description: "Encourages global action to protect the environment and combat climate change."),
        DailyObservance(date: "06-21", name: "International Day of Yoga", category: "India", description: "Promotes yoga and its benefits for physical and mental well-being."),
        DailyObservance(date: "08-15", name: "Independence Day", category: "India", description: "Celebrates India's independence from British rule in 1947."),
        DailyObservance(date: "10-21", name: "Police Commemoration Day", category: "India", description: "Tribute to fallen police heroes who made the supreme sacrifice in the line of duty."),
        DailyObservance(date: "10-31", name: "National Unity Day", category: "India", description: "Commemorates Sardar Vallabhbhai Patel and promotes national unity and solidarity."),
        DailyObservance(date: "11-19", name: "International Men's Day & National Integration Day", category: "Society", description: "Commemorates Indira Gandhi's birth anniversary and promotes national harmony."),
        DailyObservance(date: "11-20", name: "World Children's Day", category: "Children", description: "Promotes children's rights, welfare, education, and protection globally."),
        DailyObservance(date: "11-21", name: "World Television Day", category: "Media", description: "Recognises television's role in communication, public security, and public awareness."),
        DailyObservance(date: "11-26", name: "Constitution Day", category: "India", description: "Commemorates the adoption of the Constitution of India in 1949 by the Constituent Assembly."),
        DailyObservance(date: "12-04", name: "Indian Navy Day", category: "India", description: "Recognises the achievements and heroic maritime service of the Indian Navy."),
        DailyObservance(date: "12-07", name: "Armed Forces Flag Day", category: "India", description: "Honours India's armed forces personnel and supports welfare of martyrs' families.")
    ]

    public static func getTodayObservances() -> [DailyObservance] {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Kolkata") ?? .current
        let m = cal.component(.month, from: Date())
        let d = cal.component(.day, from: Date())
        let todayStr = String(format: "%02d-%02d", m, d)
        return observances.filter { $0.date == todayStr }
    }
}

// MARK: - Tech Platform Bulletins & Categories (Source: Android TechPlatformData.kt)

public enum TechCategory: String, CaseIterable, Identifiable {
    case all = "ALL"
    case wirelessRadio = "WIRELESS_RADIO"
    case govtOrder = "GOVT_ORDER"
    case chiefOfficeCircular = "CHIEF_OFFICE_CIRCULAR"
    case cyberSecurity = "CYBER_SECURITY"
    case surveillanceCctv = "SURVEILLANCE_CCTV"
    case controlRoom112 = "CONTROL_ROOM_112"
    case hardwareTower = "HARDWARE_TOWER"
    case technicalSop = "TECHNICAL_SOP"

    public static let WIRELESS_RADIO = TechCategory.wirelessRadio.rawValue
    public static let CCTV_SURVEILLANCE = TechCategory.surveillanceCctv.rawValue
    public static let NETWORK_CYBER = TechCategory.cyberSecurity.rawValue
    public static let COMPUTER_HARDWARE = TechCategory.hardwareTower.rawValue
    public static let SOFTWARE_APPS = TechCategory.technicalSop.rawValue
    public static let ADMIN_GOS = TechCategory.govtOrder.rawValue

    public var id: String { rawValue }

    public var displayNameEn: String {
        switch self {
        case .all: return "All Updates"
        case .wirelessRadio: return "Wireless & DMR"
        case .govtOrder: return "TN Govt Orders (GOs)"
        case .chiefOfficeCircular: return "Police Circulars"
        case .cyberSecurity: return "Cyber & IT Security"
        case .surveillanceCctv: return "CCTV & AI Surveillance"
        case .controlRoom112: return "Control Room & 112 ERSS"
        case .hardwareTower: return "Masts, Power & Towers"
        case .technicalSop: return "Technical SOPs"
        }
    }
}

public struct TechBulletin: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let titleTa: String
    public let category: TechCategory
    public let date: String
    public let referenceNo: String
    public let issuingAuthority: String
    public let priority: String // "URGENT", "HIGH", "NORMAL", "SOP"
    public let summary: String
    public let detailedContent: String
    public let tags: [String]
    public let documentUrl: String

    public init(
        id: String,
        title: String,
        titleTa: String = "",
        category: TechCategory,
        date: String,
        referenceNo: String,
        issuingAuthority: String,
        priority: String = "NORMAL",
        summary: String,
        detailedContent: String,
        tags: [String] = [],
        documentUrl: String = ""
    ) {
        self.id = id
        self.title = title
        self.titleTa = titleTa
        self.category = category
        self.date = date
        self.referenceNo = referenceNo
        self.issuingAuthority = issuingAuthority
        self.priority = priority
        self.summary = summary
        self.detailedContent = detailedContent
        self.tags = tags
        self.documentUrl = documentUrl
    }
}

public struct TechPlatformRepository {
    public static let builtInBulletins: [TechBulletin] = [
        TechBulletin(
            id: "tb_002",
            title: "VHF / UHF Static & Mobile Wireless Operating Protocol & Code Discipline",
            titleTa: "VHF / UHF வயர்லெஸ் நெறிமுறைகள் மற்றும் சமிக்ஞை குறியீட்டு ஒழுங்குமுறை",
            category: .chiefOfficeCircular,
            date: "2024-10-05",
            referenceNo: "Chief Office Circular No. 14/Tech/DGP/2024",
            issuingAuthority: "Director General of Police, Tamil Nadu",
            priority: "URGENT",
            summary: "Mandatory standard operating procedures for wireless network discipline, police code words, call-sign verification, and emergency channel preemption during VIP security.",
            detailedContent: """
                1. General Wireless Protocol:
                All wireless transmissions on District Police Networks (Static, Mobile, and Walkie-Talkie channels) must adhere strictly to established police communication etiquette.

                2. Mandatory Instructions:
                • Strict adherence to authorized Tamil Nadu Police 10-Codes and phonetic call-signs.
                • Transmission length must be concise (not exceeding 30 seconds per transmission) to prevent carrier blockage.
                • 'Channel 1' (Control to Mobile) must remain clear for flash alerts, distress calls, and law & order emergencies.
                • Unofficial chatter or casual language on repeater frequencies is strictly prohibited and subject to disciplinary action.

                3. VIP Band & Security:
                During VIP movements, designated tactical repeater frequencies shall be activated. District Technical Officers must conduct range checks 3 hours prior to convoys.
            """,
            tags: ["Wireless", "SOP", "10-Codes", "VHF", "Circular"]
        ),
        TechBulletin(
            id: "tb_003",
            title: "DMR Tier-II / Tier-III Digital Trunked Radio Maintenance & RF Tuning",
            titleTa: "DMR டிஜிட்டல் வயர்லெஸ் பராமரிப்பு மற்றும் RF அலைவரிசை சரிசெய்தல்",
            category: .wirelessRadio,
            date: "2024-10-24",
            referenceNo: "Tech Advisory PTB/RAD-2024/09",
            issuingAuthority: "Superintendent of Police, Technical Services",
            priority: "NORMAL",
            summary: "Preventive maintenance protocols for Motorola & Hytera digital repeaters, antenna VSWR calibration (<1.5), and duplexer cavity tuning.",
            detailedContent: """
                1. Digital Repeater Inspection Checklist:
                • Measure transmitter Forward Power and Reflected Power using calibrated Bird Thruline Wattmeters.
                • Ensure Voltage Standing Wave Ratio (VSWR) is strictly below 1.5:1. Any reading above 1.8 indicates feeder cable water ingress or connector degradation.
                • Verify Duplexer Isolation: TX to RX isolation must exceed 75 dB to avoid receiver desensitization.

                2. Base Station Battery Guidelines:
                • Float charge voltage must be maintained at 13.6V - 13.8V DC per 12V block.
                • Equalization charge to be given once every 60 days to prevent battery plate sulfation.
                • Ensure terminal lugs are coated with petroleum jelly to prevent acid corrosion.
            """,
            tags: ["DMR", "Repeater", "VSWR", "Battery", "Radio"]
        ),
        TechBulletin(
            id: "tb_004",
            title: "112 ERSS Master Console & Mobile Data Terminal (MDT) Field Troubleshooting",
            titleTa: "112 ERSS கட்டுப்பாட்டு மையம் & வாகன MDT கணினி சரிசெய்தல் வழிகாட்டி",
            category: .controlRoom112,
            date: "2024-11-02",
            referenceNo: "Tech Manual ERSS-TN-Vol-3",
            issuingAuthority: "State Emergency Response Centre (SERC), Chennai",
            priority: "SOP",
            summary: "Field troubleshooting guide for patrol vehicle Mobile Data Terminals (MDT), CAD sync drops, GPS antenna alignment, and audio routing.",
            detailedContent: """
                1. Frequent MDT Issues & Remediation:
                • Symptom: MDT shows 'CAD Disconnected' while vehicle has GSM network signal.
                  Remedy: Clear CAD cache from App Settings -> Force Stop CAD -> Re-launch CAD.
                • Symptom: Vehicle location frozen on SERC map console.
                  Remedy: Inspect external active GPS puck antenna mounted on vehicle roof. Ensure connector is tightened to 4 Nm.
            """,
            tags: ["112 ERSS", "MDT", "CAD", "GPS", "Control Room"]
        ),
        TechBulletin(
            id: "tb_005",
            title: "CCTNS & State Police IT Infrastructure Cyber Hardening Guidelines",
            titleTa: "CCTNS மற்றும் காவல்துறை கணினி நெட்வொர்க் சைபர் பாதுகாப்பு வழிகாட்டுதல்கள்",
            category: .cyberSecurity,
            date: "2024-11-10",
            referenceNo: "Advisory CERT-TN-POL-08/2024",
            issuingAuthority: "Cyber Crime Wing & Chief Office IT Cell",
            priority: "URGENT",
            summary: "Crucial cyber safety measures: network segmentation for CCTNS workstations, disabling legacy SMBv1, endpoint antivirus updates, and USB port lockdown.",
            detailedContent: """
                1. Mandatory Security Baseline:
                • Station CCTNS systems must operate on segregated VLANs with zero direct routing to commercial public internet.
                • USB mass storage devices are strictly blocked by Group Policy. Unauthorized flash drives will trigger security alerts at State Data Centre (SDC).
                • Disable legacy SMBv1 and Windows Remote Desktop (RDP) on all client terminals.
            """,
            tags: ["Cyber", "CCTNS", "Security", "Antivirus", "IT Cell"]
        ),
        TechBulletin(
            id: "tb_007",
            title: "Artificial Intelligence ANPR & CCTV Camera Optimization Standards",
            titleTa: "AI தானியங்கி வாகன எண் பலகை கண்டறிதல் மற்றும் சிசிடிவி தொழில்நுட்ப வழிகாட்டுதல்",
            category: .surveillanceCctv,
            date: "2024-11-08",
            referenceNo: "Tech Bulletin CCTV-AI-2024/04",
            issuingAuthority: "Technical Services Directorate, Chennai",
            priority: "NORMAL",
            summary: "Technical parameters for Automatic Number Plate Recognition (ANPR), H.265 compression bitrate calculation, and camera lens cleaning schedules.",
            detailedContent: """
                1. ANPR Optical Parameters:
                • Camera mounting height: 4.5m to 5.5m at a maximum horizontal angle of 15° to traffic flow.
                • Shutter speed must be set to minimum 1/1000 sec to eliminate motion blur of vehicles traveling up to 100 km/h.
                • IR Illuminators: Ensure synchronized 850nm infrared strobe for night license plate capture without plate glare.
            """,
            tags: ["CCTV", "ANPR", "AI", "Surveillance", "Storage"]
        )
    ]
}
