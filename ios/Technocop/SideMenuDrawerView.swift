import SwiftUI

struct SideMenuDrawerView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var isOpen: Bool
    @Binding var activePage: String
    @Binding var showAboutDialog: Bool
    @Binding var showUpdateDialog: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            // Scrim dimming background
            if isOpen {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isOpen = false
                        }
                    }
            }

            // Drawer Sheet
            if isOpen {
                VStack(alignment: .leading, spacing: 0) {
                    // Header with Officer Details
                    if let officer = store.session?.officer {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("TECHNOCOP")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.white)

                            Text("Welcome \(officer.name)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.white)
                                .lineLimit(1)

                            Text(officer.mobile)
                                .font(.system(size: 13))
                                .foregroundStyle(TechTheme.textLightHeader)

                            let rankParts: [String?] = [officer.rank, officer.batch.isEmpty ? nil : "Batch \(officer.batch)"]
                            let rankBatch = rankParts
                                .compactMap { $0 }
                                .filter { !$0.isEmpty }
                                .joined(separator: " • ")
                            if !rankBatch.isEmpty {
                                Text(rankBatch)
                                    .font(.system(size: 13))
                                    .foregroundStyle(TechTheme.textLightHeader)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(TechTheme.navy)
                    }

                    // Menu Items
                    VStack(alignment: .leading, spacing: 2) {
                        menuButton(title: "Dashboard", systemImage: "chart.bar.fill", isSelected: activePage == "home") {
                            activePage = "home"
                            closeDrawer()
                        }

                        menuButton(title: "Profile", systemImage: "person.crop.circle.fill", isSelected: activePage == "profile") {
                            activePage = "profile"
                            closeDrawer()
                        }

                        menuButton(title: "App Update", systemImage: "arrow.down.circle.fill", isSelected: false) {
                            closeDrawer()
                            showUpdateDialog = true
                            Task {
                                await store.checkForAppUpdate()
                            }
                        }

                        menuButton(title: "About", systemImage: "info.circle.fill", isSelected: false) {
                            closeDrawer()
                            showAboutDialog = true
                        }

                        Divider()
                            .padding(.vertical, 8)

                        menuButton(title: "Sign out", systemImage: "rectangle.portrait.and.arrow.right", isDestructive: true) {
                            closeDrawer()
                            Task {
                                await store.signOut()
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 8)

                    Spacer()
                }
                .frame(width: 280)
                .background(Color.white)
                .ignoresSafeArea(edges: .vertical)
                .transition(.move(edge: .leading))
            }
        }
    }

    private func menuButton(
        title: String,
        systemImage: String,
        isSelected: Bool = false,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 18))
                    .foregroundStyle(isDestructive ? Color.red : (isSelected ? TechTheme.navy : Color.secondary))
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(isDestructive ? Color.red : TechTheme.navy)

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(isSelected ? TechTheme.officerRowBackgroundLight : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func closeDrawer() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isOpen = false
        }
    }
}

