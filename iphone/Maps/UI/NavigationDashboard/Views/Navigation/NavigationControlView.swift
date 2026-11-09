final class NavigationControlView: SolidTouchView {
  private enum Constants {
    // The summary row dips into the home-indicator inset so the panel hugs the screen bottom.
    static let summaryRowBottomOffset: CGFloat = 4
    // Keeps the map framing of the former layout, whose frame ran 80 pt past the screen bottom.
    static let viewportExtraInset: CGFloat = 40
    static let voiceButtonSymbol = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
  }

  @IBOutlet private var summaryRow: UIStackView!
  @IBOutlet private var durationLabel: UILabel!
  @IBOutlet private var tripDetailsLabel: UILabel!
  @IBOutlet private var ttsButton: MWMButton!
  @IBOutlet private var stopButton: UIButton!

  weak var ownerView: UIView!
  weak var delegate: RouteNavigationControlsDelegate!

  var isVisible = false {
    didSet {
      guard isVisible != oldValue else { return }
      if isVisible {
        addView()
      } else {
        removeView()
      }
    }
  }

  private var lastViewportHeight: CGFloat = 0

  override func awakeFromNib() {
    super.awakeFromNib()

    durationLabel.font = UIFont.bold28.dynamic(maxSize: 34)
    tripDetailsLabel.font = UIFont.medium16.dynamic(maxSize: 22)
    for label in [durationLabel!, tripDetailsLabel!] {
      label.adjustsFontForContentSizeCategory = true
      label.configureSingleLineAutoScaling()
    }
    configureVoiceButton()
    configureStopButton()
    applySummaryColors()

    MWMTextToSpeech.add(self)
  }

  private func configureVoiceButton() {
    let muted = UIImage(systemName: "speaker.slash.fill", withConfiguration: Constants.voiceButtonSymbol)
    let speaking = UIImage(systemName: "speaker.wave.2.fill", withConfiguration: Constants.voiceButtonSymbol)
    ttsButton.setImage(muted, for: .normal)
    ttsButton.setImage(speaking, for: .selected)
    ttsButton.setImage(speaking, for: [.selected, .highlighted])
    ttsButton.layer.cornerRadius = 22
    ttsButton.layer.cornerCurve = .continuous
    ttsButton.accessibilityIdentifier = "navigationVoiceButton"
    ttsButton.accessibilityLabel = L("pref_tts_enable_title")
  }

  private func configureStopButton() {
    stopButton.titleLabel?.adjustsFontForContentSizeCategory = true
    stopButton.titleLabel?.numberOfLines = 1
    stopButton.setContentCompressionResistancePriority(.required, for: .vertical)
    stopButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 22, bottom: 10, right: 22)
  }

  private func applySummaryColors() {
    durationLabel.textColor = InterfaceStyleSheet.ink
    tripDetailsLabel.textColor = InterfaceStyleSheet.ink.withAlphaComponent(0.65)
    ttsButton.backgroundColor = InterfaceStyleSheet.background
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    guard isVisible, superview != nil, frame.height != lastViewportHeight else { return }
    lastViewportHeight = frame.height
    updateVisibleViewportArea()
  }

  private func addView() {
    guard superview != ownerView, !ownerView.subviews.contains(self) else { return }
    ownerView.addSubview(self)

    let lg = ownerView.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: lg.leadingAnchor),
      trailingAnchor.constraint(equalTo: lg.trailingAnchor),
      bottomAnchor.constraint(equalTo: ownerView.bottomAnchor),
      summaryRow.bottomAnchor.constraint(equalTo: lg.bottomAnchor, constant: Constants.summaryRowBottomOffset),
    ])

    updateVisibleViewportArea()
  }

  private func removeView() {
    updateVisibleViewportArea(onClose: true)
    removeFromSuperview()
  }

  private func updateVisibleViewportArea(onClose: Bool = false) {
    let bottom = frame.height / 2 + Constants.viewportExtraInset
    let insets = UIEdgeInsets(top: 0, left: 0, bottom: onClose ? 0 : bottom, right: 0)
    MapViewController.shared()?.updateVisibleAreaInsets(for: self, insets: insets, updatingViewport: true)
  }

  func onNavigationInfoUpdated(_ info: MWMNavigationDashboardEntity) {
    guard isVisible else { return }
    durationLabel.text = DurationFormatter.routingDurationString(from: TimeInterval(info.timeToTarget))
    let distance = [info.targetDistance, info.targetUnits].compactMap { $0 }.joined(separator: " ")
    tripDetailsLabel.text = [distance, info.arrival ?? ""].filter { !$0.isEmpty }.joined(separator: " · ")
  }

  @IBAction
  private func ttsButtonAction(_: Any) {
    delegate.ttsButtonDidTap()
  }

  @IBAction
  private func stopRoutingButtonAction(_: Any) {
    delegate.stopRoutingButtonDidTap()
  }

  override func applyTheme() {
    super.applyTheme()
    applySummaryColors()
    onTTSStatusUpdated()
  }

  override var sideButtonsAreaAffectDirections: MWMAvailableAreaAffectDirections {
    .bottom
  }

  override var widgetsAreaAffectDirections: MWMAvailableAreaAffectDirections {
    alternative(iPhone: .bottom, iPad: [])
  }

  override var trackRecordingButtonAreaAffectDirections: MWMAvailableAreaAffectDirections {
    .bottom
  }
}

extension NavigationControlView: MWMTextToSpeechObserver {
  func onTTSStatusUpdated() {
    guard MWMRouter.isRoutingActive() else { return }
    ttsButton.isHidden = !MWMTextToSpeech.isTTSEnabled()
    if !ttsButton.isHidden {
      ttsButton.isSelected = MWMTextToSpeech.tts().active
      ttsButton.accessibilityValue = L(ttsButton.isSelected ? "on" : "off")
    }
  }
}
