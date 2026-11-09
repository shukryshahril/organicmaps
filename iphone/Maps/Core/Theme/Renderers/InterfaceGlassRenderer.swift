import UIKit

/// Installs a noninteractive material behind a control's existing content and touch target.
/// Call after its ordinary stylesheet so switching off can restore that exact solid appearance.
enum InterfaceGlassRenderer {
  static func updateCornerRadius(_ radius: CGFloat, on view: UIView) {
    (objc_getAssociatedObject(view, &surfaceKey) as? GlassSurface)?.updateCornerRadius(radius)
  }

  private static var surfaceKey: UInt8 = 0

  static func render(_ view: UIView, solidColor: UIColor, tintColor: UIColor,
                     cornerRadius: CGFloat, allowsGlass: Bool = true) {
    let existing = objc_getAssociatedObject(view, &surfaceKey) as? GlassSurface
    guard InterfaceMaterial.current == .glass || existing != nil else { return }
    let surface = existing ?? GlassSurface(host: view)
    objc_setAssociatedObject(view, &surfaceKey, surface, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    surface.configure(solidColor: solidColor, tintColor: tintColor,
                      cornerRadius: cornerRadius, allowsGlass: allowsGlass)
  }
}

private final class GlassSurface: NSObject {
  private weak var host: UIView?
  private var effectView: UIVisualEffectView?
  private var solidColor: UIColor = .clear
  private var tintColor: UIColor = .clear
  private var cornerRadius: CGFloat = 0
  private var borderWidth: CGFloat = 0
  private var shadowOpacity: Float = 0
  private var allowsGlass = true

  init(host: UIView) {
    self.host = host
    super.init()
    for name in [UIAccessibility.reduceTransparencyStatusDidChangeNotification,
                 UIAccessibility.darkerSystemColorsStatusDidChangeNotification,
                 UIAccessibility.reduceMotionStatusDidChangeNotification] {
      NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: name, object: nil)
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  func configure(solidColor: UIColor, tintColor: UIColor, cornerRadius: CGFloat, allowsGlass: Bool) {
    guard let host else { return }
    self.solidColor = solidColor
    self.tintColor = tintColor
    self.cornerRadius = cornerRadius
    self.allowsGlass = allowsGlass
    borderWidth = host.layer.borderWidth
    shadowOpacity = host.layer.shadowOpacity
    refresh()
  }

  func updateCornerRadius(_ radius: CGFloat) {
    cornerRadius = radius
    if #available(iOS 26.0, *) {
      effectView?.cornerConfiguration = .corners(radius: .fixed(Double(radius)))
    } else {
      effectView?.layer.cornerRadius = radius
    }
  }

  @objc private func refresh() {
    guard let host else { return }
    let useGlass = allowsGlass && InterfaceMaterial.current == .glass
      && !UIAccessibility.isReduceTransparencyEnabled && !UIAccessibility.isDarkerSystemColorsEnabled
    guard useGlass else {
      effectView?.removeFromSuperview()
      effectView = nil
      host.backgroundColor = solidColor
      host.layer.borderWidth = borderWidth
      host.layer.shadowOpacity = shadowOpacity
      return
    }

    let effect: UIVisualEffect
    if #available(iOS 26.0, *) {
      let glass = UIGlassEffect(style: .regular)
      glass.tintColor = tintColor.withAlphaComponent(0.12)
      // Controls retain their existing pressed feedback. The backdrop never captures a touch.
      glass.isInteractive = false
      effect = glass
    } else {
      effect = UIBlurEffect(style: .systemMaterial)
    }

    let background = effectView ?? UIVisualEffectView(effect: nil)
    if effectView == nil {
      // UIButton can reorder its image view during layout; keep the material below its content.
      background.layer.zPosition = -1
      background.isUserInteractionEnabled = false
      background.accessibilityElementsHidden = true
      background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      host.insertSubview(background, at: 0)
      effectView = background
    }
    background.frame = host.bounds
    background.effect = effect
    if #available(iOS 26.0, *) {
      background.cornerConfiguration = .corners(radius: .fixed(Double(cornerRadius)))
    } else {
      background.layer.cornerRadius = cornerRadius
      background.layer.cornerCurve = .continuous
      background.clipsToBounds = true
    }
    host.backgroundColor = .clear
    host.layer.borderWidth = 0
    host.layer.shadowOpacity = 0
  }
}
