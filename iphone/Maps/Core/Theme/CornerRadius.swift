enum CornerRadius {
  case modalSheet
  case buttonDefault
  case buttonDefaultSmall
  case buttonDefaultBig
  case buttonSmall
  case grabber
  case custom(CGFloat)
  /// Rounded by the given value, near-square in the pixel interface style.
  case floating(CGFloat)
}

extension CornerRadius {
  var value: CGFloat {
    if InterfaceStyleSheet.isPixel {
      switch self {
      case .modalSheet, .floating: return 2
      case .buttonDefault, .buttonDefaultSmall, .buttonDefaultBig, .buttonSmall: return 0
      case .grabber, .custom: break
      }
    }
    switch self {
    case .modalSheet:
      if #available(iOS 26.0, *) {
        // The iOS 26 uses 38 radiuses for the modal screen.
        return 28
      } else {
        return 12
      }
    case .buttonDefault: return 8
    case .buttonDefaultSmall: return 6
    case .buttonDefaultBig: return 12
    case .buttonSmall: return 4
    case .grabber: return 2.5
    case .custom(let value), .floating(let value): return value
    }
  }
}
