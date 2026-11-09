import AVFoundation
import KokoroCoreML

/// Local English speech. The model and voice ship in the app; synthesis never makes a network request.
@objc(MWMKokoroVoicePlayer)
final class KokoroVoicePlayer: NSObject, AVAudioPlayerDelegate {
  @objc static let voiceIdentifier = "organicmaps.kokoro.af_heart"
  @objc static var isAvailable: Bool {
    guard #available(iOS 18.0, *), let directory = modelDirectory else { return false }
    return KokoroEngine.isDownloaded(at: directory)
      && FileManager.default.fileExists(atPath: directory.appendingPathComponent("voices/af_heart.bin").path)
  }

  private static var modelDirectory: URL? {
    Bundle.main.url(forResource: "Kokoro", withExtension: nil)
  }

  @objc private(set) var isBusy = false
  private let inferenceThread = InferenceThread()
  private let requestLock = NSLock()
  private var requestID = UUID()
  // Only accessed on inferenceThread. AnyObject keeps the optional engine compatible with older iOS versions.
  private var storedEngine: AnyObject?
  private var player: AVAudioPlayer?
  private var completion: ((Bool) -> Void)?
  private var timeout: DispatchWorkItem?
  private var interruptionObserver: NSObjectProtocol?

  override init() {
    super.init()
    interruptionObserver = NotificationCenter.default.addObserver(
      forName: AVAudioSession.interruptionNotification, object: nil, queue: .main
    ) { [weak self] notification in
      guard let value = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
            AVAudioSession.InterruptionType(rawValue: value) == .began else { return }
      // Never replay an obsolete turn after a phone call.
      self?.finish(success: true)
    }
  }

  deinit {
    interruptionObserver.map(NotificationCenter.default.removeObserver(_:))
    timeout?.cancel()
    inferenceThread.cancel()
  }

  @available(iOS 18.0, *)
  private func engine() throws -> KokoroEngine {
    if let engine = storedEngine as? KokoroEngine { return engine }
    guard let directory = Self.modelDirectory else { throw CocoaError(.fileNoSuchFile) }
    // CPU inference remains usable while navigating with the screen locked; Metal cannot run there.
    let engine = try KokoroEngine(modelDirectory: directory, forceCPU: true)
    storedEngine = engine
    return engine
  }

  @objc func prepare() {
    guard Self.isAvailable else { return }
    inferenceThread.async { [weak self] in
      guard let self, #available(iOS 18.0, *) else { return }
      _ = try? self.engine()
    }
  }

  /// Main-thread entry point. A newer request cancels old audio and discards unfinished inference.
  /// Navigation has a short deadline so a cold/slow model cannot delay a turn instruction indefinitely.
  @objc func speak(_ text: String, navigation: Bool, completion: @escaping (Bool) -> Void) {
    dispatchPrecondition(condition: .onQueue(.main))
    stop()
    guard Self.isAvailable, !text.isEmpty else { completion(false); return }
    self.completion = completion
    isBusy = true
    let identifier = requestLock.withLock { requestID }
    let deadline = DispatchWorkItem { [weak self] in
      guard let self, self.isCurrent(identifier) else { return }
      self.finish(success: false)
    }
    timeout = deadline
    DispatchQueue.main.asyncAfter(deadline: .now() + (navigation ? 2.5 : 20), execute: deadline)
    inferenceThread.async { [weak self] in
      guard let self, self.isCurrent(identifier), #available(iOS 18.0, *) else { return }
      let result: Result<Data, Error> = Result {
        let audio = try self.engine().synthesize(text: text, voice: "af_heart")
        return try Self.waveData(samples: audio.samples)
      }
      DispatchQueue.main.async { [weak self] in
        guard let self, self.isCurrent(identifier) else { return }
        self.timeout?.cancel()
        self.timeout = nil
        do {
          let player = try AVAudioPlayer(data: result.get(), fileTypeHint: AVFileType.wav.rawValue)
          player.delegate = self
          try AVAudioSession.sharedInstance().setActive(true)
          self.player = player
          guard player.play() else { self.finish(success: false); return }
        } catch {
          // Do not log the navigation text, street names, or coordinates.
          self.finish(success: false)
        }
      }
    }
  }

  private func isCurrent(_ identifier: UUID) -> Bool {
    requestLock.withLock { requestID == identifier }
  }

  @objc func stop() {
    dispatchPrecondition(condition: .onQueue(.main))
    requestLock.withLock { requestID = UUID() }
    timeout?.cancel()
    timeout = nil
    player?.stop()
    player = nil
    completion = nil
    isBusy = false
  }

  private func finish(success: Bool) {
    let callback = completion
    stop()
    callback?(success)
  }

  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    guard self.player === player else { return }
    finish(success: flag)
  }

  func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
    guard self.player === player else { return }
    finish(success: false)
  }

  /// Encode mono 24 kHz PCM without writing navigation audio to disk.
  static func waveData(samples: [Float]) throws -> Data {
    guard !samples.isEmpty, samples.allSatisfy(\.isFinite), samples.count < Int(UInt32.max) / 2 - 36
    else { throw CocoaError(.fileReadCorruptFile) }
    let byteCount = UInt32(samples.count * 2)
    var data = Data()
    func append<T: FixedWidthInteger>(_ value: T) {
      var value = value.littleEndian
      withUnsafeBytes(of: &value) { data.append(contentsOf: $0) }
    }
    data.append(contentsOf: "RIFF".utf8)
    append(byteCount + 36)
    data.append(contentsOf: "WAVEfmt ".utf8)
    append(UInt32(16)); append(UInt16(1)); append(UInt16(1))
    append(UInt32(24_000)); append(UInt32(48_000)); append(UInt16(2)); append(UInt16(16))
    data.append(contentsOf: "data".utf8)
    append(byteCount)
    for sample in samples { append(Int16(max(-1, min(1, sample)) * Float(Int16.max))) }
    return data
  }
}

/// Serial executor with a large stack. CoreML CPU inference (BNNS) overflows GCD's 512 KB worker stacks.
private final class InferenceThread: Thread {
  private let condition = NSCondition()
  private var jobs: [() -> Void] = []

  override init() {
    super.init()
    name = "app.organicmaps.kokoro"
    stackSize = 16 << 20
    qualityOfService = .userInitiated
    start()
  }

  func async(_ job: @escaping () -> Void) {
    condition.withLock {
      jobs.append(job)
      condition.signal()
    }
  }

  override func cancel() {
    condition.withLock {
      super.cancel()
      jobs.removeAll()
      condition.signal()
    }
  }

  override func main() {
    while true {
      condition.lock()
      while jobs.isEmpty && !isCancelled { condition.wait() }
      if isCancelled { condition.unlock(); return }
      let job = jobs.removeFirst()
      condition.unlock()
      autoreleasepool(invoking: job)
    }
  }
}
