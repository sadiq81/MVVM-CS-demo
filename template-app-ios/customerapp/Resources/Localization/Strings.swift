// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Strings {
  internal enum Alert {
    internal enum LogOut {
      /// Log ud
      internal static let accept = Strings.tr("Localizable", "alert.log_out.accept", fallback: "Log ud")
      /// Annuller
      internal static let cancel = Strings.tr("Localizable", "alert.log_out.cancel", fallback: "Annuller")
      /// Er du sikker på at du ville logge ud?
      internal static let message = Strings.tr("Localizable", "alert.log_out.message", fallback: "Er du sikker på at du ville logge ud?")
      /// Log ud
      internal static let title = Strings.tr("Localizable", "alert.log_out.title", fallback: "Log ud")
    }
    internal enum Pin {
      internal enum FaceId {
        /// Vil du bruge Face ID i stedet for adgangskode næste gang?
        internal static let message = Strings.tr("Localizable", "alert.pin.faceId.message", fallback: "Vil du bruge Face ID i stedet for adgangskode næste gang?")
        /// Face ID
        internal static let title = Strings.tr("Localizable", "alert.pin.faceId.title", fallback: "Face ID")
      }
      internal enum NotMatching {
        /// Pin er ikke ens
        internal static let message = Strings.tr("Localizable", "alert.pin.notMatching.message", fallback: "Pin er ikke ens")
      }
      internal enum Reset {
        /// Hvis du nulstiller din kode bliver du logget ud af appen og alle data tilhørende din pin vil blive slettet
        internal static let message = Strings.tr("Localizable", "alert.pin.reset.message", fallback: "Hvis du nulstiller din kode bliver du logget ud af appen og alle data tilhørende din pin vil blive slettet")
        /// Nulstil
        internal static let title = Strings.tr("Localizable", "alert.pin.reset.title", fallback: "Nulstil")
      }
      internal enum TouchId {
        /// Vil du bruge Touch ID i stedet for adgangskode næste gang?
        internal static let message = Strings.tr("Localizable", "alert.pin.touchId.message", fallback: "Vil du bruge Touch ID i stedet for adgangskode næste gang?")
        /// Touch ID
        internal static let title = Strings.tr("Localizable", "alert.pin.touchId.title", fallback: "Touch ID")
      }
    }
  }
  internal enum Button {
    /// Tilbage
    internal static let back = Strings.tr("Localizable", "button.back", fallback: "Tilbage")
    /// Afbryd
    internal static let cancel = Strings.tr("Localizable", "button.cancel", fallback: "Afbryd")
    /// Annuller
    internal static let dismiss = Strings.tr("Localizable", "button.dismiss", fallback: "Annuller")
    /// OK
    internal static let ok = Strings.tr("Localizable", "button.ok", fallback: "OK")
  }
  internal enum Category {
    /// Køretøjer
    internal static let automotive = Strings.tr("Localizable", "category.automotive", fallback: "Køretøjer")
    /// Parfumer
    internal static let fragrances = Strings.tr("Localizable", "category.fragrances", fallback: "Parfumer")
    /// Møbler
    internal static let furniture = Strings.tr("Localizable", "category.furniture", fallback: "Møbler")
    /// Dagligvarer
    internal static let groceries = Strings.tr("Localizable", "category.groceries", fallback: "Dagligvarer")
    /// Dekoration
    internal static let homeDecoration = Strings.tr("Localizable", "category.homeDecoration", fallback: "Dekoration")
    /// Bærbare
    internal static let laptops = Strings.tr("Localizable", "category.laptops", fallback: "Bærbare")
    /// Belysning
    internal static let lighting = Strings.tr("Localizable", "category.lighting", fallback: "Belysning")
    /// Skjorter
    internal static let mensShirts = Strings.tr("Localizable", "category.mensShirts", fallback: "Skjorter")
    /// Herresko
    internal static let mensShoes = Strings.tr("Localizable", "category.mensShoes", fallback: "Herresko")
    /// Mandeure
    internal static let mensWatches = Strings.tr("Localizable", "category.mensWatches", fallback: "Mandeure")
    /// Motorcykler
    internal static let motorcycle = Strings.tr("Localizable", "category.motorcycle", fallback: "Motorcykler")
    /// Hudpleje
    internal static let skincare = Strings.tr("Localizable", "category.skincare", fallback: "Hudpleje")
    /// Telefoner
    internal static let smartphones = Strings.tr("Localizable", "category.smartphones", fallback: "Telefoner")
    /// Solbriller
    internal static let sunglasses = Strings.tr("Localizable", "category.sunglasses", fallback: "Solbriller")
    /// Toppe
    internal static let tops = Strings.tr("Localizable", "category.tops", fallback: "Toppe")
    /// Tasker
    internal static let womensBags = Strings.tr("Localizable", "category.womensBags", fallback: "Tasker")
    /// Kjoler
    internal static let womensDresses = Strings.tr("Localizable", "category.womensDresses", fallback: "Kjoler")
    /// Smykker
    internal static let womensJewellery = Strings.tr("Localizable", "category.womensJewellery", fallback: "Smykker")
    /// Damesko
    internal static let womensShoes = Strings.tr("Localizable", "category.womensShoes", fallback: "Damesko")
    /// Dameure
    internal static let womensWatches = Strings.tr("Localizable", "category.womensWatches", fallback: "Dameure")
  }
  internal enum Error {
    internal enum Generic {
      /// Der er sket en ukendt fejl
      internal static let message = Strings.tr("Localizable", "error.generic.message", fallback: "Der er sket en ukendt fejl")
      /// Fejl
      internal static let title = Strings.tr("Localizable", "error.generic.title", fallback: "Fejl")
    }
    internal enum Login {
      /// Den indtastede email eller adgangskode er ugyldig. Kan du ikke huske din adgangskode kan du nulstille den.
      internal static let message = Strings.tr("Localizable", "error.login.message", fallback: "Den indtastede email eller adgangskode er ugyldig. Kan du ikke huske din adgangskode kan du nulstille den.")
    }
    internal enum Profile {
      /// Vælg land først
      internal static let missingCountry = Strings.tr("Localizable", "error.profile.missing_country", fallback: "Vælg land først")
    }
  }
  internal enum Filter {
    /// Alle
    internal static let all = Strings.tr("Localizable", "filter.all", fallback: "Alle")
    /// %@ valgt
    internal static func selected(_ p1: Any) -> String {
      return Strings.tr("Localizable", "filter.selected", String(describing: p1), fallback: "%@ valgt")
    }
  }
  internal enum ForgotPassword {
    /// Skriv din e-mailadresse her. Så sender vi dig et link.
    internal static let body = Strings.tr("Localizable", "forgot_password.body", fallback: "Skriv din e-mailadresse her. Så sender vi dig et link.")
    /// GLEMT ADGANGSKODE?
    internal static let title = Strings.tr("Localizable", "forgot_password.title", fallback: "GLEMT ADGANGSKODE?")
    internal enum Alert {
      /// Vi har sendt dig en mail med oplysninger
      internal static let title = Strings.tr("Localizable", "forgot_password.alert.title", fallback: "Vi har sendt dig en mail med oplysninger")
    }
    internal enum Button {
      /// Gendan adgangskode
      internal static let title = Strings.tr("Localizable", "forgot_password.button.title", fallback: "Gendan adgangskode")
    }
    internal enum Textfield {
      /// Email
      internal static let placeholder = Strings.tr("Localizable", "forgot_password.textfield.placeholder", fallback: "Email")
    }
  }
  internal enum Login {
    /// Log ind med de oplysninger, du har fået i din velkomstmail.
    internal static let body = Strings.tr("Localizable", "login.body", fallback: "Log ind med de oplysninger, du har fået i din velkomstmail.")
    /// VELKOMMEN
    internal static let title = Strings.tr("Localizable", "login.title", fallback: "VELKOMMEN")
    internal enum Button {
      internal enum Forgot {
        /// Glemt adgangskode
        internal static let title = Strings.tr("Localizable", "login.button.forgot.title", fallback: "Glemt adgangskode")
      }
      internal enum Login {
        /// LOGIN
        internal static let title = Strings.tr("Localizable", "login.button.login.title", fallback: "LOGIN")
      }
    }
    internal enum Textfield {
      internal enum Password {
        /// Adgangskode
        internal static let placeholder = Strings.tr("Localizable", "login.textfield.password.placeholder", fallback: "Adgangskode")
      }
      internal enum Username {
        /// Email
        internal static let placeholder = Strings.tr("Localizable", "login.textfield.username.placeholder", fallback: "Email")
      }
    }
  }
  internal enum More {
    internal enum Button {
      /// LOG UD
      internal static let logout = Strings.tr("Localizable", "more.button.logout", fallback: "LOG UD")
    }
    internal enum Caption {
      /// FaceID
      internal static let faceId = Strings.tr("Localizable", "more.caption.faceId", fallback: "FaceID")
      /// Indstillinger
      internal static let settings = Strings.tr("Localizable", "more.caption.settings", fallback: "Indstillinger")
    }
    internal enum Label {
      /// Feature 2
      internal static let feature2 = Strings.tr("Localizable", "more.label.feature2", fallback: "Feature 2")
      /// Profil
      internal static let profile = Strings.tr("Localizable", "more.label.profile", fallback: "Profil")
      /// Hemmeligt
      internal static let secret = Strings.tr("Localizable", "more.label.secret", fallback: "Hemmeligt")
    }
  }
  internal enum Onboarding {
    internal enum Button {
      /// NÆSTE
      internal static let title = Strings.tr("Localizable", "onboarding.button.title", fallback: "NÆSTE")
    }
    internal enum Step1 {
      /// Vi bruger din lokation til bla bla bla bla bla.
      internal static let body = Strings.tr("Localizable", "onboarding.step1.body", fallback: "Vi bruger din lokation til bla bla bla bla bla.")
      /// Lokation
      internal static let title = Strings.tr("Localizable", "onboarding.step1.title", fallback: "Lokation")
    }
    internal enum Step2 {
      /// Vi bruger push beskeder til bla bla bla bla bla
      internal static let body = Strings.tr("Localizable", "onboarding.step2.body", fallback: "Vi bruger push beskeder til bla bla bla bla bla")
      /// Beskeder
      internal static let title = Strings.tr("Localizable", "onboarding.step2.title", fallback: "Beskeder")
    }
    internal enum Step3 {
      /// Vi bruger kameraet til bla bla bla bla bla
      internal static let body = Strings.tr("Localizable", "onboarding.step3.body", fallback: "Vi bruger kameraet til bla bla bla bla bla")
      /// Kamera
      internal static let title = Strings.tr("Localizable", "onboarding.step3.title", fallback: "Kamera")
    }
  }
  internal enum Password {
    internal enum Button {
      /// GEM
      internal static let save = Strings.tr("Localizable", "password.button.save", fallback: "GEM")
    }
    internal enum Caption {
      /// Gammel adgangskode
      internal static let oldPassword = Strings.tr("Localizable", "password.caption.oldPassword", fallback: "Gammel adgangskode")
      /// Ny adgangskode
      internal static let password = Strings.tr("Localizable", "password.caption.password", fallback: "Ny adgangskode")
      /// Gentag ny adgangskode
      internal static let repeatPassword = Strings.tr("Localizable", "password.caption.repeatPassword", fallback: "Gentag ny adgangskode")
    }
    internal enum Textfield {
      internal enum Placeholder {
        /// 
        internal static let oldPassword = Strings.tr("Localizable", "password.textfield.placeholder.oldPassword", fallback: "")
        /// 
        internal static let password = Strings.tr("Localizable", "password.textfield.placeholder.password", fallback: "")
        /// 
        internal static let repeatPassword = Strings.tr("Localizable", "password.textfield.placeholder.repeatPassword", fallback: "")
      }
    }
  }
  internal enum Pin {
    internal enum Change {
      /// Vælg den 4-cifrede sikkerhedskode, du vil benytte se/redigere dine betalingskort.
      internal static let body = Strings.tr("Localizable", "pin.change.body", fallback: "Vælg den 4-cifrede sikkerhedskode, du vil benytte se/redigere dine betalingskort.")
      /// Bekræft din kode
      internal static let bodyRepeat = Strings.tr("Localizable", "pin.change.bodyRepeat", fallback: "Bekræft din kode")
      /// SKIFT SIKKERHEDSKODE
      internal static let title = Strings.tr("Localizable", "pin.change.title", fallback: "SKIFT SIKKERHEDSKODE")
      internal enum Button {
        /// Gem sikkerhedskode
        internal static let submit = Strings.tr("Localizable", "pin.change.button.submit", fallback: "Gem sikkerhedskode")
      }
    }
    internal enum Enroll {
      /// Vælg den 4-cifrede sikkerhedskode, du vil benytte se/redigere dine betalingskort.
      internal static let body = Strings.tr("Localizable", "pin.enroll.body", fallback: "Vælg den 4-cifrede sikkerhedskode, du vil benytte se/redigere dine betalingskort.")
      /// Bekræft din kode
      internal static let `repeat` = Strings.tr("Localizable", "pin.enroll.repeat", fallback: "Bekræft din kode")
      /// OPRET SIKKERHEDSKODE
      internal static let title = Strings.tr("Localizable", "pin.enroll.title", fallback: "OPRET SIKKERHEDSKODE")
      internal enum Button {
        /// Gem sikkerhedskode
        internal static let submit = Strings.tr("Localizable", "pin.enroll.button.submit", fallback: "Gem sikkerhedskode")
      }
    }
    internal enum Validation {
      /// INDTAST SIKKERHEDSKODE
      internal static let title = Strings.tr("Localizable", "pin.validation.title", fallback: "INDTAST SIKKERHEDSKODE")
      internal enum Button {
        /// Jeg har glemt min kode
        internal static let forgot = Strings.tr("Localizable", "pin.validation.button.forgot", fallback: "Jeg har glemt min kode")
        /// Valider
        internal static let submit = Strings.tr("Localizable", "pin.validation.button.submit", fallback: "Valider")
      }
    }
  }
  internal enum Product {
    internal enum Details {
      /// Tilføj
      internal static let add = Strings.tr("Localizable", "product.details.add", fallback: "Tilføj")
      /// %@ %%
      internal static func discount(_ p1: Any) -> String {
        return Strings.tr("Localizable", "product.details.discount", String(describing: p1), fallback: "%@ %%")
      }
      /// %@ DKK
      internal static func price(_ p1: Any) -> String {
        return Strings.tr("Localizable", "product.details.price", String(describing: p1), fallback: "%@ DKK")
      }
      /// Fjern
      internal static let remove = Strings.tr("Localizable", "product.details.remove", fallback: "Fjern")
      /// %@ tilbage på lager
      internal static func stock(_ p1: Any) -> String {
        return Strings.tr("Localizable", "product.details.stock", String(describing: p1), fallback: "%@ tilbage på lager")
      }
      internal enum Details {
        /// Detaljer
        internal static let caption = Strings.tr("Localizable", "product.details.details.caption", fallback: "Detaljer")
      }
      internal enum Discount {
        /// Rabat
        internal static let caption = Strings.tr("Localizable", "product.details.discount.caption", fallback: "Rabat")
      }
      internal enum EmptyView {
        /// VÆLG FAVORITTER
        internal static let button = Strings.tr("Localizable", "product.details.emptyView.button", fallback: "VÆLG FAVORITTER")
        /// INGEN
        /// FAVORITTER
        internal static let title = Strings.tr("Localizable", "product.details.emptyView.title", fallback: "INGEN\nFAVORITTER")
      }
      internal enum Notice {
        /// Dette produkt er ekstra nedsat i denne periode.
        internal static let discount = Strings.tr("Localizable", "product.details.notice.discount", fallback: "Dette produkt er ekstra nedsat i denne periode.")
        /// Der er kun få produkter tilbage, skynd dig at bestille hvis du vil være sikker på at få en.
        internal static let fewProducts = Strings.tr("Localizable", "product.details.notice.fewProducts", fallback: "Der er kun få produkter tilbage, skynd dig at bestille hvis du vil være sikker på at få en.")
      }
      internal enum Rating {
        /// Rating
        internal static let caption = Strings.tr("Localizable", "product.details.rating.caption", fallback: "Rating")
      }
    }
    internal enum Filter {
      /// Mærke
      internal static let brand = Strings.tr("Localizable", "product.filter.brand", fallback: "Mærke")
      /// Kategori
      internal static let category = Strings.tr("Localizable", "product.filter.category", fallback: "Kategori")
      /// Ryd
      internal static let clearFilters = Strings.tr("Localizable", "product.filter.clearFilters", fallback: "Ryd")
      internal enum Button {
        /// GEM OG FORTSÆT
        internal static let title = Strings.tr("Localizable", "product.filter.button.title", fallback: "GEM OG FORTSÆT")
      }
      internal enum EmptyView {
        /// Vi kunne ikke finde nogle filtre, der matcher din søgning.
        internal static let body = Strings.tr("Localizable", "product.filter.emptyView.body", fallback: "Vi kunne ikke finde nogle filtre, der matcher din søgning.")
        /// INGEN
        /// RESULTATER
        internal static let title = Strings.tr("Localizable", "product.filter.emptyView.title", fallback: "INGEN\nRESULTATER")
      }
    }
    internal enum Header {
      internal enum NoBrand {
        /// Ukendt
        internal static let title = Strings.tr("Localizable", "product.header.noBrand.title", fallback: "Ukendt")
      }
    }
    internal enum Search {
      /// Søg
      internal static let placehoder = Strings.tr("Localizable", "product.search.placehoder", fallback: "Søg")
    }
    internal enum Segment {
      internal enum Am {
        /// A-M (%@)
        internal static func button(_ p1: Any) -> String {
          return Strings.tr("Localizable", "product.segment.am.button", String(describing: p1), fallback: "A-M (%@)")
        }
        /// A-M
        internal static let buttonEmpty = Strings.tr("Localizable", "product.segment.am.buttonEmpty", fallback: "A-M")
      }
      internal enum Nz {
        /// N-Z (%@)
        internal static func button(_ p1: Any) -> String {
          return Strings.tr("Localizable", "product.segment.nz.button", String(describing: p1), fallback: "N-Z (%@)")
        }
        /// N-Z
        internal static let buttonEmpty = Strings.tr("Localizable", "product.segment.nz.buttonEmpty", fallback: "N-Z")
      }
    }
  }
  internal enum Profile {
    internal enum Address {
      internal enum Searchfield {
        /// Æblevej 36, 1000 Andeby
        internal static let placeholder = Strings.tr("Localizable", "profile.address.searchfield.placeholder", fallback: "Æblevej 36, 1000 Andeby")
      }
    }
    internal enum Button {
      /// Skift adgangskode
      internal static let changePassword = Strings.tr("Localizable", "profile.button.changePassword", fallback: "Skift adgangskode")
      /// Fjern alders validering
      internal static let removeValidation = Strings.tr("Localizable", "profile.button.removeValidation", fallback: "Fjern alders validering")
      /// GEM
      internal static let save = Strings.tr("Localizable", "profile.button.save", fallback: "GEM")
      /// Valider din alder
      internal static let validateBirthday = Strings.tr("Localizable", "profile.button.validateBirthday", fallback: "Valider din alder")
    }
    internal enum Caption {
      /// Adresse
      internal static let address = Strings.tr("Localizable", "profile.caption.address", fallback: "Adresse")
      /// Fødselsdato
      internal static let birthdate = Strings.tr("Localizable", "profile.caption.birthdate", fallback: "Fødselsdato")
      /// Adgangskode
      internal static let changePassword = Strings.tr("Localizable", "profile.caption.changePassword", fallback: "Adgangskode")
      /// By
      internal static let city = Strings.tr("Localizable", "profile.caption.city", fallback: "By")
      /// Land
      internal static let country = Strings.tr("Localizable", "profile.caption.country", fallback: "Land")
      /// Email
      internal static let email = Strings.tr("Localizable", "profile.caption.email", fallback: "Email")
      /// Fornavn
      internal static let firstName = Strings.tr("Localizable", "profile.caption.firstName", fallback: "Fornavn")
      /// Efternavn
      internal static let lastName = Strings.tr("Localizable", "profile.caption.lastName", fallback: "Efternavn")
      /// Tlf.
      internal static let phone = Strings.tr("Localizable", "profile.caption.phone", fallback: "Tlf.")
      /// Profil
      internal static let profile = Strings.tr("Localizable", "profile.caption.profile", fallback: "Profil")
      /// Vejnavn
      internal static let streetAddress = Strings.tr("Localizable", "profile.caption.streetAddress", fallback: "Vejnavn")
      /// Valider
      internal static let validateBirthday = Strings.tr("Localizable", "profile.caption.validateBirthday", fallback: "Valider")
      /// Postnr.
      internal static let zipCode = Strings.tr("Localizable", "profile.caption.zipCode", fallback: "Postnr.")
    }
    internal enum Country {
      internal enum Searchfield {
        /// Fx Danmark
        internal static let placeholder = Strings.tr("Localizable", "profile.country.searchfield.placeholder", fallback: "Fx Danmark")
      }
    }
    internal enum Textfield {
      internal enum Placeholder {
        /// 01-01-1981
        internal static let birthdate = Strings.tr("Localizable", "profile.textfield.placeholder.birthdate", fallback: "01-01-1981")
        /// Andeby
        internal static let city = Strings.tr("Localizable", "profile.textfield.placeholder.city", fallback: "Andeby")
        /// Danmark
        internal static let country = Strings.tr("Localizable", "profile.textfield.placeholder.country", fallback: "Danmark")
        /// jens@hansen.dk
        internal static let email = Strings.tr("Localizable", "profile.textfield.placeholder.email", fallback: "jens@hansen.dk")
        /// Jens
        internal static let firstName = Strings.tr("Localizable", "profile.textfield.placeholder.firstName", fallback: "Jens")
        /// Hansen
        internal static let lastName = Strings.tr("Localizable", "profile.textfield.placeholder.lastName", fallback: "Hansen")
        /// 00000000
        internal static let phoneNumber = Strings.tr("Localizable", "profile.textfield.placeholder.phoneNumber", fallback: "00000000")
        /// Æblevej 36
        internal static let streetAddress = Strings.tr("Localizable", "profile.textfield.placeholder.streetAddress", fallback: "Æblevej 36")
        /// 1000
        internal static let zipCode = Strings.tr("Localizable", "profile.textfield.placeholder.zipCode", fallback: "1000")
      }
    }
  }
  internal enum Tabbar {
    /// Localizable.strings
    ///   customerapp
    /// 
    ///   Created by Tommy Sadiq Hinrichsen on 02/01/2023.
    internal static let dashboard = Strings.tr("Localizable", "tabbar.dashboard", fallback: "Hjem")
    /// Favoritter
    internal static let entities = Strings.tr("Localizable", "tabbar.entities", fallback: "Favoritter")
    /// Mere
    internal static let more = Strings.tr("Localizable", "tabbar.more", fallback: "Mere")
    /// Søg
    internal static let search = Strings.tr("Localizable", "tabbar.search", fallback: "Søg")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Strings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
