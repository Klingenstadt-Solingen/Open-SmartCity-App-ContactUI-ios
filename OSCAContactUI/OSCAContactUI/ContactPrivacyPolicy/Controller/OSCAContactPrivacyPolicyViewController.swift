//
//  OSCAContactPrivacyPolicyViewController.swift
//  OSCAContactUI
//
//  Created by Ömer Kurutay on 26.08.22.
//

import OSCAEssentials
import UIKit

public final class OSCAContactPrivacyPolicyViewController: UIViewController {
  
  @IBOutlet private var privacyTextContainer: UIView!
  @IBOutlet private var privacyTextView: UITextView!
  @IBOutlet private var textViewHeight: NSLayoutConstraint!
  
  private var viewModel: OSCAContactPrivacyPolicyViewModel!
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    viewModel.viewDidLoad()
  }
  
  private func setupViews() {
    self.navigationItem.title = self.viewModel.screenTitle
    
    self.view.backgroundColor = OSCAContactUI.configuration.colorConfig.backgroundColor
    
    self.privacyTextContainer.backgroundColor = .clear
    
    privacyTextView.isScrollEnabled = false
    privacyTextView.textContainerInset = .zero
    privacyTextView.textContainer.lineFragmentPadding = 0
    
    let size = OSCAContactUI.configuration.fontConfig.bodyLight.pointSize
    let fontSize = "\(size)"
    let css = "<style> body {font-stretch: normal; font-size: \(fontSize)px; line-height: normal; font-family: 'Helvetica Neue'} </style>"
    let htmlString = "\(css)\(self.viewModel.privacyPolicy)"
    guard let attrString = try? NSMutableAttributedString(
      HTMLString: htmlString,
      color: OSCAContactUI.configuration.colorConfig.textColor)
    else { return }
    
    privacyTextView.attributedText = attrString
    privacyTextView.linkTextAttributes = [.foregroundColor: OSCAContactUI.configuration.colorConfig.primaryColor]
    
    textViewHeight.constant = privacyTextView.sizeThatFits(privacyTextView.frame.size).height
    
    view.layoutIfNeeded()
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    textViewHeight.constant = privacyTextView.sizeThatFits(privacyTextView.frame.size).height
    view.layoutIfNeeded()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setup(
      largeTitles: true,
      tintColor: OSCAContactUI.configuration.colorConfig.navigationTintColor,
      titleTextColor: OSCAContactUI.configuration.colorConfig.navigationTitleTextColor,
      barColor: OSCAContactUI.configuration.colorConfig.navigationBarColor)
  }
}

// MARK: - instantiate view controller
extension OSCAContactPrivacyPolicyViewController: StoryboardInstantiable {
  public static func create(with viewModel: OSCAContactPrivacyPolicyViewModel) -> OSCAContactPrivacyPolicyViewController {
    let vc: Self = Self.instantiateViewController(OSCAContactUI.bundle)
    vc.viewModel = viewModel
    return vc
  }
}
