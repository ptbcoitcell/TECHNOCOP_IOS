import SwiftUI

struct ThemeAndAppearanceDialog: View {
    @EnvironmentObject var themeManager: TechThemeManager
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(themeManager.lavenderWashColor)
                        .frame(width: 36, height: 36)
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 18))
                        .foregroundColor(themeManager.primaryColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Display & Theme")
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
                VStack(spacing: 16) {
                    // 1. Font Size Control
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Font Size")
                                .font(.system(size: 13 * themeManager.fontScale, weight: .bold))
                                .foregroundColor(themeManager.primaryTextColor)
                            Spacer()
                            Text(fontScaleLabel)
                                .font(.system(size: 12 * themeManager.fontScale, weight: .semibold))
                                .foregroundColor(themeManager.accentColor)
                        }

                        // Stepper buttons
                        HStack(spacing: 8) {
                            Button(action: { themeManager.decreaseFontScale() }) {
                                Text("A -")
                                    .font(.system(size: 13 * themeManager.fontScale, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 38)
                                    .background(themeManager.surfaceColor)
                                    .foregroundColor(themeManager.primaryTextColor)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(themeManager.borderColor, lineWidth: 1))
                            }
                            .disabled(themeManager.fontScale <= 0.86)

                            Button(action: { themeManager.increaseFontScale() }) {
                                Text("A +")
                                    .font(.system(size: 15 * themeManager.fontScale, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 38)
                                    .background(themeManager.surfaceColor)
                                    .foregroundColor(themeManager.primaryTextColor)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(themeManager.borderColor, lineWidth: 1))
                            }
                            .disabled(themeManager.fontScale >= 1.29)
                        }

                        // Presets
                        HStack(spacing: 4) {
                            ForEach([
                                (scale: CGFloat(0.85), label: "85%"),
                                (scale: CGFloat(1.00), label: "100%"),
                                (scale: CGFloat(1.15), label: "115%"),
                                (scale: CGFloat(1.30), label: "130%")
                            ], id: \.label) { item in
                                let isSelected = abs(themeManager.fontScale - item.scale) < 0.05
                                Button(action: { themeManager.setFontScale(item.scale) }) {
                                    Text(item.label)
                                        .font(.system(size: 11 * themeManager.fontScale, weight: isSelected ? .bold : .regular))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 6)
                                        .background(isSelected ? themeManager.primaryColor : themeManager.surfaceColor)
                                        .foregroundColor(isSelected ? .white : themeManager.primaryTextColor)
                                        .cornerRadius(6)
                                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(isSelected ? themeManager.accentColor : themeManager.borderColor, lineWidth: 1))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(12)
                    .background(themeManager.lavenderWashColor)
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(themeManager.borderColor, lineWidth: 1))

                    // 2. Light / Dark / System Mode
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Theme Mode")
                            .font(.system(size: 13 * themeManager.fontScale, weight: .bold))
                            .foregroundColor(themeManager.primaryTextColor)

                        HStack(spacing: 6) {
                            ForEach([
                                (mode: "LIGHT", label: "Light", icon: "sun.max.fill"),
                                (mode: "DARK", label: "Dark", icon: "moon.fill"),
                                (mode: "SYSTEM", label: "System", icon: "gearshape.fill")
                            ], id: \.mode) { item in
                                let isSelected = themeManager.themeMode.caseInsensitiveCompare(item.mode) == .orderedSame
                                Button(action: { themeManager.setThemeMode(item.mode) }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: item.icon)
                                            .font(.system(size: 13))
                                        Text(item.label)
                                            .font(.system(size: 12 * themeManager.fontScale, weight: isSelected ? .bold : .medium))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? themeManager.primaryColor : themeManager.surfaceColor)
                                    .foregroundColor(isSelected ? .white : themeManager.primaryTextColor)
                                    .cornerRadius(8)
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? themeManager.accentColor : themeManager.borderColor, lineWidth: 1))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(12)
                    .background(themeManager.lavenderWashColor)
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(themeManager.borderColor, lineWidth: 1))

                    // 3. Police Color Palette
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Police Color Palette")
                            .font(.system(size: 13 * themeManager.fontScale, weight: .bold))
                            .foregroundColor(themeManager.primaryTextColor)

                        VStack(spacing: 8) {
                            ForEach(themeManager.availablePalettes.chunked(into: 2), id: \.first?.id) { rowPalettes in
                                HStack(spacing: 8) {
                                    ForEach(rowPalettes) { palette in
                                        let isSelected = themeManager.paletteId == palette.id
                                        Button(action: { themeManager.setPalette(palette.id) }) {
                                            HStack(spacing: 8) {
                                                ZStack {
                                                    Circle()
                                                        .fill(palette.primary)
                                                        .frame(width: 24, height: 24)
                                                        .overlay(Circle().stroke(palette.accent, lineWidth: 1.5))
                                                    if isSelected {
                                                        Image(systemName: "checkmark")
                                                            .font(.system(size: 11, weight: .bold))
                                                            .foregroundColor(.white)
                                                    }
                                                }

                                                VStack(alignment: .leading, spacing: 1) {
                                                    Text(palette.name)
                                                        .font(.system(size: 11.5 * themeManager.fontScale, weight: isSelected ? .bold : .semibold))
                                                        .foregroundColor(themeManager.primaryTextColor)
                                                        .lineLimit(1)
                                                    Text(palette.subtitle)
                                                        .font(.system(size: 9 * themeManager.fontScale))
                                                        .foregroundColor(themeManager.secondaryTextColor)
                                                        .lineLimit(1)
                                                }
                                                Spacer(minLength: 0)
                                            }
                                            .padding(8)
                                            .frame(maxWidth: .infinity)
                                            .background(isSelected ? palette.primary.opacity(0.12) : themeManager.surfaceColor)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(isSelected ? palette.accent : themeManager.borderColor, lineWidth: isSelected ? 2 : 1)
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                    }
                    .padding(12)
                    .background(themeManager.lavenderWashColor)
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(themeManager.borderColor, lineWidth: 1))
                }
                .padding(.horizontal, 16)
            }

            // Apply & Close Button
            Button(action: onDismiss) {
                Text("Apply & Close")
                    .font(.system(size: 13.5 * themeManager.fontScale, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(themeManager.accentColor)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(themeManager.surfaceColor)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 16)
    }

    private var fontScaleLabel: String {
        if themeManager.fontScale <= 0.88 { return "Small (85%)" }
        if themeManager.fontScale <= 1.05 { return "Standard (100%)" }
        if themeManager.fontScale <= 1.20 { return "Large (115%)" }
        return "Extra Large (130%)"
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
