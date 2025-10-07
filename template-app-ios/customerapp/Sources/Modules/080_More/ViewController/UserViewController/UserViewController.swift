import Foundation

import MustacheCombine
import MustacheServices
import MustacheUIKit

class UserViewController: UIViewController {
    
    // MARK: @IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: Section 1
    @IBOutlet weak var profileCaptionLabel: UILabel!
    
    @IBOutlet weak var firstNameCaptionLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameCaptionLabel: UILabel!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var birthdateCaptionLabel: UILabel!
    @IBOutlet weak var birthdateTextField: UITextField!
    
    @IBOutlet weak var phoneCaptionLabel: UILabel!
    @IBOutlet weak var phoneCountryButton: UIButton!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet weak var emailCaptionLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    
    // MARK: Section 2
    @IBOutlet weak var addressCaptionLabel: UILabel!
    
    @IBOutlet weak var streetAddressCaptionLabel: UILabel!
    @IBOutlet weak var streetAddressTextField: UITextField!
    
    @IBOutlet weak var zipCodeCaptionLabel: UILabel!
    @IBOutlet weak var zipCodeTextField: UITextField!
    
    @IBOutlet weak var cityCaptionLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    
    @IBOutlet weak var countryCaptionLabel: UILabel!
    @IBOutlet weak var countryTextField: UITextField!
    
    // MARK: Section 3
    @IBOutlet weak var passwordCaptionLabel: UILabel!
    @IBOutlet weak var passwordButton: UIButton!
    
    // MARK: Section 4
    @IBOutlet weak var validateBirthdayCaptionLabel: UILabel!
    @IBOutlet weak var validateBirthdayLabel: UILabel!
    @IBOutlet weak var validateBirthdayButton: UIButton!
    
    // MARK: Section 5
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: ViewModel
    
    @Injected
    private var viewModel: UserViewModelType
    
    // MARK: Coordinator
    
    var coordinator: CoordinatorType!
    
    // MARK: Cancellable
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: UI State Variables (Avoid if possible)
    
    private let datePicker = UIDatePicker()
    private var countryMode: CountrySelectionMode!
    
    // MARK: View lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        self.configureConstraints()
        self.configureProfileBindings()
        
    }
    
    // MARK: Configure
    
    private func configureView() {
        // Set background colors
        view.backgroundColor = Colors.Background.default.color
        scrollView.backgroundColor = Colors.Background.default.color

        self.datePicker.datePickerMode = .dateAndTime
        self.datePicker.maximumDate = Date()
        self.datePicker.preferredDatePickerStyle = .inline
        self.datePicker.addTarget(self, action: #selector(UserViewController.dateChanged), for: .valueChanged)
        self.datePicker.tintColor = Colors.Foreground.brand.color
        self.datePicker.translatesAutoresizingMaskIntoConstraints = false

        self.birthdateTextField.inputView = self.datePicker
        self.birthdateTextField.addDoneButton()

        if #available(iOS 15.0, *) {
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.keyboardLayoutGuide.topAnchor).isActive = true
        } else {
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        }

        // Section headers - use muted color
        self.profileCaptionLabel.configure(textStyle: .caption1, text: Strings.Profile.Caption.profile.uppercased(), color: .muted)
        self.addressCaptionLabel.configure(textStyle: .caption1, text: Strings.Profile.Caption.address.uppercased(), color: .muted)
        self.passwordCaptionLabel.configure(textStyle: .caption1, text: Strings.Profile.Caption.changePassword.uppercased(), color: .muted)
        self.validateBirthdayCaptionLabel.configure(textStyle: .caption1, text: Strings.Profile.Caption.validateBirthday.uppercased(), color: .muted)

        // Field labels - use muted color for captions
        self.firstNameCaptionLabel.configure(textStyle: .caption2, text: Strings.Profile.Caption.firstName, color: .muted)
        self.firstNameTextField.configure(textStyle: .body, placeholder: Strings.Profile.Textfield.Placeholder.firstName)

        self.lastNameCaptionLabel.configure(textStyle: .caption2, text: Strings.Profile.Caption.lastName, color: .muted)
        self.lastNameTextField.configure(textStyle: .body, placeholder: Strings.Profile.Textfield.Placeholder.lastName)

        self.birthdateCaptionLabel.configure(textStyle: .caption2, text: Strings.Profile.Caption.birthdate, color: .muted)
        self.birthdateTextField.configure(textStyle: .body, placeholder: Strings.Profile.Textfield.Placeholder.birthdate)

        self.phoneCaptionLabel.configure(textStyle: .caption2, text: Strings.Profile.Caption.phone, color: .muted)
        self.phoneNumberTextField.configure(textStyle: .body, placeholder: Strings.Profile.Textfield.Placeholder.phoneNumber)

        self.emailCaptionLabel.configure(textStyle: .caption2, text: Strings.Profile.Caption.email, color: .muted)
        self.emailTextField.configure(textStyle: .body, placeholder: Strings.Profile.Textfield.Placeholder.email)

        self.streetAddressCaptionLabel.configure(textStyle: .caption2, text: Strings.Profile.Caption.streetAddress, color: .muted)
        self.streetAddressTextField.configure(textStyle: .body, placeholder: Strings.Profile.Textfield.Placeholder.streetAddress)

        self.zipCodeCaptionLabel.configure(textStyle: .caption2, text: Strings.Profile.Caption.zipCode, color: .muted)
        self.zipCodeTextField.configure(textStyle: .body, placeholder: Strings.Profile.Textfield.Placeholder.zipCode)

        self.cityCaptionLabel.configure(textStyle: .caption2, text: Strings.Profile.Caption.city, color: .muted)
        self.cityTextField.configure(textStyle: .body, placeholder: Strings.Profile.Textfield.Placeholder.city)

        self.countryCaptionLabel.configure(textStyle: .caption2, text: Strings.Profile.Caption.country, color: .muted)
        self.countryTextField.configure(textStyle: .body, placeholder: Strings.Profile.Textfield.Placeholder.country)

        self.validateBirthdayLabel.configure(textStyle: .body, text: Strings.Profile.Button.validateBirthday, color: .default)

        self.saveButton.configure(style: .primary, text: Strings.Profile.Button.save)

    }
    
    private func configureConstraints() {
        self.constrainKeyboard(to: self.scrollView)
    }
    
    private func configureProfileBindings() {
        
        self.viewModel.userPublisher
            .compactMap { $0 }
            .sink { [weak self] (user: UserModel) in
                self?.firstNameTextField.text = user.firstName
                self?.lastNameTextField.text = user.lastName
                self?.birthdateTextField.text = DateFormatter.dMMMMyyyy.string(optional: user.birthDate)
                self?.datePicker.date = user.birthDate ?? .now

                if let phoneCountry = user.phoneCountry,
                   let country = Country.getCountry(from: phoneCountry) {
                    self?.phoneCountryButton.setTitle("\(country.flag) +\(country.prefix)", for: .normal)
                    self?.phoneCountryButton.accessibilityIdentifier = user.phoneCountry
                }
                
                self?.phoneNumberTextField.text = user.phoneNumber
                self?.emailTextField.text = user.email
                self?.streetAddressTextField.text = user.street
                self?.zipCodeTextField.text = user.zipCode
                self?.cityTextField.text = user.city
                
                if let country = user.country,
                   let country = Country.getCountry(from: country) {
                    self?.countryTextField.text = country.localized
                    self?.countryTextField.accessibilityIdentifier = user.phoneCountry
                }
                
                let validateText = user.isBirthDateValidated ? Strings.Profile.Button.removeValidation : Strings.Profile.Button.validateBirthday
                self?.validateBirthdayLabel.configure(textStyle: .emphasizedBody, text: validateText)
            }
            .store(in: &self.cancellables)
        
        let textPublisher: AnyPublisher<String, Never> = self.firstNameTextField.textPublisher()
            .merge(with: self.lastNameTextField.textPublisher())
            .merge(with: self.birthdateTextField.textPublisher())
            .merge(with: self.phoneNumberTextField.textPublisher())
            .merge(with: self.emailTextField.textPublisher())
            .merge(with: self.streetAddressTextField.textPublisher())
            .merge(with: self.zipCodeTextField.textPublisher())
            .merge(with: self.cityTextField.textPublisher())
            .merge(with: self.countryTextField.textPublisher())
            .prepend("")
            .eraseToAnyPublisher()
        
        textPublisher
            .combineLatest(
                self.viewModel.userPublisher,
                { (latest: String, user: UserModel?) -> UserModel? in
                    return user
                }
            )
        //            .compactMap({ $0 })
            .map { [weak self] (user: UserModel?) -> Int in
                guard let self, let user else { return 0 }
                
                let firstName = self.firstNameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
                let lastName = self.lastNameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
                let birthDate = self.birthdateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let phoneCountry = self.phoneCountryButton.accessibilityIdentifier ?? ""
                let phoneNumber = self.phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let email = self.emailTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
                let streetAddress = self.streetAddressTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
                let zipCode = self.zipCodeTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
                let city = self.cityTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
                let country = self.countryTextField.accessibilityIdentifier ?? ""

                guard
                    firstName == (user.firstName ?? ""),
                    lastName == (user.lastName ?? ""),
                    email == (user.email ?? ""),
                    streetAddress == (user.street ?? ""),
                    zipCode == (user.zipCode ?? ""),
                    city == (user.city ?? ""),
                    birthDate == (DateFormatter.dMMMMyyyy.string(optional: user.birthDate) ?? ""),
                    phoneCountry == (user.phoneCountry ?? ""),
                    phoneNumber == (user.phoneNumber ?? ""),
                    country == (user.country ?? "")
                else { return 1 }
                
                return 0
            }
            .removeDuplicates()
            .sink { [weak self] (alpha: Int) in
                UIView.animate(withDuration: 0.3) { self?.saveButton.alpha = CGFloat(alpha) }
            }
            .store(in: &self.cancellables)
        
       
    }
    
    // MARK: @IBActions
    
    @IBAction func save() { Task {
                defer { self.saveButton.isBusy = false }
        guard let user = self.viewModel.user else { return }
        
        guard let firstName = self.firstNameTextField.text else {
            self.firstNameTextField.shake()
            return
        }
        
        guard let email = self.emailTextField.text else {
            self.emailTextField.shake()
            return
        }
        
        user.firstName = firstName
        user.lastName = self.lastNameTextField.text
        user.email = email
        
        user.birthDate = DateFormatter.dMMMMyyyy.date(from: self.birthdateTextField.safeText)
        
        if let country = self.phoneCountryButton.country, let phoneNumber = self.phoneNumberTextField.text {
            //TODO: validate the phone number is the correct format, consider regex
            user.phoneCountry = country.isoCountryCode
            user.phoneNumber = phoneNumber
        }
        
        //TODO: validate we dont have a partial input
        user.country = self.countryTextField.country?.isoCountryCode
        user.street = self.streetAddressTextField.text
        user.zipCode = self.zipCodeTextField.text
        user.city = self.cityTextField.text
        
        do {
            
            self.saveButton.isBusy = true
            
            try await self.viewModel.save(user)
            
            self.navigationController?.popViewController(animated: true)
            
        } catch {
            self.alert(error: error)
        }
        
    }}
    
    @IBAction func changePassword() {
        try? self.coordinator.transition(to: MoreTransition.password)
    }
    
    @IBAction func validateAge() {
        try? self.coordinator.transition(to: OIDAuthorizationTransition.validateAge(presenter: self.navigationController))
    }
    
    @IBAction func editingDidEndOnExit(_ textfield: UITextField) {
        switch textfield {
                
            case self.firstNameTextField:
                self.lastNameTextField.becomeFirstResponder()
                
            case self.lastNameTextField:
                self.birthdateTextField.becomeFirstResponder()
                
            case self.birthdateTextField:
                self.phoneNumberTextField.becomeFirstResponder()
                
            case self.phoneNumberTextField:
                self.emailTextField.becomeFirstResponder()
                
            case self.emailTextField:
                self.streetAddressTextField.becomeFirstResponder()
                
            case self.streetAddressTextField:
                self.zipCodeTextField.becomeFirstResponder()
                
            case self.zipCodeTextField:
                self.cityTextField.becomeFirstResponder()
                
            default:
                break
        }
    }
    
    @objc func dateChanged(sender: UIDatePicker) {
        let date = sender.date
        self.birthdateTextField.text = DateFormatter.dMMMMyyyy.string(from: date)
        self.birthdateTextField.sendActions(for: .editingChanged)
    }
    
    // MARK: Override UIViewController functions
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.scrollView.contentInset.bottom = (self.view.frame.height - self.saveButton.frame.minY) + 16
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
}

// MARK: Extensions

extension UserViewController: UITextFieldDelegate {
    
    @IBAction func selectPhoneNumberCountry() {
        self.countryMode = .phone
        try? self.coordinator.transition(to: MoreTransition.countryPicker(delegate: self))
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.countryTextField {
            self.countryMode = .address
            try? self.coordinator.transition(to: MoreTransition.countryPicker(delegate: self))
            return false
        } else if textField == self.phoneNumberTextField && self.phoneCountryButton.country == nil {
            UIAlertController.alert(title: Strings.Error.Generic.title, message: Strings.Error.Profile.missingCountry)
                .action(title: Strings.Button.ok, handler: { [weak self] _ in self?.phoneNumberTextField.resignFirstResponder() })
                .present(in: self)
            return false
        } else if textField == self.streetAddressTextField &&
                    (self.phoneCountryButton.country?.isAddressAutoCompleteAvailable == true ||
                     self.countryTextField.country?.isAddressAutoCompleteAvailable == true) {
            self.countryMode = .address
            try? self.coordinator.transition(to: MoreTransition.addressPicker(delegate: self))
            return false
        } else {
            return true
        }
    }
    
}

extension UserViewController: CountryPickerDelegate {
    
    func didSelect(_ country: Country) {
        switch self.countryMode! {
            case .phone:
                // TODO: Change placeholder based on country phone pattern
                self.phoneCountryButton.setTitle("\(country.flag) +\(country.prefix)", for: .normal)
                self.phoneCountryButton.country = country
                
                NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: self.phoneNumberTextField)
                
                // This way we also nudge the user to enter their address
                if self.countryTextField.safeText.isEmpty {
                    self.countryTextField.text = country.localized
                    self.countryTextField.country = country
                }
                
            case .address:
                
                self.countryTextField.text = country.localized
                self.countryTextField.country = country
                
                self.zipCodeTextField.isEnabled = !country.isAddressAutoCompleteAvailable
                self.cityTextField.isEnabled = !country.isAddressAutoCompleteAvailable
                
                NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: self.countryTextField)
        }
    }
}

extension UserViewController: AddressSearchDelegate {
    
    func didSelect(_ suggestion: AddressSuggestionModel) {
        self.streetAddressTextField.text = suggestion.addressModel?.readableStreetAddress
        self.cityTextField.text = suggestion.addressModel?.postnrnavn
        self.zipCodeTextField.text = suggestion.addressModel?.postnr
    }
}

extension UserViewController {
    enum CountrySelectionMode {
        case phone
        case address
    }
}
