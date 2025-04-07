//
//  OSCAContactPrivacyPolicyViewModel.swift
//  OSCAContactUI
//
//  Created by Ömer Kurutay on 26.08.22.
//

import Foundation

public struct OSCAContactPrivacyPolicyViewModelActions {}

public final class OSCAContactPrivacyPolicyViewModel {
  private let actions: OSCAContactPrivacyPolicyViewModelActions?
  let privacyPolicy: String
  
  // MARK: Initializer
  public init(actions: OSCAContactPrivacyPolicyViewModelActions,
              privacyPolicy: String) {
    self.actions = actions
    self.privacyPolicy = privacyPolicy
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
  
  var screenTitle: String { NSLocalizedString(
    "contact_privacy_policy_screen_title",
    bundle: self.bundle,
    comment: "The screen title for privacy policy") }
}

// MARK: - INPUT. View event methods

extension OSCAContactPrivacyPolicyViewModel {
  func viewDidLoad() {}
}
