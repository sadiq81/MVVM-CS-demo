// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Colors {
  internal enum Background {
    internal static let attention = ColorAsset(name: "Background/attention")
    internal static let brandSubtle = ColorAsset(name: "Background/brand-subtle")
    internal static let brand = ColorAsset(name: "Background/brand")
    internal static let danger = ColorAsset(name: "Background/danger")
    internal static let dark = ColorAsset(name: "Background/dark")
    internal static let `default` = ColorAsset(name: "Background/default")
    internal static let interactive = ColorAsset(name: "Background/interactive")
    internal static let neutralStrong = ColorAsset(name: "Background/neutral-strong")
    internal static let neutralSubtle = ColorAsset(name: "Background/neutral-subtle")
    internal static let neutral = ColorAsset(name: "Background/neutral")
    internal static let overlay = ColorAsset(name: "Background/overlay")
    internal static let success = ColorAsset(name: "Background/success")
    internal static let surfacePress = ColorAsset(name: "Background/surface-press")
    internal static let surface = ColorAsset(name: "Background/surface")
  }
  internal enum Border {
    internal static let brand = ColorAsset(name: "Border/brand")
    internal static let danger = ColorAsset(name: "Border/danger")
    internal static let `default` = ColorAsset(name: "Border/default")
    internal static let interactiveStrong = ColorAsset(name: "Border/interactive-strong")
    internal static let interactive = ColorAsset(name: "Border/interactive")
    internal static let inverse = ColorAsset(name: "Border/inverse")
    internal static let strong = ColorAsset(name: "Border/strong")
  }
  internal enum Component {
    internal enum Button {
      internal enum Link {
        internal enum Foreground {
          internal static let `default` = ColorAsset(name: "Component/Button/Link/Foreground/default")
          internal static let disabled = ColorAsset(name: "Component/Button/Link/Foreground/disabled")
          internal static let press = ColorAsset(name: "Component/Button/Link/Foreground/press")
        }
      }
      internal enum Primary {
        internal enum Background {
          internal static let `default` = ColorAsset(name: "Component/Button/Primary/Background/default")
          internal static let disabled = ColorAsset(name: "Component/Button/Primary/Background/disabled")
          internal static let press = ColorAsset(name: "Component/Button/Primary/Background/press")
        }
        internal enum Foreground {
          internal static let `default` = ColorAsset(name: "Component/Button/Primary/Foreground/default")
          internal static let disabled = ColorAsset(name: "Component/Button/Primary/Foreground/disabled")
          internal static let press = ColorAsset(name: "Component/Button/Primary/Foreground/press")
        }
      }
      internal enum Secondary {
        internal enum Background {
          internal static let `default` = ColorAsset(name: "Component/Button/Secondary/Background/default")
          internal static let disabled = ColorAsset(name: "Component/Button/Secondary/Background/disabled")
          internal static let press = ColorAsset(name: "Component/Button/Secondary/Background/press")
        }
        internal enum Foreground {
          internal static let `default` = ColorAsset(name: "Component/Button/Secondary/Foreground/default")
          internal static let disabled = ColorAsset(name: "Component/Button/Secondary/Foreground/disabled")
          internal static let press = ColorAsset(name: "Component/Button/Secondary/Foreground/press")
        }
      }
      internal enum Tertiary {
        internal enum Background {
          internal static let `default` = ColorAsset(name: "Component/Button/Tertiary/Background/default")
          internal static let disabled = ColorAsset(name: "Component/Button/Tertiary/Background/disabled")
          internal static let press = ColorAsset(name: "Component/Button/Tertiary/Background/press")
        }
        internal enum Foreground {
          internal static let `default` = ColorAsset(name: "Component/Button/Tertiary/Foreground/default")
          internal static let disabled = ColorAsset(name: "Component/Button/Tertiary/Foreground/disabled")
          internal static let press = ColorAsset(name: "Component/Button/Tertiary/Foreground/press")
        }
      }
    }
  }
  internal enum Foreground {
    internal static let attention = ColorAsset(name: "Foreground/attention")
    internal static let brand = ColorAsset(name: "Foreground/brand")
    internal static let danger = ColorAsset(name: "Foreground/danger")
    internal static let `default` = ColorAsset(name: "Foreground/default")
    internal static let lightMuted = ColorAsset(name: "Foreground/light-muted")
    internal static let light = ColorAsset(name: "Foreground/light")
    internal static let link = ColorAsset(name: "Foreground/link")
    internal static let muted = ColorAsset(name: "Foreground/muted")
    internal static let placeholder = ColorAsset(name: "Foreground/placeholder")
    internal static let success = ColorAsset(name: "Foreground/success")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

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
