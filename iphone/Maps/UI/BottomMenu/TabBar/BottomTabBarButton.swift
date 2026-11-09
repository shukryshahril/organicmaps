import UIKit

class BottomTabBarButton: MWMButton {
  @objc override func applyTheme() {
    if styleName.isEmpty {
      setStyle(.bottomTabBarButton)
    }

    for style in StyleManager.shared.getStyle(styleName) where !style.isEmpty && !style.hasExclusion(view: self) {
      BottomTabBarButtonRenderer.render(self, style: style)
    }
  }

  override func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
    bounds.insetBy(dx: kExtendedTabBarTappableMargin, dy: kExtendedTabBarTappableMargin).contains(point)
  }
}

class BottomTabBarButtonRenderer {
  class func render(_ control: BottomTabBarButton, style: Style) {
    // The container supplies the shared surface and shadow.
    control.backgroundColor = .clear
    control.layer.shadowOpacity = 0
    control.layer.borderWidth = 0
    control.contentHorizontalAlignment = .center
    control.contentVerticalAlignment = .center
    control.imageEdgeInsets = .zero
    control.imageView?.contentMode = .scaleAspectFit
    control.coloring = .blue
    if let imageName = style.mwmImage {
      control.imageName = imageName
    }
  }
}
