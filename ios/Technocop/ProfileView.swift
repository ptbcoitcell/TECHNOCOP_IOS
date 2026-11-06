import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: AppStore
    @State private var isEditing = false

    var body: some View {
        VStack(spacing: 12) {
            if let officer = store.session?.officer {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Profile details")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(TechTheme.navy)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                    VStack(alignment: .leading, spacing: 0) {
                        profileDetailRow("Name", officer.name)
                        profileDetailRow("Rank", officer.rank)
                        profileDetailRow("Batch", officer.batch)
                        profileDetailRow("Zone", officer.zone)
                        profileDetailRow("Range", officer.range)
                        profileDetailRow("Unit", officer.unit)
                        profileDetailRow("Unit_Categ", officer.technicalUnit)
                        profileDetailRow("DOJ in present unit", officer.doj)
                        profileDetailRow("Mobile number", officer.mobile)
                    }

                    Button {
                        isEditing = true
                    } label: {
                        Text("EDIT PROFILE")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(TechTheme.navy)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(16)
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(TechTheme.tableBorder, lineWidth: 1)
                )
            }
        }
        .sheet(isPresented: $isEditing) {
            if let officer = store.session?.officer {
                EditProfileSheetView(officer: officer)
            }
        }
    }

    private func profileDetailRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Color.secondary)
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(TechTheme.navy)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .overlay(Divider().opacity(0.3), alignment: .bottom)
    }
}

// MARK: - Edit Profile Sheet with Dependent Pickers & Native DatePicker

struct EditProfileSheetView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var officer: Officer
    @State private var options: ProfileOptions?
    @State private var isLoadingOptions = true
    @State private var isSaving = false
    @State private var statusMessage = ""
    @State private var isErrorMessage = false
    @State private var selectedDate = Date()
    @State private var hasDoj = false

    init(officer: Officer) {
        _officer = State(initialValue: officer)
        _hasDoj = State(initialValue: !officer.doj.isEmpty)
        if let d = parseDOJDate(officer.doj) {
            _selectedDate = State(initialValue: d)
        }
    }

    // Dependent choices
    private var availableZones: [String] {
        let all = (options?.zones ?? []).filter { !$0.isEmpty }
        var list = all.sorted(by: profileZoneComparator())
        if !officer.zone.isEmpty && !list.contains(officer.zone) {
            list.insert(officer.zone, at: 0)
        }
        return list
    }

    private var availableRanges: [String] {
        let matching = (options?.zoneRanges ?? []).filter { row in
            guard row.count >= 2 else { return false }
            return officer.zone.isEmpty || normalizedOrgLabel(row[0]) == normalizedOrgLabel(officer.zone)
        }.map { $0[1] }
        
        var list = Array(Set(matching.filter { !$0.isEmpty })).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        if !officer.range.isEmpty && !list.contains(officer.range) {
            list.insert(officer.range, at: 0)
        }
        return list
    }

    private var availableUnits: [String] {
        let matching = (options?.zoneRangeUnits ?? []).filter { row in
            guard row.count >= 3 else { return false }
            let zoneMatch = officer.zone.isEmpty || normalizedOrgLabel(row[0]) == normalizedOrgLabel(officer.zone)
            let rangeMatch = officer.range.isEmpty || normalizedOrgLabel(row[1]) == normalizedOrgLabel(officer.range)
            return zoneMatch && rangeMatch
        }.map { $0[2] }

        var list = Array(Set(matching.filter { !$0.isEmpty })).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        if !officer.unit.isEmpty && !list.contains(officer.unit) {
            list.insert(officer.unit, at: 0)
        }
        return list
    }

    private var availableCategories: [String] {
        let matching = (options?.zoneRangeUnitCategories ?? []).filter { choice in
            let zoneMatch = officer.zone.isEmpty || normalizedOrgLabel(choice.zone) == normalizedOrgLabel(officer.zone)
            let rangeMatch = officer.range.isEmpty || normalizedOrgLabel(choice.range) == normalizedOrgLabel(officer.range)
            let unitMatch = officer.unit.isEmpty || normalizedOrgLabel(choice.unit) == normalizedOrgLabel(officer.unit)
            return zoneMatch && rangeMatch && unitMatch
        }.map { $0.category }

        var list = Array(Set(matching.filter { !$0.isEmpty })).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        if list.isEmpty {
            list = (options?.unitCategories ?? []).filter { !$0.isEmpty }.sorted()
        }
        if !officer.technicalUnit.isEmpty && !list.contains(officer.technicalUnit) {
            list.insert(officer.technicalUnit, at: 0)
        }
        return list
    }

    private var availableRanks: [String] {
        let all = (options?.ranks ?? []).filter { !$0.isEmpty }
        var list = all.sorted(by: profileRankComparator())
        if !officer.rank.isEmpty && !list.contains(officer.rank) {
            list.insert(officer.rank, at: 0)
        }
        return list
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Details") {
                    TextField("Name", text: $officer.name)
                        .textContentType(.name)

                    HStack {
                        Text("Mobile number")
                            .foregroundStyle(Color.secondary)
                        Spacer()
                        Text(officer.mobile)
                            .foregroundStyle(TechTheme.navy)
                    }
                }

                Section("Service & Unit Details") {
                    // Rank Dropdown
                    Picker("Rank", selection: $officer.rank) {
                        Text("Select Rank").tag("")
                        ForEach(availableRanks, id: \.self) { Text($0).tag($0) }
                    }

                    // Batch Dropdown
                    Picker("Batch", selection: $officer.batch) {
                        Text("Select Batch").tag("")
                        ForEach(options?.batches ?? [], id: \.self) { Text($0).tag($0) }
                    }

                    // Zone Dropdown (Cascades: resets Range, Unit, Unit_Categ)
                    Picker("Zone", selection: $officer.zone) {
                        Text("Select Zone").tag("")
                        ForEach(availableZones, id: \.self) { Text($0).tag($0) }
                    }
                    .onChange(of: officer.zone) { _ in
                        officer.range = ""
                        officer.unit = ""
                        officer.technicalUnit = ""
                    }

                    // Range Dropdown (Cascades: resets Unit, Unit_Categ)
                    Picker("Range", selection: $officer.range) {
                        Text("Select Range").tag("")
                        ForEach(availableRanges, id: \.self) { Text($0).tag($0) }
                    }
                    .onChange(of: officer.range) { _ in
                        officer.unit = ""
                        officer.technicalUnit = ""
                    }

                    // Unit Dropdown (Cascades: resets Unit_Categ)
                    Picker("Unit", selection: $officer.unit) {
                        Text("Select Unit").tag("")
                        ForEach(availableUnits, id: \.self) { Text($0).tag($0) }
                    }
                    .onChange(of: officer.unit) { _ in
                        officer.technicalUnit = ""
                    }

                    // Unit_Categ Dropdown
                    Picker("Unit_Categ", selection: $officer.technicalUnit) {
                        Text("Select Unit_Categ").tag("")
                        ForEach(availableCategories, id: \.self) { Text($0).tag($0) }
                    }
                }

                Section("Joining Date") {
                    Toggle("DOJ in present unit", isOn: $hasDoj)
                        .onChange(of: hasDoj) { enabled in
                            if !enabled {
                                officer.doj = ""
                            } else {
                                officer.doj = formatDOJDate(selectedDate)
                            }
                        }

                    if hasDoj {
                        DatePicker(
                            "Date of Joining",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .onChange(of: selectedDate) { date in
                            officer.doj = formatDOJDate(date)
                        }
                    }
                }

                if !statusMessage.isEmpty {
                    Section {
                        Text(statusMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(isErrorMessage ? TechTheme.textError : Color.green)
                    }
                }

                Section {
                    Button {
                        Task { await saveProfile() }
                    } label: {
                        HStack {
                            Spacer()
                            if isSaving {
                                ProgressView()
                                    .padding(.trailing, 6)
                            }
                            Text(isSaving ? "SYNCING…" : "SUBMIT CHANGES")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color.white)
                            Spacer()
                        }
                        .frame(height: 44)
                        .background(canSubmit ? TechTheme.navy : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .disabled(!canSubmit || isSaving)
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                do {
                    options = try await store.loadProfileOptions()
                } catch {
                    statusMessage = "Profile options are temporarily unavailable."
                    isErrorMessage = true
                }
                isLoadingOptions = false
            }
        }
    }

    private var canSubmit: Bool {
        !officer.name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !officer.rank.isEmpty &&
        !officer.unit.isEmpty &&
        !officer.mobile.isEmpty
    }

    private func saveProfile() async {
        isSaving = true
        statusMessage = ""
        isErrorMessage = false
        defer { isSaving = false }

        do {
            try await store.updateProfile(officer)
            statusMessage = "Profile updated."
            try? await Task.sleep(nanoseconds: 800_000_000)
            dismiss()
        } catch {
            isErrorMessage = true
            statusMessage = "Could not update profile. Please try again."
        }
    }
}
