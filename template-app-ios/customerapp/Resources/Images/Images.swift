// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Images {
  internal enum Background {
    internal static let background = ImageAsset(name: "Background/background")
  }
  internal enum Button {
    internal static let clear = ImageAsset(name: "Button/clear")
    internal static let close = ImageAsset(name: "Button/close")
    internal static let closeCircular = ImageAsset(name: "Button/close_circular")
  }
  internal enum Common {
    internal static let brand = ImageAsset(name: "Common/brand")
  }
  internal enum Navigation {
    internal static let shadow = ImageAsset(name: "Navigation/shadow")
  }
  internal enum Splash {
    internal static let background = ImageAsset(name: "Splash/background")
  }
  internal enum TabBar {
    internal static let background = ImageAsset(name: "TabBar/background")
    internal static let dashboardSelected = ImageAsset(name: "TabBar/dashboard.selected")
    internal static let entitiesSelected = ImageAsset(name: "TabBar/entities.selected")
    internal static let featureSelected = ImageAsset(name: "TabBar/feature.selected")
    internal static let moreSelected = ImageAsset(name: "TabBar/more.selected")
    internal static let searchSelected = ImageAsset(name: "TabBar/search.selected")
  }
  internal enum TextField {
    internal static let iconPasswordEyeActive = ImageAsset(name: "TextField/icon.password.eye.active")
    internal static let iconPasswordEyeDeactive = ImageAsset(name: "TextField/icon.password.eye.deactive")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
