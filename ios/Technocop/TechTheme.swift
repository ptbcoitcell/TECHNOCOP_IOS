import SwiftUI

// MARK: - App Color Palette Definition (Matching Android AppPalette)

public struct AppPalette: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let subtitle: String
    public let primary: Color
    public let deepPrimary: Color
    public let indigoPrimary: Color
    public let accent: Color
    public let accentDeep: Color
    public let accentIcon: Color
    public let darkPrimary: Color
    public let darkDeepPrimary: Color
    public let previewColors: [Color]
}

public let PalettePoliceNavy = AppPalette(
    id: "navy",
    name: "Police Navy",
    subtitle: "Classic Indigo & Lavender",
    primary: Color(red: 43/255, green: 34/255, blue: 87/255), // #2B2257
    deepPrimary: Color(red: 33/255, green: 25/255, blue: 65/255), // #211941
    indigoPrimary: Color(red: 55/255, green: 48/255, blue: 109/255), // #37306D
    accent: Color(red: 128/255, green: 104/255, blue: 214/255), // #8068D6
    accentDeep: Color(red: 98/255, green: 79/255, blue: 165/255), // #624FA5
    accentIcon: Color(red: 117/255, green: 96/255, blue: 195/255), // #7560C3
    darkPrimary: Color(red: 157/255, green: 141/255, blue: 241/255), // #9D8DF1
    darkDeepPrimary: Color(red: 27/255, green: 22/255, blue: 56/255), // #1B1638
    previewColors: [Color(red: 43/255, green: 34/255, blue: 87/255), Color(red: 128/255, green: 104/255, blue: 214/255)]
)

public let PaletteCyberBlue = AppPalette(
    id: "blue",
    name: "Cyber Blue",
    subtitle: "High-Tech Technical Services",
    primary: Color(red: 15/255, green: 62/255, blue: 122/255), // #0F3E7A
    deepPrimary: Color(red: 11/255, green: 43/255, blue: 86/255), // #0B2B56
    indigoPrimary: Color(red: 26/255, green: 77/255, blue: 143/255), // #1A4D8F
    accent: Color(red: 2/255, green: 132/255, blue: 199/255), // #0284C7
    accentDeep: Color(red: 3/255, green: 105/255, blue: 161/255), // #0369A1
    accentIcon: Color(red: 14/255, green: 165/255, blue: 233/255), // #0EA5E9
    darkPrimary: Color(red: 56/255, green: 189/255, blue: 248/255), // #38BDF8
    darkDeepPrimary: Color(red: 11/255, green: 33/255, blue: 62/255), // #0B213E
    previewColors: [Color(red: 15/255, green: 62/255, blue: 122/255), Color(red: 2/255, green: 132/255, blue: 199/255)]
)

public let PaletteKhakiGold = AppPalette(
    id: "khaki",
    name: "Police Khaki",
    subtitle: "Tamil Nadu Police Uniform Heritage",
    primary: Color(red: 74/255, green: 53/255, blue: 37/255), // #4A3525
    deepPrimary: Color(red: 56/255, green: 38/255, blue: 24/255), // #382618
    indigoPrimary: Color(red: 94/255, green: 67/255, blue: 47/255), // #5E432F
    accent: Color(red: 199/255, green: 140/255, blue: 6/255), // #C78C06
    accentDeep: Color(red: 161/255, green: 111/255, blue: 2/255), // #A16F02
    accentIcon: Color(red: 217/255, green: 119/255, blue: 6/255), // #D97706
    darkPrimary: Color(red: 251/255, green: 191/255, blue: 36/255), // #FBBF24
    darkDeepPrimary: Color(red: 46/255, green: 32/255, blue: 22/255), // #2E2016
    previewColors: [Color(red: 74/255, green: 53/255, blue: 37/255), Color(red: 199/255, green: 140/255, blue: 6/255)]
)

public let PaletteEmeraldTactical = AppPalette(
    id: "emerald",
    name: "Commando Emerald",
    subtitle: "Forest & Special Tactical Units",
    primary: Color(red: 17/255, green: 71/255, blue: 43/255), // #11472B
    deepPrimary: Color(red: 11/255, green: 51/255, blue: 30/255), // #0B331E
    indigoPrimary: Color(red: 24/255, green: 89/255, blue: 54/255), // #185936
    accent: Color(red: 5/255, green: 150/255, blue: 105/255), // #059669
    accentDeep: Color(red: 4/255, green: 120/255, blue: 87/255), // #047857
    accentIcon: Color(red: 16/255, green: 185/255, blue: 129/255), // #10B981
    darkPrimary: Color(red: 52/255, green: 211/255, blue: 153/255), // #34D399
    darkDeepPrimary: Color(red: 9/255, green: 38/255, blue: 23/255), // #092617
    previewColors: [Color(red: 17/255, green: 71/255, blue: 43/255), Color(red: 5/255, green: 150/255, blue: 105/255)]
)

public let PaletteCrimsonMaroon = AppPalette(
    id: "crimson",
    name: "Special Task Maroon",
    subtitle: "STF Elite Maroon & Crimson",
    primary: Color(red: 92/255, green: 20/255, blue: 35/255), // #5C1423
    deepPrimary: Color(red: 68/255, green: 12/255, blue: 23/255), // #440C17
    indigoPrimary: Color(red: 116/255, green: 28/255, blue: 46/255), // #741C2E
    accent: Color(red: 220/255, green: 38/255, blue: 38/255), // #DC2626
    accentDeep: Color(red: 185/255, green: 28/255, blue: 28/255), // #B91C1C
    accentIcon: Color(red: 239/255, green: 68/255, blue: 68/255), // #EF4444
    darkPrimary: Color(red: 248/255, green: 113/255, blue: 113/255), // #F87171
    darkDeepPrimary: Color(red: 59/255, green: 11/255, blue: 20/255), // #3B0B14
    previewColors: [Color(red: 92/255, green: 20/255, blue: 35/255), Color(red: 220/255, green: 38/255, blue: 38/255)]
)

public let PaletteCarbonSlate = AppPalette(
    id: "slate",
    name: "Tactical Carbon",
    subtitle: "Modern Slate & Cyber Dark",
    primary: Color(red: 30/255, green: 41/255, blue: 59/255), // #1E293B
    deepPrimary: Color(red: 15/255, green: 23/255, blue: 42/255), // #0F172A
    indigoPrimary: Color(red: 51/255, green: 65/255, blue: 85/255), // #334155
    accent: Color(red: 71/255, green: 85/255, blue: 105/255), // #475569
    accentDeep: Color(red: 51/255, green: 65/255, blue: 85/255), // #334155
    accentIcon: Color(red: 100/255, green: 116/255, blue: 139/255), // #64748B
    darkPrimary: Color(red: 148/255, green: 163/255, blue: 184/255), // #94A3B8
    darkDeepPrimary: Color(red: 9/255, green: 13/255, blue: 21/255), // #090D15
    previewColors: [Color(red: 30/255, green: 41/255, blue: 59/255), Color(red: 71/255, green: 85/255, blue: 105/255)]
)

public let AvailablePalettes: [AppPalette] = [
    PalettePoliceNavy,
    PaletteCyberBlue,
    PaletteKhakiGold,
    PaletteEmeraldTactical,
    PaletteCrimsonMaroon,
    PaletteCarbonSlate
]

public func findPaletteById(_ id: String) -> AppPalette {
    AvailablePalettes.first { $0.id.caseInsensitiveCompare(id) == .orderedSame } ?? PalettePoliceNavy
}

// MARK: - Dynamic Global Theme Manager

public final class TechThemeManager: ObservableObject {
    public static let shared = TechThemeManager()

    @Published public var palette: AppPalette = PalettePoliceNavy
    @Published public var themeMode: String = "SYSTEM" // "LIGHT", "DARK", "SYSTEM"
    @Published public var fontScale: CGFloat = 1.0 // 0.85, 1.0, 1.15, 1.30
    @Published public var isDarkActive: Bool = false

    private init() {
        let savedMode = UserDefaults.standard.string(forKey: "technocop_theme_mode") ?? "SYSTEM"
        let savedPalette = UserDefaults.standard.string(forKey: "technocop_palette_id") ?? "navy"
        let savedScale = UserDefaults.standard.double(forKey: "technocop_font_scale")

        self.themeMode = savedMode
        self.palette = findPaletteById(savedPalette)
        self.fontScale = savedScale > 0 ? CGFloat(savedScale) : 1.0
    }

    public func setPalette(_ newPalette: AppPalette) {
        self.palette = newPalette
        UserDefaults.standard.set(newPalette.id, forKey: "technocop_palette_id")
    }

    public func setThemeMode(_ mode: String) {
        self.themeMode = mode
        UserDefaults.standard.set(mode, forKey: "technocop_theme_mode")
    }

    public func setFontScale(_ scale: CGFloat) {
        self.fontScale = scale
        UserDefaults.standard.set(Double(scale), forKey: "technocop_font_scale")
    }

    public func increaseFontScale() {
        if fontScale < 1.25 {
            setFontScale(fontScale + 0.15)
        }
    }

    public func decreaseFontScale() {
        if fontScale > 0.90 {
            setFontScale(fontScale - 0.15)
        }
    }
}

// MARK: - Legacy and Dynamic TechTheme Namespace

public enum TechTheme {
    public static var currentPalette: AppPalette {
        TechThemeManager.shared.palette
    }

    public static var isDark: Bool {
        TechThemeManager.shared.isDarkActive
    }

    // Dynamic brand primary colors
    public static var navy: Color {
        isDark ? Color.white : currentPalette.primary
    }

    public static var deepNavy: Color {
        isDark ? Color.white : currentPalette.deepPrimary
    }

    public static var headerBackground: Color {
        isDark ? currentPalette.darkDeepPrimary : currentPalette.primary
    }

    public static var accent: Color {
        isDark ? currentPalette.darkPrimary : currentPalette.accent
    }

    public static var accentDeep: Color {
        isDark ? Color.white : currentPalette.accentDeep
    }

    public static var lavender: Color {
        isDark ? Color(red: 180/255, green: 165/255, blue: 255/255) : currentPalette.accent
    }

    public static var lavenderDeep: Color {
        isDark ? Color.white : currentPalette.accentDeep
    }

    public static var saffron: Color {
        Color(red: 233/255, green: 145/255, blue: 42/255)
    }

    // Backgrounds & Surfaces
    public static var pageBackground: Color {
        isDark ? Color(red: 12/255, green: 14/255, blue: 20/255) : Color(red: 247/255, green: 244/255, blue: 252/255)
    }

    public static var surface: Color {
        isDark ? Color(red: 22/255, green: 25/255, blue: 34/255) : Color.white
    }

    public static var cardBackground: Color {
        isDark ? Color(red: 22/255, green: 25/255, blue: 34/255) : Color.white
    }

    public static var lavenderTint: Color {
        isDark ? Color(red: 27/255, green: 31/255, blue: 45/255) : Color(red: 240/255, green: 237/255, blue: 255/255)
    }

    public static var lavenderTintLight: Color {
        isDark ? Color(red: 34/255, green: 39/255, blue: 56/255) : Color(red: 245/255, green: 240/255, blue: 255/255)
    }

    public static var filterCardBackground: Color {
        isDark ? Color(red: 27/255, green: 31/255, blue: 45/255) : Color(red: 240/255, green: 237/255, blue: 255/255)
    }

    public static var officerRowBackgroundLight: Color {
        isDark ? Color(red: 22/255, green: 26/255, blue: 38/255) : Color(red: 245/255, green: 242/255, blue: 255/255)
    }

    public static var officerRowBackgroundDark: Color {
        isDark ? Color(red: 27/255, green: 31/255, blue: 45/255) : Color(red: 238/255, green: 233/255, blue: 252/255)
    }

    // Borders & Table Styling
    public static var tableBorder: Color {
        isDark ? Color.white.opacity(0.2) : Color(red: 212/255, green: 204/255, blue: 232/255)
    }

    public static var tableAltRow: Color {
        isDark ? Color(red: 22/255, green: 26/255, blue: 38/255) : Color(red: 245/255, green: 242/255, blue: 255/255)
    }

    public static var tableTotals: Color {
        isDark ? Color(red: 34/255, green: 39/255, blue: 56/255) : Color(red: 232/255, green: 225/255, blue: 247/255)
    }

    public static var rangeHeaderBlue: Color {
        isDark ? Color(red: 38/255, green: 51/255, blue: 77/255) : Color(red: 49/255, green: 90/255, blue: 155/255)
    }

    // Badges & Accents
    public static var badgeYellow: Color {
        isDark ? Color(red: 66/255, green: 55/255, blue: 25/255) : Color(red: 255/255, green: 224/255, blue: 130/255)
    }

    public static var badgeYellowText: Color {
        isDark ? Color(red: 255/255, green: 224/255, blue: 130/255) : Color(red: 93/255, green: 67/255, blue: 0/255)
    }

    public static var badgeIT: Color {
        Color(red: 225/255, green: 183/255, blue: 68/255)
    }

    public static var whatsAppGreen: Color {
        Color(red: 37/255, green: 211/255, blue: 102/255) // #25D366
    }

    public static var gold: Color {
        Color(red: 255/255, green: 213/255, blue: 79/255) // #FFD54F
    }

    // Text Colors
    public static var textPrimary: Color {
        isDark ? Color.white : currentPalette.primary
    }

    public static var textSecondary: Color {
        isDark ? Color.white.opacity(0.7) : Color(red: 78/255, green: 88/255, blue: 113/255)
    }

    public static var textSubtitle: Color {
        isDark ? Color.white.opacity(0.6) : Color(red: 104/255, green: 117/255, blue: 138/255)
    }

    public static var textDark: Color {
        isDark ? Color.white : Color(red: 51/255, green: 68/255, blue: 91/255)
    }

    public static var textLightHeader: Color {
        Color(red: 231/255, green: 233/255, blue: 243/255)
    }

    public static var textError: Color {
        Color(red: 220/255, green: 38/255, blue: 38/255) // #DC2626
    }

    public static var loginError: Color {
        Color(red: 255/255, green: 197/255, blue: 197/255)
    }
}
