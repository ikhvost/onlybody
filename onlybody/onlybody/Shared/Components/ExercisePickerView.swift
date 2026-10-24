import SwiftUI

struct ExercisePickerView: View {
    let exercises: [ExerciseSnapshot]
    let onAdd: (ExerciseSnapshot) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedFilter = "All"

    let filters = ExerciseCatalog.filters

    private var filteredExercises: [ExerciseSnapshot] {
        exercises.filter { exercise in
            let matchesFilter = selectedFilter == "All" || exercise.primaryMuscle == selectedFilter
            let matchesSearch = searchText.isEmpty || exercise.name.localizedStandardContains(searchText)
            return matchesFilter && matchesSearch
        }
    }

    var body: some View {
        VStack(spacing: Theme.space0) {
            NavBarView(title: "Add Movement") {
                Button {
                    dismiss()
                } label: {
                    ChevronIcon(isBack: true, color: Theme.text, size: Theme.type18, inset: 8)
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: Theme.space8) {
                HStack(spacing: Theme.space8) {
                    SearchIcon(color: Theme.text3, size: Theme.type15)

                    TextField("Search movements...", text: $searchText)
                        .font(Theme.fontSans(Theme.type14))
                        .foregroundStyle(Theme.text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, Theme.space10)
                .padding(.vertical, Theme.space9)
                .background(Theme.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Theme.border2, lineWidth: 1)
                }
                .clipShape(.rect(cornerRadius: Theme.cornerRadius))

                ScrollView(.horizontal) {
                    HStack(spacing: Theme.space6) {
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
                    .padding(.bottom, Theme.space2)
                }
                .scrollIndicators(.hidden)
            }
            .padding(.horizontal, Theme.horizontalPadding)
            .padding(.vertical, Theme.space10)

            Rectangle()
                .fill(Theme.border)
                .frame(height: 1)

            if filteredExercises.isEmpty {
                VStack(spacing: Theme.space8) {
                    Spacer()
                    MonoLabel(
                        text: "No movements found",
                        size: Theme.type11,
                        color: Theme.text2,
                        tracking: 0.4
                    )
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: Theme.space0) {
                        ForEach(filteredExercises, id: \.id) { exercise in
                            Button {
                                onAdd(exercise)
                                dismiss()
                            } label: {
                                HStack(spacing: Theme.space10) {
                                    VStack(alignment: .leading, spacing: Theme.space2) {
                                        Text(exercise.name)
                                            .font(Theme.fontSans(Theme.type16, .bold))
                                            .foregroundStyle(Theme.text)

                                        MonoLabel(
                                            text: "\(exercise.primaryMuscle.uppercased()) · \(exercise.equipmentLabel.uppercased())",
                                            size: Theme.type10,
                                            color: Theme.text3,
                                            tracking: 0.3
                                        )

                                    }

                                    Spacer()

                                    PlusIcon(color: Theme.accent, size: Theme.type16)
                                }
                                .padding(.vertical, Theme.space13)
                                .padding(.horizontal, Theme.horizontalPadding)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("exercise.pick.\(exercise.name)")

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
