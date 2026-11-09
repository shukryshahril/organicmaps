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
      if InterfaceIcons.image(forAssetName: imageName) != nil {
        control.setBackgroundImage(nil, for: .normal)
        control.backgroundColor = style.backgroundColor
        control.contentHorizontalAlignment = .center
        control.contentVerticalAlignment = .center
        control.imageEdgeInsets = .zero
        control.imageView?.contentMode = .scaleAspectFit
        if let color = style.backgroundColor {
          // The active follow state stays opaque so its white navigation arrow remains legible.
          let following = imageName == "btn_follow" || imageName == "btn_follow_and_rotate"
          InterfaceGlassRenderer.render(control, solidColor: color,
                                        tintColor: InterfaceStyleSheet.accent,
                                        cornerRadius: control.layer.cornerRadius,
                                        allowsGlass: !following)
        }
      }
    }
  }
}
