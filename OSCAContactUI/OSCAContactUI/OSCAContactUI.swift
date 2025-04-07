//
//  OSCAContactUI.swift
//  OSCAContactUI
//
//  Created by Stephan Breidenbach on 01.02.22.
//

import OSCAEssentials
import UIKit
import OSCAContact

public protocol OSCAContactUIModuleConfig: OSCAUIModuleConfig {
  var personalData: PeronalData { get set }
  var cornerRadius: Double { get set }
  var shadow: OSCAShadowSettings { get set }
  var fontConfig: OSCAFontConfig { get set }
  var colorConfig: OSCAColorConfig { get set }
  var deeplinkScheme: String { get set }
}// end public protocol OSCAContactUIModuleConfig

public struct OSCAContactUIDependencies {
  let moduleConfig: OSCAContactUIConfig
  let dataModule: OSCAContact
  let analyticsModule: OSCAAnalyticsModule?
  
  public init( moduleConfig   : OSCAContactUIConfig,
               dataModule     : OSCAContact,
               analyticsModule: OSCAAnalyticsModule? = nil
  ) {
    self.moduleConfig    = moduleConfig
    self.dataModule      = dataModule
    self.analyticsModule = analyticsModule
  }// end public memberwise init
}// end public struct OSCAContactUIDependencies

/// The configuration of th `OSCAContactUI` module
public struct OSCAContactUIConfig: OSCAContactUIModuleConfig {
  /// module title
  public var title: String?
  public var externalBundle: Bundle?
  public var personalData: PeronalData
  public var cornerRadius: Double
  public var shadow: OSCAShadowSettings
  public var fontConfig: OSCAFontConfig
  public var colorConfig: OSCAColorConfig
  /// app deeplink scheme URL part before `://`
  public var deeplinkScheme      : String = "solingen"
  
  public init(title: String?,
              externalBundle: Bundle? = nil,
              personalData: PeronalData = .all,
              cornerRadius: Double = 10.0,
              shadow: OSCAShadowSettings,
              fontConfig: OSCAFontConfig,
              colorConfig: OSCAColorConfig,
              deeplinkScheme: String = "solingen") {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    self.title = title
    self.externalBundle = externalBundle
    self.personalData = personalData
    self.cornerRadius = cornerRadius
    self.shadow = shadow
    self.fontConfig = fontConfig
    self.colorConfig = colorConfig
    self.deeplinkScheme = deeplinkScheme
  }// end public memberwise init
}// end public struct OSCAContactUIConfig

/// OSCAContactUI module
public struct OSCAContactUI: OSCAModule {
  /// module DI container
  private var moduleDIContainer: OSCAContactUIDIContainer!
  /// version of the module
  public var version: String = "1.0.3"
  /// bundle prefix of the module
  public var bundlePrefix: String = "de.osca.contact.ui"
  ///  module configuration
  public internal(set) static var configuration: OSCAContactUIConfig!
  /// module `Bundle`
  ///
  /// **available after module initialization only!!!**
  public internal(set) static var bundle: Bundle!
  
  /**
   create module and inject module dependencies
   - Parameter mduleDependencies: module dependencies
   */
  public static func create(with moduleDependencies: OSCAContactUIDependencies) -> OSCAContactUI {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    var module: Self = Self.init(with: moduleDependencies.moduleConfig)
    module.moduleDIContainer = OSCAContactUIDIContainer(dependencies: moduleDependencies)
    return module
  }// end public static func create with module dependencies
  
  /// public initializer with module configuration
  /// - Parameter config: module configuration
  public init(with config: OSCAUIModuleConfig) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
#if SWIFT_PACKAGE
    Self.bundle = Bundle.module
#else
    guard let bundle: Bundle = Bundle(identifier: self.bundlePrefix) else { fatalError("Module bundle not initialized!") }
    Self.bundle = bundle
#endif
    guard let extendedConfig = config as? OSCAContactUIConfig
    else {
      fatalError("Config couldn't be initialized")
    }// end guard
    OSCAContactUI.configuration = extendedConfig
  }// end public init with config
}// end public struct OSCAContactUI

// MARK: - public ui module interface
extension OSCAContactUI {
  /// public getter of `OSCAContactFormFlowCoordinator`
  /// - Parameter router: router needed for the navigation graph
  /// - Returns: `Coordinator`
  public func getOSCAContactFormFlowCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let flow = self.moduleDIContainer.makeOSCAContactFormFlowCoordinator(router: router)
    return flow
  }// end public func getOSCAContactFormFLowCoordinator
}// end public struct OSCAContactUI
