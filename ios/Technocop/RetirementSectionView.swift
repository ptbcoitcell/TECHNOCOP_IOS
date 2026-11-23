import SwiftUI

struct RetirementSectionView: View {
    let forecast: RetirementForecast?
    let contacts: [Contact]
    let onRefresh: () -> Void

    @EnvironmentObject var themeManager: TechThemeManager
    @State private var selectedCategory: String = "technical"
    @State private var expandedYear: Int? = nil

    private var contactByName: [String: Contact] {
        Dictionary(contacts.map { ($0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), $0) }, uniquingKeysWith: { first, _ in first })
    }

    private var contactByNormName: [String: Contact] {
        Dictionary(contacts.map { ($0.name.lowercased().filter { $0.isLetter || $0.isNumber }, $0) }, uniquingKeysWith: { first, _ in first })
    }

    private func officerCategory(_ o: RetirementOfficer) -> String {
        if !o.category.isEmpty {
            return o.category.lowercased()
        }
        let norm = o.name.lowercased().filter { $0.isLetter || $0.isNumber }
        let matched = contactByName[o.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()] ?? contactByNormName[norm]
        if let matched = matched {
            if isExecutiveContact(matched) { return "executive" }
            if isMinisterialContact(matched) { return "ministerial" }
            return "technical"
        }
        let rankKey = o.rank.lowercased().filter { $0.isLetter || $0.isNumber }
        let unitKey = o.unit.lowercased().filter { $0.isLetter || $0.isNumber }
        if ministerialRankOrder(o.rank) != Int.max || rankKey.contains("ministerial") || unitKey.contains("ministerial") {
            return "ministerial"
        }
        if rankKey.contains("executive") || rankKey.contains("exe") || unitKey.contains("executive") || o.rank.localizedCaseInsensitiveContains("(e)") {
            return "executive"
        }
        return "technical"
    }

    private func filterForecastByCategory(_ base: RetirementForecast, targetCat: String) -> RetirementForecast {
        let filteredYears = base.years.compactMap { y -> RetirementYear? in
            let officersInCat = y.officers.map { o -> RetirementOfficer in
                let norm = o.name.lowercased().filter { $0.isLetter || $0.isNumber }
                let matched = contactByName[o.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()] ?? contactByNormName[norm]
                let updatedBatch = !o.batch.isEmpty ? o.batch : (matched?.batch.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                let updatedCategory = !o.category.isEmpty ? o.category : (matched != nil ? (isExecutiveContact(matched!) ? "executive" : (isMinisterialContact(matched!) ? "ministerial" : "technical")) : "")
                return RetirementOfficer(name: o.name, rank: o.rank, unit: o.unit, dor: o.dor, batch: updatedBatch, category: updatedCategory)
            }.filter { officerCategory($0) == targetCat }

            if !officersInCat.isEmpty {
                return RetirementYear(year: y.year, count: officersInCat.count, officers: officersInCat)
            }
            return nil
        }
        return RetirementForecast(available: true, years: filteredYears)
    }

    private var baseForecast: RetirementForecast {
        if let f = forecast, !f.years.isEmpty {
            return f
        }
        let fromContacts = computeRetirementForecastFromContacts(contacts)
        if !fromContacts.years.isEmpty {
            return fromContacts
        }
        return forecast ?? buildBaselineRetirementForecast()
    }

    private var techForecast: RetirementForecast { filterForecastByCategory(baseForecast, targetCat: "technical") }
    private var execForecast: RetirementForecast { filterForecastByCategory(baseForecast, targetCat: "executive") }
    private var minForecast: RetirementForecast { filterForecastByCategory(baseForecast, targetCat: "ministerial") }

    private var activeForecast: RetirementForecast {
        switch selectedCategory {
        case "executive": return execForecast
        case "ministerial": return minForecast
        default: return techForecast
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Category Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    RetirementFilterPill(
                        title: "Technical Officers",
                        count: techForecast.years.reduce(0) { $0 + $1.count },
                        isSelected: selectedCategory == "technical",
                        onTap: { selectedCategory = "technical" }
                    )
                    RetirementFilterPill(
                        title: "Executive Officers",
                        count: execForecast.years.reduce(0) { $0 + $1.count },
                        isSelected: selectedCategory == "executive",
                        onTap: { selectedCategory = "executive" }
                    )
                    RetirementFilterPill(
                        title: "Ministerial Staff",
                        count: minForecast.years.reduce(0) { $0 + $1.count },
                        isSelected: selectedCategory == "ministerial",
                        onTap: { selectedCategory = "ministerial" }
                    )
                }
                .padding(.horizontal, 4)
            }

            // Years List
            if activeForecast.years.isEmpty {
                Text("No future retirement dates are listed in the roster.")
                    .font(.system(size: 13 * themeManager.fontScale))
                    .foregroundColor(themeManager.secondaryTextColor)
                    .padding()
            } else {
                VStack(spacing: 10) {
                    ForEach(activeForecast.years) { item in
                        let isExpanded = expandedYear == item.year
                        let sortedOfficers = sortRetirementOfficers(item.officers)

                        VStack(spacing: 0) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    expandedYear = isExpanded ? nil : item.year
                                }
                            }) {
                                HStack {
                                    Text("\(String(item.year))")
                                        .font(.system(size: 16 * themeManager.fontScale, weight: .bold))
                                        .foregroundColor(themeManager.primaryTextColor)

                                    Spacer()

                                    Text("\(item.count)")
                                        .font(.system(size: 13 * themeManager.fontScale, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 3)
                                        .background(themeManager.accentColor)
                                        .clipShape(Capsule())

                                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(themeManager.primaryTextColor)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(PlainButtonStyle())

                            if isExpanded {
                                Divider()
                                    .background(themeManager.borderColor)

                                if sortedOfficers.isEmpty {
                                    Text(item.count > 0 ? "Officer details require updated roster synchronization." : "No officers listed for \(String(item.year)).")
                                        .font(.system(size: 12 * themeManager.fontScale))
                                        .foregroundColor(themeManager.secondaryTextColor)
                                        .padding(12)
                                } else {
                                    VStack(spacing: 6) {
                                        ForEach(Array(sortedOfficers.enumerated()), id: \.offset) { index, person in
                                            HStack(alignment: .center) {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(person.name.isEmpty ? "Name unavailable" : person.name)
                                                        .font(.system(size: 14 * themeManager.fontScale, weight: .semibold))
                                                        .foregroundColor(themeManager.primaryTextColor)

                                                    if !person.unit.isEmpty {
                                                        Text(person.unit)
                                                            .font(.system(size: 11 * themeManager.fontScale))
                                                            .foregroundColor(themeManager.secondaryTextColor)
                                                    }

                                                    let meta = [
                                                        !person.batch.isEmpty ? "Batch: \(person.batch)" : nil,
                                                        !person.dor.isEmpty ? "DOR: \(person.dor)" : nil
                                                    ].compactMap { $0 }.joined(separator: " • ")

                                                    if !meta.isEmpty {
                                                        Text(meta)
                                                            .font(.system(size: 11 * themeManager.fontScale, weight: .medium))
                                                            .foregroundColor(themeManager.accentColor)
                                                    }
                                                }

                                                Spacer()

                                                Text(person.rank.isEmpty ? "—" : person.rank)
                                                    .font(.system(size: 11 * themeManager.fontScale, weight: .semibold))
                                                    .foregroundColor(themeManager.primaryTextColor)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 3)
                                                    .background(themeManager.isDark ? Color(red: 0.17, green: 0.20, blue: 0.29) : Color(red: 0.90, green: 0.88, blue: 0.98))
                                                    .clipShape(Capsule())
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 8)
                                            .background(
                                                themeManager.isDark ?
                                                    (index % 2 == 0 ? Color(red: 0.11, green: 0.12, blue: 0.18) : Color(red: 0.13, green: 0.15, blue: 0.22)) :
                                                    (index % 2 == 0 ? Color.white : Color(red: 0.96, green: 0.95, blue: 1.0))
                                            )
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding(8)
                                }
                            }
                        }
                        .background(themeManager.surfaceColor)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isExpanded ? themeManager.accentColor : themeManager.borderColor, lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
}

private struct RetirementFilterPill: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let onTap: () -> Void

    @EnvironmentObject var themeManager: TechThemeManager

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 12.5 * themeManager.fontScale, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : themeManager.primaryTextColor)

                Text("\(count)")
                    .font(.system(size: 11 * themeManager.fontScale, weight: .bold))
                    .foregroundColor(isSelected ? .white : themeManager.primaryTextColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white.opacity(0.25) : (themeManager.isDark ? Color(red: 0.18, green: 0.21, blue: 0.31) : Color(red: 0.87, green: 0.85, blue: 0.95)))
                    .clipShape(Circle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? themeManager.primaryColor : themeManager.surfaceColor)
            .cornerRadius(50)
            .overlay(
                RoundedRectangle(cornerRadius: 50)
                    .stroke(isSelected ? themeManager.accentColor : themeManager.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
