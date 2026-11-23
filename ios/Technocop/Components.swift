import SwiftUI

// MARK: - Expandable Section Component

public struct ExpandableSection<Content: View>: View {
    public let title: String
    @Binding public var isExpanded: Bool
    public var prominent: Bool = false
    public var contentHorizontalPadding: CGFloat = 8
    @ViewBuilder public let content: () -> Content

    public init(
        title: String,
        isExpanded: Binding<Bool>,
        prominent: Bool = false,
        contentHorizontalPadding: CGFloat = 8,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self._isExpanded = isExpanded
        self.prominent = prominent
        self.contentHorizontalPadding = contentHorizontalPadding
        self.content = content
    }

    public var body: some View {
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
                .background(prominent ? TechTheme.headerBackground : Color.clear)
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

public struct LocationGroupHeader: View {
    public let title: String
    public let isExpanded: Bool
    public let depth: Int
    public let onToggle: () -> Void

    public init(title: String, isExpanded: Bool, depth: Int, onToggle: @escaping () -> Void) {
        self.title = title
        self.isExpanded = isExpanded
        self.depth = depth
        self.onToggle = onToggle
    }

    private var backgroundColor: Color {
        switch depth {
        case 0: return TechTheme.headerBackground
        case 1: return TechTheme.tableTotals
        default: return TechTheme.surface
        }
    }

    private var textColor: Color {
        depth == 0 ? Color.white : TechTheme.navy
    }

    public var body: some View {
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
                    .stroke(depth == 0 ? TechTheme.headerBackground : TechTheme.tableBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.leading, CGFloat(depth * 8))
    }
}

// MARK: - Officer Card & Contact Row (Matching Android ContactRow)

public struct ContactRowView: View {
    public let contact: Contact
    public var isDarker: Bool = false
    public var isFavorite: Bool = false
    public var onToggleFavorite: (() -> Void)? = nil

    public init(
        contact: Contact,
        isDarker: Bool = false,
        isFavorite: Bool = false,
        onToggleFavorite: (() -> Void)? = nil
    ) {
        self.contact = contact
        self.isDarker = isDarker
        self.isFavorite = isFavorite
        self.onToggleFavorite = onToggleFavorite
    }

    private var isItCell: Bool {
        contact.unitCategory.trimmingCharacters(in: .whitespacesAndNewlines)
            .caseInsensitiveCompare("IT Cell") == .orderedSame
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(contact.name.isEmpty ? "Name unavailable" : contact.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(TechTheme.navy)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        if let onToggleFavorite {
                            Button(action: onToggleFavorite) {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 13))
                                    .foregroundStyle(isFavorite ? Color(red: 225/255, green: 29/255, blue: 72/255) : Color.secondary.opacity(0.6))
                            }
                            .buttonStyle(.plain)
                        }
                    }

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
                            .foregroundStyle(TechTheme.navy)
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
                                    .font(.system(size: 16))
                                    .foregroundStyle(TechTheme.navy)
                                    .frame(width: 36, height: 36)
                                    .background(TechTheme.surface)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.06), radius: 2)
                            }
                        }

                        if let wa = whatsAppURL(for: contact.mobile) {
                            Link(destination: wa) {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(TechTheme.whatsAppGreen)
                                    .frame(width: 36, height: 36)
                                    .background(TechTheme.surface)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.06), radius: 2)
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

// MARK: - Technical Officer Row

public struct TechnicalOfficerRowView: View {
    public let officer: TechnicalOfficer

    public init(officer: TechnicalOfficer) {
        self.officer = officer
    }

    public var body: some View {
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
                                .font(.system(size: 15))
                                .foregroundStyle(TechTheme.navy)
                                .frame(width: 32, height: 32)
                                .background(TechTheme.surface)
                                .clipShape(Circle())
                        }
                    }

                    if let wa = whatsAppURL(for: officer.mobile) {
                        Link(destination: wa) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 15))
                                .foregroundStyle(TechTheme.whatsAppGreen)
                                .frame(width: 32, height: 32)
                                .background(TechTheme.surface)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(TechTheme.officerRowBackgroundLight)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Technical Officer Group Card

public struct TechnicalOfficerGroupCard: View {
    public let title: String
    public let count: Int?
    public let officers: [TechnicalOfficer]
    public let isExpanded: Bool
    public let onToggle: () -> Void

    public init(title: String, count: Int?, officers: [TechnicalOfficer], isExpanded: Bool, onToggle: @escaping () -> Void) {
        self.title = title
        self.count = count
        self.officers = officers
        self.isExpanded = isExpanded
        self.onToggle = onToggle
    }

    public var body: some View {
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
                .background(TechTheme.surface)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 5) {
                    if officers.isEmpty {
                        Text("No officers listed.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.secondary)
                            .padding(8)
                    } else {
                        ForEach(officers) { o in
                            TechnicalOfficerRowView(officer: o)
                        }
                    }
                }
                .padding(8)
                .background(TechTheme.pageBackground)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(TechTheme.tableBorder, lineWidth: 1)
        )
    }
}

// MARK: - Subscreen Header with Back Button

public struct CategorySubscreenHeader: View {
    public let title: String
    public let onBack: () -> Void

    public init(title: String, onBack: @escaping () -> Void) {
        self.title = title
        self.onBack = onBack
    }

    public var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(TechTheme.navy)
                    .frame(width: 36, height: 36)
                    .background(TechTheme.lavenderTint)
                    .clipShape(Circle())
            }

            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(TechTheme.navy)

            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }
}

// MARK: - Sync Status Banner

public struct SyncStatusBanner: View {
    public let lastUpdatedText: String?
    public let isRefreshing: Bool
    public let errorMessage: String
    public let onRetry: () -> Void

    public init(lastUpdatedText: String?, isRefreshing: Bool, errorMessage: String, onRetry: @escaping () -> Void) {
        self.lastUpdatedText = lastUpdatedText
        self.isRefreshing = isRefreshing
        self.errorMessage = errorMessage
        self.onRetry = onRetry
    }

    public var body: some View {
        if !errorMessage.isEmpty || isRefreshing {
            HStack(spacing: 8) {
                if isRefreshing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(TechTheme.textError)
                }

                Text(isRefreshing ? "Refreshing live roster…" : "\(errorMessage) Showing saved data.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isRefreshing ? TechTheme.navy : TechTheme.textError)
                    .lineLimit(2)

                Spacer()

                if !isRefreshing {
                    Button("Retry", action: onRetry)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(TechTheme.navy)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(errorMessage.isEmpty ? TechTheme.lavenderTint : Color(red: 255/255, green: 242/255, blue: 242/255))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(errorMessage.isEmpty ? TechTheme.tableBorder : Color(red: 240/255, green: 199/255, blue: 199/255), lineWidth: 1)
            )
        }
    }
}

// MARK: - Smart Caller ID Setup Banner

public struct SmartCallerIdSetupBanner: View {
    public let onConfigure: () -> Void

    public init(onConfigure: @escaping () -> Void) {
        self.onConfigure = onConfigure
    }

    public var body: some View {
        Button(action: onConfigure) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(TechTheme.accent)
                        .frame(width: 36, height: 36)
                    Image(systemName: "phone.badge.checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Smart Caller ID")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(TechTheme.navy)
                    Text("Identify officer calls with instant police directory lookup")
                        .font(.system(size: 11))
                        .foregroundStyle(TechTheme.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Text("Setup")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(TechTheme.accent)
                    .clipShape(Capsule())
            }
            .padding(10)
            .background(TechTheme.lavenderTint)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(TechTheme.tableBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Hero Greeting Card

public struct HeroGreetingCard: View {
    public let officer: Officer
    public let quickStats: DashboardQuickStats
    public let onProfile: () -> Void

    public init(officer: Officer, quickStats: DashboardQuickStats, onProfile: @escaping () -> Void) {
        self.officer = officer
        self.quickStats = quickStats
        self.onProfile = onProfile
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return greetingForHour(hour)
    }

    public var body: some View {
        Button(action: onProfile) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 12) {
                    // Avatar Initials Badge
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [TechTheme.currentPalette.primary, TechTheme.currentPalette.indigoPrimary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 48, height: 48)
                        Text(officerInitials(officer.name))
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(greetingText),")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(TechTheme.textSecondary)

                        Text(officer.name.isEmpty ? "Police Officer" : officer.name)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(TechTheme.navy)
                            .lineLimit(1)

                        Text([officer.rank, officer.unit].filter { !$0.isEmpty }.joined(separator: " • "))
                            .font(.system(size: 12))
                            .foregroundStyle(TechTheme.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(TechTheme.textSecondary.opacity(0.5))
                }

                Divider()

                // QuickStats Chips
                HStack(spacing: 8) {
                    statChip("Roster", "\(quickStats.totalRosterCount)")
                    statChip("Technical", "\(quickStats.totalTechnicalOfficers)")
                    statChip("My Unit", "\(quickStats.myUnitCount)")
                    if quickStats.upcomingRetirementsCount > 0 {
                        statChip("DOR", "\(quickStats.upcomingRetirementsCount)")
                    }
                }
            }
            .padding(14)
            .background(TechTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(TechTheme.tableBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func statChip(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(TechTheme.navy)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(TechTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(TechTheme.lavenderTint)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Birthday Wishes Card

public struct BirthdayWishesCard: View {
    public let birthdayData: BirthdayFeed?
    public let onOpenAll: () -> Void

    public init(birthdayData: BirthdayFeed?, onOpenAll: @escaping () -> Void) {
        self.birthdayData = birthdayData
        self.onOpenAll = onOpenAll
    }

    public var body: some View {
        if let birthdays = birthdayData?.birthdays, !birthdays.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "cake.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(red: 236/255, green: 72/255, blue: 153/255))
                        Text("Today's Birthdays")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(TechTheme.navy)
                    }

                    Spacer()

                    Button("View All (\(birthdays.count))", action: onOpenAll)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(TechTheme.accent)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(birthdays) { person in
                            HStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(person.name)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(TechTheme.navy)
                                        .lineLimit(1)
                                    Text("\(person.rank) • \(person.unit)")
                                        .font(.system(size: 11))
                                        .foregroundStyle(TechTheme.textSecondary)
                                        .lineLimit(1)
                                }

                                if !person.mobile.isEmpty {
                                    HStack(spacing: 6) {
                                        if let tel = telURL(for: person.mobile) {
                                            Link(destination: tel) {
                                                Image(systemName: "phone.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundStyle(TechTheme.navy)
                                                    .frame(width: 26, height: 26)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                            }
                                        }
                                        if let wa = whatsAppURL(for: person.mobile) {
                                            Link(destination: wa) {
                                                Image(systemName: "message.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundStyle(TechTheme.whatsAppGreen)
                                                    .frame(width: 26, height: 26)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(TechTheme.lavenderTint)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
            .padding(12)
            .background(TechTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(TechTheme.tableBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Daily Thirukkural Card

public struct DailyThirukkuralCard: View {
    @State private var kural: Thirukkural = ThirukkuralRepository.getTodayKural()
    @State private var showCopiedAlert: Bool = false

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "book.pages.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(TechTheme.gold)
                    Text("Daily Thirukkural")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(TechTheme.navy)
                }

                Spacer()

                Text("குறள் \(kural.number) • \(kural.chapter)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(TechTheme.textSecondary)

                Button {
                    UIPasteboard.general.string = "\(kural.line1)\n\(kural.line2)\n\n\(kural.explanationTamil)\n\n\(kural.explanationEnglish)"
                    showCopiedAlert = true
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 13))
                        .foregroundStyle(TechTheme.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(kural.line1)
                    .font(.system(size: 13.5, weight: .bold))
                    .foregroundStyle(TechTheme.navy)
                Text(kural.line2)
                    .font(.system(size: 13.5, weight: .bold))
                    .foregroundStyle(TechTheme.navy)
            }
            .padding(.vertical, 2)

            Text(kural.explanationTamil)
                .font(.system(size: 12))
                .foregroundStyle(TechTheme.textDark)
                .lineLimit(3)

            Text(kural.explanationEnglish)
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(TechTheme.textSecondary)
                .italic()
                .lineLimit(2)
        }
        .padding(14)
        .background(TechTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(TechTheme.tableBorder, lineWidth: 1)
        )
    }
}

// MARK: - Daily Motivational Quote Card

public struct DailyMotivationalQuoteCard: View {
    @State private var quote: MotivationalQuote = MotivationalQuotesRepository.getTodayQuote()

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(TechTheme.accent)
                    Text("Daily Inspiration")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(TechTheme.navy)
                }

                Spacer()

                Text(quote.category)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(TechTheme.accentDeep)
            }

            Text("\"\(quote.quote)\"")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(TechTheme.navy)
                .italic()
                .lineLimit(3)

            HStack {
                Spacer()
                Text("— \(quote.author), \(quote.designationOrField)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(TechTheme.textSecondary)
            }
        }
        .padding(14)
        .background(TechTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(TechTheme.tableBorder, lineWidth: 1)
        )
    }
}

// MARK: - Daily Observance Card

public struct DailyObservanceCard: View {
    @State private var observances: [DailyObservance] = DailyObservancesRepository.getTodayObservances()

    public init() {}

    public var body: some View {
        if !observances.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(TechTheme.currentPalette.accent)
                    Text("Today's Observance")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(TechTheme.navy)
                }

                ForEach(observances) { obs in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(obs.name)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(TechTheme.navy)
                        Text(obs.description)
                            .font(.system(size: 11.5))
                            .foregroundStyle(TechTheme.textSecondary)
                    }
                }
            }
            .padding(12)
            .background(TechTheme.lavenderTint)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(TechTheme.tableBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Quick Access Card

public struct QuickAccessCard: View {
    public let title: String
    public let subtitle: String
    public let systemImage: String
    public let action: () -> Void

    public init(title: String, subtitle: String, systemImage: String, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(TechTheme.lavenderTint)
                            .frame(width: 36, height: 36)
                        Image(systemName: systemImage)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(TechTheme.navy)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(TechTheme.textSecondary.opacity(0.5))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(TechTheme.navy)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(TechTheme.textSecondary)
                        .lineLimit(1)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(TechTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(TechTheme.tableBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 3, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Strength Tables (Batch, Compact, Ministerial, Executive)

public struct BatchStrengthTableView: View {
    public let contacts: [Contact]

    public init(contacts: [Contact]) {
        self.contacts = contacts
    }

    private var batchRows: [BatchStrengthRowItem] {
        let eligible = contacts.filter { rankOrder($0.rank) <= 2 }
        let groups = Dictionary(grouping: eligible) {
            $0.batch.trimmingCharacters(in: .whitespaces).isEmpty ? "Not specified" : $0.batch.trimmingCharacters(in: .whitespaces)
        }
        return groups.keys.sorted { a, b in
            let numA = Int(a.filter { $0.isNumber }) ?? Int.max
            let numB = Int(b.filter { $0.isNumber }) ?? Int.max
            if numA != numB { return numA < numB }
            return a.localizedCaseInsensitiveCompare(b) == .orderedAscending
        }.map { BatchStrengthRowItem(batch: $0, strength: rankCounts(for: groups[$0] ?? [])) }
    }

    public var body: some View {
        let rows = batchRows
        let totalDsp = rows.map(\.strength.dsp).reduce(0, +)
        let totalInsp = rows.map(\.strength.inspector).reduce(0, +)
        let totalSi = rows.map(\.strength.si).reduce(0, +)
        let grandTotal = totalDsp + totalInsp + totalSi

        VStack(spacing: 0) {
            // Header
            HStack(spacing: 0) {
                tableCell("Batch", flex: 2.2, isHeader: true, align: .leading)
                tableCell("DSP(T)", flex: 1.2, isHeader: true)
                tableCell("Inspr(T)", flex: 1.3, isHeader: true)
                tableCell("SI(T)", flex: 1.2, isHeader: true)
                tableCell("Total", flex: 1.3, isHeader: true)
            }
            .background(TechTheme.headerBackground)

            // Rows
            ForEach(rows.indices, id: \.self) { idx in
                let r = rows[idx]
                HStack(spacing: 0) {
                    tableCell(r.batch, flex: 2.2, align: .leading)
                    tableCell(r.strength.dsp == 0 ? "" : "\(r.strength.dsp)", flex: 1.2)
                    tableCell(r.strength.inspector == 0 ? "" : "\(r.strength.inspector)", flex: 1.3)
                    tableCell(r.strength.si == 0 ? "" : "\(r.strength.si)", flex: 1.2)
                    tableCell("\(r.strength.total)", flex: 1.3, isBold: true)
                }
                .background(idx % 2 == 1 ? TechTheme.tableAltRow : TechTheme.surface)
            }

            // Total row
            HStack(spacing: 0) {
                tableCell("Total", flex: 2.2, isBold: true, align: .leading)
                tableCell("\(totalDsp)", flex: 1.2, isBold: true)
                tableCell("\(totalInsp)", flex: 1.3, isBold: true)
                tableCell("\(totalSi)", flex: 1.2, isBold: true)
                tableCell("\(grandTotal)", flex: 1.3, isBold: true)
            }
            .background(TechTheme.tableTotals)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(TechTheme.tableBorder, lineWidth: 1))
    }

    private func tableCell(_ text: String, flex: CGFloat, isHeader: Bool = false, isBold: Bool = false, align: Alignment = .center) -> some View {
        Text(text)
            .font(.system(size: isHeader ? 12 : 12, weight: (isHeader || isBold) ? .bold : .regular))
            .foregroundStyle(isHeader ? Color.white : TechTheme.navy)
            .frame(maxWidth: .infinity, alignment: align)
            .padding(.horizontal, 6)
            .padding(.vertical, 7)
    }
}

public struct CompactStrengthTableView: View {
    public let rows: [StrengthTableRowItem]
    public var rangeLayout: Bool = false
    public var firstColumnTitle: String = "Location"

    public init(rows: [StrengthTableRowItem], rangeLayout: Bool = false, firstColumnTitle: String = "Location") {
        self.rows = rows
        self.rangeLayout = rangeLayout
        self.firstColumnTitle = firstColumnTitle
    }

    public var body: some View {
        let filteredForTotals = rangeLayout ? rows.filter { $0.depth == 0 } : rows
        let totalDsp = filteredForTotals.map(\.strength.dsp).reduce(0, +)
        let totalInsp = filteredForTotals.map(\.strength.inspector).reduce(0, +)
        let totalSi = filteredForTotals.map(\.strength.si).reduce(0, +)
        let grandTotal = totalDsp + totalInsp + totalSi

        VStack(spacing: 0) {
            // Header
            HStack(spacing: 0) {
                tableCell(firstColumnTitle, flex: 2.6, isHeader: true, align: .leading)
                tableCell("DSP(T)", flex: 1.2, isHeader: true)
                tableCell("Inspr(T)", flex: 1.3, isHeader: true)
                tableCell("SI(T)", flex: 1.2, isHeader: true)
                tableCell("Total", flex: 1.3, isHeader: true)
            }
            .background(TechTheme.headerBackground)

            // Rows
            ForEach(rows.indices, id: \.self) { idx in
                let r = rows[idx]
                let isZoneHeader = rangeLayout && r.depth == 0
                let isRangeHeader = rangeLayout && r.depth == 1
                let bgColor: Color = isZoneHeader ? TechTheme.tableTotals : (isRangeHeader ? TechTheme.lavenderTint : (idx % 2 == 1 ? TechTheme.tableAltRow : TechTheme.surface))

                HStack(spacing: 0) {
                    HStack(spacing: 4) {
                        if r.depth > 0 {
                            Spacer().frame(width: CGFloat(r.depth * 10))
                        }
                        Text(r.label)
                            .font(.system(size: 12, weight: (isZoneHeader || isRangeHeader) ? .bold : .regular))
                            .foregroundStyle(isZoneHeader ? TechTheme.navy : (isRangeHeader ? TechTheme.currentPalette.accentDeep : TechTheme.navy))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 7)

                    tableCell(r.strength.dsp == 0 ? "" : "\(r.strength.dsp)", flex: 1.2, isBold: isZoneHeader)
                    tableCell(r.strength.inspector == 0 ? "" : "\(r.strength.inspector)", flex: 1.3, isBold: isZoneHeader)
                    tableCell(r.strength.si == 0 ? "" : "\(r.strength.si)", flex: 1.2, isBold: isZoneHeader)
                    tableCell("\(r.strength.total)", flex: 1.3, isBold: true)
                }
                .background(bgColor)
            }

            // Total row
            HStack(spacing: 0) {
                tableCell("Total", flex: 2.6, isBold: true, align: .leading)
                tableCell("\(totalDsp)", flex: 1.2, isBold: true)
                tableCell("\(totalInsp)", flex: 1.3, isBold: true)
                tableCell("\(totalSi)", flex: 1.2, isBold: true)
                tableCell("\(grandTotal)", flex: 1.3, isBold: true)
            }
            .background(TechTheme.tableTotals)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(TechTheme.tableBorder, lineWidth: 1))
    }

    private func tableCell(_ text: String, flex: CGFloat, isHeader: Bool = false, isBold: Bool = false, align: Alignment = .center) -> some View {
        Text(text)
            .font(.system(size: isHeader ? 12 : 12, weight: (isHeader || isBold) ? .bold : .regular))
            .foregroundStyle(isHeader ? Color.white : TechTheme.navy)
            .frame(maxWidth: .infinity, alignment: align)
            .padding(.horizontal, 6)
            .padding(.vertical, 7)
    }
}

public struct MinisterialStrengthTableView: View {
    public let contacts: [Contact]

    public init(contacts: [Contact]) {
        self.contacts = contacts
    }

    public var body: some View {
        let ministerial = contacts.filter(isMinisterialContact)
        let groups = Dictionary(grouping: ministerial) {
            $0.unit.trimmingCharacters(in: .whitespaces).isEmpty ? "Unit not specified" : $0.unit.trimmingCharacters(in: .whitespaces)
        }
        let sortedUnits = groups.keys.sorted { ministerialUnitOrder($0) < ministerialUnitOrder($1) }

        ScrollView(.horizontal, showsIndicators: true) {
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 0) {
                    minCell("Unit", width: 140, isHeader: true, align: .leading)
                    minCell("AO", width: 50, isHeader: true)
                    minCell("Supdt", width: 55, isHeader: true)
                    minCell("Asst", width: 50, isHeader: true)
                    minCell("Jr.Asst", width: 55, isHeader: true)
                    minCell("RC", width: 45, isHeader: true)
                    minCell("Typist", width: 55, isHeader: true)
                    minCell("OA", width: 45, isHeader: true)
                    minCell("SB Asst", width: 60, isHeader: true)
                    minCell("Steno", width: 55, isHeader: true)
                    minCell("Total", width: 60, isHeader: true)
                }
                .background(TechTheme.headerBackground)

                ForEach(sortedUnits.indices, id: \.self) { idx in
                    let unit = sortedUnits[idx]
                    let staff = groups[unit] ?? []
                    HStack(spacing: 0) {
                        minCell(unit, width: 140, align: .leading)
                        minCell(countStr(staff, 0), width: 50)
                        minCell(countStr(staff, 1), width: 55)
                        minCell(countStr(staff, 2), width: 50)
                        minCell(countStr(staff, 3), width: 55)
                        minCell(countStr(staff, 4), width: 45)
                        minCell(countStr(staff, 5), width: 55)
                        minCell(countStr(staff, 6), width: 45)
                        minCell(countStr(staff, 7), width: 60)
                        minCell(countStr(staff, 8), width: 55)
                        minCell("\(staff.count)", width: 60, isBold: true)
                    }
                    .background(idx % 2 == 1 ? TechTheme.tableAltRow : TechTheme.surface)
                }

                // Total
                HStack(spacing: 0) {
                    minCell("Total", width: 140, isBold: true, align: .leading)
                    minCell(totalStr(ministerial, 0), width: 50, isBold: true)
                    minCell(totalStr(ministerial, 1), width: 55, isBold: true)
                    minCell(totalStr(ministerial, 2), width: 50, isBold: true)
                    minCell(totalStr(ministerial, 3), width: 55, isBold: true)
                    minCell(totalStr(ministerial, 4), width: 45, isBold: true)
                    minCell(totalStr(ministerial, 5), width: 55, isBold: true)
                    minCell(totalStr(ministerial, 6), width: 45, isBold: true)
                    minCell(totalStr(ministerial, 7), width: 60, isBold: true)
                    minCell(totalStr(ministerial, 8), width: 55, isBold: true)
                    minCell("\(ministerial.count)", width: 60, isBold: true)
                }
                .background(TechTheme.tableTotals)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(TechTheme.tableBorder, lineWidth: 1))
    }

    private func countStr(_ staff: [Contact], _ order: Int) -> String {
        let c = staff.filter { ministerialRankOrder($0.rank) == order }.count
        return c == 0 ? "" : "\(c)"
    }

    private func totalStr(_ staff: [Contact], _ order: Int) -> String {
        let c = staff.filter { ministerialRankOrder($0.rank) == order }.count
        return "\(c)"
    }

    private func minCell(_ text: String, width: CGFloat, isHeader: Bool = false, isBold: Bool = false, align: Alignment = .center) -> some View {
        Text(text)
            .font(.system(size: 11.5, weight: (isHeader || isBold) ? .bold : .regular))
            .foregroundStyle(isHeader ? Color.white : TechTheme.navy)
            .frame(width: width, alignment: align)
            .padding(.horizontal, 4)
            .padding(.vertical, 7)
    }
}
