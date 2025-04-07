//
//  OSCAContactFormFlowCoordinator.swift
//  OSCAContactUI
//
//  Created by Stephan Breidenbach on 01.02.22.
//  Reviewed by Stephan Breidenbach on 12.07.22
//

import Foundation
import OSCAEssentials
import OSCAContact

protocol OSCAContactFormFlowCoordinatorDependencies {
  var deeplinkScheme: String { get }
  func makeOSCAContactFormViewController(actions: OSCAContactFormViewModelActions) -> OSCAContactFormViewController
  func makeOSCAContactPickerViewController(actions: OSCAContactPickerViewModelActions, viewModel: OSCAContactFormViewModel) -> OSCAContactPickerViewController
  func makeOSCAContactPrivacyPolicyViewController(actions: OSCAContactPrivacyPolicyViewModelActions, privacyPolicy: String) -> OSCAContactPrivacyPolicyViewController
}// end public protocol OSCAContactFormFlowCoordinatorDependencies

final class OSCAContactFormFlowCoordinator: Coordinator {
  /**
   `children`property for conforming to `Coordinator` protocol is a list of `Coordinator`'s
   */
  var children: [Coordinator] = []
  
  var router: Router
  
  let dependencies: OSCAContactFormFlowCoordinatorDependencies
  
  private weak var contactFormVC: OSCAContactFormViewController?
  
  private weak var contactPickerVC: OSCAContactPickerViewController?
  
  private weak var contactPrivacyPolicyVC: OSCAContactPrivacyPolicyViewController?
  
  init( router: Router,
        dependencies: OSCAContactFormFlowCoordinatorDependencies) {
    self.router = router
    self.dependencies = dependencies
  }// end public init
  
  // MARK: - Contact Picker Actions
  
  private func closeContactPicker() -> Void {
    self.router.navigateBack(animated: true)
  }
  
  // MARK: - Contact Form Actions
  
  private func showContactPrivacyPolicy(privacyPolicy: String) -> Void {
    let actions = OSCAContactPrivacyPolicyViewModelActions()
    let vc = self.dependencies.makeOSCAContactPrivacyPolicyViewController(
      actions: actions,
      privacyPolicy: privacyPolicy)
    
    self.router.present(vc,
                        animated: true)
    self.contactPrivacyPolicyVC = vc
  }
  
  private func showContactPicker(viewModel: OSCAContactFormViewModel) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let actions = OSCAContactPickerViewModelActions(
      closeContactPicker: self.closeContactPicker)
    let vc = self.dependencies.makeOSCAContactPickerViewController(
      actions: actions,
      viewModel: viewModel)
    self.router.presentModalViewController(
      vc,
      animated: true,
      onDismissed: nil)
    self.contactPickerVC = vc
  }// end private func showModalContactPicker
  
  private func closeContactForm() -> Void {
    self.router.navigateBack(animated: true)
  }
  
  func showContactForm(animated: Bool,
                       onDismissed: (()-> Void)?) -> Void {
    let actions: OSCAContactFormViewModelActions = OSCAContactFormViewModelActions(
      showContactPrivacyPolicy: self.showContactPrivacyPolicy,
      showContactPicker: self.showContactPicker,
      closeContactForm: self.closeContactForm)
    let vc = self.dependencies.makeOSCAContactFormViewController(
      actions: actions)
    self.router.present(vc,
                        animated: animated,
                        onDismissed: onDismissed)
    self.contactFormVC = vc
  }// end public func showContactForm
  
  func present(animated: Bool,
               onDismissed: (() -> Void)?) -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    showContactForm(animated: animated,
                    onDismissed: onDismissed)
  }// end func present
}// end public final class OSCAContactFormFlowCoordinator
