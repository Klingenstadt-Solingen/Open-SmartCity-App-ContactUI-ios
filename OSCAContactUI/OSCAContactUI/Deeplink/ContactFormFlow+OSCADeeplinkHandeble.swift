//
//  ContactFormFlow+OSCADeeplinkHandeble.swift
//  OSCAContactUI
//
//  Created by Stephan Breidenbach on 08.09.22.
//

import Foundation
import OSCAEssentials

extension OSCAContactFormFlowCoordinator: OSCADeeplinkHandeble {
  ///```console
  ///xcrun simctl openurl booted \
  /// "solingen://contact/"
  /// ```
  public func canOpenURL(_ url: URL) -> Bool {
    let deeplinkScheme: String = dependencies
      .deeplinkScheme
    return url.absoluteString.hasPrefix("\(deeplinkScheme)://contact")
  }// end public func canOpenURL
  
  public func openURL(_ url: URL,
                      onDismissed:(() -> Void)?) throws -> Void {
#if DEBUG
    print("\(String(describing: self)): \(#function): url: \(url.absoluteString)")
#endif
    guard canOpenURL(url)
    else { return }
    showContactForm(animated: true,
                    onDismissed: onDismissed)
  }// end public func openURL
}// end extension final class OSCAContactFormFlowCoordinator
