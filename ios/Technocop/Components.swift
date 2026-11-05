import SwiftUI

// MARK: - Expandable Section Component (Matching Android ExpandableSection)

struct ExpandableSection<Content: View>: View {
    let title: String
    @Binding var isExpanded: Bool
    var prominent: Bool = false
    var contentHorizontalPadding: CGFloat = 8
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: prominent ? 18 : 15, weight: .bold))
                        .foregroundStyle(prominent ? Color.white : TechTheme.navy)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: prominent ? 16 : 14, weight: .bold))
                        .foregroundStyle(prominent ? Color.white : TechTheme.navy)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, prominent ? 14 : 11)
                .background(prominent ? TechTheme.navy : Color.clear)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 8) {
                    content()
                }
                .padding(.horizontal, contentHorizontalPadding)
                .padding(.top, 6)
                .padding(.bottom, 10)
            }
        }
        .background(TechTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(TechTheme.tableBorder.opacity(0.5), lineWidth: 1)
        )
    }
}

// MARK: - Location Group Header (Depth 0: Zone, Depth 1: Range, Depth 2: Unit)

struct LocationGroupHeader: View {
    let title: String
    let isExpanded: Bool
    let depth: Int
    let onToggle: () -> Void

    var backgroundColor: Color {
        switch depth {
        case 0: return TechTheme.navy
        case 1: return TechTheme.tableTotals
        default: return Color.white
        }
    }

    var textColor: Color {
        depth == 0 ? Color.white : TechTheme.navy
    }

    var body: some View {
        Button(action: onToggle) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(textColor)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(textColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(depth == 0 ? TechTheme.navy : TechTheme.tableBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.leading, CGFloat(depth * 8))
    }
}

// MARK: - Officer Card & Contact Row (Matching Android ContactRow)

struct ContactRowView: View {
    let contact: Contact
    var isDarker: Bool = false

    private var isItCell: Bool {
        contact.unitCategory.trimmingCharacters(in: .whitespacesAndNewlines)
            .caseInsensitiveCompare("IT Cell") == .orderedSame
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(contact.name.isEmpty ? "Name unavailable" : contact.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(TechTheme.navy)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    HStack(spacing: 6) {
                        Text(contact.rank.isEmpty ? "Rank unavailable" : contact.rank)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(TechTheme.textDark)

                        if !contact.batch.trimmingCharacters(in: .whitespaces).isEmpty {
                            Text(contact.batch)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(TechTheme.badgeYellowText)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(TechTheme.badgeYellow)
                                .clipShape(Capsule())
                        }
                    }

                    if !contact.unit.isEmpty {
                        Text(contact.unit)
                            .font(.system(size: 12))
                            .foregroundStyle(TechTheme.textSubtitle)
                    }

                    if !contact.mobile.isEmpty {
                        Text(contact.mobile)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color(red: 38/255, green: 54/255, blue: 75/255))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, isItCell ? 36 : 0)

                // Call and WhatsApp Actions
                if contact.mobile.count == 10 {
                    HStack(spacing: 8) {
                        if let tel = telURL(for: contact.mobile) {
                            Link(destination: tel) {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 17))
                                    .foregroundStyle(TechTheme.navy)
                                    .frame(width: 38, height: 38)
                                    .background(Color.white.opacity(0.8))
                                    .clipShape(Circle())
                            }
                        }

                        if let wa = whatsAppURL(for: contact.mobile) {
                            Link(destination: wa) {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 17))
                                    .foregroundStyle(TechTheme.whatsAppGreen)
                                    .frame(width: 38, height: 38)
                                    .background(Color.white.opacity(0.8))
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isDarker ? TechTheme.officerRowBackgroundDark : TechTheme.officerRowBackgroundLight)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(TechTheme.tableBorder.opacity(0.4), lineWidth: 0.8)
            )

            // IT Badge
            if isItCell {
                Text("IT")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(TechTheme.navy)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(TechTheme.badgeIT)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(.top, 6)
                    .padding(.trailing, 6)
            }
        }
    }
}

// MARK: - Technical Officer Row (in Contacts -> Technical Officers)

struct TechnicalOfficerRowView: View {
    let officer: TechnicalOfficer

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(officer.name.isEmpty ? "Name unavailable" : officer.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(TechTheme.navy)

                if !officer.unit.isEmpty {
                    Text(officer.unit)
                        .font(.system(size: 12))
                        .foregroundStyle(TechTheme.textSubtitle)
                }

                if !officer.mobile.isEmpty {
                    Text(officer.mobile)
                        .font(.system(size: 13))
                        .foregroundStyle(TechTheme.textDark)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if officer.mobile.count == 10 {
                HStack(spacing: 6) {
                    if let tel = telURL(for: officer.mobile) {
                        Link(destination: tel) {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(TechTheme.navy)
                                .frame(width: 34, height: 34)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }

                    if let wa = whatsAppURL(for: officer.mobile) {
                        Link(destination: wa) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(TechTheme.whatsAppGreen)
                                .frame(width: 34, height: 34)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color(red: 241/255, green: 244/255, blue: 248/255))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Technical Officer Group Card

struct TechnicalOfficerGroupCard: View {
    let title: String
    let count: Int?
    let officers: [TechnicalOfficer]
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(TechTheme.navy)

                    Spacer()

                    Text(count != nil ? "\(count!)" : "—")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(TechTheme.navy)
                        .padding(.trailing, 6)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(TechTheme.navy)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 5) {
                    if officers.isEmpty {
                        Text("No officers listed.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.secondary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(officers) { officer in
                            TechnicalOfficerRowView(officer: officer)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                .background(Color.white)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(TechTheme.tableBorder.opacity(0.6), lineWidth: 1)
        )
    }
}

// MARK: - Strength Table Row Model

struct StrengthTableRowItem: Identifiable {
    let id = UUID()
    let label: String
    let strength: RankStrength
    var depth: Int = 0
}

// MARK: - Compact Strength Table (PTB Hqrs, City, Zone, Range, Special Unit)

struct CompactStrengthTableView: View {
    let rows: [StrengthTableRowItem]
    var rangeLayout: Bool = false
    var firstColumnTitle: String = "Zone"

    private var totalStrength: RankStrength {
        let totalRows = rangeLayout ? rows.filter { $0.depth == 0 } : rows
        return RankStrength(
            dsp: totalRows.reduce(0) { $0 + $1.strength.dsp },
            inspector: totalRows.reduce(0) { $0 + $1.strength.inspector },
            si: totalRows.reduce(0) { $0 + $1.strength.si }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header Row
            HStack(spacing: 0) {
                Text(firstColumnTitle)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("DSP\n(T)")
                    .font(.system(size: 11, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white)
                    .frame(width: 58)

                Text("INSPR\n(T)")
                    .font(.system(size: 11, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white)
                    .frame(width: 66)

                Text("SI\n(T)")
                    .font(.system(size: 11, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white)
                    .frame(width: 58)
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 8)
            .background(TechTheme.navy)

            // Data Rows
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                let isZoneHeader = rangeLayout && row.depth == 0
                let isRangeHeader = rangeLayout && row.depth == 1
                
                let rowBg: Color = {
                    if isZoneHeader { return TechTheme.navy }
                    if isRangeHeader { return TechTheme.rangeHeaderBlue }
                    return index % 2 == 0 ? Color.white : TechTheme.tableAltRow
                }()
                
                let textColor: Color = {
                    if isZoneHeader || isRangeHeader { return Color.white }
                    return TechTheme.navy
                }()

                HStack(spacing: 0) {
                    Text(row.label)
                        .font(.system(size: 12, weight: (row.depth <= 1 || isZoneHeader) ? .bold : .medium))
                        .foregroundStyle(textColor)
                        .padding(.leading, CGFloat(row.depth * 10))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    Text(row.strength.dsp > 0 ? "\(row.strength.dsp)" : "")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(textColor)
                        .frame(width: 58, alignment: .center)

                    Text(row.strength.inspector > 0 ? "\(row.strength.inspector)" : "")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(textColor)
                        .frame(width: 66, alignment: .center)

                    Text(row.strength.si > 0 ? "\(row.strength.si)" : "")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(textColor)
                        .frame(width: 58, alignment: .center)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
                .background(rowBg)
                
                Divider().opacity(0.3)
            }

            // Totals Row
            HStack(spacing: 0) {
                Text("Total")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(TechTheme.navy)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(totalStrength.dsp > 0 ? "\(totalStrength.dsp)" : "")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(TechTheme.navy)
                    .frame(width: 58, alignment: .center)

                Text(totalStrength.inspector > 0 ? "\(totalStrength.inspector)" : "")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(TechTheme.navy)
                    .frame(width: 66, alignment: .center)

                Text(totalStrength.si > 0 ? "\(totalStrength.si)" : "")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(TechTheme.navy)
                    .frame(width: 58, alignment: .center)
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 8)
            .background(TechTheme.tableTotals)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(TechTheme.tableBorder, lineWidth: 1)
        )
    }
}

// MARK: - Batch Strength Table (Columns: Batch, DSP(T), INSPR(T), SI(T), Total)

struct BatchStrengthTableView: View {
    let contacts: [Contact]

    private struct BatchRow: Identifiable {
        let id: String
        let batch: String
        let strength: RankStrength
    }

    private var rows: [BatchRow] {
        let eligible = contacts.filter { rankOrder($0.rank) in 0...2 }
        let grouped = Dictionary(grouping: eligible) { contact in
            contact.batch.trimmingCharacters(in: .whitespaces).isEmpty ? "Not specified" : contact.batch.trimmingCharacters(in: .whitespaces)
        }
        
        return grouped.keys.sorted { a, b in
            let numA = Int(a.filter { $0.isNumber }) ?? Int.max
            let numB = Int(b.filter { $0.isNumber }) ?? Int.max
            if numA != numB { return numA < numB }
            return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
        }.map { batch in
            BatchRow(id: batch, batch: batch, strength: rankCounts(for: grouped[batch] ?? []))
        }
    }

    private var totals: RankStrength {
        RankStrength(
            dsp: rows.reduce(0) { $0 + $1.strength.dsp },
            inspector: rows.reduce(0) { $0 + $1.strength.inspector },
            si: rows.reduce(0) { $0 + $1.strength.si }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header Row
            HStack(spacing: 0) {
                Text("Batch")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("DSP\n(T)")
                    .font(.system(size: 11, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white)
                    .frame(width: 54)

                Text("INSPR\n(T)")
                    .font(.system(size: 11, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white)
                    .frame(width: 60)

                Text("SI\n(T)")
                    .font(.system(size: 11, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white)
                    .frame(width: 54)

                Text("Total")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 52)
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 6)
            .background(TechTheme.navy)

            // Data Rows (Zero cells left blank!)
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                HStack(spacing: 0) {
                    Text(row.batch)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(TechTheme.navy)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 4)

                    Text(row.strength.dsp > 0 ? "\(row.strength.dsp)" : "")
                        .font(.system(size: 12))
                        .foregroundStyle(TechTheme.navy)
                        .frame(width: 54, alignment: .center)

                    Text(row.strength.inspector > 0 ? "\(row.strength.inspector)" : "")
                        .font(.system(size: 12))
                        .foregroundStyle(TechTheme.navy)
                        .frame(width: 60, alignment: .center)

                    Text(row.strength.si > 0 ? "\(row.strength.si)" : "")
                        .font(.system(size: 12))
                        .foregroundStyle(TechTheme.navy)
                        .frame(width: 54, alignment: .center)

                    let rowTotal = row.strength.total
                    Text(rowTotal > 0 ? "\(rowTotal)" : "")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(TechTheme.navy)
                        .frame(width: 52, alignment: .center)
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 6)
                .background(index % 2 == 0 ? Color.white : TechTheme.tableAltRow)

                Divider().opacity(0.25)
            }

            // Totals Row
            HStack(spacing: 0) {
                Text("Total")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(TechTheme.navy)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 4)

                Text(totals.dsp > 0 ? "\(totals.dsp)" : "")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(TechTheme.navy)
                    .frame(width: 54, alignment: .center)

                Text(totals.inspector > 0 ? "\(totals.inspector)" : "")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(TechTheme.navy)
                    .frame(width: 60, alignment: .center)

                Text(totals.si > 0 ? "\(totals.si)" : "")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(TechTheme.navy)
                    .frame(width: 54, alignment: .center)

                Text(totals.total > 0 ? "\(totals.total)" : "")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(TechTheme.navy)
                    .frame(width: 52, alignment: .center)
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 6)
            .background(TechTheme.tableTotals)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(TechTheme.tableBorder, lineWidth: 1)
        )
    }
}

// MARK: - Ministerial Strength Table (Scrollable horizontally with all ranks and column totals)

struct MinisterialStrengthTableView: View {
    let contacts: [Contact]

    private var groupedUnits: [(key: String, officers: [Contact])] {
        let ministerial = contacts.filter(isMinisterialContact)
        let dict = Dictionary(grouping: ministerial) { $0.unit.trimmingCharacters(in: .whitespaces).isEmpty ? "Unit not specified" : $0.unit.trimmingCharacters(in: .whitespaces) }
        return dict.keys.sorted { a, b in
            let ordA = ministerialUnitOrder(a)
            let ordB = ministerialUnitOrder(b)
            if ordA != ordB { return ordA < ordB }
            return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
        }.map { (key: $0, officers: dict[$0] ?? []) }
    }

    private var distinctRanks: [String] {
        let allRanks = contacts.filter(isMinisterialContact).map { $0.rank.trimmingCharacters(in: .whitespaces).isEmpty ? "Rank not specified" : $0.rank.trimmingCharacters(in: .whitespaces) }
        return Array(Set(allRanks)).sorted { a, b in
            let ordA = ministerialRankOrder(a)
            let ordB = ministerialRankOrder(b)
            if ordA != ordB { return ordA < ordB }
            return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
        }
    }

    var body: some View {
        let ranks = distinctRanks
        let units = groupedUnits
        let allMinisterial = contacts.filter(isMinisterialContact)

        ScrollView(.horizontal, showsIndicators: true) {
            VStack(spacing: 0) {
                // Header Row
                HStack(spacing: 0) {
                    Text("Unit")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(width: 140, alignment: .center)

                    ForEach(ranks, id: \.self) { rank in
                        Text(rank)
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(width: 80, alignment: .center)
                    }

                    Text("Total")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(width: 60, alignment: .center)
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 6)
                .background(TechTheme.navy)

                // Data Rows
                ForEach(Array(units.enumerated()), id: \.element.key) { index, entry in
                    let rankCounts = Dictionary(grouping: entry.officers) { $0.rank.trimmingCharacters(in: .whitespaces).isEmpty ? "Rank not specified" : $0.rank.trimmingCharacters(in: .whitespaces) }
                        .mapValues { $0.count }

                    HStack(spacing: 0) {
                        Text(entry.key)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(TechTheme.navy)
                            .frame(width: 140, alignment: .leading)
                            .padding(.leading, 4)
                            .lineLimit(2)

                        ForEach(ranks, id: \.self) { rank in
                            let count = rankCounts[rank] ?? 0
                            Text(count > 0 ? "\(count)" : "")
                                .font(.system(size: 12))
                                .foregroundStyle(TechTheme.navy)
                                .frame(width: 80, alignment: .center)
                        }

                        Text("\(entry.officers.count)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(TechTheme.navy)
                            .frame(width: 60, alignment: .center)
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 6)
                    .background(index % 2 == 0 ? Color.white : TechTheme.tableAltRow)

                    Divider().opacity(0.25)
                }

                // Total Row
                let totalCounts = Dictionary(grouping: allMinisterial) { $0.rank.trimmingCharacters(in: .whitespaces).isEmpty ? "Rank not specified" : $0.rank.trimmingCharacters(in: .whitespaces) }
                    .mapValues { $0.count }

                HStack(spacing: 0) {
                    Text("Total")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(TechTheme.navy)
                        .frame(width: 140, alignment: .leading)
                        .padding(.leading, 4)

                    ForEach(ranks, id: \.self) { rank in
                        let count = totalCounts[rank] ?? 0
                        Text(count > 0 ? "\(count)" : "")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(TechTheme.navy)
                            .frame(width: 80, alignment: .center)
                    }

                    Text("\(allMinisterial.count)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(TechTheme.navy)
                        .frame(width: 60, alignment: .center)
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 6)
                .background(TechTheme.tableTotals)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(TechTheme.tableBorder, lineWidth: 1)
        )
    }
}

