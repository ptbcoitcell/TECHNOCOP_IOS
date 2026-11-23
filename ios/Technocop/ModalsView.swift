import SwiftUI

public enum DashboardModalType: String, Identifiable {
    case birthdays
    case announcements
    case digest
    case retirement
    case techPlatform
    case specialDays
    case callerId
    case knowledgeCentre
    case themeDialog

    public var id: String { rawValue }
}

struct ModalsHostView: View {
    let modal: DashboardModalType
    let birthdayData: BirthdayFeed?
    let dashboardContent: DashboardContent?
    let retirementForecast: RetirementForecast?
    let contacts: [Contact]
    let currentOfficer: Officer?
    let onDismiss: () -> Void
    var onPostBroadcast: ((String, String, String, String, String, @escaping () -> Void) -> Void)? = nil

    @EnvironmentObject var themeManager: TechThemeManager

    var body: some View {
        Group {
            switch modal {
            case .birthdays:
                BirthdaysModalView(
                    birthdays: birthdayData?.birthdays ?? [],
                    onDismiss: onDismiss
                )
            case .announcements:
                OfficialAnnouncementsModalView(
                    content: dashboardContent,
                    currentOfficer: currentOfficer,
                    onDismiss: onDismiss,
                    onPostBroadcast: onPostBroadcast
                )
            case .digest, .techPlatform:
                TechPlatformModalView(
                    dashboardContent: dashboardContent,
                    currentUserMobile: currentOfficer?.mobile,
                    onDismiss: onDismiss
                )
            case .retirement:
                RetirementModalView(
                    forecast: retirementForecast,
                    contacts: contacts,
                    onDismiss: onDismiss
                )
            case .specialDays:
                SpecialDaysModalView(onDismiss: onDismiss)
            default:
                EmptyView()
            }
        }
    }
}

// -------------------------------------------------------------
// 1. Birthdays Modal View
// -------------------------------------------------------------
struct BirthdaysModalView: View {
    let birthdays: [BirthdayPerson]
    let onDismiss: () -> Void

    @EnvironmentObject var themeManager: TechThemeManager

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Today's birthday wishes")
                    .font(.system(size: 17 * themeManager.fontScale, weight: .bold))
                    .foregroundColor(themeManager.primaryTextColor)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(themeManager.secondaryTextColor)
                        .padding(6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 10)

            if birthdays.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "gift")
                        .font(.system(size: 36))
                        .foregroundColor(themeManager.accentColor)
                    Text("No birthdays today.")
                        .font(.system(size: 14 * themeManager.fontScale, weight: .semibold))
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                .padding(32)
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(birthdays) { person in
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(person.isSelf ? "Happy Birthday, \(person.name)!" : person.name)
                                        .font(.system(size: 14.5 * themeManager.fontScale, weight: .bold))
                                        .foregroundColor(themeManager.primaryTextColor)

                                    let meta = [person.rank, person.unit].filter { !$0.isEmpty }.joined(separator: " • ")
                                    Text(meta.isEmpty ? "—" : meta)
                                        .font(.system(size: 12 * themeManager.fontScale))
                                        .foregroundColor(themeManager.secondaryTextColor)

                                    if person.isSelf {
                                        Text("Wishing you happiness, good health and success in the year ahead.")
                                            .font(.system(size: 11 * themeManager.fontScale))
                                            .foregroundColor(themeManager.accentColor)
                                            .padding(.top, 2)
                                    }
                                }

                                Spacer()

                                let cleanMobile = person.mobile.filter { $0.isNumber }
                                if cleanMobile.count >= 10 {
                                    HStack(spacing: 8) {
                                        Button(action: {
                                            if let url = URL(string: "tel:\(cleanMobile)") {
                                                UIApplication.shared.open(url)
                                            }
                                        }) {
                                            Image(systemName: "phone.fill")
                                                .font(.system(size: 13))
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(themeManager.primaryColor)
                                                .clipShape(Circle())
                                        }

                                        Button(action: {
                                            let waNum = cleanMobile.hasPrefix("91") ? cleanMobile : "91\(cleanMobile)"
                                            let msg = "Dear \(person.name), Wishing you a very Happy Birthday! 💐🎂 - Tamil Nadu Police Technical Services"
                                            if let encoded = msg.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                               let url = URL(string: "https://wa.me/\(waNum)?text=\(encoded)") {
                                                UIApplication.shared.open(url)
                                            }
                                        }) {
                                            Image(systemName: "message.fill")
                                                .font(.system(size: 13))
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(Color(red: 0.15, green: 0.83, blue: 0.40))
                                                .clipShape(Circle())
                                        }
                                    }
                                }
                            }
                            .padding(12)
                            .background(
                                person.isSelf ?
                                    (themeManager.isDark ? Color(red: 0.18, green: 0.14, blue: 0.32) : Color(red: 0.91, green: 0.88, blue: 1.0)) :
                                    themeManager.lavenderWashColor
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(person.isSelf ? themeManager.accentColor : themeManager.borderColor, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(maxHeight: 380)
            }

            Button("Done", action: onDismiss)
                .font(.system(size: 14 * themeManager.fontScale, weight: .bold))
                .foregroundColor(themeManager.primaryColor)
                .padding(.vertical, 12)
        }
        .background(themeManager.surfaceColor)
        .cornerRadius(20)
        .padding(.horizontal, 16)
    }
}

// -------------------------------------------------------------
// 2. Official Announcements Modal View
// -------------------------------------------------------------
struct OfficialAnnouncementsModalView: View {
    let content: DashboardContent?
    let currentOfficer: Officer?
    let onDismiss: () -> Void
    var onPostBroadcast: ((String, String, String, String, String, @escaping () -> Void) -> Void)? = nil

    @EnvironmentObject var themeManager: TechThemeManager
    @State private var showComposer: Bool = false

    private var isAdmin: Bool {
        isBroadcastAdmin(currentOfficer?.mobile ?? "")
    }

    private var filteredItems: [Announcement] {
        let items = content?.announcements.items ?? []
        return items.filter { matchesBroadcastAudience($0.targetGroup, currentOfficer) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Official Announcements")
                    .font(.system(size: 17 * themeManager.fontScale, weight: .bold))
                    .foregroundColor(themeManager.primaryTextColor)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(themeManager.secondaryTextColor)
                        .padding(6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 10)

            ScrollView {
                VStack(spacing: 12) {
                    if isAdmin {
                        Button(action: { showComposer = true }) {
                            HStack {
                                Image(systemName: "megaphone.fill")
                                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                                Text("Push Broadcast Announcement")
                                    .font(.system(size: 13 * themeManager.fontScale, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(themeManager.primaryColor)
                            .cornerRadius(10)
                        }
                    }

                    if filteredItems.isEmpty {
                        Text("There are no announcements for your category at this time.")
                            .font(.system(size: 13 * themeManager.fontScale))
                            .foregroundColor(themeManager.secondaryTextColor)
                            .padding(24)
                    } else {
                        ForEach(filteredItems) { item in
                            let target = BroadcastTarget.fromCode(item.targetGroup)
                            let isUrgent = item.priority.localizedCaseInsensitiveContains("URGENT") || item.priority.localizedCaseInsensitiveContains("HIGH")

                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("🎯 \(target.label)")
                                        .font(.system(size: 11 * themeManager.fontScale, weight: .semibold))
                                        .foregroundColor(themeManager.primaryColor)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(themeManager.lavenderWashColor)
                                        .cornerRadius(4)

                                    Spacer()

                                    if !item.priority.isEmpty && item.priority.uppercased() != "NORMAL" {
                                        Text(item.priority.uppercased())
                                            .font(.system(size: 10 * themeManager.fontScale, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(isUrgent ? Color.red : Color.orange)
                                            .cornerRadius(4)
                                    }
                                }

                                Text(item.title)
                                    .font(.system(size: 14.5 * themeManager.fontScale, weight: .bold))
                                    .foregroundColor(themeManager.primaryTextColor)

                                if !item.date.isEmpty {
                                    Text(item.date)
                                        .font(.system(size: 11 * themeManager.fontScale))
                                        .foregroundColor(themeManager.secondaryTextColor)
                                }

                                if !item.body.isEmpty {
                                    Text(item.body)
                                        .font(.system(size: 12.5 * themeManager.fontScale))
                                        .foregroundColor(themeManager.primaryTextColor)
                                        .lineSpacing(2)
                                }

                                if !item.url.isEmpty, let link = URL(string: item.url.trimmingCharacters(in: .whitespacesAndNewlines)) {
                                    Button(action: { UIApplication.shared.open(link) }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "doc.text.fill")
                                            Text("Open official letter")
                                        }
                                        .font(.system(size: 12 * themeManager.fontScale, weight: .semibold))
                                        .foregroundColor(themeManager.accentColor)
                                    }
                                    .padding(.top, 2)
                                }

                                HStack {
                                    Spacer()
                                    Button(action: {
                                        let msg = "📢 *\(item.title)*\n\n\(item.body)\n\n— Tamil Nadu Police Technical Services"
                                        if let encoded = msg.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                                           let url = URL(string: "https://wa.me/?text=\(encoded)") {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "square.and.arrow.up")
                                            Text("Share to WhatsApp")
                                        }
                                        .font(.system(size: 11.5 * themeManager.fontScale, weight: .semibold))
                                        .foregroundColor(Color(red: 0.15, green: 0.83, blue: 0.40))
                                    }
                                }
                                .padding(.top, 4)
                            }
                            .padding(12)
                            .background(themeManager.surfaceColor)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isUrgent ? Color.red.opacity(0.6) : themeManager.borderColor, lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(maxHeight: 420)

            Button("Done", action: onDismiss)
                .font(.system(size: 14 * themeManager.fontScale, weight: .bold))
                .foregroundColor(themeManager.primaryColor)
                .padding(.vertical, 12)
        }
        .background(themeManager.surfaceColor)
        .cornerRadius(20)
        .padding(.horizontal, 16)
        .sheet(isPresented: $showComposer) {
            BroadcastComposerSheet(onPost: { title, body, priority, target, url in
                onPostBroadcast?(title, body, priority, target, url) {
                    showComposer = false
                }
            })
            .environmentObject(themeManager)
        }
    }
}

private struct BroadcastComposerSheet: View {
    let onPost: (String, String, String, String, String) -> Void

    @EnvironmentObject var themeManager: TechThemeManager
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String = ""
    @State private var bodyText: String = ""
    @State private var priority: String = "NORMAL"
    @State private var targetGroup: String = "ALL"
    @State private var url: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("TARGET AUDIENCE")) {
                    Picker("Audience", selection: $targetGroup) {
                        Text("All Officers (ALL)").tag("ALL")
                        Text("Technical Only (TECHNICAL)").tag("TECHNICAL")
                        Text("Cities Only (CITIES)").tag("CITIES")
                        Text("Districts Only (DISTRICTS)").tag("DISTRICTS")
                        Text("IT Cell Members (IT_CELL)").tag("IT_CELL")
                    }
                }

                Section(header: Text("PRIORITY")) {
                    Picker("Priority", selection: $priority) {
                        Text("Normal").tag("NORMAL")
                        Text("High").tag("HIGH")
                        Text("Urgent").tag("URGENT")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("ANNOUNCEMENT CONTENT")) {
                    TextField("Title", text: $title)
                    TextEditor(text: $bodyText)
                        .frame(minHeight: 100)
                    TextField("Attachment / Letter URL (Optional)", text: $url)
                        .keyboardType(.URL)
                }

                Section {
                    Button(action: {
                        onPost(title, bodyText, priority, targetGroup, url)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Push Broadcast Announcement")
                            .font(.system(size: 14 * themeManager.fontScale, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(themeManager.accentColor)
                            .cornerRadius(8)
                    }
                    .disabled(title.isEmpty || bodyText.isEmpty)
                }
            }
            .navigationBarTitle("Compose Broadcast", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") { presentationMode.wrappedValue.dismiss() })
        }
    }
}

// -------------------------------------------------------------
// 3. Tech Platform & Digest Modal View
// -------------------------------------------------------------
struct TechPlatformModalView: View {
    let dashboardContent: DashboardContent?
    let currentUserMobile: String?
    let onDismiss: () -> Void

    @EnvironmentObject var themeManager: TechThemeManager
    @State private var searchQuery: String = ""
    @State private var selectedCategory: String = "ALL"

    private let categories: [String] = [
        "ALL",
        TechCategory.WIRELESS_RADIO,
        TechCategory.CCTV_SURVEILLANCE,
        TechCategory.NETWORK_CYBER,
        TechCategory.COMPUTER_HARDWARE,
        TechCategory.SOFTWARE_APPS,
        TechCategory.ADMIN_GOS
    ]

    private var allBulletins: [TechBulletin] {
        TechPlatformRepository.getCombinedBulletins(dashboardContent: dashboardContent)
    }

    private var filteredBulletins: [TechBulletin] {
        allBulletins.filter { b in
            (selectedCategory == "ALL" || b.category.rawValue == selectedCategory) &&
            (searchQuery.isEmpty || b.title.localizedCaseInsensitiveContains(searchQuery) || b.summary.localizedCaseInsensitiveContains(searchQuery))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily TechnoCop Digest")
                        .font(.system(size: 17 * themeManager.fontScale, weight: .bold))
                        .foregroundColor(themeManager.primaryTextColor)
                    Text("Technical Bulletins, Circulars & Government Orders")
                        .font(.system(size: 11 * themeManager.fontScale))
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(themeManager.secondaryTextColor)
                        .padding(6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 10)

            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Search bulletins, GOs, circulars...", text: $searchQuery)
                    .font(.system(size: 13 * themeManager.fontScale))
            }
            .padding(8)
            .background(themeManager.surfaceColor)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(themeManager.borderColor, lineWidth: 1))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            // Category Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(categories, id: \.self) { cat in
                        Button(action: { selectedCategory = cat }) {
                            Text(cat)
                                .font(.system(size: 11.5 * themeManager.fontScale, weight: selectedCategory == cat ? .bold : .medium))
                                .foregroundColor(selectedCategory == cat ? .white : themeManager.primaryTextColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(selectedCategory == cat ? themeManager.primaryColor : themeManager.surfaceColor)
                                .cornerRadius(50)
                                .overlay(RoundedRectangle(cornerRadius: 50).stroke(themeManager.borderColor, lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 8)

            ScrollView {
                VStack(spacing: 10) {
                    if filteredBulletins.isEmpty {
                        Text("No bulletins found in this category.")
                            .font(.system(size: 13 * themeManager.fontScale))
                            .foregroundColor(themeManager.secondaryTextColor)
                            .padding(24)
                    } else {
                        ForEach(filteredBulletins) { b in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(b.category.displayNameEn)
                                        .font(.system(size: 10 * themeManager.fontScale, weight: .bold))
                                        .foregroundColor(themeManager.primaryColor)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(themeManager.lavenderWashColor)
                                        .cornerRadius(4)
                                    Spacer()
                                    Text(b.date)
                                        .font(.system(size: 11 * themeManager.fontScale))
                                        .foregroundColor(themeManager.secondaryTextColor)
                                }

                                Text(b.title)
                                    .font(.system(size: 14 * themeManager.fontScale, weight: .bold))
                                    .foregroundColor(themeManager.primaryTextColor)

                                Text(b.summary)
                                    .font(.system(size: 12.5 * themeManager.fontScale))
                                    .foregroundColor(themeManager.secondaryTextColor)
                                    .lineSpacing(2)

                                if let url = b.fileUrl, !url.isEmpty, let link = URL(string: url) {
                                    Button(action: { UIApplication.shared.open(link) }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "arrow.down.doc.fill")
                                            Text("Download Directive / GO")
                                        }
                                        .font(.system(size: 12 * themeManager.fontScale, weight: .semibold))
                                        .foregroundColor(themeManager.accentColor)
                                    }
                                    .padding(.top, 2)
                                }
                            }
                            .padding(12)
                            .background(themeManager.surfaceColor)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(themeManager.borderColor, lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(maxHeight: 400)

            Button("Done", action: onDismiss)
                .font(.system(size: 14 * themeManager.fontScale, weight: .bold))
                .foregroundColor(themeManager.primaryColor)
                .padding(.vertical, 12)
        }
        .background(themeManager.surfaceColor)
        .cornerRadius(20)
        .padding(.horizontal, 16)
    }
}

// -------------------------------------------------------------
// 4. Retirement Modal View
// -------------------------------------------------------------
struct RetirementModalView: View {
    let forecast: RetirementForecast?
    let contacts: [Contact]
    let onDismiss: () -> Void

    @EnvironmentObject var themeManager: TechThemeManager

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Retirement Forecast")
                    .font(.system(size: 17 * themeManager.fontScale, weight: .bold))
                    .foregroundColor(themeManager.primaryTextColor)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(themeManager.secondaryTextColor)
                        .padding(6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 10)

            ScrollView {
                RetirementSectionView(forecast: forecast, contacts: contacts, onRefresh: {})
                    .padding(.horizontal, 8)
            }
            .frame(maxHeight: 440)

            Button("Done", action: onDismiss)
                .font(.system(size: 14 * themeManager.fontScale, weight: .bold))
                .foregroundColor(themeManager.primaryColor)
                .padding(.vertical, 12)
        }
        .background(themeManager.surfaceColor)
        .cornerRadius(20)
        .padding(.horizontal, 16)
    }
}

// -------------------------------------------------------------
// 5. Special Days Modal View
// -------------------------------------------------------------
struct SpecialDaysModalView: View {
    let onDismiss: () -> Void

    @EnvironmentObject var themeManager: TechThemeManager
    @State private var searchQuery: String = ""

    private let observances: [DailyObservance] = DailyObservancesRepository.observances

    private var filteredObservances: [DailyObservance] {
        if searchQuery.isEmpty { return observances }
        return observances.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.category.localizedCaseInsensitiveContains(searchQuery) ||
            $0.description.localizedCaseInsensitiveContains(searchQuery) ||
            $0.date.contains(searchQuery)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "party.popper.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Special Days & Observances")
                        .font(.system(size: 16.5 * themeManager.fontScale, weight: .bold))
                        .foregroundColor(themeManager.primaryTextColor)
                    Text("Important national, state & police calendar days")
                        .font(.system(size: 11 * themeManager.fontScale))
                        .foregroundColor(themeManager.secondaryTextColor)
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(themeManager.secondaryTextColor)
                        .padding(6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 10)

            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Search special days...", text: $searchQuery)
                    .font(.system(size: 13 * themeManager.fontScale))
            }
            .padding(8)
            .background(themeManager.surfaceColor)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(themeManager.borderColor, lineWidth: 1))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(filteredObservances) { obs in
                        HStack(alignment: .top, spacing: 12) {
                            VStack {
                                Text(obs.date)
                                    .font(.system(size: 12 * themeManager.fontScale, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(themeManager.primaryColor)
                                    .clipShape(Capsule())
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text(obs.name)
                                    .font(.system(size: 13.5 * themeManager.fontScale, weight: .bold))
                                    .foregroundColor(themeManager.primaryTextColor)

                                Text(obs.category)
                                    .font(.system(size: 10.5 * themeManager.fontScale, weight: .semibold))
                                    .foregroundColor(themeManager.accentColor)

                                Text(obs.description)
                                    .font(.system(size: 11.5 * themeManager.fontScale))
                                    .foregroundColor(themeManager.secondaryTextColor)
                                    .lineSpacing(2)
                            }

                            Spacer()
                        }
                        .padding(10)
                        .background(themeManager.surfaceColor)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(themeManager.borderColor, lineWidth: 1))
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(maxHeight: 400)

            Button("Done", action: onDismiss)
                .font(.system(size: 14 * themeManager.fontScale, weight: .bold))
                .foregroundColor(themeManager.primaryColor)
                .padding(.vertical, 12)
        }
        .background(themeManager.surfaceColor)
        .cornerRadius(20)
        .padding(.horizontal, 16)
    }
}
