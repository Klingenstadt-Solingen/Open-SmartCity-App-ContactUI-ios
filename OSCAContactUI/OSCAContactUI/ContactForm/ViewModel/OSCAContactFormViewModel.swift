//
//  OSCAContactFormViewModel.swift
//  OSCAContactUI
//
//  Created by Ömer Kurutay on 29.08.22.
//

import Foundation
import Combine
import OSCAContact
import OSCAEssentials

public struct OSCAContactFormViewModelActions {
  let showContactPrivacyPolicy: (String) -> Void
  let showContactPicker       : (OSCAContactFormViewModel) -> Void
  let closeContactForm        : () -> Void
}

public struct PeronalData: OptionSet {
  public var rawValue: Int
  
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  public static var fullName = PeronalData(rawValue: 1 << 0)
  public static var address = PeronalData(rawValue: 1 << 1)
  public static var postalCode = PeronalData(rawValue: 1 << 2)
  public static var city = PeronalData(rawValue: 1 << 3)
  public static var phone = PeronalData(rawValue: 1 << 4)
  public static var email = PeronalData(rawValue: 1 << 5)
  public static var all: PeronalData = [.fullName, .address, .postalCode, .city, .phone, .email]
  public static var none: PeronalData = []
}

public enum OSCAContactFormViewModelError: Error, Equatable {
  case privacyPolicyFetch
  case contactFormDataSubmit
}

public enum OSCAContactFormViewModelState: Equatable {
  case fillInForm
  case validating
  case sending
  case finishedSending
  case loading
  case finishedLoading
  case receivedResponse
  case error(OSCAContactFormViewModelError)
}

public final class OSCAContactFormViewModel {
  
  private let dataModule: OSCAContact
  private let actions: OSCAContactFormViewModelActions?
  private var bindings = Set<AnyCancellable>()
  
  // MARK: Initializer
  public init(dataModule: OSCAContact,
              actions: OSCAContactFormViewModelActions) {
    self.dataModule = dataModule
    self.actions = actions
  }
  
  // MARK: - OUTPUT
  
  /**
   Use this to get access to the __Bundle__ delivered from this module's configuration parameter __externalBundle__.
   - Returns: The __Bundle__ given to this module's configuration parameter __externalBundle__. If __externalBundle__ is __nil__, The module's own __Bundle__ is returned instead.
   */
  var bundle: Bundle = {
    if let bundle = OSCAContactUI.configuration.externalBundle {
      return bundle
    }
    else { return OSCAContactUI.bundle }
  }()
  
  @Published var state: OSCAContactFormViewModelState = .fillInForm
  @Published var contactType: OSCAContactFormContact? = nil
  @Published var fullName: String = ""
  @Published var address: String = ""
  @Published var postalCode: String = ""
  @Published var city: String = ""
  @Published var phone: String = ""
  @Published var email: String = ""
  
  /// The note which will be sent to the server after submission
  var note: String = ""
  var isPrivacyPolicyConfirmed: Bool = false
  
  // MARK: Localized Strings
  
  var screenTitle: String { NSLocalizedString(
    "contact_form_screen_title",
    bundle: self.bundle,
    comment: "The screen title") }
  var info: String { NSLocalizedString(
    "contact_form_info_text",
    bundle: self.bundle,
    comment: "The contact form info text") }
  var contactTitle: String { NSLocalizedString(
    "contact_contact_title",
    bundle: self.bundle,
    comment: "The title for the contact form fields") }
  var contactTypeTitle: String { NSLocalizedString(
    "contact_contact_type_title",
    bundle: self.bundle,
    comment: "The title for the contact types") }
  var notePlaceholder: String { NSLocalizedString(
    "contact_note_placeholder",
    bundle: self.bundle,
    comment: "The note placeholder") }
  var personalDataTitle: String = NSLocalizedString(
    "contact_personal_data_title",
    bundle: OSCAContactUI.bundle,
    comment: "The title for the personal data fields")
  var fullNamePlaceholder: String { NSLocalizedString(
    "contact_placeholder_full_name",
    bundle: self.bundle,
    comment: "The placeholder for the full name field") }
  var addressPlaceholder: String { NSLocalizedString(
    "contact_placeholder_address",
    bundle: self.bundle,
    comment: "The placeholder for the address field") }
  var postalCodePlaceholder: String { NSLocalizedString(
    "contact_placeholder_postal_code",
    bundle: self.bundle,
    comment: "The placeholder for the postal code field") }
  var cityPlaceholder: String  { NSLocalizedString(
    "contact_placeholder_city",
    bundle: self.bundle,
    comment: "The placeholder for the city field") }
  var phonePlaceholder: String { NSLocalizedString(
    "contact_placeholder_phone",
    bundle: self.bundle,
    comment: "The placeholder for the phone number field") }
  var emailPlaceholder: String { NSLocalizedString(
    "contact_placeholder_email",
    bundle: self.bundle,
    comment: "The placeholder for the e-mail address field") }
  var inputMessageError: String { NSLocalizedString(
    "contact_input_message_error",
    bundle: self.bundle,
    comment: "The error message for invalid inputs in text fields") }
  var privacyConsent: String { NSLocalizedString(
    "contact_privacy_policy_consent",
    bundle: self.bundle,
    comment: "The consent to the privacy policy") }
  var privacyConsentLinks: [String] { [
    NSLocalizedString("contact_privacy_policy_consent_link",
                      bundle: self.bundle,
                      comment: "The link in the privacy policy consent")] }
  var privacyRange: NSRange {
    (privacyConsent as NSString).range(of: privacyConsentLinks[0])
  }
  var submitTitle: String { NSLocalizedString(
    "contact_submit_title",
    bundle: self.bundle,
    comment: "The title for the submit button") }
  var alertTitleSuccess: String { NSLocalizedString(
    "contact_alert_title_success",
    bundle: self.bundle,
    comment: "The alert action title to show success") }
  var alertMessageSuccess: String { NSLocalizedString(
    "contact_alert_message_success",
    bundle: self.bundle,
    comment: "The alert action message to show success") }
  var alertTitleError: String { NSLocalizedString(
    "contact_alert_title_error",
    bundle: self.bundle,
    comment: "The alert title for an error") }
  var alertMessageError: String { NSLocalizedString(
    "contact_alert_message_error",
    bundle: self.bundle,
    comment: "The alert message for an entry error") }
  var alertActionConfirm: String { NSLocalizedString(
    "contact_alert_title_confirm",
    bundle: self.bundle,
    comment: "The alert action title to confirm") }
  var alertActionCancel: String { NSLocalizedString(
    "contact_alert_title_cancel",
    bundle: self.bundle,
    comment: "The alert action title to cancel") }
  
  // MARK: - Private
  
  private func fetchParseConfigParams() {
    state = .loading
    
    self.dataModule
      .getParseConfigParams()
      .sink { completion in
        switch completion {
        case .finished:
          self.state = .finishedLoading
          
        case .failure:
          self.state = .error(.privacyPolicyFetch)
        }
      } receiveValue: { config in
        guard let privacyText = config.privacyText
        else {
          self.state = .error(.privacyPolicyFetch)
          return
        }
        self.actions?.showContactPrivacyPolicy(privacyText)
      }
      .store(in: &self.bindings)
  }
  
  private func sendContactForm() {
    let personalData = OSCAContactUI.configuration.personalData
    
    let contactFormData = OSCAContactFormData(
      name         : personalData.contains(.fullName) ? fullName : nil,
      address      : personalData.contains(.address) ? address : nil,
      postalCode   : personalData.contains(.postalCode) ? postalCode : nil,
      city         : personalData.contains(.city) ? city : nil,
      phone        : personalData.contains(.phone) ? phone : nil,
      email        : personalData.contains(.email) ? email : nil,
      message      : note,
      contactId    : contactType?.objectId)
    
    self.dataModule
      .send(contactFormData: contactFormData)
      .sink { completion in
        switch completion {
        case .finished:
          self.state = .finishedSending
          
        case .failure:
          self.state = .error(.contactFormDataSubmit)
        }
      } receiveValue: { result in
        switch result {
        case let .success(response):
          print("\(Self.self): \(#function): \(response)")
          
          self.state = .receivedResponse
          
        case .failure:
          self.state = .error(.contactFormDataSubmit)
        }
      }
      .store(in: &self.bindings)
  }
  
  private func isValid(fullName: String) -> Bool {
    return fullName.count >= 3 && fullName.contains(" ")
  }
  
  public func checkIsFormValid() -> Bool {
    if contactType != nil,
       !note.isEmpty && note != notePlaceholder,
       isPrivacyPolicyConfirmed {
      if OSCAContactUI.configuration.personalData == .none {
        return true
      } else {
        for option: PeronalData in [.fullName, .address, .postalCode, .city, .phone, .email] {
          guard OSCAContactUI.configuration.personalData.contains(option)
          else { continue }
          
          switch option {
          case .address:
            if address.isEmpty { return false }
            
          case .postalCode:
            if postalCode.isEmpty { return false }
            
          case .city:
            if city.isEmpty { return false }
            
          case .phone:
            if phone.isEmpty { return false }
            
          case .email:
            if !email.isValidEmail() { return false }
            
          default: continue
          }
        }
        return true
      }
    }
    
    return false
  }
  
  private func isFormValid() -> Bool {
    state = .validating
    return checkIsFormValid()
  }
}

// MARK: - INPUT. View event methods
extension OSCAContactFormViewModel {
  func viewDidLoad() {
    note = notePlaceholder
  }
  
  func textFieldShouldBeginEditing() {
    actions?.showContactPicker(self)
  }
  
  func textFieldsEditingChanged(_ type: PeronalData, text: String) {
    let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
    
    switch type {
    case .fullName:
      fullName = text
      
    case .address:
      address = text
      
    case .postalCode:
      postalCode = text
      
    case .city:
      city = text
      
    case .phone:
      phone = text
      
    case .email:
      email = text.isValidEmail() ? text : ""
      
    default: break
    }
  }
  
  func privacySwitchTouch(isOn: Bool) {
    isPrivacyPolicyConfirmed = isOn
  }
  
  func tapPrivacyLabel() {
    fetchParseConfigParams()
  }
  
  func submitButtonTouch() {
    if isFormValid() {
      sendContactForm()
    }
  }
  
  func receivedResponseAlertCompletion() {
    actions?.closeContactForm()
  }
}
