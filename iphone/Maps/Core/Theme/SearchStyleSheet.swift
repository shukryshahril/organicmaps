enum SearchStyleSheet: String, CaseIterable {
  case searchOnMapSearchBar
  case searchCancelButton
  case searchPopularView = "SearchPopularView"
  case searchSideAvailableMarker = "SearchSideAvaliableMarker"
}

extension SearchStyleSheet: IStyleSheet {
  var styleResolver: Theme.StyleResolver {
    switch self {
    case .searchOnMapSearchBar:
      return .add { s in
        s.backgroundColor = InterfaceStyleSheet.background
        s.barTintColor = .clear
        s.fontColor = InterfaceStyleSheet.ink
        s.fontColorDetailed = InterfaceStyleSheet.accent
        s.tintColor = InterfaceStyleSheet.accent
        s.fontStyle = InterfaceStyleSheet.searchFont
        s.cornerRadius = .buttonDefaultBig
        s.borderColor = InterfaceStyleSheet.border
        s.borderWidth = InterfaceStyleSheet.isPixel ? 2 : 0
      }
    case .searchPopularView:
      return .add { s in
        s.cornerRadius = .custom(10)
        s.backgroundColor = InterfaceStyleSheet.accent.withAlphaComponent(0.12)
      }
    case .searchSideAvailableMarker:
      return .add { s in
        s.backgroundColor = .ratingGreen
      }
    case .searchCancelButton:
      return .add { s in
        s.fontColor = InterfaceStyleSheet.accent
        s.fontColorHighlighted = InterfaceStyleSheet.accent.withAlphaComponent(0.7)
        s.fontStyle = .dynamic(.regular17)
        s.backgroundColor = .clear
      }
    }
  }
}
