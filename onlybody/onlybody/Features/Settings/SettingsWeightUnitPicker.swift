import SwiftUI

struct SettingsWeightUnitPicker: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        Menu {
            Picker("Weight units", selection: $viewModel.weightUnit) {
                ForEach(viewModel.weightUnits, id: \.self) { unit in
                    Text(unit.title).tag(unit)
                }
            }
        } label: {
            HStack(spacing: Theme.space12) {
                Text("Weight units")
                    .font(Theme.fontSans(Theme.type14, .medium))
                    .foregroundStyle(Theme.text)
                Spacer()
                Text(viewModel.weightUnit.rawValue)
                    .font(Theme.fontMono(Theme.type14))
                    .foregroundStyle(Theme.accent)
                ChevronIcon(color: Theme.text3, size: Theme.type16)
                    .rotationEffect(.degrees(90))
            }
            .frame(minHeight: Theme.space44)
            .padding(Theme.space16)
            .contentShape(.rect)
        }
        .accessibilityLabel("Weight units")
        .accessibilityValue(viewModel.weightUnit.title)
        .accessibilityIdentifier("settings.weightUnit")
    }
}
