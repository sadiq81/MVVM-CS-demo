
import SwiftUI

import MustacheServices

struct CountryPickerView: View {

    let mode: CountrySelectionMode

    var countries: [Country] = Country.countries

    @State
    private var searchText = ""

    @InjectedObject(\.userProfileViewModel)
    private var viewModel

    @EnvironmentObject
    private var coordinator: HostingCoordinator

    private var filteredCountries: [Country] {
        if self.searchText.isEmpty {
            return self.countries
        }
        return self.countries.filter {
            $0.localized.localizedCaseInsensitiveContains(self.searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List(self.filteredCountries, id: \.isoCountryCode) { country in
                Button {
                    self.viewModel.selectCountry(country, mode: self.mode)
                    try? self.coordinator.transition(to: MoreTransition.dismiss)
                } label: {
                    HStack(spacing: 12) {
                        Text(country.flag)
                            .font(.title2)
                        Text(country.localized)
                            .font(.body)
                            .foregroundColor(Color(Colors.Foreground.default.color))
                        Spacer()
                        Text("+\(country.prefix)")
                            .font(.caption)
                            .foregroundColor(Color(Colors.Foreground.muted.color))
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: self.$searchText, prompt: Strings.Profile.Country.Searchfield.placeholder)
            .navigationTitle(Strings.Profile.Country.Searchfield.placeholder)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.Button.cancel) {
                        try? self.coordinator.transition(to: MoreTransition.dismiss)
                    }
                }
            }
        }
    }
}

#if DEBUG
#Preview("CountryPickerView", traits: .fixedLayout(width: 402, height: 874)) {
    Container.shared.userService.register { PreviewUserService() }
    return CountryPickerView(mode: .address, countries: Array(Country.countries.prefix(15)))
        .environmentObject(HostingCoordinator(coordinator: PreviewCoordinator()))
}
#endif
