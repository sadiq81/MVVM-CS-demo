
import SwiftUI

import MustacheServices

struct AddressSearchView: View {

    @EnvironmentObject
    private var coordinator: HostingCoordinator

    @InjectedObject(\.addressSearchViewModel)
    private var viewModel

    var body: some View {
        NavigationStack {
            List(self.viewModel.suggestions, id: \.self) { suggestion in
                Button {
                    self.viewModel.select(suggestion)
                } label: {
                    HStack(spacing: 12) {
                        Text(suggestion.text)
                            .font(.body)
                            .foregroundColor(Color(Colors.Foreground.default.color))

                        Spacer()

                        self.suggestionIcon(for: suggestion.type)
                    }
                }
                .listRowBackground(Color(Colors.Background.default.color))
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(Colors.Background.default.color))
            .overlay {
                if self.viewModel.suggestions.isEmpty && !self.viewModel.searchText.isEmpty && self.viewModel.searchText.count >= 3 {
                    if self.viewModel.isLoading {
                        ProgressView()
                            .tint(Color(Colors.Foreground.brand.color))
                    } else {
                        Text(Strings.Profile.Address.emptyState)
                            .font(.body)
                            .foregroundColor(Color(Colors.Foreground.muted.color))
                    }
                }
            }
            .searchable(text: self.$viewModel.searchText, prompt: Strings.Profile.Textfield.Placeholder.streetAddress)
            .navigationTitle(Strings.Profile.Address.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.Button.cancel) {
                        try? self.coordinator.transition(to: MoreTransition.dismiss)
                    }
                }
            }
            .onReceive(self.viewModel.$selectedSuggestion) { suggestion in
                guard let suggestion else { return }
                let profileViewModel = Container.shared.userProfileViewModel()
                profileViewModel.applyAddressSuggestion(suggestion)
                try? self.coordinator.transition(to: MoreTransition.dismiss)
            }
        }
    }

    @ViewBuilder
    private func suggestionIcon(for type: AddressSuggestionType) -> some View {
        switch type {
            case .address:
                Image(systemName: Images.System.checkmark)
                    .font(.caption)
                    .foregroundColor(Color(Colors.Foreground.success.color))
            case .streetName, .accessAddress, .unknown:
                Image(systemName: Images.System.forward)
                    .font(.caption)
                    .foregroundColor(Color(Colors.Foreground.muted.color))
        }
    }
}

#if DEBUG
#Preview("AddressSearchView") {
    Container.shared.addressService.register { PreviewAddressService() }
    Container.shared.addressSearchViewModel.register {
        MainActor.assumeIsolated {
            let viewModel = AddressSearchViewModel()
            viewModel.searchText = "Æblevej 36"
            viewModel.suggestions = AddressSuggestionModel.mockDataArray
            return viewModel
        }
    }
    return AddressSearchView()
        .environmentObject(HostingCoordinator(coordinator: PreviewCoordinator()))
}
#endif
