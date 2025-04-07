//
//  OSCAContactFormViewController.swift
//  OSCAContactUI
//
//  Created by Ömer Kurutay on 29.08.22.
//

import OSCAEssentials
import OSCAContact
import UIKit
import Combine
import SkyFloatingLabelTextField

public final class OSCAContactFormViewController: UIViewController, Alertable, ActivityIndicatable {
  
  @IBOutlet private var tapOnMainView: UITapGestureRecognizer!
  @IBOutlet private var scrollView: UIScrollView!
  @IBOutlet private var infoLabel: UILabel!
  @IBOutlet private var contactTitleLabel: UILabel!
  @IBOutlet private var contactContainerView: UIView!
  @IBOutlet private var contactTypeTextField: SkyFloatingLabelTextField!
  @IBOutlet private var noteTextView: UITextView!
  @IBOutlet private var personalDataStackView: UIStackView!
  @IBOutlet private var personalDataTitleLabel: UILabel!
  @IBOutlet private var personalDataFieldsStackView: UIStackView!
  @IBOutlet private var fullNameTextField: SkyFloatingLabelTextField!
  @IBOutlet private var addressTextField: SkyFloatingLabelTextField!
  @IBOutlet private var postalCodeTextField: SkyFloatingLabelTextField!
  @IBOutlet private var cityTextField: SkyFloatingLabelTextField!
  @IBOutlet private var phoneTextField: SkyFloatingLabelTextField!
  @IBOutlet private var emailTextField: SkyFloatingLabelTextField!
  @IBOutlet private var privacyStackView: UIStackView!
  @IBOutlet private var privacySwitch: UISwitch!
  @IBOutlet private var privacyLabel: UILabel!
  @IBOutlet private var submitButton: UIButton!
  
  private var viewModel: OSCAContactFormViewModel!
  private var bindings = Set<AnyCancellable>()
  
  public lazy var activityIndicatorView = ActivityIndicatorView(style: .large)
  
  private var activeField: UITextField?
  private var activeTextView: UITextView?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    setupBindings()
    self.viewModel.viewDidLoad()
  }
  
  private func setupViews() {
    scrollView.delegate = self
    contactTypeTextField.delegate = self
    noteTextView.delegate = self
    fullNameTextField.delegate = self
    addressTextField.delegate = self
    postalCodeTextField.delegate = self
    cityTextField.delegate = self
    phoneTextField.delegate = self
    emailTextField.delegate = self
    
    self.view.backgroundColor = OSCAContactUI.configuration.colorConfig.backgroundColor
    self.view.addSubview(activityIndicatorView)
    activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      activityIndicatorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      activityIndicatorView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
      activityIndicatorView.heightAnchor.constraint(equalToConstant: 100.0),
      activityIndicatorView.widthAnchor.constraint(equalToConstant: 100.0),
    ])
    
    tapOnMainView.cancelsTouchesInView = false
    
    self.navigationItem.title = self.viewModel.screenTitle
    
    infoLabel.text = viewModel.info
    infoLabel.font = OSCAContactUI.configuration.fontConfig.bodyLight
    infoLabel.textColor = OSCAContactUI.configuration.colorConfig.textColor
    
    contactTitleLabel.text = viewModel.contactTitle
    contactTitleLabel.font = OSCAContactUI.configuration.fontConfig.titleHeavy
    contactTitleLabel.textColor = OSCAContactUI.configuration.colorConfig.textColor
    
    self.contactContainerView.backgroundColor = OSCAContactUI.configuration.colorConfig.secondaryBackgroundColor
    contactContainerView.layer.cornerRadius = OSCAContactUI.configuration.cornerRadius
    contactContainerView.addShadow(with: OSCAContactUI.configuration.shadow)
    
    contactTypeTextField.font = OSCAContactUI.configuration.fontConfig.bodyLight
    contactTypeTextField.placeholder = viewModel.contactTypeTitle
    contactTypeTextField.textColor = OSCAContactUI.configuration.colorConfig.textColor
    contactTypeTextField.selectedTitleColor = OSCAContactUI.configuration.colorConfig.primaryColor
    contactTypeTextField.errorColor = OSCAContactUI.configuration.colorConfig.errorColor
    let imageArrowDownConfig = UIImage.SymbolConfiguration(scale: .small)
    let imageArrowDown = UIImage(systemName: "arrowtriangle.down.fill")?
      .withConfiguration(imageArrowDownConfig)
    if let image = imageArrowDown {
      let tapGesture = UITapGestureRecognizer(target: self,
                                              action: #selector(self.showPicker(_:)))
      self.contactTypeTextField.withImage(
        image,
        imagePadding: 10,
        imageColor: OSCAContactUI.configuration.colorConfig.primaryColor,
        separatorColor: .clear,
        direction: .right,
        tapGesture: tapGesture)
    }
    
    noteTextView.text = viewModel.notePlaceholder
    noteTextView.font = OSCAContactUI.configuration.fontConfig.bodyLight
    noteTextView.textColor = OSCAContactUI.configuration.colorConfig.whiteDarker
    noteTextView.backgroundColor = OSCAContactUI.configuration.colorConfig.grayColor.withAlphaComponent(0.25)
    noteTextView.layer.cornerRadius = OSCAContactUI.configuration.cornerRadius
    noteTextView.layer.masksToBounds = true
    noteTextView.inputAccessoryView = keyboardToolbar()
    
    personalDataStackView.isHidden = OSCAContactUI.configuration.personalData == .none
    
    personalDataTitleLabel.text = viewModel.personalDataTitle
    personalDataTitleLabel.font = OSCAContactUI.configuration.fontConfig.titleHeavy
    personalDataTitleLabel.textColor = OSCAContactUI.configuration.colorConfig.textColor
    
    self.personalDataFieldsStackView.backgroundColor = OSCAContactUI.configuration.colorConfig.secondaryBackgroundColor
    personalDataFieldsStackView.layer.cornerRadius = OSCAContactUI.configuration.cornerRadius
    personalDataFieldsStackView.addShadow(with: OSCAContactUI.configuration.shadow)
    
    fullNameTextField.isHidden = !OSCAContactUI.configuration.personalData.contains(.fullName)
    fullNameTextField.textContentType = .name
    fullNameTextField.placeholder = viewModel.fullNamePlaceholder
    fullNameTextField.font = OSCAContactUI.configuration.fontConfig.bodyLight
    fullNameTextField.textColor = OSCAContactUI.configuration.colorConfig.textColor
    fullNameTextField.selectedTitleColor = OSCAContactUI.configuration.colorConfig.primaryColor
    fullNameTextField.errorColor = OSCAContactUI.configuration.colorConfig.errorColor
    fullNameTextField.clearButtonMode = .whileEditing
    fullNameTextField.inputAccessoryView = keyboardToolbar()
    
    addressTextField.isHidden = !OSCAContactUI.configuration.personalData.contains(.address)
    addressTextField.textContentType = .fullStreetAddress
    addressTextField.placeholder = viewModel.addressPlaceholder
    addressTextField.font = OSCAContactUI.configuration.fontConfig.bodyLight
    addressTextField.textColor = OSCAContactUI.configuration.colorConfig.textColor
    addressTextField.selectedTitleColor = OSCAContactUI.configuration.colorConfig.primaryColor
    addressTextField.errorColor = OSCAContactUI.configuration.colorConfig.errorColor
    addressTextField.clearButtonMode = .whileEditing
    addressTextField.inputAccessoryView = keyboardToolbar()
    
    postalCodeTextField.isHidden = !OSCAContactUI.configuration.personalData.contains(.postalCode)
    postalCodeTextField.textContentType = .postalCode
    postalCodeTextField.placeholder = viewModel.postalCodePlaceholder
    postalCodeTextField.font = OSCAContactUI.configuration.fontConfig.bodyLight
    postalCodeTextField.textColor = OSCAContactUI.configuration.colorConfig.textColor
    postalCodeTextField.selectedTitleColor = OSCAContactUI.configuration.colorConfig.primaryColor
    postalCodeTextField.errorColor = OSCAContactUI.configuration.colorConfig.errorColor
    postalCodeTextField.clearButtonMode = .whileEditing
    postalCodeTextField.inputAccessoryView = keyboardToolbar()
    
    cityTextField.isHidden = !OSCAContactUI.configuration.personalData.contains(.city)
    cityTextField.textContentType = .addressCity
    cityTextField.placeholder = viewModel.cityPlaceholder
    cityTextField.font = OSCAContactUI.configuration.fontConfig.bodyLight
    cityTextField.textColor = OSCAContactUI.configuration.colorConfig.textColor
    cityTextField.selectedTitleColor = OSCAContactUI.configuration.colorConfig.primaryColor
    cityTextField.errorColor = OSCAContactUI.configuration.colorConfig.errorColor
    cityTextField.clearButtonMode = .whileEditing
    cityTextField.inputAccessoryView = keyboardToolbar()
    
    phoneTextField.isHidden = !OSCAContactUI.configuration.personalData.contains(.phone)
    phoneTextField.textContentType = .telephoneNumber
    phoneTextField.placeholder = viewModel.phonePlaceholder
    phoneTextField.font = OSCAContactUI.configuration.fontConfig.bodyLight
    phoneTextField.textColor = OSCAContactUI.configuration.colorConfig.textColor
    phoneTextField.selectedTitleColor = OSCAContactUI.configuration.colorConfig.primaryColor
    phoneTextField.errorColor = OSCAContactUI.configuration.colorConfig.errorColor
    phoneTextField.clearButtonMode = .whileEditing
    phoneTextField.inputAccessoryView = keyboardToolbar()
    
    emailTextField.isHidden = !OSCAContactUI.configuration.personalData.contains(.email)
    emailTextField.textContentType = .emailAddress
    emailTextField.keyboardType = .emailAddress
    emailTextField.placeholder = viewModel.emailPlaceholder
    emailTextField.font = OSCAContactUI.configuration.fontConfig.bodyLight
    emailTextField.textColor = OSCAContactUI.configuration.colorConfig.textColor
    emailTextField.selectedTitleColor = OSCAContactUI.configuration.colorConfig.primaryColor
    emailTextField.errorColor = OSCAContactUI.configuration.colorConfig.errorColor
    emailTextField.clearButtonMode = .whileEditing
    emailTextField.inputAccessoryView = keyboardToolbar()
    
    privacyStackView.backgroundColor = OSCAContactUI.configuration.colorConfig.secondaryBackgroundColor
    privacyStackView.layer.cornerRadius = OSCAContactUI.configuration.cornerRadius
    privacyStackView.addShadow(with: OSCAContactUI.configuration.shadow)
    
    privacySwitch.onTintColor = OSCAContactUI.configuration.colorConfig.primaryColor
    
    privacyLabel.font = OSCAContactUI.configuration.fontConfig.bodyLight
    privacyLabel.textColor = OSCAContactUI.configuration.colorConfig.textColor
    privacyLabel.setTextWithLinks(
      text: viewModel.privacyConsent,
      links: viewModel.privacyConsentLinks,
      color: OSCAContactUI.configuration.colorConfig.primaryColor)
    privacyLabel.numberOfLines = 2
    
    submitButton.setTitle(viewModel.submitTitle, for: .normal)
    submitButton.titleLabel?.font = OSCAContactUI.configuration.fontConfig.bodyLight
    submitButton.setTitleColor(OSCAContactUI.configuration.colorConfig.whiteDark, for: .normal)
    submitButton.setTitleColor(OSCAContactUI.configuration.colorConfig.grayDark, for: .disabled)

    self.validateFormButton()
  }
  
  private func setupBindings() {
    viewModel.$contactType
      .receive(on: RunLoop.main)
      .sink (receiveValue: { [weak self] contactType in
        guard let title = contactType?.title else { return }
        self?.contactTypeTextField.text = title
        self?.contactTypeTextField.errorMessage = nil
        self?.validateFormButton()
      })
      .store(in: &self.bindings)
    
    viewModel.$fullName
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink (receiveValue: { [weak self] _ in
        let _ = self?.errorMessage(for: .fullName)
        self?.validateFormButton()
      })
      .store(in: &self.bindings)
    
    viewModel.$address
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink (receiveValue: { [weak self] _ in
        let _ = self?.errorMessage(for: .address)
        self?.validateFormButton()
      })
      .store(in: &self.bindings)
    
    viewModel.$postalCode
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink (receiveValue: { [weak self] _ in
        let _ = self?.errorMessage(for: .postalCode)
        self?.validateFormButton()
      })
      .store(in: &self.bindings)
    
    viewModel.$city
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink (receiveValue: { [weak self] _ in
        let _ = self?.errorMessage(for: .city)
        self?.validateFormButton()
      })
      .store(in: &self.bindings)
    
    viewModel.$phone
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink (receiveValue: { [weak self] _ in
        let _ = self?.errorMessage(for: .phone)
        self?.validateFormButton()
      })
      .store(in: &self.bindings)
    
    viewModel.$email
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink (receiveValue: { [weak self] _ in
        let _ = self?.errorMessage(for: .email)
        self?.validateFormButton()
      })
      .store(in: &self.bindings)
    
    let stateValueHandler: (OSCAContactFormViewModelState) -> Void = { [weak self] viewModelState in
      guard let `self` = self else { return }
      
      switch viewModelState {
      case .fillInForm:
        self.hideActivityIndicator()
        
      case .validating:
        var error: Int = 0
        
        if let contactTypeTitle = self.viewModel.contactType?.title,
           !contactTypeTitle.isEmpty {
          self.contactTypeTextField.errorMessage = nil
        } else {
          error += 1
          self.contactTypeTextField.errorMessage = self.viewModel.inputMessageError
        }
        
        if let note = self.noteTextView.text,
           !note.isEmpty,
           note != self.viewModel.notePlaceholder {
          self.noteTextView.textColor = OSCAContactUI.configuration.colorConfig.textColor
        } else {
          error += 1
          self.noteTextView.textColor = OSCAContactUI.configuration.colorConfig.errorColor
        }
        
        for option: PeronalData in [.fullName, .address, .postalCode, .city, .phone, .email] {
          guard OSCAContactUI.configuration.personalData.contains(option)
          else { continue }
          
          switch option {
          case .address   : error += self.errorMessage(for: .address)
          case .postalCode: error += self.errorMessage(for: .postalCode)
          case .city      : error += self.errorMessage(for: .city)
          case .phone     : error += self.errorMessage(for: .phone)
          case .email     : error += self.errorMessage(for: .email)
          default: continue
          }
        }
        
        if !self.privacySwitch.isOn {
          error += 1
          self.privacySwitch.subviews[0].subviews[0].backgroundColor = OSCAContactUI.configuration.colorConfig.errorColor
        }
        
        if error > 0 {
          self.showAlert(
            title: self.viewModel.alertTitleError,
            message: self.viewModel.alertMessageError,
            actionTitle: self.viewModel.alertActionConfirm)
        }
        
      case .sending:
        self.userInteraction(isEnabled: false)
        self.showActivityIndicator()
        
      case .finishedSending:
        self.userInteraction(isEnabled: true)
        self.hideActivityIndicator()
        
      case .loading:
        self.userInteraction(isEnabled: false)
        self.showActivityIndicator()
        
      case .finishedLoading:
        self.userInteraction(isEnabled: true)
        self.hideActivityIndicator()
        
      case .receivedResponse:
        let alertController = UIAlertController(
          title: self.viewModel.alertTitleSuccess,
          message: self.viewModel.alertMessageSuccess,
          preferredStyle: .alert)
        let alertAction = UIAlertAction(
          title: self.viewModel.alertActionConfirm,
          style: .default) { _ in
            self.viewModel.receivedResponseAlertCompletion()
          }
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
        
      case let .error(error):
        self.userInteraction(isEnabled: true)
        self.hideActivityIndicator()
        self.showAlert(
          title: self.viewModel.alertTitleError,
          error: error,
          actionTitle: self.viewModel.alertActionConfirm)
      }
    }
    
    viewModel.$state
      .receive(on: RunLoop.main)
      .sink(receiveValue: stateValueHandler)
      .store(in: &self.bindings)
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setup(
      largeTitles: true,
      tintColor: OSCAContactUI.configuration.colorConfig.navigationTintColor,
      titleTextColor: OSCAContactUI.configuration.colorConfig.navigationTitleTextColor,
      barColor: OSCAContactUI.configuration.colorConfig.navigationBarColor)
    registerForKeyboardNotifications()
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    deregisterFromKeyboardNotifications()
  }
  
  private func userInteraction(isEnabled: Bool) {
    self.view.isUserInteractionEnabled = isEnabled
    self.navigationController?.navigationBar.isUserInteractionEnabled = isEnabled
  }
  
  private func validateFormButton() {
    let isFormValid = self.viewModel.checkIsFormValid()
    self.submitButton.isEnabled = isFormValid
    
    submitButton.backgroundColor = isFormValid ? OSCAContactUI.configuration.colorConfig.primaryColor : OSCAContactUI.configuration.colorConfig.grayLight.withAlphaComponent(0.5)
    submitButton.addLimitedCornerRadius(OSCAContactUI.configuration.cornerRadius)
    submitButton.addShadow(with: OSCAContactUI.configuration.shadow)
  }
  
  private func registerForKeyboardNotifications(){
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillAppear(notification:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillDisappear(notification:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil)
  }
  
  private func deregisterFromKeyboardNotifications(){
    NotificationCenter.default.removeObserver(
      self,
      name: UIResponder.keyboardWillShowNotification,
      object: nil)
    NotificationCenter.default.removeObserver(
      self,
      name: UIResponder.keyboardWillHideNotification,
      object: nil)
  }
  
  private func keyboardToolbar() -> UIToolbar {
    let keyboardToolbar = UIToolbar()
    let doneButton = UIBarButtonItem(
      barButtonSystemItem: .done,
      target: self,
      action: #selector(keyboardDoneButtonTouch(barButton:)))
    doneButton.tintColor = OSCAContactUI.configuration.colorConfig.primaryColor
    let flexibleSpace = UIBarButtonItem(
      barButtonSystemItem: .flexibleSpace,
      target: nil,
      action: nil)
    keyboardToolbar.items = [flexibleSpace, doneButton]
    keyboardToolbar.sizeToFit()
    keyboardToolbar.layoutIfNeeded()
    return keyboardToolbar
  }
  
  private func errorMessage(for field: PeronalData) -> Int {
    switch field {
    case .fullName:
      fullNameTextField.errorMessage = viewModel.fullName.isEmpty
      ? viewModel.inputMessageError
      : nil
      return fullNameTextField.hasErrorMessage ? 1 : 0
      
    case .address:
      addressTextField.errorMessage = viewModel.address.isEmpty
      ? viewModel.inputMessageError
      : nil
      return addressTextField.hasErrorMessage ? 1 : 0
      
    case .postalCode:
      postalCodeTextField.errorMessage = viewModel.postalCode.isEmpty
      ? viewModel.inputMessageError
      : nil
      return postalCodeTextField.hasErrorMessage ? 1 : 0
      
    case .city:
      cityTextField.errorMessage = viewModel.city.isEmpty
      ? viewModel.inputMessageError
      : nil
      return cityTextField.hasErrorMessage ? 1 : 0
      
    case .phone:
      phoneTextField.errorMessage = viewModel.phone.isEmpty
      ? viewModel.inputMessageError
      : nil
      return phoneTextField.hasErrorMessage ? 1 : 0
      
    case .email:
      emailTextField.errorMessage = viewModel.email.isEmpty
      ? viewModel.inputMessageError
      : nil
      return emailTextField.hasErrorMessage ? 1 : 0
      
    default: return 0
    }
  }
  
  @objc private func keyboardDoneButtonTouch(barButton: UIBarButtonItem) {
    self.view.endEditing(true)
  }
  
  @objc private func keyboardWillAppear(notification: NSNotification) {
    self.scrollView.isScrollEnabled = true
    let info = notification.userInfo!
    let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
    var adjustedHeight = keyboardSize!.height
    if let tabbarSize = tabBarController?.tabBar.frame.size {
      adjustedHeight = keyboardSize!.height - tabbarSize.height
    }
    
    let contentInsets = UIEdgeInsets(top: 0.0,
                                     left: 0.0,
                                     bottom: adjustedHeight,
                                     right: 0.0)
    
    self.scrollView.contentInset = contentInsets
    self.scrollView.scrollIndicatorInsets = contentInsets
    
    var aRect: CGRect = self.view.frame
    aRect.size.height -= keyboardSize!.height
    if let activeField = self.activeField {
      if (!aRect.contains(activeField.frame.origin)) {
        self.scrollView.scrollRectToVisible(activeField.frame,
                                            animated: true)
      }
    } else if let activeTextView = self.activeTextView {
      let converted = activeTextView.convert(activeTextView.frame,
                                             to: self.scrollView)
      if (!aRect.contains(converted.origin)) {
        self.scrollView.scrollRectToVisible(converted,
                                            animated: true)
      }
    }
  }
  
  @objc private func keyboardWillDisappear(notification: NSNotification) {
    let contentInsets: UIEdgeInsets = .zero
    self.scrollView.contentInset = contentInsets
    self.scrollView.scrollIndicatorInsets = contentInsets
  }
  
  @objc private func showPicker(_ sender: UITapGestureRecognizer) {
    self.viewModel.textFieldShouldBeginEditing()
  }
  
  @IBAction private func tapOnMainViewTouch(_ sender: UITapGestureRecognizer) {
    self.view.endEditing(true)
  }
  
  @IBAction func textFieldsEditingChanged(_ sender: SkyFloatingLabelTextField) {
    guard let text = sender.text else { return }
    var type: PeronalData = .none
    
    switch sender {
    case fullNameTextField  : type = .fullName
    case addressTextField   : type = .address
    case postalCodeTextField: type = .postalCode
    case cityTextField      : type = .city
    case phoneTextField     : type = .phone
    case emailTextField     : type = .email
    default                 : type = .none
    }
    
    viewModel.textFieldsEditingChanged(type, text: text)
  }
  
  @IBAction func privacySwitchTouch(_ sender: UISwitch) {
    viewModel.privacySwitchTouch(isOn: sender.isOn)
    validateFormButton()
  }
  
  /// Handles the tap on "privacy policy"
  /// - Parameter gesture: the caller of the function
  @IBAction private func tapPrivacyLabel(_ gesture: UITapGestureRecognizer) {
    self.viewModel.tapPrivacyLabel()
  }
  
  /// Handles the touch of the "submit" button
  /// - Parameter sender: caller of the function
  @IBAction func submitButtonTouch(_ sender: UIButton) {
    viewModel.submitButtonTouch()
  }
}

// MARK: - instantiate view conroller
extension OSCAContactFormViewController: StoryboardInstantiable {
  public static func create(with viewModel: OSCAContactFormViewModel) -> OSCAContactFormViewController {
    let vc = Self.instantiateViewController(OSCAContactUI.bundle)
    vc.viewModel = viewModel
    return vc
  }
}

extension OSCAContactFormViewController: UITextViewDelegate {
  public func textViewDidChange(_ textView: UITextView) {
    let text = textView.text
      .trimmingCharacters(in: .whitespacesAndNewlines)
    
    viewModel.note = text.isEmpty
    ? viewModel.notePlaceholder
    : text
  }
  
  public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    activeTextView = textView
    return true
  }
  
  public func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == viewModel.notePlaceholder {
      viewModel.note = textView.text
      textView.text = ""
      textView.textColor = OSCAContactUI.configuration.colorConfig.textColor
    }
  }
  
  public func textViewDidEndEditing(_ textView: UITextView) {
    activeTextView = nil
    let text = textView.text
      .trimmingCharacters(in: .whitespacesAndNewlines)
    
    if text.isEmpty {
      viewModel.note = ""
      textView.text = viewModel.notePlaceholder
      textView.textColor = OSCAContactUI.configuration.colorConfig.whiteDarker
    }
  }
}

extension OSCAContactFormViewController: UITextFieldDelegate {
  public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if textField == contactTypeTextField {
      self.view.endEditing(true)
      viewModel.textFieldShouldBeginEditing()
      return false
    } else {
      return true
    }
  }
}
