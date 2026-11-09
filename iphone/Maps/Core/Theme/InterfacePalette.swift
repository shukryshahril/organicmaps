import Foundation

/// Colour is saved separately from interface shape and light/dark appearance.
enum InterfacePalette: String, CaseIterable {
  case forest
  case graphite
  case ocean
  case teal
  case sage
  case sand
  case terracotta
  case rose
  case lavender
  case plum
  case midnight
  case citrus

  struct Colors {
    let background: UInt32
    let surface: UInt32
    let ink: UInt32
    let accent: UInt32
    let border: UInt32
  }

  private static let preferenceKey = "PersonalInterfacePalette"

  static var current: InterfacePalette {
    get { load() }
    set { newValue.save() }
  }

  static func load(from defaults: UserDefaults = .standard) -> InterfacePalette {
    defaults.string(forKey: preferenceKey).flatMap(InterfacePalette.init(rawValue:)) ?? .forest
  }

  func save(to defaults: UserDefaults = .standard) {
    defaults.set(rawValue, forKey: Self.preferenceKey)
  }

  var titleKey: String { "pref_palette_\(rawValue)" }

  func colors(isDark: Bool) -> Colors {
    switch self {
    case .forest:
      return isDark ? Colors(background: 0x18231E, surface: 0x223329, ink: 0xF1F4E8, accent: 0xB8E68A, border: 0x8B9D86)
        : Colors(background: 0xF8F9F4, surface: 0xFFFFFF, ink: 0x18382C, accent: 0x214B37, border: 0x718675)
    case .graphite:
      return isDark ? Colors(background: 0x181B1A, surface: 0x252C28, ink: 0xF0F3EF, accent: 0xD0DDD3, border: 0x8E9E94)
        : Colors(background: 0xF4F5F4, surface: 0xFFFFFF, ink: 0x202523, accent: 0x404B46, border: 0x7C8781)
    case .ocean:
      return isDark ? Colors(background: 0x141F30, surface: 0x203149, ink: 0xEEF5FF, accent: 0x9FCBFF, border: 0x839DBB)
        : Colors(background: 0xF1F6FB, surface: 0xFFFFFF, ink: 0x182F4C, accent: 0x245990, border: 0x718CA9)
    case .teal:
      return isDark ? Colors(background: 0x132724, surface: 0x203B36, ink: 0xEAFAF4, accent: 0x8DDCCE, border: 0x7DA89D)
        : Colors(background: 0xEFF8F6, surface: 0xFFFFFF, ink: 0x183C37, accent: 0x21695F, border: 0x6C938B)
    case .sage:
      return isDark ? Colors(background: 0x20261B, surface: 0x303C27, ink: 0xF0F5E4, accent: 0xC4D99F, border: 0x99AC82)
        : Colors(background: 0xF4F6EE, surface: 0xFFFFFA, ink: 0x303C28, accent: 0x50633C, border: 0x879478)
    case .sand:
      return isDark ? Colors(background: 0x282119, surface: 0x3B3023, ink: 0xFBF1DE, accent: 0xE7C58B, border: 0xB29B76)
        : Colors(background: 0xF9F5ED, surface: 0xFFFDFA, ink: 0x43382B, accent: 0x795A32, border: 0xA39176)
    case .terracotta:
      return isDark ? Colors(background: 0x2D1E19, surface: 0x442C23, ink: 0xFFF0E7, accent: 0xF2B397, border: 0xBA9180)
        : Colors(background: 0xFCF3EE, surface: 0xFFFCFA, ink: 0x4C2B23, accent: 0x964428, border: 0xB18371)
    case .rose:
      return isDark ? Colors(background: 0x2C1B23, surface: 0x422A35, ink: 0xFFEDF3, accent: 0xF2ADCA, border: 0xBC8DA3)
        : Colors(background: 0xFCF2F4, surface: 0xFFFCFD, ink: 0x4B2633, accent: 0x963E60, border: 0xB17C90)
    case .lavender:
      return isDark ? Colors(background: 0x211C2D, surface: 0x322A44, ink: 0xF5EEFF, accent: 0xCDBAF3, border: 0xA292BE)
        : Colors(background: 0xF5F3FC, surface: 0xFDFCFF, ink: 0x342B4B, accent: 0x665098, border: 0x9987B4)
    case .plum:
      return isDark ? Colors(background: 0x281A2A, surface: 0x3D2841, ink: 0xFCEEFE, accent: 0xE2B0E8, border: 0xB18BB7)
        : Colors(background: 0xF8F2F8, surface: 0xFFFCFF, ink: 0x402540, accent: 0x7E397D, border: 0xA87DA6)
    case .midnight:
      return isDark ? Colors(background: 0x121728, surface: 0x202A43, ink: 0xEDF1FF, accent: 0xAFBFFF, border: 0x8396C4)
        : Colors(background: 0xF1F3FA, surface: 0xFFFFFF, ink: 0x242C4D, accent: 0x3F518F, border: 0x7F8BAE)
    case .citrus:
      return isDark ? Colors(background: 0x222510, surface: 0x33391D, ink: 0xF6F9DC, accent: 0xD8E887, border: 0xA7B66C)
        : Colors(background: 0xF8F8E9, surface: 0xFFFFF7, ink: 0x36391D, accent: 0x5D661D, border: 0x93975E)
    }
  }
}
