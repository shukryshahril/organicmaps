import Foundation

/// Surface material is independent of the interface style, palette, and light/dark appearance.
enum InterfaceMaterial: String, CaseIterable {
  case solid
  case glass

  private static let preferenceKey = "PersonalInterfaceMaterial"

  static var current: InterfaceMaterial {
    get { load() }
    set { newValue.save() }
  }

  static func load(from defaults: UserDefaults = .standard) -> InterfaceMaterial {
    defaults.string(forKey: preferenceKey).flatMap(InterfaceMaterial.init(rawValue:)) ?? .solid
  }

  func save(to defaults: UserDefaults = .standard) {
    defaults.set(rawValue, forKey: Self.preferenceKey)
  }
}
