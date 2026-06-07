
import SwiftUI

import MustacheServices
import NavigatorUI

struct UserProfileView: View {

    @Environment(\.navigator)
    private var navigator: Navigator

    @InjectedObject(\.userProfileViewModel)
    private var viewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: Profile Section
                self.sectionHeader(Strings.Profile.Caption.profile)
                self.profileSection

                // MARK: Address Section
                self.sectionHeader(Strings.Profile.Caption.address)
                self.addressSection

                // MARK: Password Section
                self.sectionHeader(Strings.Profile.Caption.changePassword)
                self.passwordSection

                // MARK: Validate Section
                self.sectionHeader(Strings.Profile.Caption.validateBirthday)
                self.validateSection

                // MARK: Save Button
                Button {
                    self.viewModel.save()
                } label: {
                    if self.viewModel.isSaving {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    } else {
                        Text(Strings.Profile.Button.save)
                            .font(.emphasizedBody)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!self.viewModel.isDirty || self.viewModel.isSaving)
                .opacity(self.viewModel.isDirty ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.3), value: self.viewModel.isDirty)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .padding(.vertical, 16)
        }
        .background(Color(Colors.Background.default.color).ignoresSafeArea())
        .navigationTitle(Strings.Profile.Caption.profile)
        .alert(Strings.Error.Generic.title, isPresented: self.$viewModel.showError) {
            Button(Strings.Button.ok, role: .cancel) {}
        } message: {
            Text(self.viewModel.errorMessage ?? Strings.Error.Generic.message)
        }
        .alert(Strings.Alert.BirthdayRemoveValidation.title, isPresented: self.$viewModel.showRemoveValidationAlert) {
            Button(Strings.Button.ok, role: .destructive) {
                self.viewModel.removeVerification()
            }
            Button(Strings.Button.cancel, role: .cancel) {}
        } message: {
            Text(Strings.Alert.BirthdayRemoveValidation.message)
        }
        .alert(Strings.Alert.BirthdayValidation.title, isPresented: self.$viewModel.showValidationSuccess) {
            Button(Strings.Button.ok) {}
        } message: {
            Text(Strings.Alert.BirthdayValidation.message)
        }
        .onChange(of: self.viewModel.didSave) { _, didSave in
            if didSave {
                self.navigator.pop()
            }
        }
    }

    // MARK: - Profile Section

    private var profileSection: some View {
        self.groupedContainer {
            self.fieldRow(caption: Strings.Profile.Caption.firstName,
                         placeholder: Strings.Profile.Textfield.Placeholder.firstName,
                         text: self.$viewModel.firstName)
            Divider()
            self.fieldRow(caption: Strings.Profile.Caption.lastName,
                         placeholder: Strings.Profile.Textfield.Placeholder.lastName,
                         text: self.$viewModel.lastName)
            Divider()
            self.dateRow(caption: Strings.Profile.Caption.birthdate)
            Divider()
            self.phoneRow()
            Divider()
            self.fieldRow(caption: Strings.Profile.Caption.email,
                         placeholder: Strings.Profile.Textfield.Placeholder.email,
                         text: self.$viewModel.email,
                         keyboardType: .emailAddress)
        }
    }

    // MARK: - Address Section

    private var addressSection: some View {
        self.groupedContainer {
            self.tappableRow(caption: Strings.Profile.Caption.country, value: self.viewModel.country) {
                self.navigator.navigate(to: MoreDestination.countryPicker(.address))
            }
            Divider()
            self.tappableRow(caption: Strings.Profile.Caption.streetAddress, value: self.viewModel.street) {
                self.navigator.navigate(to: MoreDestination.addressSearch)
            }
            Divider()
            self.fieldRow(caption: Strings.Profile.Caption.zipCode,
                         placeholder: Strings.Profile.Textfield.Placeholder.zipCode,
                         text: self.$viewModel.zipCode,
                         keyboardType: .numberPad)
            Divider()
            self.fieldRow(caption: Strings.Profile.Caption.city,
                         placeholder: Strings.Profile.Textfield.Placeholder.city,
                         text: self.$viewModel.city)
        }
    }

    // MARK: - Password Section

    private var passwordSection: some View {
        self.groupedContainer {
            Button {
                self.navigator.navigate(to: MoreDestination.password)
            } label: {
                HStack {
                    Text(Strings.Profile.Button.changePassword)
                        .font(.body)
                        .foregroundColor(Color(Colors.Foreground.default.color))
                    Spacer()
                    Image(systemName: Images.System.forward)
                        .foregroundColor(Color(Colors.Foreground.muted.color))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
    }

    // MARK: - Validate Section

    @ViewBuilder
    private var validateSection: some View {
        if self.viewModel.isBirthDateValidated {
            Button {
                self.viewModel.showRemoveValidationAlert = true
            } label: {
                Text(Strings.Profile.Button.removeValidation)
            }
            .buttonStyle(DangerButtonStyle())
            .padding(.horizontal, 16)
        } else {
            Button {
                self.navigator.navigate(to: MoreDestination.validateAge)
            } label: {
                Text(Strings.Profile.Button.validateBirthday)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption)
            .foregroundColor(Color(Colors.Foreground.muted.color))
            .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func groupedContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Color(Colors.Background.neutralSubtle.color))
        .cornerRadius(Constants.Rounding.small)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func phoneRow() -> some View {
        HStack {
            Text(Strings.Profile.Caption.phone)
                .font(.caption2)
                .foregroundColor(Color(Colors.Foreground.muted.color))
            Button {
                self.navigator.navigate(to: MoreDestination.countryPicker(.phone))
            } label: {
                Text(self.viewModel.phoneCountryLabel)
                    .font(.caption2)
                    .foregroundColor(Color(Colors.Foreground.muted.color))
            }
            Spacer()
            TextField(Strings.Profile.Textfield.Placeholder.phoneNumber, text: self.$viewModel.phoneNumber)
                .font(.body)
                .keyboardType(.phonePad)
                .multilineTextAlignment(.trailing)
                .foregroundColor(Color(Colors.Foreground.default.color))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func fieldRow(caption: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        HStack {
            Text(caption)
                .font(.caption2)
                .foregroundColor(Color(Colors.Foreground.muted.color))
                .frame(minWidth: 80, alignment: .leading)
            Spacer()
            TextField(placeholder, text: text)
                .font(.body)
                .keyboardType(keyboardType)
                .multilineTextAlignment(.trailing)
                .foregroundColor(Color(Colors.Foreground.default.color))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func dateRow(caption: String) -> some View {
        HStack {
            Text(caption)
                .font(.caption2)
                .foregroundColor(Color(Colors.Foreground.muted.color))
                .frame(minWidth: 80, alignment: .leading)
            Spacer()
            DatePicker("",
                       selection: Binding(
                           get: { self.viewModel.birthDate ?? Date() },
                           set: { self.viewModel.birthDate = $0 }
                       ),
                       in: ...Date(),
                       displayedComponents: .date)
                .labelsHidden()
                .tint(Color(Colors.Foreground.brand.color))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func tappableRow(caption: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(caption)
                    .font(.caption2)
                    .foregroundColor(Color(Colors.Foreground.muted.color))
                    .frame(minWidth: 80, alignment: .leading)
                Spacer()
                Text(value.isEmpty ? "-" : value)
                    .font(.body)
                    .foregroundColor(Color(Colors.Foreground.muted.color))
                Image(systemName: Images.System.forward)
                    .font(.caption2)
                    .foregroundColor(Color(Colors.Foreground.muted.color))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#if DEBUG
#Preview("UserProfileView") {
    Container.shared.userService.register { PreviewUserService() }
    // Mark the form dirty (after the async user load) so the save (GEM) button is shown, matching UIKit.
    let viewModel = Container.shared.userProfileViewModel()
    DispatchQueue.main.async {
        viewModel.firstName += " "
        viewModel.isDirty = true
    }
    return NavigationStack {
        UserProfileView()
    }
}
#endif
