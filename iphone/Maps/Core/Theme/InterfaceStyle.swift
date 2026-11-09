import Foundation

/// Independent of the map's light/dark appearance.
enum InterfaceStyle: String, CaseIterable {
  case minimal
  case pixel

  private static let preferenceKey = "PersonalInterfaceStyle"

  static var current: InterfaceStyle {
    get { load() }
    set { newValue.save() }
  }

  static func load(from defaults: UserDefaults = .standard) -> InterfaceStyle {
    defaults.string(forKey: preferenceKey).flatMap(InterfaceStyle.init(rawValue:)) ?? .minimal
  }

  func save(to defaults: UserDefaults = .standard) {
    defaults.set(rawValue, forKey: Self.preferenceKey)
  }
}
