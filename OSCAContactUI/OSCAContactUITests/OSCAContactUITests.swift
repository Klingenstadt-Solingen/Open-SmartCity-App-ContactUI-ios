// Reviewed by Stephan Breidenbach on 21.06.2022
// Reviewed by Stephan Breidenbach on 08.07.22

#if canImport(XCTest) && canImport(OSCATestCaseExtension)
import XCTest
@testable import OSCAContactUI
import OSCAEssentials
import OSCATestCaseExtension
@testable import OSCAContact

final class OSCAContactUITests: XCTestCase {
  static let moduleVersion = "1.0.3"
  override func setUpWithError() throws -> Void {
    try super.setUpWithError()
  }// end override func setupWithError
  
  func testModuleInit() throws -> Void {
    let uiModule = try makeDevUIModule()
    XCTAssertNotNil(uiModule)
    XCTAssertEqual(uiModule.version, OSCAContactUITests.moduleVersion)
    XCTAssertEqual(uiModule.bundlePrefix, "de.osca.contact.ui")
    let bundle = OSCAContact.bundle
    XCTAssertNotNil(bundle)
    let uiBundle = OSCAContactUI.bundle
    XCTAssertNotNil(uiBundle)
    let configuration = OSCAContactUI.configuration
    XCTAssertNotNil(configuration)
  }// end func testModuleInit
  
  func testContactUIConfiguration() throws -> Void {
    let _ = try makeDevUIModule()
    let uiModuleConfig = try makeUIModuleConfig()
    XCTAssertEqual(OSCAContactUI.configuration.title, uiModuleConfig.title)
    XCTAssertEqual(OSCAContactUI.configuration.colorConfig.accentColor, uiModuleConfig.colorConfig.accentColor)
    XCTAssertEqual(OSCAContactUI.configuration.fontConfig.bodyHeavy, uiModuleConfig.fontConfig.bodyHeavy)
  }// end func testEventsUIConfiguration
}// end final class OSCAContactUITests

// MARK: - factory methods
extension OSCAContactUITests {
  public func makeDevModuleDependencies() throws -> OSCAContactDependencies {
    let networkService = try makeDevNetworkService()
    let userDefaults   = try makeUserDefaults(domainString: "de.osca.contact.ui")
    let deeplinkScheme = try makeDevDeeplinkScheme()
    let dependencies = OSCAContactDependencies(
      networkService: networkService,
      userDefaults: userDefaults,
      deeplinkScheme: deeplinkScheme
    )// end dependencies
    return dependencies
  }// end public func makeDevModuleDependencies
  
  public func makeDevModule() throws -> OSCAContact {
    let devDependencies = try makeDevModuleDependencies()
    // initialize module
    let module = OSCAContact.create(with: devDependencies)
    return module
  }// end public func makeDevModule
  
  public func makeProductionModuleDependencies() throws -> OSCAContactDependencies {
    let networkService = try makeProductionNetworkService()
    let userDefaults   = try makeUserDefaults(domainString: "de.osca.contact.ui")
    let deeplinkScheme = try makeProductionDeeplinkScheme()
    let dependencies = OSCAContactDependencies(
      networkService: networkService,
      userDefaults: userDefaults,
      deeplinkScheme: deeplinkScheme
    )// end dependencies
    return dependencies
  }// end public func makeProductionModuleDependencies
  
  public func makeProductionModule() throws -> OSCAContact {
    let productionDependencies = try makeProductionModuleDependencies()
    // initialize module
    let module = OSCAContact.create(with: productionDependencies)
    return module
  }// end public func makeProductionModule
  
  public func makeUIModuleConfig() throws -> OSCAContactUIConfig {
    return OSCAContactUIConfig(title: "OSCAContactUI",
                               shadow: OSCAShadowSettings(opacity: 0.3,
                                                          radius: 10,
                                                          offset: CGSize(width: 0, height: 2)),
                              fontConfig: OSCAFontSettings(),
                               colorConfig: OSCAColorSettings())
  }// end public func makeUIModuleConfig
  
  public func makeDevUIModuleDependencies() throws -> OSCAContactUIDependencies {
    let module      = try makeDevModule()
    let uiConfig    = try makeUIModuleConfig()
    return OSCAContactUIDependencies(moduleConfig: uiConfig,
                                    dataModule: module)
  }// end public func makeDevUIModuleDependencies
  
  public func makeDevUIModule() throws -> OSCAContactUI {
    let devDependencies = try makeDevUIModuleDependencies()
    // init ui module
    let uiModule = OSCAContactUI.create(with: devDependencies)
    return uiModule
  }// end public func makeUIModule
  
  public func makeProductionUIModuleDependencies() throws -> OSCAContactUIDependencies {
    let module      = try makeProductionModule()
    let uiConfig    = try makeUIModuleConfig()
    return OSCAContactUIDependencies(moduleConfig: uiConfig,
                                    dataModule: module)
  }// end public func makeProductionUIModuleDependencies
  
  public func makeProductionUIModule() throws -> OSCAContactUI {
    let productionDependencies = try makeProductionUIModuleDependencies()
    // init ui module
    let uiModule = OSCAContactUI.create(with: productionDependencies)
    return uiModule
  }// end public func makeProductionUIModule
}// end extension OSCAContactUITests
#endif
