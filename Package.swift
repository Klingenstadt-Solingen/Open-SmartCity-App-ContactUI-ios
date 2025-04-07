// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
/// use local package path
let packageLocal: Bool = false

let oscaEssentialsVersion = Version("1.1.0")
let oscaNetworkServiceVersion = Version("1.1.0")
let oscaTestCaseExtensionVersion = Version("1.1.0")
let oscaContactVersion = Version("1.1.0")
let skyFloatingLabelTextFieldVersion = Version("3.8.0")

let package = Package(
  name: "OSCAContactUI",
  defaultLocalization: "de",
  platforms: [.iOS(.v13)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "OSCAContactUI",
      targets: ["OSCAContactUI"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    // OSCAEssentials
    packageLocal ? .package(path: "../OSCAEssentials") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscaessentials-ios.git",
             .upToNextMajor(from: oscaEssentialsVersion)),
    // OSCAContact
    packageLocal ? .package(path: "../OSCAContact") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscacontact-ios.git",
             .upToNextMajor(from: oscaContactVersion)),
    
    // OSCATestCaseExtension
    packageLocal ? .package(path: "../OSCATestCaseExtension") :
    .package(url: "https://git-dev.solingen.de/smartcityapp/modules/oscatestcaseextension-ios.git",
             .upToNextMajor(from: oscaTestCaseExtensionVersion)),
    // SkyFloatingLabelTextField
    .package(url: "https://github.com/Skyscanner/SkyFloatingLabelTextField.git",
             exact: skyFloatingLabelTextFieldVersion),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "OSCAContactUI",
      dependencies: [ /* OSCAEssentials */
                      .product(name: "OSCAEssentials",
                               package: packageLocal ? "OSCAEssentials" : "oscaessentials-ios"),
                      .product(name: "OSCAContact",
                               package: packageLocal ? "OSCAContact" : "oscacontact-ios"),
                      .product(name: "SkyFloatingLabelTextField",
                               package: "SkyFloatingLabelTextField")],
      path: "OSCAContactUI/OSCAContactUI",
      exclude:["Info.plist",
               "SupportingFiles"],
      resources: [.process("Resources")]),
    .testTarget(
      name: "OSCAContactUITests",
      dependencies: ["OSCAContactUI",
                     .product(name: "OSCATestCaseExtension",
                              package: packageLocal ? "OSCATestCaseExtension" : "oscatestcaseextension-ios")],
      path: "OSCAContactUI/OSCAContactUITests",
      exclude:["Info.plist"],
      resources: [.process("Resources")]),
  ]
)
