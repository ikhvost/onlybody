import SwiftUI

struct ExercisePickerView: View {
    let exercises: [Exercise]
    let onAdd: (Exercise) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedFilter = "All"

    let filters = ExerciseCatalog.filters

    private var filteredExercises: [Exercise] {
        exercises.filter { exercise in
            let matchesFilter = selectedFilter == "All" || exercise.primaryMuscle == selectedFilter
            let matchesSearch = searchText.isEmpty || exercise.name.localizedStandardContains(searchText)
            return matchesFilter && matchesSearch
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            NavBarView(title: "Add Movement") {
                Button {
                    dismiss()
                } label: {
                    ChevronIcon(isBack: true, color: Theme.text, size: 18, inset: 8)
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    SearchIcon(color: Theme.text3, size: 15)

                    TextField("Search movements...", text: $searchText)
                        .font(Theme.fontSans(14))
                        .foregroundStyle(Theme.text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 9)
                .background(Theme.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Theme.border2, lineWidth: 1)
                }
                .clipShape(.rect(cornerRadius: Theme.cornerRadius))

                ScrollView(.horizontal) {
                    HStack(spacing: 6) {
                        ForEach(filters, id: \.self) { filter in
                            ChipView(
                                label: filter,
                                isActive: selectedFilter == filter,
                                isSmall: true
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.bottom, 2)
                }
                .scrollIndicators(.hidden)
            }
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.vertical, 10)

            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)

            if filteredExercises.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    MonoLabel(
                        text: "No movements found",
                        size: 11,
                        color: Theme.text2,
                        tracking: 0.4
                    )
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredExercises, id: \.id) { exercise in
                            Button {
                                onAdd(exercise)
                                dismiss()
                            } label: {
                                HStack(spacing: 10) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(exercise.name)
                                            .font(Theme.fontSans(16, .bold))
                                            .foregroundStyle(Theme.text)

                                        MonoLabel(
                                            text: "\(exercise.primaryMuscle.uppercased()) · \(exercise.equipmentLabel.uppercased())",
                                            size: 10,
                                            color: Theme.text3,
                                            tracking: 0.3
                                        )

                                        if exercise.isCustom {
                                            CustomBadgeView()
                                            .padding(.top, 5)
                                        }
                                    }

                                    Spacer()

                                    PlusIcon(color: Theme.accent, size: 16)
                                }
                                .padding(.vertical, 13)
                                .padding(.horizontal, Theme.horizontalPadding)
                            }
                            .buttonStyle(.plain)

                            Rectangle()
                                .fill(Theme.border)
                                .frame(height: 1)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .background(Theme.bg)
    }
}
