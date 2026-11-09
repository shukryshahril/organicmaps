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
    guard style.usesFloatingSurface == true else { return }
    control.setBackgroundImage(nil, for: .normal)
    control.backgroundColor = style.backgroundColor
    control.contentHorizontalAlignment = .center
    control.contentVerticalAlignment = .center
    control.imageEdgeInsets = .zero
    control.imageView?.contentMode = .scaleAspectFit
    if let color = style.backgroundColor {
      InterfaceGlassRenderer.render(control, solidColor: color,
                                    tintColor: InterfaceStyleSheet.accent,
                                    cornerRadius: control.layer.cornerRadius,
                                    allowsGlass: style.allowsGlass ?? true)
    }
  }
}
