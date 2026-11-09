extension MWMButton {
  @objc override func applyTheme() {
    for style in StyleManager.shared.getStyle(styleName)
      where !style.isEmpty && !style.hasExclusion(view: self) {
      MWMButtonRenderer.render(self, style: style)
    }
  }
}

class MWMButtonRenderer {
  class func render(_ control: MWMButton, style: Style) {
    UIButtonRenderer.render(control, style: style)
    if let coloring = style.coloring {
      control.coloring = coloring
    }
    if let imageName = style.mwmImage {
      control.imageName = imageName
    }
    // Styles without an image of their own (the icon is picked in code) still use the modern surface.
    guard let imageName = style.mwmImage ?? (style.backgroundColor != nil ? control.imageName : nil),
          InterfaceIcons.image(forAssetName: imageName) != nil else { return }
    control.setBackgroundImage(nil, for: .normal)
    control.backgroundColor = style.backgroundColor
    control.contentHorizontalAlignment = .center
    control.contentVerticalAlignment = .center
    control.imageEdgeInsets = .zero
    control.imageView?.contentMode = .scaleAspectFit
    if let color = style.backgroundColor {
      // The follow state stays opaque so its white arrow remains legible.
      let following = imageName == "btn_follow"
      InterfaceGlassRenderer.render(control, solidColor: color,
                                    tintColor: InterfaceStyleSheet.accent,
                                    cornerRadius: control.layer.cornerRadius,
                                    allowsGlass: !following)
    }
  }
}
