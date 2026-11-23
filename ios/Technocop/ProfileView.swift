import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var themeManager: TechThemeManager
    @State private var isEditing = false

    var body: some View {
        VStack(spacing: 12) {
            if let officer = store.session?.officer {
                VStack(alignment: .leading, spacing: 0) {
                    // Header Card
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TECHNOCOP PROFILE")
                            .font(.system(size: 12 * themeManager.fontScale, weight: .bold))
                            .foregroundColor(themeManager.accentColor)
                            .tracking(0.5)

                        Text("PTB in your fingertips")
                            .font(.system(size: 11 * themeManager.fontScale, weight: .medium))
                            .foregroundColor(themeManager.secondaryTextColor)

                        Spacer().frame(height: 4)

                        Text(officer.name)
                            .font(.system(size: 22 * themeManager.fontScale, weight: .bold))
                            .foregroundColor(themeManager.primaryTextColor)

                        let sub = [officer.rank, officer.unit].filter { !$0.isEmpty }.joined(separator: " • ")
                        Text(sub)
                            .font(.system(size: 14 * themeManager.fontScale))
                            .foregroundColor(themeManager.secondaryTextColor)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(themeManager.lavenderWashColor)
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(themeManager.borderColor, lineWidth: 1))
                    .padding(16)

                    // Profile Details Title
                    Text("Profile details")
                        .font(.system(size: 18 * themeManager.fontScale, weight: .bold))
                        .foregroundColor(themeManager.primaryTextColor)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 6)

                    // Field Rows matching Android exactly
                    VStack(alignment: .leading, spacing: 0) {
                        profileDetailRow("Rank", officer.rank)
                        profileDetailRow("Batch", officer.batch)
                        profileDetailRow("Zone", officer.zone)
                        profileDetailRow("Range", officer.range)
                        profileDetailRow("Unit", officer.unit)
                        profileDetailRow("Unit category", officer.technicalUnit)
                        profileDetailRow("IFHRMS No.", officer.ifhrmsNo)
                        profileDetailRow("Date of birth (DOB)", officer.dob)
                        profileDetailRow("Date of enlistment (DOE)", officer.doe)
                        profileDetailRow("Date of retirement (DOR)", officer.dor)
                        profileDetailRow("Date joined present unit (DOJ)", officer.doj)
                        profileDetailRow("Mobile number", officer.mobile)
                    }

                    // Edit Profile Button
                    Button {
                        isEditing = true
                    } label: {
                        Text("EDIT PROFILE")
                            .font(.system(size: 14.5 * themeManager.fontScale, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(themeManager.primaryColor)
                            .cornerRadius(12)
                    }
                    .padding(16)
                }
                .background(themeManager.surfaceColor)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(themeManager.borderColor, lineWidth: 1))
            }
        }
        .sheet(isPresented: $isEditing) {
            if let officer = store.session?.officer {
                EditProfileSheetView(officer: officer)
                    .environmentObject(themeManager)
                    .environmentObject(store)
            }
        }
    }

    private func profileDetailRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 12 * themeManager.fontScale))
                .foregroundColor(themeManager.secondaryTextColor)
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 16 * themeManager.fontScale, weight: .medium))
                .foregroundColor(themeManager.primaryTextColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .overlay(Divider().background(themeManager.borderColor), alignment: .bottom)
    }
}

// MARK: - Edit Profile Sheet with All Android v3.21 Fields & Pickers

struct EditProfileSheetView: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var themeManager: TechThemeManager
    @Environment(\.dismiss) private var dismiss

    @State private var officer: Officer
    @State private var options: ProfileOptions?
    @State private var isLoadingOptions = true
    @State private var isSaving = false
    @State private var statusMessage = ""
    @State private var isErrorMessage = false

    // Date picker states
    @State private var dobDate: Date = Date()
    @State private var hasDob: Bool = false
    @State private var doeDate: Date = Date()
    @State private var hasDoe: Bool = false
    @State private var dorDate: Date = Date()
    @State private var hasDor: Bool = false
    @State private var dojDate: Date = Date()
    @State private var hasDoj: Bool = false

    init(officer: Officer) {
        _officer = State(initialValue: officer)
        _hasDob = State(initialValue: !officer.dob.isEmpty)
        _dobDate = State(initialValue: parseDate(officer.dob) ?? Date())
        _hasDoe = State(initialValue: !officer.doe.isEmpty)
        _doeDate = State(initialValue: parseDate(officer.doe) ?? Date())
        _hasDor = State(initialValue: !officer.dor.isEmpty)
        _dorDate = State(initialValue: parseDate(officer.dor) ?? Date())
        _hasDoj = State(initialValue: !officer.doj.isEmpty)
        _dojDate = State(initialValue: parseDate(officer.doj) ?? Date())
    }

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
                Section("IFHRMS & Identification") {
                    TextField("Enter IFHRMS No.", text: $officer.ifhrmsNo)
                        .keyboardType(.numberPad)
                    TextField("Name", text: $officer.name)
                        .textContentType(.name)
                    HStack {
                        Text("Mobile number")
                            .foregroundColor(themeManager.secondaryTextColor)
                        Spacer()
                        Text(officer.mobile)
                            .foregroundColor(themeManager.primaryTextColor)
                    }
                }

                Section("Rank & Service Assignment") {
                    Picker("Rank", selection: $officer.rank) {
                        Text("Select Rank").tag("")
                        ForEach(availableRanks, id: \.self) { Text($0).tag($0) }
                    }

                    Picker("Batch", selection: $officer.batch) {
                        Text("Select Batch").tag("")
                        ForEach(options?.batches ?? [], id: \.self) { Text($0).tag($0) }
                    }

                    Picker("Zone", selection: $officer.zone) {
                        Text("Select Zone").tag("")
                        ForEach(availableZones, id: \.self) { Text($0).tag($0) }
                    }
                    .onChange(of: officer.zone) { _ in
                        officer.range = ""
                        officer.unit = ""
                        officer.technicalUnit = ""
                    }

                    Picker("Range", selection: $officer.range) {
                        Text("Select Range").tag("")
                        ForEach(availableRanges, id: \.self) { Text($0).tag($0) }
                    }
                    .onChange(of: officer.range) { _ in
                        officer.unit = ""
                        officer.technicalUnit = ""
                    }

                    Picker("Unit", selection: $officer.unit) {
                        Text("Select Unit").tag("")
                        ForEach(availableUnits, id: \.self) { Text($0).tag($0) }
                    }
                    .onChange(of: officer.unit) { _ in
                        officer.technicalUnit = ""
                    }

                    Picker("Unit_Categ", selection: $officer.technicalUnit) {
                        Text("Select Unit_Categ").tag("")
                        ForEach(availableCategories, id: \.self) { Text($0).tag($0) }
                    }
                }

                Section("Important Service Dates") {
                    // DOB
                    Toggle("Date of Birth (DOB)", isOn: $hasDob)
                        .onChange(of: hasDob) { on in
                            officer.dob = on ? formatDate(dobDate) : ""
                        }
                    if hasDob {
                        DatePicker("DOB", selection: $dobDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .onChange(of: dobDate) { date in officer.dob = formatDate(date) }
                    }

                    // DOE
                    Toggle("Date of Enlistment (DOE)", isOn: $hasDoe)
                        .onChange(of: hasDoe) { on in
                            officer.doe = on ? formatDate(doeDate) : ""
                        }
                    if hasDoe {
                        DatePicker("DOE", selection: $doeDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .onChange(of: doeDate) { date in officer.doe = formatDate(date) }
                    }

                    // DOR
                    Toggle("Date of Retirement (DOR)", isOn: $hasDor)
                        .onChange(of: hasDor) { on in
                            officer.dor = on ? formatDate(dorDate) : ""
                        }
                    if hasDor {
                        DatePicker("DOR", selection: $dorDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .onChange(of: dorDate) { date in officer.dor = formatDate(date) }
                    }

                    // DOJ
                    Toggle("DOJ in present unit", isOn: $hasDoj)
                        .onChange(of: hasDoj) { on in
                            officer.doj = on ? formatDate(dojDate) : ""
                        }
                    if hasDoj {
                        DatePicker("DOJ", selection: $dojDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .onChange(of: dojDate) { date in officer.doj = formatDate(date) }
                    }
                }

                if !statusMessage.isEmpty {
                    Section {
                        Text(statusMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(isErrorMessage ? Color.red : Color.green)
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
                            Text(isSaving ? "SAVING…" : "SUBMIT CHANGES")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .frame(height: 44)
                        .background(canSubmit ? themeManager.primaryColor : Color.gray)
                        .cornerRadius(8)
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
                    statusMessage = "Profile choices are temporarily unavailable."
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
        officer.mobile.filter { $0.isNumber }.count == 10
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

private func parseDate(_ str: String) -> Date? {
    let clean = str.trimmingCharacters(in: .whitespacesAndNewlines)
    if clean.isEmpty { return nil }
    let formatters: [DateFormatter] = [
        {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            df.locale = Locale(identifier: "en_US_POSIX")
            return df
        }(),
        {
            let df = DateFormatter()
            df.dateFormat = "dd-MM-yyyy"
            df.locale = Locale(identifier: "en_US_POSIX")
            return df
        }(),
        {
            let df = DateFormatter()
            df.dateFormat = "dd/MM/yyyy"
            df.locale = Locale(identifier: "en_US_POSIX")
            return df
        }()
    ]
    for df in formatters {
        if let d = df.date(from: clean) { return d }
    }
    return nil
}

private func formatDate(_ date: Date) -> String {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd"
    df.locale = Locale(identifier: "en_US_POSIX")
    return df.string(from: date)
}
