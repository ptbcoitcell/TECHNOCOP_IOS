import SwiftUI

// MARK: - Favourite Contacts Section View (Matching Android FavouritesSection)

public struct FavouritesSectionView: View {
    @EnvironmentObject private var store: AppStore

    public init() {}

    private var favouriteOfficers: [Contact] {
        store.contacts.filter { c in
            let digits = c.mobile.filter { $0.isNumber }
            let last10 = String(digits.suffix(10))
            return !last10.isEmpty && store.favoriteNumbers.contains(last10)
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            let favs = favouriteOfficers

            if favs.isEmpty {
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(TechTheme.lavenderTint)
                            .frame(width: 64, height: 64)
                        Image(systemName: "heart.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color(red: 225/255, green: 29/255, blue: 72/255))
                    }

                    Text("No Favourite Contacts Yet")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(TechTheme.navy)

                    Text("Tap the heart icon on any officer in Employee Directory or My Unit to save them here for 1-tap quick access.")
                        .font(.system(size: 13))
                        .foregroundStyle(TechTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 36)
                .background(TechTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(TechTheme.tableBorder, lineWidth: 1)
                )
            } else {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 225/255, green: 29/255, blue: 72/255))
                    Text("\(favs.count) Favourite Officer\(favs.count == 1 ? "" : "s")")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(TechTheme.navy)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(TechTheme.lavenderTint)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(spacing: 3) {
                    ForEach(favs.indices, id: \.self) { idx in
                        let c = favs[idx]
                        let digits = String(c.mobile.filter { $0.isNumber }.suffix(10))
                        ContactRowView(
                            contact: c,
                            isDarker: idx % 2 == 1,
                            isFavorite: true,
                            onToggleFavorite: { store.toggleFavorite(digits) }
                        )
                    }
                }
            }
        }
    }
}
