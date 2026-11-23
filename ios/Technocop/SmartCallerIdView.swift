import SwiftUI

struct SmartCallerIdView: View {
    let officer: Officer?
    let contacts: [Contact]
    let onDismiss: () -> Void

    @EnvironmentObject var themeManager: TechThemeManager
    @State private var lookupQuery: String = ""
    @State private var showTestBadge: Bool = false

    private var matchedOfficer: Contact? {
        let clean = lookupQuery.filter { $0.isNumber }
        if clean.count < 4 { return nil }
        return contacts.first { contact in
            let cDigits = contact.mobile.filter { $0.isNumber }
            return cDigits.hasSuffix(clean) || clean.hasSuffix(cDigits)
        }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(themeManager.lavenderWashColor)
                            .frame(width: 36, height: 36)
                        Image(systemName: "phone.fill")
                            .font(.system(size: 18))
                            .foregroundColor(themeManager.primaryColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Smart Caller ID")
                            .font(.system(size: 17 * themeManager.fontScale, weight: .bold))
                            .foregroundColor(themeManager.primaryTextColor)
                        Text("PTB in your fingertips")
                            .font(.system(size: 11 * themeManager.fontScale, weight: .medium))
                            .foregroundColor(themeManager.accentColor)
                    }

                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(themeManager.secondaryTextColor)
                            .padding(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Pops up a futuristic police badge showing officer rank and unit on incoming calls.")
                            .font(.system(size: 12.5 * themeManager.fontScale))
                            .foregroundColor(themeManager.secondaryTextColor)
                            .lineSpacing(3)

                        // 1. Status Row
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.shield.fill")
                                    .foregroundColor(.green)
                                Text("Call Directory Lookup")
                                    .font(.system(size: 13 * themeManager.fontScale, weight: .semibold))
                                    .foregroundColor(themeManager.primaryTextColor)
                            }
                            Spacer()
                            Text("Active")
                                .font(.system(size: 11 * themeManager.fontScale, weight: .bold))
                                .foregroundColor(Color(red: 0.08, green: 0.50, blue: 0.24))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(red: 0.86, green: 0.99, blue: 0.91))
                                .clipShape(Capsule())
                        }
                        .padding(12)
                        .background(Color(red: 0.94, green: 0.99, blue: 0.96))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 0.73, green: 0.97, blue: 0.82), lineWidth: 1))

                        // 2. In-App Instant Number Lookup
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Instant Number Lookup")
                                .font(.system(size: 13 * themeManager.fontScale, weight: .bold))
                                .foregroundColor(themeManager.primaryTextColor)

                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                TextField("Enter last 4-10 digits of mobile...", text: $lookupQuery)
                                    .keyboardType(.phonePad)
                                    .font(.system(size: 13 * themeManager.fontScale))
                                if !lookupQuery.isEmpty {
                                    Button(action: { lookupQuery = "" }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(10)
                            .background(themeManager.surfaceColor)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(themeManager.borderColor, lineWidth: 1))

                            if let match = matchedOfficer {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(themeManager.primaryColor)
                                            .frame(width: 44, height: 44)
                                        Text(officerInitials(match.name))
                                            .font(.system(size: 16 * themeManager.fontScale, weight: .bold))
                                            .foregroundColor(.white)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(match.name)
                                            .font(.system(size: 14 * themeManager.fontScale, weight: .bold))
                                            .foregroundColor(themeManager.primaryTextColor)
                                        Text("\(match.rank) • \(match.unit)")
                                            .font(.system(size: 12 * themeManager.fontScale))
                                            .foregroundColor(themeManager.secondaryTextColor)
                                        Text(match.mobile)
                                            .font(.system(size: 11 * themeManager.fontScale, weight: .medium))
                                            .foregroundColor(themeManager.accentColor)
                                    }

                                    Spacer()

                                    Button(action: {
                                        if let url = URL(string: "tel:\(match.mobile)") {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        Image(systemName: "phone.circle.fill")
                                            .font(.system(size: 32))
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding(12)
                                .background(themeManager.lavenderWashColor)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(themeManager.accentColor, lineWidth: 1))
                            } else if lookupQuery.count >= 4 {
                                Text("No officer found matching '\(lookupQuery)'.")
                                    .font(.system(size: 12 * themeManager.fontScale))
                                    .foregroundColor(.gray)
                                    .padding(.vertical, 4)
                            }
                        }

                        // 3. iOS System Instructions
                        VStack(alignment: .leading, spacing: 6) {
                            Text("iOS Caller ID Setup:")
                                .font(.system(size: 12 * themeManager.fontScale, weight: .bold))
                                .foregroundColor(themeManager.primaryTextColor)
                            Text("1. Open iPhone Settings > Phone")
                                .font(.system(size: 11.5 * themeManager.fontScale))
                                .foregroundColor(themeManager.secondaryTextColor)
                            Text("2. Tap 'Call Blocking & Identification'")
                                .font(.system(size: 11.5 * themeManager.fontScale))
                                .foregroundColor(themeManager.secondaryTextColor)
                            Text("3. Enable 'TECHNOCOP' to identify incoming police calls.")
                                .font(.system(size: 11.5 * themeManager.fontScale))
                                .foregroundColor(themeManager.secondaryTextColor)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(themeManager.lavenderWashColor)
                        .cornerRadius(8)

                        // 4. Test Pop-up Button
                        Button(action: {
                            showTestBadge = true
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 14))
                                Text("Test Caller ID Pop-up")
                                    .font(.system(size: 13.5 * themeManager.fontScale, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(themeManager.accentColor)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }

                // Done Button
                Button(action: onDismiss) {
                    Text("Done")
                        .font(.system(size: 13.5 * themeManager.fontScale, weight: .bold))
                        .foregroundColor(themeManager.primaryColor)
                        .padding(.vertical, 12)
                }
            }
            .background(themeManager.surfaceColor)
            .cornerRadius(20)
            .padding(.horizontal, 16)

            // Futuristic Badge Overlay Simulation
            if showTestBadge {
                Color.black.opacity(0.6)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { showTestBadge = false }

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image("TechnocopLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color(red: 1.0, green: 0.84, blue: 0.0), lineWidth: 2))

                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text("TAMIL NADU POLICE")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                                Spacer()
                                Text("VERIFIED")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green)
                                    .cornerRadius(4)
                            }

                            Text(officer?.name ?? "R.A.ARULKALAISELVAN")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)

                            Text("\(officer?.rank ?? "SI(T)") • \(officer?.unit ?? "PTB Hqrs")")
                                .font(.system(size: 12))
                                .foregroundColor(Color.white.opacity(0.85))

                            Text("Technical Services • Batch \(officer?.batch ?? "2013")")
                                .font(.system(size: 11))
                                .foregroundColor(Color(red: 0.58, green: 0.77, blue: 0.98))
                        }
                    }
                    .padding(14)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.11, green: 0.13, blue: 0.30), Color(red: 0.17, green: 0.13, blue: 0.34)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(red: 1.0, green: 0.84, blue: 0.0), lineWidth: 1.5))
                    .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 24)

                    Button("Dismiss Preview") { showTestBadge = false }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        }
    }
}
