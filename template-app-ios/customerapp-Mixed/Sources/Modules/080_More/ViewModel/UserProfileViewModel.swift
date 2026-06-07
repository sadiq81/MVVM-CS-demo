
import Combine
import SwiftUI

import MustacheServices

@MainActor
final class UserProfileViewModel: ObservableObject {

    // MARK: - Form Fields
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var phoneCountryLabel: String = ""
    @Published var phoneNumber: String = ""
    @Published var birthDate: Date?
    @Published var street: String = ""
    @Published var zipCode: String = ""
    @Published var city: String = ""
    @Published var country: String = ""
    @Published var isBirthDateValidated: Bool = false
    private var phoneCountryCode: String?
    private var addressCountryCode: String?

    // MARK: - State

    @Published var isSaving = false
    @Published var isDirty = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var didSave = false

    // MARK: Services
    
    @Injected(\.userService)
    private var userService: any UserServiceType
    
    private var cancellables = Set<AnyCancellable>()
    private var originalUser: UserModel?

    // MARK: Init

    init() {
        self.userService.userPublisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .first()
            .sink { [weak self] user in
                self?.populateFields(from: user)
                self?.originalUser = user
            }
            .store(in: &self.cancellables)

        // Track dirty state
        Publishers.CombineLatest4(
            self.$firstName, self.$lastName, self.$email, self.$phoneNumber
        )
        .combineLatest(Publishers.CombineLatest4(self.$street, self.$zipCode, self.$city, self.$birthDate))
        .map { [weak self] personal, address -> Bool in
            guard let self, let user = self.originalUser else { return false }
            let (first, last, mail, phone) = personal
            let (str, zip, cty, bdate) = address

            return first != (user.firstName ?? "") ||
                last != (user.lastName ?? "") ||
                mail != (user.email ?? "") ||
                phone != (user.phoneNumber ?? "") ||
                str != (user.street ?? "") ||
                zip != (user.zipCode ?? "") ||
                cty != (user.city ?? "") ||
                bdate != user.birthDate
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &self.$isDirty)
    }

    // MARK: Functions

    private func populateFields(from user: UserModel) {
        self.firstName = user.firstName ?? ""
        self.lastName = user.lastName ?? ""
        self.email = user.email ?? ""
        let defaultCountry = Country.getCountry(from: "DK")
        if let phoneCountry = user.phoneCountry, let country = Country.getCountry(from: phoneCountry) {
            self.phoneCountryLabel = "\(country.flag) +\(country.prefix)"
            self.phoneCountryCode = country.isoCountryCode
        } else if let country = defaultCountry {
            self.phoneCountryLabel = "\(country.flag) +\(country.prefix)"
            self.phoneCountryCode = country.isoCountryCode
        }
        self.phoneNumber = user.phoneNumber ?? ""
        self.birthDate = user.birthDate
        self.street = user.street ?? ""
        self.zipCode = user.zipCode ?? ""
        self.city = user.city ?? ""
        if let countryCode = user.country, let country = Country.getCountry(from: countryCode) {
            self.country = country.localized
            self.addressCountryCode = country.isoCountryCode
        }
        self.isBirthDateValidated = user.isBirthDateValidated
    }

    func selectCountry(_ country: Country, mode: CountrySelectionMode) {
        switch mode {
            case .phone:
                self.phoneCountryLabel = "\(country.flag) +\(country.prefix)"
                self.phoneCountryCode = country.isoCountryCode
                // Also set address country if not yet set
                if self.country.isEmpty {
                    self.country = country.localized
                    self.addressCountryCode = country.isoCountryCode
                }
            case .address:
                self.country = country.localized
                self.addressCountryCode = country.isoCountryCode
        }
    }

    func applyAddressSuggestion(_ suggestion: AddressSuggestionModel) {
        if let address = suggestion.addressModel {
            self.street = address.readableStreetAddress
            self.city = address.city ?? ""
            self.zipCode = address.postalCode ?? ""
        } else if let access = suggestion.accessAddressModel {
            self.street = access.readableStreetAddress
            self.city = access.city ?? ""
            self.zipCode = access.postalCode ?? ""
        }
    }

    func save() async {
        guard var user = self.userService.user else { return }

        self.isSaving = true
        defer { self.isSaving = false }

        user.firstName = self.firstName
        user.lastName = self.lastName
        user.email = self.email
        user.phoneCountry = self.phoneCountryCode
        user.phoneNumber = self.phoneNumber
        user.birthDate = self.birthDate
        user.street = self.street
        user.zipCode = self.zipCode
        user.city = self.city
        user.country = self.addressCountryCode

        do {
            try await self.userService.save(model: user)
            self.didSave = true
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }

    deinit {
        debugPrint("deinit \(self)")
    }
}
