import SwiftUI

// MARK: - Employee Directory View (Matching Android DirectorySection)

public struct ContactsSectionView: View {
    @EnvironmentObject private var store: AppStore

    // Sub-section expansion states
    @State private var favouritesExpanded = true
    @State private var technicalExpanded = false
    @State private var executiveExpanded = false
    @State private var ptbOpen = false
    @State private var districtsOpen = false
    @State private var citiesOpen = false
    @State private var battalionOpen = false
    @State private var repeatersOpen = false
    @State private var specialOpen = false
    @State private var ministerialOpen = false

    // Selection states for drilling down
    @State private var expandedRank: String? = nil
    @State private var selectedExecutiveUnit: String? = nil
    @State private var selectedPtbUnit: String? = nil
    @State private var selectedDistrictZone: String? = nil
    @State private var selectedDistrictRange: String? = nil
    @State private var selectedDistrictUnit: String? = nil
    @State private var selectedCityUnit: String? = nil
    @State private var selectedBattalionUnit: String? = nil
    @State private var selectedRepeaterUnit: String? = nil
    @State private var selectedSpecialUnit: String? = nil
    @State private var selectedMinisterialUnit: String? = nil

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let roster = store.contacts
            let counts = store.dashboardData

            // 0. Favourite Contacts (if any saved)
            let favs = roster.filter { c in
                let digits = c.mobile.filter { $0.isNumber }
                let last10 = String(digits.suffix(10))
                return !last10.isEmpty && store.favoriteNumbers.contains(last10)
            }

            if !favs.isEmpty {
                ExpandableSection(title: "Favourite Contacts (\(favs.count))", isExpanded: $favouritesExpanded) {
                    VStack(spacing: 3) {
                        ForEach(favs.indices, id: \.self) { idx in
                            let contact = favs[idx]
                            let digits = String(contact.mobile.filter { $0.isNumber }.suffix(10))
                            ContactRowView(
                                contact: contact,
                                isDarker: idx % 2 == 1,
                                isFavorite: true,
                                onToggleFavorite: { store.toggleFavorite(digits) }
                            )
                        }
                    }
                }
            }

            // 1. Technical Officers
            ExpandableSection(title: "Technical Officers", isExpanded: $technicalExpanded) {
                VStack(spacing: 6) {
                    TechnicalOfficerGroupCard(
                        title: "SP (T)",
                        count: counts?.sps,
                        officers: counts?.spOfficers ?? [],
                        isExpanded: expandedRank == "sp"
                    ) {
                        expandedRank = (expandedRank == "sp") ? nil : "sp"
                    }

                    TechnicalOfficerGroupCard(
                        title: "Addl. SP (T)",
                        count: counts?.addlSps,
                        officers: counts?.addlSpOfficers ?? [],
                        isExpanded: expandedRank == "addlSp"
                    ) {
                        expandedRank = (expandedRank == "addlSp") ? nil : "addlSp"
                    }

                    TechnicalOfficerGroupCard(
                        title: "DSP (T)",
                        count: counts?.dsps,
                        officers: counts?.dspOfficers ?? [],
                        isExpanded: expandedRank == "dsp"
                    ) {
                        expandedRank = (expandedRank == "dsp") ? nil : "dsp"
                    }

                    TechnicalOfficerGroupCard(
                        title: "Inspector (T)",
                        count: counts?.inspectors,
                        officers: counts?.inspectorOfficers ?? [],
                        isExpanded: expandedRank == "inspector"
                    ) {
                        expandedRank = (expandedRank == "inspector") ? nil : "inspector"
                    }

                    TechnicalOfficerGroupCard(
                        title: "SI (T)",
                        count: counts?.subInspectors,
                        officers: counts?.siOfficers ?? [],
                        isExpanded: expandedRank == "si"
                    ) {
                        expandedRank = (expandedRank == "si") ? nil : "si"
                    }
                }
            }

            // 2. Executive Officers
            let execContacts = roster.filter(isExecutiveContact)
            if !execContacts.isEmpty {
                ExpandableSection(title: "Executive Officers", isExpanded: $executiveExpanded) {
                    ContactUnitGroupsView(
                        contacts: execContacts,
                        selected: selectedExecutiveUnit,
                        depth: 1,
                        favoriteNumbers: store.favoriteNumbers,
                        onToggleFavorite: { store.toggleFavorite($0) }
                    ) { unit in
                        selectedExecutiveUnit = (selectedExecutiveUnit == unit) ? nil : unit
                    }
                }
            }

            // 3. PTB Hqrs
            ExpandableSection(title: "PTB Hqrs", isExpanded: $ptbOpen) {
                let ptbContacts = roster.filter(isPtbHqrsContact)
                ContactUnitGroupsView(
                    contacts: ptbContacts,
                    selected: selectedPtbUnit,
                    depth: 1,
                    favoriteNumbers: store.favoriteNumbers,
                    onToggleFavorite: { store.toggleFavorite($0) }
                ) { unit in
                    selectedPtbUnit = (selectedPtbUnit == unit) ? nil : unit
                }
            }

            // 4. Districts (Zone -> Range -> Unit)
            ExpandableSection(title: "Districts", isExpanded: $districtsOpen) {
                let districtContacts = roster.filter(isDistrictContact)
                let zoneNames = Array(Set(Array(ZONE_RANGE_MAP.keys) + districtContacts.map(\.zone)))
                    .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                    .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }

                VStack(spacing: 5) {
                    ForEach(zoneNames, id: \.self) { zone in
                        let ranged = districtContacts.filter { normalizedOrgLabel($0.zone) == normalizedOrgLabel(zone) }
                        let isZoneSelected = selectedDistrictZone == zone

                        LocationGroupHeader(
                            title: zone,
                            isExpanded: isZoneSelected,
                            depth: 0
                        ) {
                            selectedDistrictZone = isZoneSelected ? nil : zone
                        }

                        if isZoneSelected {
                            let availableRanges = Array(Set(
                                (ZONE_RANGE_MAP[zone] ?? []).filter { !$0.localizedCaseInsensitiveContains("city") } +
                                ranged.map(\.range)
                            )).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty && !$0.localizedCaseInsensitiveContains("city") }
                              .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }

                            ForEach(availableRanges, id: \.self) { range in
                                let rangeKey = "\(zone)|\(range)"
                                let isRangeSelected = selectedDistrictRange == rangeKey
                                let rangeUnits = ranged.filter { normalizedOrgLabel($0.range) == normalizedOrgLabel(range) }

                                LocationGroupHeader(
                                    title: range,
                                    isExpanded: isRangeSelected,
                                    depth: 1
                                ) {
                                    selectedDistrictRange = isRangeSelected ? nil : rangeKey
                                }

                                if isRangeSelected {
                                    ContactUnitGroupsView(
                                        contacts: rangeUnits,
                                        selected: selectedDistrictUnit,
                                        depth: 2,
                                        primaryUnit: range,
                                        favoriteNumbers: store.favoriteNumbers,
                                        onToggleFavorite: { store.toggleFavorite($0) }
                                    ) { unit in
                                        selectedDistrictUnit = (selectedDistrictUnit == unit) ? nil : unit
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 5. Cities
            ExpandableSection(title: "Cities", isExpanded: $citiesOpen) {
                let cityContacts = roster.filter(isCityContact)
                ContactUnitGroupsView(
                    contacts: cityContacts,
                    selected: selectedCityUnit,
                    depth: 1,
                    favoriteNumbers: store.favoriteNumbers,
                    onToggleFavorite: { store.toggleFavorite($0) }
                ) { unit in
                    selectedCityUnit = (selectedCityUnit == unit) ? nil : unit
                }
            }

            // 6. Battalion
            ExpandableSection(title: "Battalion", isExpanded: $battalionOpen) {
                let battalionContacts = roster.filter(isBattalionContact)
                ContactUnitGroupsView(
                    contacts: battalionContacts,
                    selected: selectedBattalionUnit,
                    depth: 1,
                    favoriteNumbers: store.favoriteNumbers,
                    onToggleFavorite: { store.toggleFavorite($0) }
                ) { unit in
                    selectedBattalionUnit = (selectedBattalionUnit == unit) ? nil : unit
                }
            }

            // 7. Repeaters
            ExpandableSection(title: "Repeaters", isExpanded: $repeatersOpen) {
                let repeaterContacts = roster.filter(isRepeaterContact)
                ContactUnitGroupsView(
                    contacts: repeaterContacts,
                    selected: selectedRepeaterUnit,
                    depth: 1,
                    favoriteNumbers: store.favoriteNumbers,
                    onToggleFavorite: { store.toggleFavorite($0) }
                ) { unit in
                    selectedRepeaterUnit = (selectedRepeaterUnit == unit) ? nil : unit
                }
            }

            // 8. Special units
            ExpandableSection(title: "Special units", isExpanded: $specialOpen) {
                let specialContacts = roster.filter(isSpecialDirectoryContact)
                ContactUnitGroupsView(
                    contacts: specialContacts,
                    selected: selectedSpecialUnit,
                    depth: 1,
                    favoriteNumbers: store.favoriteNumbers,
                    onToggleFavorite: { store.toggleFavorite($0) }
                ) { unit in
                    selectedSpecialUnit = (selectedSpecialUnit == unit) ? nil : unit
                }
            }

            // 9. Ministerial Staff
            ExpandableSection(title: "Ministerial Staff", isExpanded: $ministerialOpen) {
                let ministerialContacts = roster.filter(isMinisterialContact)
                ContactUnitGroupsView(
                    contacts: ministerialContacts,
                    selected: selectedMinisterialUnit,
                    depth: 1,
                    prioritizedUnits: ["CC to DIG Camp", "CC to IGP Camp", "AO Accounts", "AO Admin", "A-Section"],
                    ministerialOrder: true,
                    favoriteNumbers: store.favoriteNumbers,
                    onToggleFavorite: { store.toggleFavorite($0) }
                ) { unit in
                    selectedMinisterialUnit = (selectedMinisterialUnit == unit) ? nil : unit
                }
            }
        }
    }
}

// MARK: - Unit Grouping & Contact Listing Helper

public struct ContactUnitGroupsView: View {
    public let contacts: [Contact]
    public let selected: String?
    public let depth: Int
    public var primaryUnit: String? = nil
    public var prioritizedUnits: [String] = []
    public var ministerialOrder: Bool = false
    public var favoriteNumbers: Set<String> = []
    public var onToggleFavorite: ((String) -> Void)? = nil
    public let onSelect: (String) -> Void

    public init(
        contacts: [Contact],
        selected: String?,
        depth: Int,
        primaryUnit: String? = nil,
        prioritizedUnits: [String] = [],
        ministerialOrder: Bool = false,
        favoriteNumbers: Set<String> = [],
        onToggleFavorite: ((String) -> Void)? = nil,
        onSelect: @escaping (String) -> Void
    ) {
        self.contacts = contacts
        self.selected = selected
        self.depth = depth
        self.primaryUnit = primaryUnit
        self.prioritizedUnits = prioritizedUnits
        self.ministerialOrder = ministerialOrder
        self.favoriteNumbers = favoriteNumbers
        self.onToggleFavorite = onToggleFavorite
        self.onSelect = onSelect
    }

    private var groupedUnits: [(key: String, officers: [Contact])] {
        let dict = Dictionary(grouping: contacts) {
            $0.unit.trimmingCharacters(in: .whitespaces).isEmpty ? "Unit not specified" : $0.unit.trimmingCharacters(in: .whitespaces)
        }

        return dict.keys.sorted { a, b in
            if let primary = primaryUnit {
                let isPriA = normalizedOrgLabel(a) == normalizedOrgLabel(primary)
                let isPriB = normalizedOrgLabel(b) == normalizedOrgLabel(primary)
                if isPriA && !isPriB { return true }
                if !isPriA && isPriB { return false }
            }
            let idxA = prioritizedUnits.firstIndex(where: { normalizedOrgLabel($0) == normalizedOrgLabel(a) }) ?? Int.max
            let idxB = prioritizedUnits.firstIndex(where: { normalizedOrgLabel($0) == normalizedOrgLabel(b) }) ?? Int.max
            if idxA != idxB { return idxA < idxB }
            return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
        }.map { (key: $0, officers: dict[$0] ?? []) }
    }

    public var body: some View {
        if groupedUnits.isEmpty {
            Text("No contacts listed.")
                .font(.system(size: 12))
                .foregroundStyle(Color.secondary)
                .padding(.leading, CGFloat(depth * 8))
                .padding(.vertical, 4)
        } else {
            VStack(spacing: 4) {
                ForEach(groupedUnits, id: \.key) { entry in
                    LocationGroupHeader(
                        title: entry.key,
                        isExpanded: selected == entry.key,
                        depth: depth
                    ) {
                        onSelect(entry.key)
                    }

                    if selected == entry.key {
                        let sortedOfficers = sortedContacts(entry.officers)
                        VStack(spacing: 3) {
                            ForEach(sortedOfficers.indices, id: \.self) { idx in
                                let c = sortedOfficers[idx]
                                let digits = String(c.mobile.filter { $0.isNumber }.suffix(10))
                                ContactRowView(
                                    contact: c,
                                    isDarker: idx % 2 == 1,
                                    isFavorite: favoriteNumbers.contains(digits),
                                    onToggleFavorite: { onToggleFavorite?(digits) }
                                )
                            }
                        }
                        .padding(.leading, CGFloat((depth + 1) * 6))
                        .padding(.vertical, 2)
                    }
                }
            }
        }
    }

    private func sortedContacts(_ list: [Contact]) -> [Contact] {
        if ministerialOrder {
            return sortContactsMinisterial(list)
        } else {
            return sortContactsStandard(list)
        }
    }
}
