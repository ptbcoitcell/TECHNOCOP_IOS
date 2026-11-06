import SwiftUI

struct SearchSectionView: View {
    @EnvironmentObject private var store: AppStore

    @State private var selectedUnit: String = "All units"
    @State private var selectedCategory: String = "All categories"
    @State private var queryInput: String = ""
    @State private var debouncedQuery: String = ""
    @State private var debounceTask: Task<Void, Never>? = nil

    private var availableUnits: [String] {
        var list = ["All units"]
        list.append(contentsOf: store.units)
        return list
    }

    private var availableCategories: [String] {
        var list = ["All categories"]
        list.append(contentsOf: store.unitCategories)
        return list
    }

    private var filteredContacts: [Contact] {
        let q = debouncedQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        let mobileQuery = q.filter { $0.isNumber }

        return store.contacts.filter { officer in
            let matchesUnit = (selectedUnit == "All units" ||
                               officer.unit.caseInsensitiveCompare(selectedUnit) == .orderedSame)
            let matchesCategory = (selectedCategory == "All categories" ||
                                   officer.unitCategory.caseInsensitiveCompare(selectedCategory) == .orderedSame)
            let matchesQuery = q.isEmpty ||
                officer.name.localizedCaseInsensitiveContains(q) ||
                officer.rank.localizedCaseInsensitiveContains(q) ||
                officer.unit.localizedCaseInsensitiveContains(q) ||
                (!mobileQuery.isEmpty && officer.mobile.contains(mobileQuery))

            return matchesUnit && matchesCategory && matchesQuery
        }.sorted { a, b in
            let batchA = Int(a.batch.filter { $0.isNumber }) ?? Int.max
            let batchB = Int(b.batch.filter { $0.isNumber }) ?? Int.max
            if batchA != batchB { return batchA < batchB }
            let rankA = rankOrder(a.rank)
            let rankB = rankOrder(b.rank)
            if rankA != rankB { return rankA < rankB }
            return a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Filter & Search Controls Card
            VStack(spacing: 8) {
                // Unit Picker
                HStack {
                    Text("Unit")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(TechTheme.navy)
                        .frame(width: 70, alignment: .leading)

                    Menu {
                        ForEach(availableUnits, id: \.self) { unit in
                            Button {
                                selectedUnit = unit
                            } label: {
                                if selectedUnit == unit {
                                    Label(unit, systemImage: "checkmark")
                                } else {
                                    Text(unit)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedUnit)
                                .font(.system(size: 13))
                                .foregroundStyle(TechTheme.navy)
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 12))
                                .foregroundStyle(TechTheme.navy.opacity(0.6))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(TechTheme.tableBorder, lineWidth: 1)
                        )
                    }
                }

                // Category Picker
                HStack {
                    Text("Categ")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(TechTheme.navy)
                        .frame(width: 70, alignment: .leading)

                    Menu {
                        ForEach(availableCategories, id: \.self) { cat in
                            Button {
                                selectedCategory = cat
                            } label: {
                                if selectedCategory == cat {
                                    Label(cat, systemImage: "checkmark")
                                } else {
                                    Text(cat)
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedCategory)
                                .font(.system(size: 13))
                                .foregroundStyle(TechTheme.navy)
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 12))
                                .foregroundStyle(TechTheme.navy.opacity(0.6))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(TechTheme.tableBorder, lineWidth: 1)
                        )
                    }
                }

                // Search Bar Input
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(TechTheme.textSubtitle)

                    TextField("Search name, rank, unit or mobile", text: $queryInput)
                        .font(.system(size: 13))
                        .foregroundStyle(TechTheme.navy)
                        .onChange(of: queryInput) { newValue in
                            debounceTask?.cancel()
                            debounceTask = Task {
                                try? await Task.sleep(nanoseconds: 180_000_000) // 180ms debounce
                                if !Task.isCancelled {
                                    debouncedQuery = newValue
                                }
                            }
                        }

                    if !queryInput.isEmpty {
                        Button {
                            queryInput = ""
                            debouncedQuery = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(TechTheme.textSubtitle)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(TechTheme.tableBorder, lineWidth: 1)
                )
            }
            .padding(10)
            .background(TechTheme.filterCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Search Results
            let results = filteredContacts
            if results.isEmpty {
                Text("No officers match these filters.")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                VStack(spacing: 3) {
                    ForEach(results.indices, id: \.self) { idx in
                        ContactRowView(contact: results[idx], isDarker: idx % 2 == 1)
                    }
                }
            }
        }
    }
}

