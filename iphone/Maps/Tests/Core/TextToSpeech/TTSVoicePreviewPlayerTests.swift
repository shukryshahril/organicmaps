@testable import Organic_Maps__Debug_
import XCTest
import AVFoundation

final class TTSVoicePreviewPlayerTests: XCTestCase {
  func test_GivenEnglish_WhenAppTipsAreRead_ThenReturnsAllTranslatedTips() {
    let tips = TTSVoicePreviewPlayer.appTips(languageCode: "en")
    XCTAssertEqual(tips.count, 10)
    XCTAssertTrue(tips.contains("Thank you for using our community-built maps!"))
    XCTAssertFalse(tips.contains { $0.hasPrefix("app_tip_") }, "Untranslated keys: \(tips)")
  }

  func test_GivenGerman_WhenAppTipsAreRead_ThenReturnsGermanTips() {
    XCTAssertTrue(TTSVoicePreviewPlayer.appTips(languageCode: "de")
      .contains("Danke, dass du unsere von der Community erstellten Karten benutzt!"))
  }

  func test_GivenCantonese_WhenAppTipsAreRead_ThenReturnsTraditionalChineseTips() {
    let traditionalChinese = TTSVoicePreviewPlayer.appTips(languageCode: "zh-Hant")
    for code in ["zh-Hant", "yue", "yue-HK", "yue-MO"] {
      let tips = TTSVoicePreviewPlayer.appTips(languageCode: code)
      XCTAssertEqual(tips.count, 10, code)
      XCTAssertTrue(tips.contains("感謝您使用我們社區構建的地圖！"), code)
      XCTAssertFalse(tips.contains { $0.hasPrefix("app_tip_") }, "Untranslated keys for \(code): \(tips)")
      XCTAssertEqual(tips, traditionalChinese, code)
    }
  }

  func test_GivenAppLocalizations_WhenAppTipsAreRead_ThenReturnsAllTranslatedTips() {
    for code in Bundle.main.localizations where code != "Base" {
      let tips = TTSVoicePreviewPlayer.appTips(languageCode: code)
      XCTAssertEqual(tips.count, 10, code)
      XCTAssertFalse(tips.contains { $0.isEmpty || $0.hasPrefix("app_tip_") }, "Missing translations for \(code): \(tips)")
    }
  }
}

final class KokoroVoicePlayerTests: XCTestCase {
  func testPCMProducesPlayableMonoAudio() throws {
    let step = 2.0 * Double.pi * 440.0 / 24_000.0
    let samples: [Float] = (0..<24_000).map { Float(sin(Double($0) * step)) * 0.5 }
    let data = try KokoroVoicePlayer.waveData(samples: samples)
    let player = try AVAudioPlayer(data: data)
    XCTAssertEqual(player.numberOfChannels, 1)
    XCTAssertEqual(player.duration, 1, accuracy: 0.001)
  }

  func testInvalidSamplesCannotBecomeAudio() {
    let invalid: [[Float]] = [[], [.nan], [.infinity]]
    for samples in invalid {
      XCTAssertThrowsError(try KokoroVoicePlayer.waveData(samples: samples))
    }
  }
}
