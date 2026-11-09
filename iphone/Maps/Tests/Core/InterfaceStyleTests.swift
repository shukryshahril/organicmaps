@testable import Organic_Maps__Debug_
import XCTest

final class InterfaceStyleTests: XCTestCase {
  func testFirstLaunchUsesMinimal() throws {
    let suite = "InterfaceStyleTests-\(UUID().uuidString)"
    let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
    defer { defaults.removePersistentDomain(forName: suite) }
    XCTAssertEqual(InterfaceStyle.load(from: defaults), .minimal)
  }

  func testChoicePersistsAndCanReturnToMinimal() throws {
    let suite = "InterfaceStyleTests-\(UUID().uuidString)"
    let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
    defer { defaults.removePersistentDomain(forName: suite) }
    defaults.set("night", forKey: "Theme")

    InterfaceStyle.pixel.save(to: defaults)
    let reloaded = try XCTUnwrap(UserDefaults(suiteName: suite))
    XCTAssertEqual(InterfaceStyle.load(from: reloaded), .pixel)

    InterfaceStyle.minimal.save(to: reloaded)
    XCTAssertEqual(InterfaceStyle.load(from: defaults), .minimal)
    XCTAssertEqual(defaults.string(forKey: "Theme"), "night")
  }

  func testUnknownStoredStyleFallsBackToMinimal() throws {
    let suite = "InterfaceStyleTests-\(UUID().uuidString)"
    let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
    defer { defaults.removePersistentDomain(forName: suite) }
    defaults.set("future-style", forKey: "PersonalInterfaceStyle")
    XCTAssertEqual(InterfaceStyle.load(from: defaults), .minimal)
  }
}

final class InterfacePaletteTests: XCTestCase {
  func testDefaultAndUnknownPaletteUseForest() throws {
    let suite = "InterfacePaletteTests-\(UUID().uuidString)"
    let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
    defer { defaults.removePersistentDomain(forName: suite) }
    XCTAssertEqual(InterfacePalette.load(from: defaults), .forest)
    XCTAssertEqual(InterfaceStyle.load(from: defaults), .minimal)
    defaults.set("removed-palette", forKey: "PersonalInterfacePalette")
    XCTAssertEqual(InterfacePalette.load(from: defaults), .forest)
  }

  func testEveryPalettePersistsIndependentlyOfInterfaceStyle() throws {
    let suite = "InterfacePaletteTests-\(UUID().uuidString)"
    let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
    defer { defaults.removePersistentDomain(forName: suite) }
    defaults.set("night", forKey: "Theme")
    for style in InterfaceStyle.allCases {
      style.save(to: defaults)
      for palette in InterfacePalette.allCases {
        palette.save(to: defaults)
        let reopened = try XCTUnwrap(UserDefaults(suiteName: suite))
        XCTAssertEqual(InterfacePalette.load(from: reopened), palette)
        XCTAssertEqual(InterfaceStyle.load(from: reopened), style)
        XCTAssertEqual(reopened.string(forKey: "Theme"), "night")
      }
    }
  }

  func testAllPalettesKeepTextReadableInLightAndDark() {
    for palette in InterfacePalette.allCases {
      for dark in [false, true] {
        let colors = palette.colors(isDark: dark)
        let context = "\(palette.rawValue), dark: \(dark)"
        XCTAssertGreaterThanOrEqual(contrast(colors.ink, colors.background), 4.5, context)
        XCTAssertGreaterThanOrEqual(contrast(colors.ink, colors.surface), 4.5, context)
        XCTAssertGreaterThanOrEqual(contrast(colors.accent, colors.surface), 4.5, context)
      }
      XCTAssertGreaterThanOrEqual(contrast(0xFFFFFF, palette.colors(isDark: false).accent), 4.5,
                                  "White text on filled \(palette.rawValue) buttons")
    }
  }

  private func contrast(_ first: UInt32, _ second: UInt32) -> Double {
    let values = [luminance(first), luminance(second)].sorted()
    return (values[1] + 0.05) / (values[0] + 0.05)
  }

  private func luminance(_ rgb: UInt32) -> Double {
    let channels = [16, 8, 0].map { shift -> Double in
      let component = Double((rgb >> shift) & 0xff) / 255
      return component <= 0.04045 ? component / 12.92 : pow((component + 0.055) / 1.055, 2.4)
    }
    return channels[0] * 0.2126 + channels[1] * 0.7152 + channels[2] * 0.0722
  }
}

final class InterfaceMaterialTests: XCTestCase {
  func testExistingInstallKeepsSolidAndUnknownMaterialFallsBack() throws {
    let suite = "InterfaceMaterialTests-\(UUID().uuidString)"
    let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
    defer { defaults.removePersistentDomain(forName: suite) }
    XCTAssertEqual(InterfaceMaterial.load(from: defaults), .solid)
    defaults.set("removed-material", forKey: "PersonalInterfaceMaterial")
    XCTAssertEqual(InterfaceMaterial.load(from: defaults), .solid)
  }

  func testGlassCanReturnToSolidWithoutChangingOtherAppearanceChoices() throws {
    let suite = "InterfaceMaterialTests-\(UUID().uuidString)"
    let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
    defer { defaults.removePersistentDomain(forName: suite) }
    defaults.set("night", forKey: "Theme")
    for style in InterfaceStyle.allCases {
      style.save(to: defaults)
      for palette in InterfacePalette.allCases {
        palette.save(to: defaults)
        for material in [InterfaceMaterial.glass, .solid] {
          material.save(to: defaults)
          let reopened = try XCTUnwrap(UserDefaults(suiteName: suite))
          XCTAssertEqual(InterfaceMaterial.load(from: reopened), material)
          XCTAssertEqual(InterfaceStyle.load(from: reopened), style)
          XCTAssertEqual(InterfacePalette.load(from: reopened), palette)
          XCTAssertEqual(reopened.string(forKey: "Theme"), "night")
        }
      }
    }
  }
}
