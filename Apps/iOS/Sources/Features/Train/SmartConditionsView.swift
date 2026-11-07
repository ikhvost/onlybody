import SwiftUI

struct SmartConditionsView: View {
    @Bindable var viewModel: SmartSelectionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.sectionGap) {
            Text(.smartOptions).font(Theme.fontSans(Theme.typeHeading, .bold))
            Text(.smartOptional).foregroundStyle(Theme.text2)
            Text(.smartEquipment).font(Theme.fontSans(Theme.typeCard, .semibold))
            Text(viewModel.offersStandardGym ? String(localized: .smartGymEquipment) : String(localized: .smartBodyEquipment))
                .font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
            if viewModel.offersStandardGym {
                Toggle(String(localized: .smartGym), isOn: Binding(
                    get: { viewModel.configuration.equipmentMode == .standardGym },
                    set: { viewModel.configuration.equipmentMode = $0 ? .standardGym : .confirmed }))
            }
            if viewModel.configuration.equipmentMode == .confirmed {
                FlowLayout(spacing: Theme.space8) {
                    ForEach(viewModel.equipment, id: \.self) { equipment in
                        ChipView(label: CatalogLocalization.label(equipment), isActive: viewModel.configuration.availableEquipment.contains(equipment)) {
                            viewModel.toggleEquipment(equipment)
                        }
                    }
                }
            }
            Text(.smartRestrictions).font(Theme.fontSans(Theme.typeCard, .semibold))
            Text(.smartRegionHint).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
            FlowLayout(spacing: Theme.space8) {
                ForEach(SmartBodyRegion.allCases, id: \.self) { region in
                    ChipView(label: region.label, isActive: viewModel.configuration.excludedRegions.contains(region)) {
                        viewModel.toggleRegion(region)
                    }.accessibilityIdentifier("smart.region.\(region.rawValue)")
                }
            }
            ForEach(SmartBodyRegion.allCases.filter { viewModel.configuration.excludedRegions.contains($0) }, id: \.self) { region in
                Text(region.label + ": " + region.exclusionSummary)
                    .font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
            }
            Text(.smartNoSafety).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
            if !viewModel.configuration.excludedLoads.isEmpty {
                Text(.smartLegacyLoads).font(Theme.fontSans(Theme.typeCard, .semibold))
                Text(.smartLegacyLoadsHint).font(Theme.fontSans(Theme.typeMeta)).foregroundStyle(Theme.text2)
                FlowLayout(spacing: Theme.space8) {
                    ForEach(ExerciseLoad.allCases.filter { viewModel.configuration.excludedLoads.contains($0) }) { load in
                        ChipView(label: load.label, isActive: true) { viewModel.removeLegacyLoad(load) }
                            .accessibilityIdentifier("smart.legacyLoad.\(load.rawValue)")
                    }
                }
            }
            if !viewModel.configuration.excludedExercises.isEmpty {
                Text(.smartExcluded).font(Theme.fontSans(Theme.typeCard, .semibold))
                ForEach(viewModel.configuration.excludedExercises.sorted(), id: \.self) { name in
                    HStack {
                        Text(CatalogLocalization.exercise(name))
                        Spacer()
                        Button(String(localized: .smartRestore)) { viewModel.configuration.excludedExercises.remove(name) }
                            .frame(minHeight: Theme.touchSize)
                    }
                }
            }
        }
    }
}
