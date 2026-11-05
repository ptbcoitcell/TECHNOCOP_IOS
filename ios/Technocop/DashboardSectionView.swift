import SwiftUI

struct DashboardSectionView: View {
    @EnvironmentObject private var store: AppStore
    
    @State private var batchStrengthExpanded = false
    @State private var ptbStrengthExpanded = false
    @State private var citySectionExpanded = false
    @State private var zoneSectionExpanded = false
    @State private var rangeSectionExpanded = false
    @State private var specialStrengthExpanded = false
    @State private var ministerialExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Last refreshed timestamp & quiet offline banner
            if let lastRefreshed = store.lastRefreshedAt {
                Text("Last refreshed \(formatRefreshTime(lastRefreshed))")
                    .font(.system(size: 11))
                    .foregroundStyle(TechTheme.textSubtitle)
            }

            if !store.offlineMessage.isEmpty {
                Text(store.offlineMessage)
                    .font(.system(size: 12))
                    .foregroundStyle(TechTheme.textError)
                    .padding(.bottom, 2)
            }

            // 1. Batch-wise Strength
            ExpandableSection(title: "Batch-wise Strength", isExpanded: $batchStrengthExpanded, contentHorizontalPadding: 0) {
                BatchStrengthTableView(contacts: store.contacts)
            }

            // 2. PTB Hqrs strength
            ExpandableSection(title: "PTB Hqrs strength", isExpanded: $ptbStrengthExpanded, contentHorizontalPadding: 0) {
                let ptbUnits = Dictionary(grouping: store.contacts.filter {
                    $0.unitCategory.trimmingCharacters(in: .whitespacesAndNewlines).caseInsensitiveCompare("PTB Hqrs") == .orderedSame
                }) { $0.unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Unit not specified" : $0.unit.trimmingCharacters(in: .whitespacesAndNewlines) }

                if ptbUnits.isEmpty && store.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(16)
                } else if ptbUnits.isEmpty {
                    Text("No contacts found where Unit_Categ is PTB Hqrs.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                        .padding(12)
                } else {
                    let sortedKeys = ptbUnits.keys.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
                    let rows = sortedKeys.map { unit in
                        StrengthTableRowItem(label: unit, strength: rankCounts(for: ptbUnits[unit] ?? []))
                    }
                    CompactStrengthTableView(rows: rows, firstColumnTitle: "Unit")
                }
            }

            // 3. City-wise Strength
            ExpandableSection(title: "City-wise Strength", isExpanded: $citySectionExpanded, contentHorizontalPadding: 0) {
                let rows = CITY_SUMMARY_LOCATIONS.map { city in
                    let officers = store.contacts.filter {
                        normalizedOrgLabel($0.unit) == normalizedOrgLabel(city) && isCityContact($0)
                    }
                    return StrengthTableRowItem(label: city, strength: rankCounts(for: officers))
                }
                CompactStrengthTableView(rows: rows, firstColumnTitle: "City")
            }

            // 4. Zone-wise Strength
            ExpandableSection(title: "Zone-wise Strength", isExpanded: $zoneSectionExpanded, contentHorizontalPadding: 0) {
                let rows = ZONE_RANGE_MAP.keys.sorted().map { zone in
                    let officers = store.contacts.filter {
                        normalizedOrgLabel($0.zone) == normalizedOrgLabel(zone) &&
                        !isPtbHqrsContact($0) &&
                        !isCityContact($0) &&
                        !isRepeaterContact($0) &&
                        !isSpecialUnitContact($0)
                    }
                    return StrengthTableRowItem(label: zone, strength: rankCounts(for: officers))
                }
                CompactStrengthTableView(rows: rows, firstColumnTitle: "Zone")
            }

            // 5. Range-wise Strength
            ExpandableSection(title: "Range-wise Strength", isExpanded: $rangeSectionExpanded, contentHorizontalPadding: 0) {
                let districtStrengths = store.dashboardData?.districtStrengths ?? []
                let rows: [StrengthTableRowItem] = buildRangeRows(districtStrengths: districtStrengths)
                CompactStrengthTableView(rows: rows, rangeLayout: true, firstColumnTitle: "Zone")
            }

            // 6. Special Unit Strength
            ExpandableSection(title: "Special Unit Strength", isExpanded: $specialStrengthExpanded, contentHorizontalPadding: 0) {
                let specialUnits = Dictionary(grouping: store.contacts.filter {
                    $0.unitCategory.trimmingCharacters(in: .whitespacesAndNewlines).caseInsensitiveCompare("Special unit") == .orderedSame
                }) { $0.unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Unit not specified" : $0.unit.trimmingCharacters(in: .whitespacesAndNewlines) }

                if specialUnits.isEmpty && store.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(16)
                } else if specialUnits.isEmpty {
                    Text("No contacts found where Unit_Categ is Special unit.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                        .padding(12)
                } else {
                    let sortedKeys = specialUnits.keys.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
                    let rows = sortedKeys.map { unit in
                        StrengthTableRowItem(label: unit, strength: rankCounts(for: specialUnits[unit] ?? []))
                    }
                    CompactStrengthTableView(rows: rows, firstColumnTitle: "Unit")
                }
            }

            // 7. Ministerial Staff Strength
            ExpandableSection(title: "Ministerial Staff Strength", isExpanded: $ministerialExpanded, contentHorizontalPadding: 0) {
                let ministerial = store.contacts.filter(isMinisterialContact)
                if ministerial.isEmpty && store.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(16)
                } else if ministerial.isEmpty {
                    Text("No contacts found where Unit_Categ identifies Ministerial Staff.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                        .padding(12)
                } else {
                    MinisterialStrengthTableView(contacts: store.contacts)
                }
            }
        }
    }

    private func buildRangeRows(districtStrengths: [DistrictStrength]) -> [StrengthTableRowItem] {
        var result: [StrengthTableRowItem] = []
        for (zone, allRanges) in ZONE_RANGE_MAP.sorted(by: { $0.key < $1.key }) {
            // Zone level
            let zoneContacts = store.contacts.filter {
                normalizedOrgLabel($0.zone) == normalizedOrgLabel(zone) &&
                !isCityContact($0) &&
                !isPtbHqrsContact($0) &&
                !isRepeaterContact($0) &&
                !isSpecialUnitContact($0)
            }
            result.append(StrengthTableRowItem(label: zone, strength: rankCounts(for: zoneContacts), depth: 0))

            // Non-city ranges
            let nonCityRanges = allRanges.filter { !$0.localizedCaseInsensitiveContains("city") }
            for range in nonCityRanges {
                let rangeContacts = store.contacts.filter {
                    normalizedOrgLabel($0.zone) == normalizedOrgLabel(zone) &&
                    normalizedOrgLabel($0.range) == normalizedOrgLabel(range) &&
                    !isCityContact($0) &&
                    !isPtbHqrsContact($0) &&
                    !isRepeaterContact($0) &&
                    !isSpecialUnitContact($0)
                }
                result.append(StrengthTableRowItem(label: range, strength: rankCounts(for: rangeContacts), depth: 1))

                // Districts under this range
                let districts = districtStrengths.filter {
                    normalizedOrgLabel($0.zone) == normalizedOrgLabel(zone) &&
                    normalizedOrgLabel($0.range) == normalizedOrgLabel(range)
                }.sorted { $0.district.localizedCaseInsensitiveCompare($1.district) == .orderedAscending }

                for d in districts {
                    result.append(StrengthTableRowItem(
                        label: d.district,
                        strength: RankStrength(dsp: 0, inspector: d.inspectors, si: d.si),
                        depth: 2
                    ))
                }
            }
        }
        return result
    }

    private func formatRefreshTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

