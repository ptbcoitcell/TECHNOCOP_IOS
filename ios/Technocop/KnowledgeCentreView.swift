import SwiftUI

struct KnowledgeCentreView: View {
    let onBack: () -> Void
    var onOpenDigest: (() -> Void)? = nil

    @EnvironmentObject var themeManager: TechThemeManager
    @State private var searchQuery: String = ""
    @State private var selectedCategory: String? = nil
    @State private var selectedDifficulty: KnowledgeDifficulty? = nil
    @State private var selectedDomain: KnowledgeDomain? = nil
    @State private var showOnlyBookmarks: Bool = false

    @State private var selectedArticle: TroubleshootingArticle? = nil
    @State private var showAiPromptsDialog: Bool = false
    @State private var showTechTipsArchive: Bool = false
    @State private var bookmarkedIds: Set<String> = Set(UserDefaults.standard.stringArray(forKey: "technocop_bookmarked_articles") ?? [])
    @State private var copiedToast: String? = nil

    private let todayTip: DailyTechTip = KnowledgeCentreRepository.getTodayTip()

    private var filteredArticles: [TroubleshootingArticle] {
        let base = KnowledgeCentreRepository.searchArticles(
            query: searchQuery,
            selectedCategory: selectedCategory,
            selectedDifficulty: selectedDifficulty,
            selectedDomain: selectedDomain
        )
        if showOnlyBookmarks {
            return base.filter { bookmarkedIds.contains($0.id) }
        }
        return base
    }

    private func toggleBookmark(_ id: String) {
        if bookmarkedIds.contains(id) {
            bookmarkedIds.remove(id)
        } else {
            bookmarkedIds.insert(id)
        }
        UserDefaults.standard.set(Array(bookmarkedIds), forKey: "technocop_bookmarked_articles")
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Button(action: onBack) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeManager.primaryTextColor)
                }
                .buttonStyle(PlainButtonStyle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("Tech-Knowledge Base")
                        .font(.system(size: 16.5 * themeManager.fontScale, weight: .bold))
                        .foregroundColor(themeManager.primaryTextColor)
                    Text("Your technical companion – PTB in your fingertips")
                        .font(.system(size: 11.5 * themeManager.fontScale, weight: .medium))
                        .foregroundColor(themeManager.accentColor)
                }
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(themeManager.surfaceColor)
            .overlay(Rectangle().frame(height: 1).foregroundColor(themeManager.borderColor), alignment: .bottom)

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    // 1. Daily Tech Tip Card
                    DailyTechTipCardView(
                        tip: todayTip,
                        onViewArchive: { showTechTipsArchive = true },
                        onCopy: { cmd in
                            UIPasteboard.general.string = cmd
                            triggerToast("Copied command to clipboard")
                        }
                    )

                    // 2. 6 Top-Level Hub Cards
                    Text("Support & Learning Hubs")
                        .font(.system(size: 15 * themeManager.fontScale, weight: .bold))
                        .foregroundColor(themeManager.primaryTextColor)

                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            HubCardView(
                                title: "Computer Support",
                                subtitle: "Windows, Acer, Apple",
                                icon: "desktopcomputer",
                                isSelected: selectedCategory == "Computer Support",
                                onTap: { selectedCategory = (selectedCategory == "Computer Support") ? nil : "Computer Support" }
                            )
                            HubCardView(
                                title: "CCTV Support",
                                subtitle: "Hardware & software",
                                icon: "video.fill",
                                isSelected: selectedCategory == "CCTV Support",
                                onTap: { selectedCategory = (selectedCategory == "CCTV Support") ? nil : "CCTV Support" }
                            )
                        }

                        HStack(spacing: 8) {
                            HubCardView(
                                title: "Network Support",
                                subtitle: "LAN, WAN, Wi-Fi, VHF",
                                icon: "network",
                                isSelected: selectedCategory == "Network Support",
                                onTap: { selectedCategory = (selectedCategory == "Network Support") ? nil : "Network Support" }
                            )
                            HubCardView(
                                title: "AI Quick Prompts",
                                subtitle: "ChatGPT, Claude, Gemini",
                                icon: "cpu",
                                isSelected: false,
                                onTap: { showAiPromptsDialog = true }
                            )
                        }

                        HStack(spacing: 8) {
                            HubCardView(
                                title: "Technical Learning",
                                subtitle: "Guides & tutorials",
                                icon: "book.fill",
                                isSelected: selectedCategory == "Technical Learning",
                                onTap: { selectedCategory = (selectedCategory == "Technical Learning") ? nil : "Technical Learning" }
                            )
                            HubCardView(
                                title: "Technology Digest",
                                subtitle: "Latest updates & directives",
                                icon: "doc.text.fill",
                                isSelected: false,
                                onTap: { onOpenDigest?() }
                            )
                        }
                    }

                    // 3. Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(themeManager.secondaryTextColor)
                        TextField("Search problems, error codes (0x...), commands...", text: $searchQuery)
                            .font(.system(size: 13 * themeManager.fontScale))
                        if !searchQuery.isEmpty {
                            Button(action: { searchQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(themeManager.surfaceColor)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(themeManager.borderColor, lineWidth: 1))

                    // 4. Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            FilterPillView(
                                label: "All Guides",
                                isSelected: selectedCategory == nil && selectedDifficulty == nil && selectedDomain == nil && !showOnlyBookmarks,
                                onTap: {
                                    selectedCategory = nil
                                    selectedDifficulty = nil
                                    selectedDomain = nil
                                    showOnlyBookmarks = false
                                }
                            )
                            FilterPillView(
                                label: "Saved (\(bookmarkedIds.count))",
                                isSelected: showOnlyBookmarks,
                                icon: "bookmark.fill",
                                onTap: { showOnlyBookmarks.toggle() }
                            )
                            FilterPillView(
                                label: "Beginner",
                                isSelected: selectedDifficulty == .beginner,
                                onTap: { selectedDifficulty = (selectedDifficulty == .beginner) ? nil : .beginner }
                            )
                            FilterPillView(
                                label: "Intermediate",
                                isSelected: selectedDifficulty == .intermediate,
                                onTap: { selectedDifficulty = (selectedDifficulty == .intermediate) ? nil : .intermediate }
                            )
                            FilterPillView(
                                label: "Advanced",
                                isSelected: selectedDifficulty == .advanced,
                                onTap: { selectedDifficulty = (selectedDifficulty == .advanced) ? nil : .advanced }
                            )
                            FilterPillView(
                                label: "Hardware",
                                isSelected: selectedDomain == .hardware,
                                onTap: { selectedDomain = (selectedDomain == .hardware) ? nil : .hardware }
                            )
                            FilterPillView(
                                label: "Software",
                                isSelected: selectedDomain == .software,
                                onTap: { selectedDomain = (selectedDomain == .software) ? nil : .software }
                            )
                        }
                    }

                    // 5. Results Header
                    HStack {
                        Text(selectedCategory != nil ? "\(selectedCategory!) (\(filteredArticles.count))" : "Troubleshooting Guides (\(filteredArticles.count))")
                            .font(.system(size: 15 * themeManager.fontScale, weight: .bold))
                            .foregroundColor(themeManager.primaryTextColor)
                        Spacer()
                        if selectedCategory != nil {
                            Button("Show All") { selectedCategory = nil }
                                .font(.system(size: 12 * themeManager.fontScale, weight: .medium))
                                .foregroundColor(themeManager.accentColor)
                        }
                    }

                    // 6. Articles List
                    if filteredArticles.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 32))
                                .foregroundColor(.gray)
                            Text("No matching troubleshooting guides found.")
                                .font(.system(size: 14 * themeManager.fontScale, weight: .bold))
                                .foregroundColor(themeManager.primaryTextColor)
                            Text("Try searching by error code or clearing category filters.")
                                .font(.system(size: 12 * themeManager.fontScale))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .background(themeManager.surfaceColor)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(themeManager.borderColor, lineWidth: 1))
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredArticles) { article in
                                ArticleCardView(
                                    article: article,
                                    isBookmarked: bookmarkedIds.contains(article.id),
                                    onToggleBookmark: { toggleBookmark(article.id) },
                                    onTap: { selectedArticle = article }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
        }
        .background(themeManager.backgroundColor)
        .sheet(item: $selectedArticle) { article in
            ArticleDetailSheet(
                article: article,
                isBookmarked: bookmarkedIds.contains(article.id),
                onToggleBookmark: { toggleBookmark(article.id) },
                onCopyCommand: { cmd in
                    UIPasteboard.general.string = cmd
                    triggerToast("Command copied")
                }
            )
            .environmentObject(themeManager)
        }
        .sheet(isPresented: $showAiPromptsDialog) {
            AiPromptsSheet(onCopy: { prompt in
                UIPasteboard.general.string = prompt
                triggerToast("AI Prompt copied to clipboard")
            })
            .environmentObject(themeManager)
        }
        .sheet(isPresented: $showTechTipsArchive) {
            TechTipsArchiveSheet(onCopy: { cmd in
                UIPasteboard.general.string = cmd
                triggerToast("Command copied")
            })
            .environmentObject(themeManager)
        }
        .overlay(
            Group {
                if let toast = copiedToast {
                    VStack {
                        Spacer()
                        Text(toast)
                            .font(.system(size: 12 * themeManager.fontScale, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.85))
                            .clipShape(Capsule())
                            .padding(.bottom, 24)
                    }
                    .transition(.opacity)
                }
            }
        )
    }

    private func triggerToast(_ msg: String) {
        copiedToast = msg
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if copiedToast == msg { copiedToast = nil }
        }
    }
}

// -------------------------------------------------------------
// Hub Card View
// -------------------------------------------------------------
private struct HubCardView: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let onTap: () -> Void

    @EnvironmentObject var themeManager: TechThemeManager

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(isSelected ? .white : themeManager.primaryColor)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }
                Spacer().frame(height: 2)
                Text(title)
                    .font(.system(size: 13.5 * themeManager.fontScale, weight: .bold))
                    .foregroundColor(isSelected ? .white : themeManager.primaryTextColor)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.system(size: 10.5 * themeManager.fontScale))
                    .foregroundColor(isSelected ? Color.white.opacity(0.85) : themeManager.secondaryTextColor)
                    .lineLimit(1)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? themeManager.primaryColor : themeManager.surfaceColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? themeManager.accentColor : themeManager.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// -------------------------------------------------------------
// Daily Tech Tip Card View
// -------------------------------------------------------------
private struct DailyTechTipCardView: View {
    let tip: DailyTechTip
    let onViewArchive: () -> Void
    let onCopy: (String) -> Void

    @EnvironmentObject var themeManager: TechThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(themeManager.accentColor)
                    Text("DAILY TECH TIP")
                        .font(.system(size: 11 * themeManager.fontScale, weight: .bold))
                        .foregroundColor(themeManager.accentColor)
                }
                Spacer()
                Text(tip.category)
                    .font(.system(size: 10 * themeManager.fontScale, weight: .bold))
                    .foregroundColor(themeManager.primaryColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(themeManager.lavenderWashColor)
                    .cornerRadius(4)
            }

            Text(tip.title)
                .font(.system(size: 14.5 * themeManager.fontScale, weight: .bold))
                .foregroundColor(themeManager.primaryTextColor)

            Text(tip.tipText)
                .font(.system(size: 12 * themeManager.fontScale))
                .foregroundColor(themeManager.secondaryTextColor)
                .lineSpacing(2)

            if let cmd = tip.commandOrShortcut, !cmd.isEmpty {
                HStack {
                    Text(cmd)
                        .font(.system(size: 11.5 * themeManager.fontScale, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(red: 0.22, green: 0.74, blue: 0.97))
                    Spacer()
                    Button(action: { onCopy(cmd) }) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(red: 0.06, green: 0.09, blue: 0.16))
                .cornerRadius(8)
            }

            if let tamil = tip.tamilExplanation, !tamil.isEmpty {
                Text(tamil)
                    .font(.system(size: 11.5 * themeManager.fontScale))
                    .foregroundColor(themeManager.secondaryTextColor)
            }

            HStack {
                Spacer()
                Button(action: onViewArchive) {
                    HStack(spacing: 4) {
                        Text("View all tips")
                            .font(.system(size: 11.5 * themeManager.fontScale, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
        .padding(14)
        .background(themeManager.isDark ? Color(red: 0.12, green: 0.14, blue: 0.22) : Color(red: 0.93, green: 0.95, blue: 1.0))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(themeManager.isDark ? Color.white.opacity(0.3) : Color(red: 0.39, green: 0.40, blue: 0.95), lineWidth: 1))
    }
}

// -------------------------------------------------------------
// Filter Pill View
// -------------------------------------------------------------
private struct FilterPillView: View {
    let label: String
    let isSelected: Bool
    var icon: String? = nil
    let onTap: () -> Void

    @EnvironmentObject var themeManager: TechThemeManager

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 11))
                }
                Text(label)
                    .font(.system(size: 12 * themeManager.fontScale, weight: isSelected ? .bold : .medium))
            }
            .foregroundColor(isSelected ? .white : themeManager.primaryTextColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? themeManager.primaryColor : themeManager.surfaceColor)
            .cornerRadius(50)
            .overlay(RoundedRectangle(cornerRadius: 50).stroke(isSelected ? themeManager.accentColor : themeManager.borderColor, lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// -------------------------------------------------------------
// Article Card View
// -------------------------------------------------------------
private struct ArticleCardView: View {
    let article: TroubleshootingArticle
    let isBookmarked: Bool
    let onToggleBookmark: () -> Void
    let onTap: () -> Void

    @EnvironmentObject var themeManager: TechThemeManager

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text(article.category)
                                .font(.system(size: 10 * themeManager.fontScale, weight: .bold))
                                .foregroundColor(themeManager.primaryColor)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(themeManager.lavenderWashColor)
                                .cornerRadius(4)

                            Text(article.difficulty.displayName)
                                .font(.system(size: 10 * themeManager.fontScale, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(article.difficulty == .beginner ? Color.green : (article.difficulty == .intermediate ? Color.orange : Color.red))
                                .cornerRadius(4)

                            Text(article.domain.displayName)
                                .font(.system(size: 10 * themeManager.fontScale, weight: .semibold))
                                .foregroundColor(themeManager.secondaryTextColor)
                        }

                        Text(article.title)
                            .font(.system(size: 14 * themeManager.fontScale, weight: .bold))
                            .foregroundColor(themeManager.primaryTextColor)
                            .lineLimit(2)
                    }

                    Spacer()

                    Button(action: onToggleBookmark) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 16))
                            .foregroundColor(isBookmarked ? Color(red: 0.88, green: 0.11, blue: 0.28) : themeManager.secondaryTextColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                if let firstSymptom = article.symptoms.first {
                    Text("• \(firstSymptom)")
                        .font(.system(size: 12 * themeManager.fontScale))
                        .foregroundColor(themeManager.secondaryTextColor)
                        .lineLimit(1)
                }

                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text(article.estimatedReadTime)
                            .font(.system(size: 11 * themeManager.fontScale))
                    }
                    .foregroundColor(themeManager.secondaryTextColor)

                    Spacer()

                    HStack(spacing: 2) {
                        Text("View Solution")
                            .font(.system(size: 11.5 * themeManager.fontScale, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
            .padding(12)
            .background(themeManager.surfaceColor)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(themeManager.borderColor, lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// -------------------------------------------------------------
// Article Detail Sheet
// -------------------------------------------------------------
private struct ArticleDetailSheet: View {
    let article: TroubleshootingArticle
    let isBookmarked: Bool
    let onToggleBookmark: () -> Void
    let onCopyCommand: (String) -> Void

    @EnvironmentObject var themeManager: TechThemeManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    // Category & Badges
                    HStack(spacing: 6) {
                        Text(article.category)
                            .font(.system(size: 11 * themeManager.fontScale, weight: .bold))
                            .foregroundColor(themeManager.primaryColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(themeManager.lavenderWashColor)
                            .cornerRadius(6)

                        Text(article.difficulty.displayName)
                            .font(.system(size: 11 * themeManager.fontScale, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(article.difficulty == .beginner ? Color.green : (article.difficulty == .intermediate ? Color.orange : Color.red))
                            .cornerRadius(6)

                        Text(article.domain.displayName)
                            .font(.system(size: 11 * themeManager.fontScale, weight: .medium))
                            .foregroundColor(themeManager.secondaryTextColor)

                        Spacer()

                        Text(article.estimatedReadTime)
                            .font(.system(size: 11 * themeManager.fontScale))
                            .foregroundColor(themeManager.secondaryTextColor)
                    }

                    // Title
                    Text(article.title)
                        .font(.system(size: 18 * themeManager.fontScale, weight: .bold))
                        .foregroundColor(themeManager.primaryTextColor)

                    // Symptoms
                    if !article.symptoms.isEmpty {
                        SectionBox(title: "Symptoms") {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(article.symptoms, id: \.self) { sym in
                                    Text("• \(sym)")
                                        .font(.system(size: 13 * themeManager.fontScale))
                                        .foregroundColor(themeManager.primaryTextColor)
                                }
                            }
                        }
                    }

                    // Possible Causes
                    if !article.possibleCauses.isEmpty {
                        SectionBox(title: "Possible Causes") {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(article.possibleCauses, id: \.self) { cause in
                                    Text("• \(cause)")
                                        .font(.system(size: 13 * themeManager.fontScale))
                                        .foregroundColor(themeManager.primaryTextColor)
                                }
                            }
                        }
                    }

                    // Tools Required
                    if !article.toolsRequired.isEmpty {
                        SectionBox(title: "Tools Required") {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(article.toolsRequired, id: \.self) { tool in
                                    Text("• \(tool)")
                                        .font(.system(size: 13 * themeManager.fontScale))
                                        .foregroundColor(themeManager.primaryTextColor)
                                }
                            }
                        }
                    }

                    // Step-by-Step Solution
                    if !article.solutionSteps.isEmpty {
                        SectionBox(title: "Step-by-Step Solution") {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(Array(article.solutionSteps.enumerated()), id: \.offset) { idx, step in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("\(idx + 1).")
                                            .font(.system(size: 13 * themeManager.fontScale, weight: .bold))
                                            .foregroundColor(themeManager.primaryColor)
                                        Text(step)
                                            .font(.system(size: 13 * themeManager.fontScale))
                                            .foregroundColor(themeManager.primaryTextColor)
                                    }
                                }
                            }
                        }
                    }

                    // Diagnostic Commands
                    if let cmds = article.diagnosticCommands, !cmds.isEmpty {
                        SectionBox(title: "Diagnostic Commands") {
                            VStack(spacing: 6) {
                                ForEach(cmds, id: \.command) { cmd in
                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack {
                                            Text(cmd.command)
                                                .font(.system(size: 12 * themeManager.fontScale, weight: .medium, design: .monospaced))
                                                .foregroundColor(Color(red: 0.22, green: 0.74, blue: 0.97))
                                            Spacer()
                                            Button(action: { onCopyCommand(cmd.command) }) {
                                                Image(systemName: "doc.on.doc")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.white)
                                            }
                                        }
                                        if !cmd.description.isEmpty {
                                            Text(cmd.description)
                                                .font(.system(size: 11 * themeManager.fontScale))
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(8)
                                    .background(Color(red: 0.06, green: 0.09, blue: 0.16))
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }

                    // Expected Result
                    if let result = article.expectedResult, !result.isEmpty {
                        SectionBox(title: "Expected Result") {
                            Text(result)
                                .font(.system(size: 13 * themeManager.fontScale))
                                .foregroundColor(themeManager.primaryTextColor)
                        }
                    }

                    // Escalation Guidelines
                    if let esc = article.escalationGuidelines, !esc.isEmpty {
                        SectionBox(title: "Escalation Guidelines") {
                            Text(esc)
                                .font(.system(size: 13 * themeManager.fontScale))
                                .foregroundColor(Color(red: 0.85, green: 0.20, blue: 0.20))
                        }
                    }

                    // Tamil Explanation
                    if let tamil = article.tamilExplanation, !tamil.isEmpty {
                        SectionBox(title: "விளக்கம் (Tamil)") {
                            Text(tamil)
                                .font(.system(size: 13 * themeManager.fontScale))
                                .foregroundColor(themeManager.primaryTextColor)
                        }
                    }
                }
                .padding(16)
            }
            .background(themeManager.backgroundColor)
            .navigationBarTitle("Guide Details", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: onToggleBookmark) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(isBookmarked ? Color(red: 0.88, green: 0.11, blue: 0.28) : themeManager.primaryTextColor)
                },
                trailing: Button("Done") { presentationMode.wrappedValue.dismiss() }
                    .foregroundColor(themeManager.primaryColor)
            )
        }
    }
}

private struct SectionBox<Content: View>: View {
    let title: String
    let content: () -> Content

    @EnvironmentObject var themeManager: TechThemeManager

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13.5 * themeManager.fontScale, weight: .bold))
                .foregroundColor(themeManager.accentColor)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(themeManager.surfaceColor)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(themeManager.borderColor, lineWidth: 1))
    }
}

// -------------------------------------------------------------
// AI Prompts Sheet
// -------------------------------------------------------------
private struct AiPromptsSheet: View {
    let onCopy: (String) -> Void

    @EnvironmentObject var themeManager: TechThemeManager
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPlatform: String = "All"
    @State private var query: String = ""

    private let prompts: [AiPrompt] = KnowledgeCentreRepository.aiPrompts

    private var filteredPrompts: [AiPrompt] {
        prompts.filter { p in
            (selectedPlatform == "All" || p.category.localizedCaseInsensitiveContains(selectedPlatform)) &&
            (query.isEmpty || p.title.localizedCaseInsensitiveContains(query) || p.prompt.localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Search AI prompts...", text: $query)
                }
                .padding(10)
                .background(themeManager.surfaceColor)
                .cornerRadius(10)
                .padding(.horizontal)

                // Platform filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(["All", "ChatGPT", "Claude", "Gemini", "Report", "Analysis"], id: \.self) { cat in
                            Button(action: { selectedPlatform = cat }) {
                                Text(cat)
                                    .font(.system(size: 12 * themeManager.fontScale, weight: selectedPlatform == cat ? .bold : .medium))
                                    .foregroundColor(selectedPlatform == cat ? .white : themeManager.primaryTextColor)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(selectedPlatform == cat ? themeManager.primaryColor : themeManager.surfaceColor)
                                    .cornerRadius(50)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                List {
                    ForEach(filteredPrompts) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(item.category)
                                    .font(.system(size: 10 * themeManager.fontScale, weight: .bold))
                                    .foregroundColor(themeManager.primaryColor)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(themeManager.lavenderWashColor)
                                    .cornerRadius(4)
                                Spacer()
                                Button(action: { onCopy(item.prompt) }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "doc.on.doc")
                                        Text("Copy")
                                    }
                                    .font(.system(size: 11 * themeManager.fontScale, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(themeManager.accentColor)
                                    .clipShape(Capsule())
                                }
                            }
                            Text(item.title)
                                .font(.system(size: 13.5 * themeManager.fontScale, weight: .bold))
                                .foregroundColor(themeManager.primaryTextColor)
                            Text(item.prompt)
                                .font(.system(size: 12 * themeManager.fontScale))
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .background(themeManager.backgroundColor)
            .navigationBarTitle("AI Quick Prompts", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") { presentationMode.wrappedValue.dismiss() })
        }
    }
}

// -------------------------------------------------------------
// Tech Tips Archive Sheet
// -------------------------------------------------------------
private struct TechTipsArchiveSheet: View {
    let onCopy: (String) -> Void

    @EnvironmentObject var themeManager: TechThemeManager
    @Environment(\.presentationMode) var presentationMode
    @State private var query: String = ""

    private let allTips: [DailyTechTip] = KnowledgeCentreRepository.dailyTips

    private var filteredTips: [DailyTechTip] {
        if query.isEmpty { return allTips }
        return allTips.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.tipText.localizedCaseInsensitiveContains(query) ||
            $0.category.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Search tech tips...", text: $query)
                }
                .padding(10)
                .background(themeManager.surfaceColor)
                .cornerRadius(10)
                .padding(.horizontal)

                List {
                    ForEach(filteredTips) { tip in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(tip.category)
                                    .font(.system(size: 10 * themeManager.fontScale, weight: .bold))
                                    .foregroundColor(themeManager.primaryColor)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(themeManager.lavenderWashColor)
                                    .cornerRadius(4)
                                Spacer()
                            }
                            Text(tip.title)
                                .font(.system(size: 13.5 * themeManager.fontScale, weight: .bold))
                                .foregroundColor(themeManager.primaryTextColor)
                            Text(tip.tipText)
                                .font(.system(size: 12 * themeManager.fontScale))
                                .foregroundColor(themeManager.secondaryTextColor)

                            if let cmd = tip.commandOrShortcut, !cmd.isEmpty {
                                HStack {
                                    Text(cmd)
                                        .font(.system(size: 11 * themeManager.fontScale, weight: .medium, design: .monospaced))
                                        .foregroundColor(Color(red: 0.22, green: 0.74, blue: 0.97))
                                    Spacer()
                                    Button(action: { onCopy(cmd) }) {
                                        Image(systemName: "doc.on.doc")
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(6)
                                .background(Color(red: 0.06, green: 0.09, blue: 0.16))
                                .cornerRadius(6)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .background(themeManager.backgroundColor)
            .navigationBarTitle("Daily Tech Tips Archive", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") { presentationMode.wrappedValue.dismiss() })
        }
    }
}
