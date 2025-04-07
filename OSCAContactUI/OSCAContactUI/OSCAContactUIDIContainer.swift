//
//  OSCAContactUIDIContainer.swift
//  OSCAContactUI
//
//  Created by Stephan Breidenbach on 01.02.22.
//

import OSCAContact
import OSCAEssentials
import UIKit

/**
 Every isolated module feature will have its own Dependency Injection Container,
 to have one entry point where we can see all dependencies and injections of the module
 */
final class OSCAContactUIDIContainer {
  let dependencies: OSCAContactUIDependencies
  let dataModule: OSCAContact
  
  public init(dependencies: OSCAContactUIDependencies) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    self.dependencies = dependencies
    self.dataModule = OSCAContactUIDIContainer.makeOSCAContactModule(dependencies: dependencies)
  }// end public init
  
  // MARK: - OSCAContactModule
  private static func makeOSCAContactModule(dependencies: OSCAContactUIDependencies) -> OSCAContact {
    return dependencies.dataModule
  }// end private static func makeOSCAContactModule
  
  // MARK: - ContactForm
  /// `make-function` for `OSCAContactFormViewController` with injected dependency
  /// - Parameter actions: view model actions
  /// - Returns: view controller `OSCAContactFormViewController`
  func makeOSCAContactFormViewController(actions: OSCAContactFormViewModelActions) -> OSCAContactFormViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return OSCAContactFormViewController.create(with: makeOSCAContactFormViewModel(actions: actions))
  }// end func makeOSCAContactFormViewController
  
  /// `make-function`for `OSCAContactFormViewModel` with injected dependency
  /// - Parameter actions: view model actions
  /// - Returns : view model `OSCAContactFormViewModel`
  func makeOSCAContactFormViewModel(actions:OSCAContactFormViewModelActions) -> OSCAContactFormViewModel {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return OSCAContactFormViewModel(dataModule: self.dependencies.dataModule,
                                    actions   : actions)
  }// end func makeOSCAContactFormViewModel
  
  // MARK: - OSCAContactPicker
  /// `make-function` for `OSCAContactPickerViewController
  /// - Parameter actions: view model actions
  /// - Returns: view model `OSCAContactPickerViewModel`
  func makeOSCAContactPickerViewController(actions: OSCAContactPickerViewModelActions, viewModel: OSCAContactFormViewModel) -> OSCAContactPickerViewController {
    return OSCAContactPickerViewController.create(with: makeOSCAContactPickerViewModel(actions: actions, viewModel: viewModel))
  }// end func makeOSCAContacdtPickerViewController
  
  ///  `make-function`for `OSCAContactPickerViewModel`
  ///  - Parameter actions: view model actions
  ///  - Parameter viewModel: parent view model `OSCAContactFormViewModel`
  ///  - Returns: view model: `OSCAContactPickerViewModel`
  func makeOSCAContactPickerViewModel(actions: OSCAContactPickerViewModelActions, viewModel: OSCAContactFormViewModel) -> OSCAContactPickerViewModel{
    return OSCAContactPickerViewModel(dataModule: self.dependencies.dataModule, actions: actions, viewModel: viewModel)
  }// end func makeOSCAContactPickerViewModel
  
  // MARK: - Contact Privacy Policy
  func makeOSCAContactPrivacyPolicyViewController(actions: OSCAContactPrivacyPolicyViewModelActions, privacyPolicy: String) -> OSCAContactPrivacyPolicyViewController {
    return OSCAContactPrivacyPolicyViewController.create(with: makeOSCAContactPrivacyPolicyViewModel(actions: actions, privacyPolicy: privacyPolicy))
  }
  
  func makeOSCAContactPrivacyPolicyViewModel(actions: OSCAContactPrivacyPolicyViewModelActions, privacyPolicy: String) -> OSCAContactPrivacyPolicyViewModel {
    return OSCAContactPrivacyPolicyViewModel(
      actions: actions,
      privacyPolicy: privacyPolicy)
  }
  
  // MARK: - flow coordinator
  func makeOSCAContactFormFlowCoordinator(router: Router) -> OSCAContactFormFlowCoordinator {
    return OSCAContactFormFlowCoordinator(router: router, dependencies: self)
  }// end func makeOSCAContactFormFlowCoordinator
}// end final class OSCAContactUIDIContaine

// MARK: - OSCAContactFormFlowCoordinatorDependencies conformance
extension OSCAContactUIDIContainer: OSCAContactFormFlowCoordinatorDependencies {}// end extension final class OSCAContactUIDIContainer
