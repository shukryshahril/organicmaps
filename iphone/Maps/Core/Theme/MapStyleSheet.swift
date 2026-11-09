enum MapStyleSheet: String, CaseIterable {
  case mapMenuButtonDisabled = "MenuButtonDisabled"
  case mapMenuButtonEnabled = "MenuButtonEnabled"
  case mapStreetNameBackgroundView = "StreetNameBackgroundView"
  case mapButtonZoomIn = "ButtonZoomIn"
  case mapButtonZoomOut = "ButtonZoomOut"
  case mapButtonPending = "ButtonPending"
  case mapButtonGetPosition = "ButtonGetPosition"
  case mapButtonFollow = "ButtonFollow"
  case mapButtonFollowAndRotate = "ButtonFollowAndRotate"
  case mapButtonMapBookmarks = "ButtonMapBookmarks"
  case mapButtonMapSearch = "ButtonMapSearch"
  case mapButtonNavigationRecord = "ButtonMapNavigationRecord"
  case mapPromoDiscoveryButton = "PromoDiscroveryButton"
  case mapButtonBookmarksBack = "ButtonBookmarksBack"
  case mapButtonBookmarksBackOpaque = "ButtonBookmarksBackOpaque"
  case mapFirstTurnView = "FirstTurnView"
  case mapSecondTurnView = "SecondTurnView"
  case mapTurnGlyphOnAccent = "TurnGlyphOnAccent"
  case mapTurnTextOnAccent = "TurnTextOnAccent"
  case mapTurnGlyphAccent = "TurnGlyphAccent"
  case mapAutoupdateView = "MapAutoupdateView"
  case mapGuidesNavigationBar = "GuidesNavigationBar"
}

extension MapStyleSheet: IStyleSheet {
  var styleResolver: Theme.StyleResolver {
    switch self {
    case .mapMenuButtonDisabled:
      return .add { s in
        s.fontColor = InterfaceStyleSheet.ink
        s.tintColor = InterfaceStyleSheet.ink
        s.fontStyle = .dynamic(.regular10)
        s.backgroundColor = .clear
        s.borderColor = .clear
        s.borderWidth = 0
        s.cornerRadius = .buttonDefault
      }
    case .mapMenuButtonEnabled:
      return .add { s in
        s.fontColor = InterfaceStyleSheet.accent
        s.tintColor = InterfaceStyleSheet.accent
        s.fontStyle = .dynamic(.regular10)
        s.backgroundColor = InterfaceStyleSheet.accent.withAlphaComponent(0.14)
        s.borderColor = InterfaceStyleSheet.accent
        s.borderWidth = 2
        s.cornerRadius = .buttonDefault
      }
    case .mapStreetNameBackgroundView:
      return .add { s in
        s.backgroundColor = .whitePrimary
        s.shadowRadius = 2
        s.shadowColor = .shadow
        s.shadowOpacity = 1
        s.shadowOffset = CGSize(width: 0, height: 1)
      }
    case .mapButtonZoomIn:
      return .add { s in Self.floatingControl(s, image: "btn_zoom_in") }
    case .mapButtonZoomOut:
      return .add { s in Self.floatingControl(s, image: "btn_zoom_out") }
    case .mapButtonPending:
      return .add { s in Self.floatingControl(s, image: "btn_pending") }
    case .mapButtonGetPosition:
      return .add { s in Self.floatingControl(s, image: "btn_get_position") }
    case .mapButtonFollow:
      // The follow state stays opaque so its white arrow remains legible.
      return .add { s in
        Self.floatingControl(s, image: "btn_follow", coloring: .whiteText)
        s.backgroundColor = InterfaceStyleSheet.filledAccent
        s.allowsGlass = false
      }
    case .mapButtonFollowAndRotate:
      // Glass like the other map buttons; the accent icon marks the active heading mode.
      return .add { s in Self.floatingControl(s, image: "btn_follow_and_rotate") }
    case .mapButtonMapBookmarks:
      return .add { s in Self.floatingControl(s, image: "ic_routing_bookmark") }
    case .mapButtonNavigationRecord:
      // The recording state sets the coloring in code.
      return .add { s in Self.floatingControl(s, image: "ic_menu_track_recording", coloring: nil) }
    case .mapButtonMapSearch:
      // The search state sets the icon in code.
      return .add { s in Self.floatingControl(s, image: nil) }
    case .mapPromoDiscoveryButton:
      return .add { s in
        s.mwmImage = "promo_discovery_button"
      }
    case .mapButtonBookmarksBack:
      return .add { s in
        s.mwmImage = "btn_back"
      }
    case .mapButtonBookmarksBackOpaque:
      return .add { s in
        s.mwmImage = "btn_back_opaque"
      }
    case .mapFirstTurnView:
      return .add { s in
        s.backgroundColor = InterfaceStyleSheet.filledAccent
        s.cornerRadius = .buttonSmall
        s.shadowRadius = 2
        s.shadowColor = .blackHintText
        s.shadowOpacity = 1
        s.shadowOffset = CGSize(width: 0, height: 2)
      }
    case .mapSecondTurnView:
      return .addFrom(Self.mapFirstTurnView) { s in
        s.backgroundColor = InterfaceStyleSheet.surface
      }
    case .mapTurnGlyphOnAccent:
      return .add { s in
        s.tintColor = .white
      }
    case .mapTurnTextOnAccent:
      return .add { s in
        s.fontColor = .white
      }
    case .mapTurnGlyphAccent:
      return .add { s in
        s.tintColor = InterfaceStyleSheet.accent
      }
    case .mapAutoupdateView:
      return .add { s in
        s.shadowOffset = CGSize(width: 0, height: 3)
        s.shadowRadius = 6
        s.cornerRadius = .buttonSmall
        s.shadowOpacity = 1
        s.backgroundColor = .whitePrimary
      }
    case .mapGuidesNavigationBar:
      return .add { s in
        s.barTintColor = .whitePrimary
        s.tintColor = .linkBlue
        s.backgroundImage = UIImage()
        s.shadowImage = UIImage()
        s.fontStyle = .dynamic(.regular18)
        s.fontColor = .blackPrimaryText
      }
    }
  }
}

private extension MapStyleSheet {
  static func floatingControl(_ s: Style, image: String?, coloring: MWMButtonColoring? = .blue) {
    InterfaceStyleSheet.floatingSurface(s)
    s.cornerRadius = .floating(20)
    s.usesFloatingSurface = true
    if let coloring {
      s.coloring = coloring
    }
    if let image {
      s.mwmImage = image
    }
  }
}
