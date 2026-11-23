import SwiftUI

// MARK: - Modern Dashboard View (Matching Android ModernDashboard)

public typealias ModernDashboardView = DashboardSectionView

public struct DashboardSectionView: View {
    @EnvironmentObject private var store: AppStore

    public init() {}

    public var body: some View {
        VStack(spacing: 12) {
            // 1. Sync & Error Status Banner
            if let lastRefreshed = store.lastRefreshedAt {
                SyncStatusBanner(
                    lastUpdatedText: formatRefreshTime(lastRefreshed),
                    isRefreshing: store.isLoading,
                    errorMessage: store.offlineMessage
                ) {
                    Task { await store.refreshData() }
                }
            }

            // 2. Smart Caller ID Setup Banner
            SmartCallerIdSetupBanner {
                store.activeModal = .callerId
            }

            // 3. Hero Greeting Card
            if let officer = store.session?.officer {
                let quickStats = computeQuickStats(
                    officer: officer,
                    counts: store.dashboardData,
                    contacts: store.contacts,
                    birthdayCount: store.birthdayData?.birthdays.count ?? 0,
                    announcementCount: store.dashboardContent?.announcements.items.count ?? 0,
                    upcomingRetirementsCount: store.retirementForecast?.years.reduce(0, { $0 + $1.count }) ?? 0
                )

                HeroGreetingCard(
                    officer: officer,
                    quickStats: quickStats,
                    onProfile: { store.navigateToPage("profile") }
                )
            }

            // 4. Today's Birthday Wishes
            if let bFeed = store.birthdayData, !bFeed.birthdays.isEmpty {
                BirthdayWishesCard(birthdayData: bFeed) {
                    store.openModal(.birthdays)
                }
            }

            // 5. Daily Thirukkural Card
            DailyThirukkuralCard()

            // 6. Daily Motivational Quote Card
            DailyMotivationalQuoteCard()

            // 7. Daily Observance Card (if today has an observance)
            DailyObservanceCard()

            // 8. Employee Services Quick Access Grid
            employeeServicesGrid

            // 9. Retirement Forecast Preview Card
            retirementPreviewCard
        }
    }

    // MARK: - Employee Services Grid

    private var employeeServicesGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Employee services")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(TechTheme.navy)

                Spacer()

                if let officer = store.session?.officer, !officer.unit.isEmpty {
                    Text(officer.unit)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(TechTheme.accentDeep)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(TechTheme.lavenderTint)
                        .clipShape(Capsule())
                }
            }

            let myUnitCount = store.session.map { myUnitContacts(for: $0.officer, in: store.contacts).count } ?? 0
            let myUnitSub = myUnitCount > 0 ? "\(myUnitCount) colleague\(myUnitCount == 1 ? "" : "s") in unit" : "Your unit contacts"
            let dirSub = store.contacts.count > 0 ? "\(store.contacts.count) staff contacts" : "Browse staff contacts"
            let favSub = store.favoriteNumbers.count > 0 ? "\(store.favoriteNumbers.count) saved" : "Quick 1-tap contacts"
            let totalTechOfficers: Int = {
                guard let d = store.dashboardData else { return 0 }
                return d.sps + d.addlSps + d.dsps + d.inspectors + d.subInspectors
            }()
            let orgSub = totalTechOfficers > 0 ? "\(totalTechOfficers) technical officers" : "View organization strength"
            let upcomingCount = store.retirementForecast?.years.reduce(0, { $0 + $1.count }) ?? 0
            let retSub = upcomingCount > 0 ? "\(upcomingCount) in forecast" : "Forecast by year"

            let isExecOrMin = isExecutiveOrMinisterialOfficer(store.session?.officer)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                QuickAccessCard(title: "My Unit", subtitle: myUnitSub, systemImage: "building.2.fill") {
                    store.selectCategory("my_unit")
                }

                QuickAccessCard(title: "Employee Directory", subtitle: dirSub, systemImage: "person.3.fill") {
                    store.selectCategory("directory")
                }

                QuickAccessCard(title: "Favourites", subtitle: favSub, systemImage: "heart.fill") {
                    store.selectCategory("favourites")
                }

                QuickAccessCard(title: "Search", subtitle: "Find a colleague", systemImage: "magnifyingglass") {
                    store.selectCategory("search")
                }

                QuickAccessCard(title: "My Organization", subtitle: orgSub, systemImage: "building.columns.fill") {
                    store.selectCategory("organization")
                }

                QuickAccessCard(title: "Retirement Forecast", subtitle: retSub, systemImage: "calendar.badge.clock") {
                    store.selectCategory("retirement")
                }

                if !isExecOrMin {
                    QuickAccessCard(title: "Tech-Knowledge Base", subtitle: "IT, CCTV & AI Help", systemImage: "book.fill") {
                        store.selectCategory("knowledge")
                    }

                    QuickAccessCard(title: "Daily Digest", subtitle: "Bulletins, GOs & Circulars", systemImage: "newspaper.fill") {
                        store.openModal(.digest)
                    }
                }

                QuickAccessCard(title: "Special Days", subtitle: "Observances Calendar", systemImage: "flag.fill") {
                    store.openModal(.specialDays)
                }
            }
        }
    }

    // MARK: - Retirement Preview Card

    private var retirementPreviewCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Retirement Forecast")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(TechTheme.navy)

                Spacer()

                let total = store.retirementForecast?.years.reduce(0, { $0 + $1.count }) ?? 0
                if total > 0 {
                    Text("\(total) upcoming")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(TechTheme.accentDeep)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(TechTheme.lavenderTint)
                        .clipShape(Capsule())
                }
            }

            Button {
                store.selectCategory("retirement")
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(TechTheme.lavenderTint)
                            .frame(width: 40, height: 40)
                        Image(systemName: "calendar")
                            .font(.system(size: 18))
                            .foregroundStyle(TechTheme.navy)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Count by year")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(TechTheme.navy)
                        Text("View retiring officers projection sorted by batch, DOR and rank")
                            .font(.system(size: 11.5))
                            .foregroundStyle(TechTheme.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(TechTheme.textSecondary)
                }
                .padding(12)
                .background(TechTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(TechTheme.tableBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func formatRefreshTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
