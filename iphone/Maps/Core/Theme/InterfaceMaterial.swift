import Foundation

/// Surface material is independent of the interface style, palette, and light/dark appearance.
enum InterfaceMaterial: String, CaseIterable, InterfacePreference {
  case solid
  case glass

  static let preferenceKey = "PersonalInterfaceMaterial"
  static let defaultValue = Self.solid
}
