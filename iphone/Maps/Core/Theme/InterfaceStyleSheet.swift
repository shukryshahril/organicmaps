import UIKit

enum InterfaceStyleSheet: String, CaseIterable {
  case routeActionButton
  case navigationTitle
  case mapDock
  case menuIcon
  case mutedMenuIcon
  case recordingMenuIcon
  case routePanelTitle, routePanelPlaceholder, routePanelLink, routePanelIcon, routePanelMutedIcon

  static var isPixel: Bool { InterfaceStyle.current == .pixel }

  static func uiColor(_ rgb: UInt32) -> UIColor {
    UIColor(red: CGFloat((rgb >> 16) & 0xff) / 255,
            green: CGFloat((rgb >> 8) & 0xff) / 255,
            blue: CGFloat(rgb & 0xff) / 255, alpha: 1)
  }

  private static func color(_ keyPath: KeyPath<InterfacePalette.Colors, UInt32>) -> UIColor {
    let palette = InterfacePalette.current
    return UIColor { traits in
      uiColor(palette.colors(isDark: traits.userInterfaceStyle == .dark)[keyPath: keyPath])
    }
  }

  static var background: UIColor { color(\.background) }
  static var surface: UIColor { color(\.surface) }
  static var ink: UIColor { color(\.ink) }
  static var accent: UIColor { color(\.accent) }
  static var border: UIColor { color(\.border).withAlphaComponent(isPixel ? 1 : 0.3) }

  // Use the deeper accent behind white button text and switch thumbs in both appearances.
  static var filledAccent: UIColor { uiColor(InterfacePalette.current.colors(isDark: false).accent) }
  static var switchAccent: UIColor { filledAccent }

  static var headingFont: FontStyle {
    .dynamic(isPixel ? .monospacedSystemFont(ofSize: 17, weight: .semibold) : .semibold17)
  }

  static var searchFont: FontStyle {
    .dynamic(isPixel ? .monospacedSystemFont(ofSize: 16, weight: .regular) : .regular16)
  }

  static func floatingSurface(_ style: Style) {
    style.backgroundColor = surface
    style.borderColor = border
    style.borderWidth = isPixel ? 2 : 0
    style.shadowColor = ink
    style.shadowRadius = isPixel ? 0 : 6
    style.shadowOffset = isPixel ? CGSize(width: 2, height: 2) : CGSize(width: 0, height: 2)
    style.shadowOpacity = isPixel ? 0.3 : 0.12
  }
}

extension InterfaceStyleSheet: IStyleSheet {
  var styleResolver: Theme.StyleResolver {
    switch self {
    case .menuIcon, .mutedMenuIcon, .recordingMenuIcon:
      let muted = self == .mutedMenuIcon
      let recording = self == .recordingMenuIcon
      return .add { s in
        let tint = recording ? UIColor.redPrimary : (muted ? Self.ink.withAlphaComponent(0.35) : Self.accent)
        s.tintColor = tint
        s.backgroundColor = tint.withAlphaComponent(muted ? 0.04 : 0.1)
        s.cornerRadius = .custom(Self.isPixel ? 2 : 12)
      }
    case .routePanelTitle, .routePanelPlaceholder, .routePanelLink:
      return .add { s in
        s.fontStyle = .dynamic(.semibold14)
        s.fontColor = self == .routePanelLink ? Self.accent : Self.ink.withAlphaComponent(self == .routePanelPlaceholder ? 0.6 : 1)
      }
    case .routePanelIcon, .routePanelMutedIcon:
      return .add { s in
        s.tintColor = self == .routePanelIcon ? Self.accent : Self.ink.withAlphaComponent(0.4)
      }
    case .mapDock:
      return .add { s in
        Self.floatingSurface(s)
        s.cornerRadius = .custom(Self.isPixel ? 2 : 24)
        s.borderWidth = Self.isPixel ? 2 : 0.5
      }
    case .navigationTitle:
      return .add { s in
        s.fontStyle = Self.headingFont
        s.fontColor = Self.ink
      }
    case .routeActionButton:
      return .add { s in
        s.backgroundColor = Self.background
        s.tintColor = Self.accent
        s.borderColor = Self.border
        s.borderWidth = Self.isPixel ? 2 : 0
        s.cornerRadius = .buttonDefaultBig
      }
    }
  }
}

// Legacy Objective-C map controls use the same palette as Swift stylesheets.
@objc(MWMInterfaceColors)
final class InterfaceColors: NSObject {
  @objc static var accent: UIColor { InterfaceStyleSheet.accent }
  @objc static var highlightedAccent: UIColor { InterfaceStyleSheet.accent.withAlphaComponent(0.7) }
}
