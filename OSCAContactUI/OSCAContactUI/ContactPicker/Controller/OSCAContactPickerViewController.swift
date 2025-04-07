//
//  OSCAContactPickerViewController.swift
//  OSCAContactUI
//
//  Created by Ömer Kurutay on 29.08.22.
//

import OSCAEssentials
import UIKit
import Combine

public final class OSCAContactPickerViewController: UIViewController, ActivityIndicatable, Alertable {
  
  @IBOutlet private var dismissView: UIView!
  @IBOutlet private var contentView: UIView!
  @IBOutlet private var cancelButton: UIButton!
  @IBOutlet private var confirmButton: UIButton!
  @IBOutlet private var pickerView: UIPickerView!
  
  public lazy var activityIndicatorView = ActivityIndicatorView(style: .large)
  
  private var viewModel: OSCAContactPickerViewModel!
  private var bindings = Set<AnyCancellable>()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    setupBindings()
    viewModel.viewDidLoad()
  }
  
  private func setupViews() {
    pickerView.delegate = self
    pickerView.dataSource = self
    
    self.view.backgroundColor = .clear
    
    self.contentView.backgroundColor = OSCAContactUI.configuration.colorConfig.backgroundColor
    contentView.addSubview(activityIndicatorView)
    activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      activityIndicatorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      activityIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      activityIndicatorView.heightAnchor.constraint(equalToConstant: 100.0),
      activityIndicatorView.widthAnchor.constraint(equalToConstant: 100.0),
    ])
    
    dismissView.backgroundColor = .clear
    
    cancelButton.setTitle(viewModel.cancelTitle,
                          for: .normal)
    cancelButton.titleLabel?.font = OSCAContactUI.configuration.fontConfig.subheaderLight
    cancelButton.setTitleColor(
      OSCAContactUI.configuration.colorConfig.primaryColor,
      for: .normal)
    
    confirmButton.setTitle(viewModel.confirmTitle,
                           for: .normal)
    confirmButton.titleLabel?.font = OSCAContactUI.configuration.fontConfig.subheaderLight
    confirmButton.setTitleColor(
      OSCAContactUI.configuration.colorConfig.primaryColor,
      for: .normal)
    confirmButton.setTitleColor(
      OSCAContactUI.configuration.colorConfig.primaryColor.withAlphaComponent(0.25),
      for: .disabled)
    confirmButton.isEnabled = false
  }
  
  private func setupBindings() {
    let viewStateError: (OSCAContactPickerViewModelError) -> Void = { [weak self] error in
      guard let `self` = self else { return }
      
      switch error {
      case .contactFormContactFetch:
          self.showAlert(
          title: self.viewModel.alertTitleError,
          error: error,
          preferredStyle: .alert)
        
      case .contactPicking:
        self.viewModel.closePicker()
      }
    }
    
    let stateValueHandler: (OSCAContactPickerViewModelState) -> Void = { [weak self] viewModelState in
      guard let `self` = self else { return }
      
      switch viewModelState {
      case .loading:
        self.confirmButton.isEnabled = false
        self.showActivityIndicator()
        
      case .finishedLoading:
        self.hideActivityIndicator()
        
      case .selected:
        self.confirmButton.isEnabled = true
        
      case let .error(error):
        viewStateError(error)
      }
    }
    
    viewModel.$state
      .receive(on: RunLoop.main)
      .sink(receiveValue: stateValueHandler)
      .store(in: &self.bindings)
    
    viewModel.$contactFormContacts
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] _ in
        self?.pickerView.reloadAllComponents()
      })
      .store(in: &self.bindings)
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    contentView.roundCorners(
      corners: [.topLeft, .topRight],
      radius: OSCAContactUI.configuration.cornerRadius)
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UINotificationFeedbackGenerator().notificationOccurred(.warning)
    viewModel.viewDidAppear()
  }
  
  @IBAction func tapOnDismissViewTouch(_ sender: UITapGestureRecognizer) {
    viewModel.tapOnMainViewTouch()
  }
  
  @IBAction func cancelButtonTouch(_ sender: UIButton) {
    viewModel.cancelButtonTouch()
  }
  
  @IBAction func confirmButtonTouch(_ sender: UIButton) {
    viewModel.confirmButtonTouch()
  }
}

// MARK: - instantiate view controller
extension OSCAContactPickerViewController: StoryboardInstantiable {
  public static func create(with viewModel: OSCAContactPickerViewModel) -> OSCAContactPickerViewController {
    let vc: Self = Self.instantiateViewController(OSCAContactUI.bundle)
    vc.viewModel = viewModel
    return vc
  }
}

extension OSCAContactPickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  public func numberOfComponents(in _: UIPickerView) -> Int {
    viewModel.numberOfComponents
  }
  
  public func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
    viewModel.numberOfItemsInComponent
  }
  
  public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    let pickerLabel = UILabel()
    pickerLabel.text = viewModel.contactFormContacts[row].title
    pickerLabel.font = OSCAContactUI.configuration.fontConfig.bodyLight
    pickerLabel.textColor = OSCAContactUI.configuration.colorConfig.textColor
    pickerLabel.textAlignment = .center
    
    return pickerLabel
  }
  
  public func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
    viewModel.didSelectItem(at: row)
  }
}
