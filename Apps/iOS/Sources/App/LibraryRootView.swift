import SwiftUI

struct LibraryRootView: View {
    let composition: AppComposition
    @Binding var path: [UUID]
    @State private var viewModel: LibraryViewModel

    init(composition: AppComposition, path: Binding<[UUID]>) {
        self.composition = composition
        _path = path
        _viewModel = State(initialValue: composition.library())
    }

    var body: some View {
        NavigationStack(path: $path) {
            LibraryView(viewModel: viewModel, showMovement: { path.append($0.id) })
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: UUID.self) { id in
                    if let exercise = viewModel.exercise(id: id) {
                        MovementDetailView(viewModel: composition.movement(exercise))
                    } else {
                        MonoLabel(text: String(localized: .uiMovementUnavailable), size: Theme.type10, color: Theme.text2)
                    }
                }
        }
        .onChange(of: path) { _, value in
            if value.isEmpty { Task { await viewModel.load() } }
        }
    }
}
