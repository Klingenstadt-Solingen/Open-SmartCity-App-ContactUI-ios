//
//  OSCAContactUILocalizationTests.swift
//  OSCAContactUITests
//
//  Created by Stephan Breidenbach on 31.01.22.
//  Reviewed by Stephan Breidenbach on 21.06.2022
//
#if canImport(XCTest) && canImport(OSCATestCaseExtension)
import Foundation
import XCTest
@testable import OSCAContactUI
import OSCAContact
import OSCATestCaseExtension
import OSCAEssentials

final class OSCAContactUILocalizationTests: XCTestCase {
  
  override func setUpWithError() throws -> Void {
    try super.setUpWithError()
    
  }// end override func setupWithError
  
  func testLocalizationDE() throws -> Void {
    let _ = try makeUIModule()
    let uiBundle = OSCAContactUI.bundle
    XCTAssertNotNil(uiBundle)
    let path = uiBundle!.path(forResource: "de", ofType: "lproj")
    XCTAssertNotNil(path)
    let bundle = Bundle(path: path!)
    XCTAssertNotNil(bundle)
    checkLocalization(with: bundle!)
  }// end func testLocalizationDE
  
  func testLocalizationEN() throws -> Void {
    let _ = try makeUIModule()
    let uiBundle = OSCAContactUI.bundle
    let path = uiBundle!.path(forResource: "en", ofType: "lproj")
    XCTAssertNotNil(path)
    let bundle = Bundle(path: path!)
    XCTAssertNotNil(bundle)
    checkLocalization(with: bundle!)
  }// end func testLocalizationEN
  
  private func checkLocalization(with bundle: Bundle) -> Void{
    // contact form title
    let contactFormTitle = NSLocalizedString("contact_form_title", tableName: nil, bundle: bundle, value: "NIL", comment: "contact form title")
    XCTAssertTrue(contactFormTitle != "NIL", "The contact form title doesn't exist!")
    // contact form info text
    let contactFormInfoText = NSLocalizedString("contact_form_info_text", tableName: nil, bundle: bundle, value: "NIL",  comment: "contact form info text")
    XCTAssertTrue(contactFormInfoText != "NIL", "The contact form info text doesn't exist!")
    // contact form name input field info text
    let contactFormNameInputFieldInfoText = NSLocalizedString("contact_form_name_input_field_info_text", tableName: nil, bundle: bundle, value: "NIL",  comment: "contact form name input field info text")
    XCTAssertTrue(contactFormNameInputFieldInfoText != "NIL", "The contact form name input field info text doesn't exist!")
    // contact form email address input field info text
    let contactFormEmailAddressInputFieldInfoText = NSLocalizedString("contact_form_email_address_input_field_info_text", tableName: nil, bundle: bundle, value: "NIL",  comment: "contact form email address input field info text")
    XCTAssertTrue(contactFormEmailAddressInputFieldInfoText != "NIL", "The contact form email address input field info text doesn't exist!")
    // contact form subject picker info text
    let contactFormSubjectPickerInfoText = NSLocalizedString("contact_form_subject_picker_info_text", tableName: nil, bundle: bundle, value: "NIL",  comment: "contact form subject picker info text")
    XCTAssertTrue(contactFormSubjectPickerInfoText != "NIL", "The contact form subject picker info text doesn't exist!")
    // contact form message input field info text
    let contactFormMessageInputFieldInfoText = NSLocalizedString("contact_form_message_input_field_info_text", tableName: nil, bundle: bundle, value: "NIL",  comment: "contact form message input field info text")
    XCTAssertTrue(contactFormMessageInputFieldInfoText != "NIL", "The contact form message input field info text doesn't exist!")
    // contact form accept data privacy switch info text
    let contactFormAcceptDataPrivacySwitchInfoText = NSLocalizedString("contact_form_accept_data_privacy_switch_info_text", tableName: nil, bundle: bundle, value: "NIL",  comment: "contact form accept data privacy switch info text")
    XCTAssertTrue(contactFormAcceptDataPrivacySwitchInfoText != "NIL", "The contact form accept data privacy switch info text doesn't exist!")
    // contact form accept data privacy switch link text in info text
    let contactFormAcceptDataPrivacySwitchLinkTextInInfoText = NSLocalizedString("contact_form_accept_data_privacy_siwtch_link_text_in_info_text", tableName: nil, bundle: bundle, value: "NIL", comment: " contact form accept data privacy switch link text in info text")
    XCTAssertTrue(contactFormAcceptDataPrivacySwitchLinkTextInInfoText != "NIL", "The contact form accept data privacy switch link text in info text doesn't exist!")
    // contact form send button text
    let contactFormSendButtonText = NSLocalizedString("contact_form_send_button_title", tableName: nil, bundle: bundle, value: "NIL",  comment: "contact form send button text")
    XCTAssertTrue(contactFormSendButtonText != "NIL", "The contact form send button text doesn't exist!")
    // contact form submit message info text
    let contactFormSubmitMessageInfoText = NSLocalizedString("contact_form_submit_message_info_text", tableName: nil, bundle: bundle, value: "NIL", comment: "contact form submit message info text")
    XCTAssertTrue(contactFormSubmitMessageInfoText != "NIL", "The contact form submit message info text doesn't exist!")
    // contact form submit alert info text
    let contactFormSubmitAlertInfoText = NSLocalizedString("contact_form_submit_alert_info_text", tableName: nil, bundle: bundle, value: "NIL", comment: "contact form submit alert info text")
    XCTAssertTrue(contactFormSubmitAlertInfoText != "NIL", "The contact form submit alert info text doesn't exist!")
    // contact form submit alert message
    let contactFormSubmitAlertMessage = NSLocalizedString("contact_form_submit_alert_message", tableName: nil, bundle: bundle, value: "NIl", comment: "contact form submit alert message")
    XCTAssertTrue(contactFormSubmitAlertMessage != "NIL", "The contact form submit alert message doesn't exist!")
    // contact form submit alert action confirm info text
    let contactformSubmitAlertActionConfirmInfoText = NSLocalizedString("contact_form_submit_alert_action_confirm_info_text", tableName: nil, bundle: bundle, value: "NIl", comment: "contact form submit alert action confirm info text")
    XCTAssertTrue(contactformSubmitAlertActionConfirmInfoText != "NIL", "The contact form submit alert action confirm info text doesn't exist!")
    // contact form submit alert error info text
    let contactFormSubmitAlertErrorInfoText = NSLocalizedString("contact_form_submit_alert_error_info_text", tableName: nil, bundle: bundle, value: "NIl", comment: "Contact form submit alert error info text")
    XCTAssertTrue(contactFormSubmitAlertErrorInfoText != "NIL", "The ontact form submit alert error info text doesn't exist!")
    // contact form submit alert error message
    let contactFormSubmitAlertErrorMessage = NSLocalizedString("contact_form_submit_alert_error_message", tableName: nil, bundle: bundle, value: "NIl", comment: "contact form submit alert error message")
    XCTAssertTrue(contactFormSubmitAlertErrorMessage != "NIL", "The contact form submit alert error message doesn't exist!")
    // contact form submit alert error action confirm info text
    let contactFormSubmitAlertErrorActionConfirmInfoText = NSLocalizedString("contact_form_submit_alert_error_action_confirm_info_text", tableName: nil, bundle: bundle, value: "NIl", comment: "contact form submit alert error action confirm info text")
    XCTAssertTrue(contactFormSubmitAlertErrorActionConfirmInfoText != "NIL", "The contact form submit alert error action confirm info text doesn't exist!")
    // contact form alert error info text
    let contactFormAlertErrorInfoText = NSLocalizedString("contact_form_alert_error_info_text", tableName: nil, bundle: bundle, value: "NIl", comment: "contact form alert error info text")
    XCTAssertTrue(contactFormAlertErrorInfoText != "NIL", "The contact form alert error info text doesn't exist!")
    // contact form name input field invalid input text
    let contactFormNameInputFieldInvalidInputText = NSLocalizedString("contact_form_name_input_field_invalid_input_text", tableName: nil, bundle: bundle, value: "NIl", comment: "contact form name input field invalid input text")
    XCTAssertTrue(contactFormNameInputFieldInvalidInputText != "NIL", "The contact form name input field invalid input text doesn't exist!")
    // contaoct form email address input field invalid input text
    let contactFormEmailAddressInputFieldInvalidInputText = NSLocalizedString("contact_form_email_address_input_field_invalid_input_text", tableName: nil, bundle: bundle, value: "NIl", comment: "contaoct form email address input field invalid input text")
    XCTAssertTrue(contactFormEmailAddressInputFieldInvalidInputText != "NIL", "The contaoct form email address input field invalid input text doesn't exist!")
    // contact form subject input field invalid input text
    let contactFormSubjectInputFieldInvalidInputText = NSLocalizedString("contact_form_subject_input_field_invalid_input_text", tableName: nil, bundle: bundle, value: "NIl", comment: "contact form subject input field invalid input text")
    XCTAssertTrue(contactFormSubjectInputFieldInvalidInputText != "NIL", "The contact form subject input field invalid input text doesn't exist!")
    // contact picker dismissed button title
    let contactPickerDismissedButtonTitle = NSLocalizedString("contact_picker_dismissed_button_title", tableName: nil, bundle: bundle, value: "NIl", comment: "contact picker dismissed button title")
    XCTAssertTrue(contactPickerDismissedButtonTitle != "NIl", "The contact picker dismissed button title doesn't exist")
    // contact picker confirm button title
    let contactPickerConfirmButtonTitle = NSLocalizedString("contact_picker_confirm_button_title", tableName: nil, bundle: bundle, value: "NIl", comment: "contact picker confirm button title")
    XCTAssertTrue(contactPickerConfirmButtonTitle != "NIl", "The contact picker confirm button title doesn't exist")
  }// end private func checkLocalization with bundle
}// end final class OSCAContactUILocalizationTests: XCTestCase

extension OSCAContactUILocalizationTests {
  public func makeUIModuleTests() throws -> OSCAContactUITests {
    return OSCAContactUITests()
  }// end public func makeUIModuleTests
  
  public func makeUIModule() throws -> OSCAContactUI {
    let uiModuleTests = try makeUIModuleTests()
    let uiModule = try uiModuleTests.makeDevUIModule()
    return uiModule
  }// end public func makeUIModule
}// end extension final class OSCAContactUILocalizationTests
#endif
