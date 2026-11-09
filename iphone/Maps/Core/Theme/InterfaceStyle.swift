import Foundation

/// An interface choice saved by raw value in user defaults.
protocol InterfacePreference: RawRepresentable<String> {
  static var preferenceKey: String { get }
  static var defaultValue: Self { get }
}

extension InterfacePreference {
  static var current: Self {
    get { load() }
    set { newValue.save() }
  }

  static func load(from defaults: UserDefaults = .standard) -> Self {
    defaults.string(forKey: preferenceKey).flatMap(Self.init(rawValue:)) ?? defaultValue
  }

  func save(to defaults: UserDefaults = .standard) {
    defaults.set(rawValue, forKey: Self.preferenceKey)
  }
}

/// Independent of the map's light/dark appearance.
enum InterfaceStyle: String, CaseIterable, InterfacePreference {
  case minimal
  case pixel

  static let preferenceKey = "PersonalInterfaceStyle"
  static let defaultValue = Self.minimal
}
