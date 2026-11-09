final class StartRouteButton: UIView {
  enum State: Equatable {
    case enabled
    case loading(progress: CGFloat)
    case disabled
  }

  private enum Constants {
    static let buttonTitle = L("p2p_start")
    static let animationDuration: TimeInterval = AppConstants.defaultAnimationDuration / 2
  }

  private let button = UIButton(type: .system)
  private let backgroundView = UIView()
  private let progressView = UIView()
  private var progressWidthConstraint: NSLayoutConstraint?
  private var loadingProgress: CGFloat = 0
  private var state: State = .enabled

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    layout()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    setLoadingProgress(loadingProgress, animated: false)
  }

  private func setupView() {
    backgroundView.backgroundColor = InterfaceStyleSheet.filledAccent
    backgroundView.layer.cornerRadius = CornerRadius.buttonDefaultBig.value
    backgroundView.layer.cornerCurve = .continuous
    backgroundView.clipsToBounds = true
    backgroundView.translatesAutoresizingMaskIntoConstraints = false

    progressView.isHidden = true
    progressView.translatesAutoresizingMaskIntoConstraints = false

    var configuration = UIButton.Configuration.plain()
    configuration.image = InterfaceIcon.startNavigation.boldImage
    configuration.imagePadding = 6
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
    configuration.baseForegroundColor = .white
    button.configuration = configuration
    button.configurationUpdateHandler = { [weak self] button in
      guard let self = self else { return }
      let foreground: UIColor = self.state == .enabled ? .white : InterfaceStyleSheet.ink
      var configuration = button.configuration
      configuration?.baseForegroundColor = foreground
      configuration?.imageColorTransformer = UIConfigurationColorTransformer { _ in foreground }
      configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
        var attributes = attributes
        attributes.foregroundColor = foreground
        attributes.font = UIFont.semibold16.dynamic
        return attributes
      }
      button.configuration = configuration
    }
    button.setTitle(Constants.buttonTitle, for: .normal)
    button.titleLabel?.font = UIFont.semibold16.dynamic
    button.titleLabel?.adjustsFontForContentSizeCategory = true
    button.setTitleColor(.whitePrimaryText, for: .normal)
    button.setTitleColor(.whitePrimaryText, for: .highlighted)
    button.setTitleColor(.whitePrimaryText, for: .disabled)
    button.titleLabel?.configureSingleLineAutoScaling()
    button.backgroundColor = .clear
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(highlightButton), for: [.touchDown, .touchDragEnter])
    button.addTarget(self,
                     action: #selector(unhighlightButton),
                     for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
  }

  private func layout() {
    addSubview(backgroundView)
    backgroundView.addSubview(progressView)
    addSubview(button)

    button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    let progressWidthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)
    self.progressWidthConstraint = progressWidthConstraint

    NSLayoutConstraint.activate([
      backgroundView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      backgroundView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      backgroundView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      backgroundView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

      progressView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor),
      progressView.topAnchor.constraint(equalTo: backgroundView.topAnchor),
      progressView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor),
      progressWidthConstraint,

      button.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
      button.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
      button.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      button.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
    ])
  }

  func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
    button.addTarget(target, action: action, for: controlEvents)
  }

  func setState(_ newState: State) {
    guard state != newState else { return }
    let oldState = state
    state = newState
    switch (oldState, newState) {
    case (.loading, .loading(let progress)): // progress update
      setLoadingProgress(progress, animated: true)
    default: // state change
      UIView.transition(with: self,
                        duration: Constants.animationDuration,
                        options: [.transitionCrossDissolve],
                        animations: { [weak self] in
                          guard let self = self else { return }
                          switch newState {
                          case .enabled:
                            self.button.setTitle(Constants.buttonTitle, for: .normal)
                            self.backgroundView.backgroundColor = InterfaceStyleSheet.filledAccent
                            self.progressView.isHidden = true
                            self.setLoadingProgress(0, animated: false)
                            self.button.isEnabled = true
                          case .loading(let progress):
                            self.button.setTitle(Constants.buttonTitle, for: .normal)
                            self.backgroundView.backgroundColor = InterfaceStyleSheet.background
                            self.progressView.backgroundColor = InterfaceStyleSheet.accent.withAlphaComponent(0.15)
                            self.progressView.isHidden = false
                            self.setLoadingProgress(progress, animated: false)
                            // Tapping while the route builds queues the start.
                            self.button.isEnabled = true
                          case .disabled:
                            self.button.setTitle(Constants.buttonTitle, for: .normal)
                            self.backgroundView.backgroundColor = InterfaceStyleSheet.background
                            self.progressView.isHidden = true
                            self.setLoadingProgress(0, animated: false)
                            self.button.isEnabled = false
                          }
                        })
    }
    button.setNeedsUpdateConfiguration()
  }

  override func applyTheme() {
    super.applyTheme()
    switch state {
    case .enabled:
      backgroundView.backgroundColor = InterfaceStyleSheet.filledAccent
    case .loading:
      backgroundView.backgroundColor = InterfaceStyleSheet.background
    case .disabled:
      backgroundView.backgroundColor = InterfaceStyleSheet.background
    }
    progressView.backgroundColor = InterfaceStyleSheet.accent.withAlphaComponent(0.15)
    button.setNeedsUpdateConfiguration()
  }

  private func setLoadingProgress(_ progress: CGFloat, animated: Bool) {
    loadingProgress = min(max(progress, 0), 1)
    progressWidthConstraint?.constant = backgroundView.bounds.width * loadingProgress
    let animations = { self.backgroundView.layoutIfNeeded() }
    if animated {
      UIView.animate(withDuration: Constants.animationDuration,
                     delay: 0,
                     options: [.beginFromCurrentState, .curveEaseInOut],
                     animations: animations)
    } else {
      animations()
    }
  }

  @objc private func highlightButton() {
    guard state == .enabled else { return }
    backgroundView.backgroundColor = InterfaceStyleSheet.filledAccent.withAlphaComponent(0.85)
  }

  @objc private func unhighlightButton() {
    guard state == .enabled else { return }
    backgroundView.backgroundColor = InterfaceStyleSheet.filledAccent
  }
}
