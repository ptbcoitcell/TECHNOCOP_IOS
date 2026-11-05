import SwiftUI

struct MainView: View {
    @EnvironmentObject private var store: AppStore

    @State private var isDrawerOpen = false
    @State private var activePage = "home"
    @State private var showAboutDialog = false
    @State private var showUpdateDialog = false

    // Expandable Sections on Main Dashboard
    @State private var myUnitExpanded = true
    @State private var dashboardExpanded = true
    @State private var contactsMainExpanded = false
    @State private var searchExpanded = false
    @State private var selectedMyUnit: String? = nil

    var body: some View {
        ZStack(alignment: .leading) {
            VStack(spacing: 0) {
                // Navy Top Header Bar
                topHeaderBar

                // Main Scrollable Content Area
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        if activePage == "home" {
                            // 1. My Unit Section
                            ExpandableSection(
                                title: "My Unit",
                                isExpanded: $myUnitExpanded,
                                prominent: true,
                                contentHorizontalPadding: 0
                            ) {
                                myUnitContent
                            }

                            // 2. Dashboard Section
                            ExpandableSection(
                                title: "Dashboard",
                                isExpanded: $dashboardExpanded,
                                prominent: true,
                                contentHorizontalPadding: 0
                            ) {
                                DashboardSectionView()
                            }

                            // 3. Contacts Section
                            ExpandableSection(
                                title: "Contacts",
                                isExpanded: $contactsMainExpanded,
                                prominent: true,
                                contentHorizontalPadding: 0
                            ) {
                                ContactsSectionView()
                            }

                            // 4. Search Section
                            ExpandableSection(
                                title: "Search",
                                isExpanded: $searchExpanded,
                                prominent: true,
                                contentHorizontalPadding: 0
                            ) {
                                SearchSectionView()
                            }
                        } else if activePage == "profile" {
                            ProfileView()
                        }
                    }
                    .padding(8)
                }
                .background(TechTheme.pageBackground)
                .refreshable {
                    await store.refreshData()
                }
            }

            // Side Menu Navigation Drawer
            SideMenuDrawerView(
                isOpen: $isDrawerOpen,
                activePage: $activePage,
                showAboutDialog: $showAboutDialog,
                showUpdateDialog: $showUpdateDialog
            )
        }
        .alert("About TECHNOCOP", isPresented: $showAboutDialog) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Version 3.4\n\nDesigned and Maintained by\nR.A.Arulkalaiselvan SI(T)\n• 9445797535")
        }
        .alert("App Update", isPresented: $showUpdateDialog) {
            if let update = store.appUpdateInfo, update.versionCode > 25, let url = URL(string: update.downloadUrl) {
                Link("Download", destination: url)
                Button("Later", role: .cancel) { }
            } else {
                Button("OK", role: .cancel) { }
            }
        } message: {
            if store.isCheckingUpdate {
                Text("Checking for updates…")
            } else if let update = store.appUpdateInfo, update.versionCode > 25 {
                Text("Version \(update.versionName) is available.")
            } else {
                Text("You have the latest version (3.4).")
            }
        }
    }

    // MARK: - Header Bar

    private var topHeaderBar: some View {
        HStack(spacing: 12) {
            // Menu Toggle Button
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isDrawerOpen.toggle()
                }
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 40, height: 40)
            }

            // Officer Name & Rank in Header
            VStack(alignment: .leading, spacing: 2) {
                Text("TECHNOCOP")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.white)

                if let officer = store.session?.officer {
                    Text(officer.name)
                        .font(.system(size: 12))
                        .foregroundStyle(TechTheme.textLightHeader)
                        .lineLimit(1)

                    Text(officer.rank)
                        .font(.system(size: 10))
                        .foregroundStyle(TechTheme.textLightHeader)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Refresh Action
            Button {
                Task {
                    await store.refreshData()
                }
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 36, height: 36)
            }

            // Home Action
            Button {
                activePage = "home"
            } label: {
                Image(systemName: "house.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.white)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(TechTheme.navy)
    }

    // MARK: - My Unit Content

    @ViewBuilder
    private var myUnitContent: some View {
        if let officer = store.session?.officer {
            let isRangeDSP = officer.rank.filter { $0.isLetter || $0.isNumber }
                .caseInsensitiveCompare("DSPT") == .orderedSame

            let unitContacts = store.contacts.filter { contact in
                if isRangeDSP {
                    return !officer.range.isEmpty &&
                        contact.range.trimmingCharacters(in: .whitespaces).caseInsensitiveCompare(officer.range.trimmingCharacters(in: .whitespaces)) == .orderedSame
                } else {
                    return !officer.unit.isEmpty &&
                        contact.unit.trimmingCharacters(in: .whitespaces).caseInsensitiveCompare(officer.unit.trimmingCharacters(in: .whitespaces)) == .orderedSame
                }
            }

            if unitContacts.isEmpty && store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(16)
            } else if unitContacts.isEmpty {
                Text("No contacts found for your unit.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
                    .padding(12)
            } else if isRangeDSP {
                ContactUnitGroupsView(
                    contacts: unitContacts,
                    selected: selectedMyUnit,
                    depth: 0
                ) { unit in
                    selectedMyUnit = (selectedMyUnit == unit) ? nil : unit
                }
            } else {
                let sorted = unitContacts.sorted { a, b in
                    let batchA = Int(a.batch.filter { $0.isNumber }) ?? Int.max
                    let batchB = Int(b.batch.filter { $0.isNumber }) ?? Int.max
                    if batchA != batchB { return batchA < batchB }
                    let rankA = rankOrder(a.rank)
                    let rankB = rankOrder(b.rank)
                    if rankA != rankB { return rankA < rankB }
                    return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
                }
                VStack(spacing: 3) {
                    ForEach(Array(sorted.enumerated()), id: \.element.id) { idx, contact in
                        ContactRowView(contact: contact, isDarker: idx % 2 == 1)
                    }
                }
            }
        }
    }
}

