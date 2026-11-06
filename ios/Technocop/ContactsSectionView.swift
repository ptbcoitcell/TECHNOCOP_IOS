import SwiftUI

struct ContactsSectionView: View {
    @EnvironmentObject private var store: AppStore

    // Sub-section expansion states
    @State private var technicalExpanded = false
    @State private var ptbOpen = false
    @State private var districtsOpen = false
    @State private var citiesOpen = false
    @State private var battalionOpen = false
    @State private var repeatersOpen = false
    @State private var specialOpen = false
    @State private var ministerialOpen = false

    // Selection states for drilling down
    @State private var expandedRank: String? = nil
    @State private var selectedPtbUnit: String? = nil
    @State private var selectedDistrictZone: String? = nil
    @State private var selectedDistrictRange: String? = nil
    @State private var selectedDistrictUnit: String? = nil
    @State private var selectedCityUnit: String? = nil
    @State private var selectedBattalionUnit: String? = nil
    @State private var selectedRepeaterUnit: String? = nil
    @State private var selectedSpecialUnit: String? = nil
    @State private var selectedMinisterialUnit: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let roster = store.contacts
            let counts = store.dashboardData

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

            // 2. PTB Hqrs
            ExpandableSection(title: "PTB Hqrs", isExpanded: $ptbOpen) {
                let ptbContacts = roster.filter(isPtbHqrsContact)
                ContactUnitGroupsView(
                    contacts: ptbContacts,
                    selected: selectedPtbUnit,
                    depth: 1
                ) { unit in
                    selectedPtbUnit = (selectedPtbUnit == unit) ? nil : unit
                }
            }

            // 3. Districts (Zone -> Range -> Unit)
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
                                        primaryUnit: range
                                    ) { unit in
                                        selectedDistrictUnit = (selectedDistrictUnit == unit) ? nil : unit
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 4. Cities
            ExpandableSection(title: "Cities", isExpanded: $citiesOpen) {
                let cityContacts = roster.filter(isCityContact)
                ContactUnitGroupsView(
                    contacts: cityContacts,
                    selected: selectedCityUnit,
                    depth: 1
                ) { unit in
                    selectedCityUnit = (selectedCityUnit == unit) ? nil : unit
                }
            }

            // 5. Battalion
            ExpandableSection(title: "Battalion", isExpanded: $battalionOpen) {
                let battalionContacts = roster.filter(isBattalionContact)
                ContactUnitGroupsView(
                    contacts: battalionContacts,
                    selected: selectedBattalionUnit,
                    depth: 1
                ) { unit in
                    selectedBattalionUnit = (selectedBattalionUnit == unit) ? nil : unit
                }
            }

            // 6. Repeaters
            ExpandableSection(title: "Repeaters", isExpanded: $repeatersOpen) {
                let repeaterContacts = roster.filter(isRepeaterContact)
                ContactUnitGroupsView(
                    contacts: repeaterContacts,
                    selected: selectedRepeaterUnit,
                    depth: 1
                ) { unit in
                    selectedRepeaterUnit = (selectedRepeaterUnit == unit) ? nil : unit
                }
            }

            // 7. Special units
            ExpandableSection(title: "Special units", isExpanded: $specialOpen) {
                let specialContacts = roster.filter(isSpecialDirectoryContact)
                ContactUnitGroupsView(
                    contacts: specialContacts,
                    selected: selectedSpecialUnit,
                    depth: 1
                ) { unit in
                    selectedSpecialUnit = (selectedSpecialUnit == unit) ? nil : unit
                }
            }

            // 8. Ministerial Staff
            ExpandableSection(title: "Ministerial Staff", isExpanded: $ministerialOpen) {
                let ministerialContacts = roster.filter(isMinisterialContact)
                ContactUnitGroupsView(
                    contacts: ministerialContacts,
                    selected: selectedMinisterialUnit,
                    depth: 1,
                    prioritizedUnits: ["CC to DIG Camp", "CC to IGP Camp", "AO Accounts", "AO Admin", "A-Section"],
                    ministerialOrder: true
                ) { unit in
                    selectedMinisterialUnit = (selectedMinisterialUnit == unit) ? nil : unit
                }
            }
        }
    }
}

// MARK: - Unit Grouping & Contact Listing Helper

struct ContactUnitGroupsView: View {
    let contacts: [Contact]
    let selected: String?
    let depth: Int
    var primaryUnit: String? = nil
    var prioritizedUnits: [String] = []
    var ministerialOrder: Bool = false
    let onSelect: (String) -> Void

    private var groupedUnits: [(key: String, officers: [Contact])] {
        let dict = Dictionary(grouping: contacts) {
            $0.unit.trimmingCharacters(in: .whitespaces).isEmpty ? "Unit not specified" : $0.unit.trimmingCharacters(in: .whitespaces)
        }
        
        return dict.keys.sorted { a, b in
            // Primary unit comes first if specified
            if let primary = primaryUnit {
                let isPriA = normalizedOrgLabel(a) == normalizedOrgLabel(primary)
                let isPriB = normalizedOrgLabel(b) == normalizedOrgLabel(primary)
                if isPriA && !isPriB { return true }
                if !isPriA && isPriB { return false }
            }
            // Prioritized units
            let idxA = prioritizedUnits.firstIndex(where: { normalizedOrgLabel($0) == normalizedOrgLabel(a) }) ?? Int.max
            let idxB = prioritizedUnits.firstIndex(where: { normalizedOrgLabel($0) == normalizedOrgLabel(b) }) ?? Int.max
            if idxA != idxB { return idxA < idxB }
            return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
        }.map { (key: $0, officers: dict[$0] ?? []) }
    }

    var body: some View {
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
                                ContactRowView(contact: sortedOfficers[idx], isDarker: idx % 2 == 1)
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
            return list.sorted { a, b in
                let ordA = ministerialRankOrder(a.rank)
                let ordB = ministerialRankOrder(b.rank)
                if ordA != ordB { return ordA < ordB }
                return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
            }
        } else {
            return list.sorted { a, b in
                let batchA = Int(a.batch.filter { $0.isNumber }) ?? Int.max
                let batchB = Int(b.batch.filter { $0.isNumber }) ?? Int.max
                if batchA != batchB { return batchA < batchB }
                let rankA = rankOrder(a.rank)
                let rankB = rankOrder(b.rank)
                if rankA != rankB { return rankA < rankB }
                return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
            }
        }
    }
}

