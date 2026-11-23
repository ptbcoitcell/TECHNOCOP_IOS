import SwiftUI

// MARK: - My Unit Section View (Matching Android MyUnitSection)

public struct MyUnitSectionView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedUnit: String? = nil

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let officer = store.session?.officer {
                let rangeDSP = isRangeDspRank(officer.rank)
                let unitContacts = myUnitContacts(for: officer, in: store.contacts)

                if unitContacts.isEmpty && store.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(24)
                } else if unitContacts.isEmpty {
                    Text("No contacts found for your unit.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                        .padding(14)
                } else if rangeDSP {
                    ContactUnitGroupsView(
                        contacts: unitContacts,
                        selected: selectedUnit,
                        depth: 0,
                        favoriteNumbers: store.favoriteNumbers,
                        onToggleFavorite: { store.toggleFavorite($0) }
                    ) { unit in
                        selectedUnit = (selectedUnit == unit) ? nil : unit
                    }
                } else {
                    let sorted = sortContactsStandard(unitContacts)
                    VStack(spacing: 3) {
                        ForEach(sorted.indices, id: \.self) { idx in
                            let c = sorted[idx]
                            let digits = String(c.mobile.filter { $0.isNumber }.suffix(10))
                            ContactRowView(
                                contact: c,
                                isDarker: idx % 2 == 1,
                                isFavorite: store.favoriteNumbers.contains(digits),
                                onToggleFavorite: { store.toggleFavorite(digits) }
                            )
                        }
                    }
                }
            }
        }
    }
}
