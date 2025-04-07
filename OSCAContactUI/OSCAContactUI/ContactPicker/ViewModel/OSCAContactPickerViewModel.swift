//
//  OSCAContactPickerViewModel.swift
//  OSCAContactUI
//
//  Created by Ömer Kurutay on 29.08.22.
//

import Foundation
import OSCAContact
import Combine

public struct OSCAContactPickerViewModelActions {
  let closeContactPicker: () -> Void
}

public enum OSCAContactPickerViewModelError: Error, Equatable {
  case contactFormContactFetch
  case contactPicking
}

public enum OSCAContactPickerViewModelState: Equatable {
  case selected
  case loading
  case finishedLoading
  case error(OSCAContactPickerViewModelError)
}

public final class OSCAContactPickerViewModel {
  
  private let dataModule: OSCAContact
  private let actions: OSCAContactPickerViewModelActions?
  private var formViewModel: OSCAContactFormViewModel!
  private var bindings = Set<AnyCancellable>()
  
  // MARK: Initializer
  public init(dataModule: OSCAContact,
              actions: OSCAContactPickerViewModelActions,
              viewModel: OSCAContactFormViewModel) {
    self.dataModule = dataModule
    self.actions = actions
    self.formViewModel = viewModel
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
  
  @Published private(set) var state: OSCAContactPickerViewModelState = .loading
  @Published private(set) var contactFormContacts: [OSCAContactFormContact] = []
  
  var selectedContactFormContact: OSCAContactFormContact? = nil
  let numberOfComponents: Int = 1
  var numberOfItemsInComponent: Int { contactFormContacts.count }
  
  // MARK: Localized Strings
  
  var alertTitleError: String { NSLocalizedString(
    "contact_alert_title_error",
    bundle: self.bundle,
    comment: "The alert title for an error") }
  var alertActionConfirm: String { NSLocalizedString(
    "contact_alert_title_confirm",
    bundle: self.bundle,
    comment: "The alert action title to confirm") }
  var cancelTitle: String { NSLocalizedString(
    "contact_picker_title_cancel",
    bundle: self.bundle,
    comment: "The title for the picker view cancel button") }
  var confirmTitle: String { NSLocalizedString(
    "contact_picker_title_confirm",
    bundle: self.bundle,
    comment: "The title for the picker view confirm button") }
  
  // MARK: - Private
  
  private func fetchAllContactFormContacts() -> Void {
    state = .loading
    
    self.dataModule
      .getContactFormContacts(limit: 1000, query: [:])
      .sink { completion in
        switch completion {
        case .finished:
          self.state = .finishedLoading
          
        case .failure:
          self.state = .error(.contactFormContactFetch)
        }
      } receiveValue: { result in
        switch result {
        case let .success(fetchedContactFormContacts):
          self.selectedContactFormContact = fetchedContactFormContacts.first
          self.state = .selected
          self.contactFormContacts = fetchedContactFormContacts
          
        case .failure:
          self.state = .error(.contactFormContactFetch)
        }
      }
      .store(in: &self.bindings)
  }
}

// MARK: - INPUT. View event methods
extension OSCAContactPickerViewModel {
  func viewDidLoad() {
    fetchAllContactFormContacts()
  }
  
  func viewDidAppear() {}
  
  func didSelectItem(at index: Int) {
    selectedContactFormContact = contactFormContacts[index]
    state = .selected
  }
  
  func closePicker() {
    selectedContactFormContact = nil
    actions?.closeContactPicker()
  }
  
  func tapOnMainViewTouch() {
    closePicker()
  }
  
  func cancelButtonTouch() {
    closePicker()
  }
  
  func confirmButtonTouch() {
    formViewModel.contactType = selectedContactFormContact
    actions?.closeContactPicker()
  }
}
