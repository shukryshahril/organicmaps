extension NavigationDashboard {
  enum Request {
    case updateState(MWMNavigationDashboardState)
    case updateRoutePoints
    case startNavigation
    case stopNavigation
    case showError(String)

    case selectRouterType(MWMRouterType)
    case selectRoutePoint(MWMRoutePointSelection)
    case deleteRoutePoint(MWMRoutePoint)
    case moveRoutePoint(from: Int, to: Int)
    case reverseRoutePoints

    case addRoutePointButtonDidTap
    case startButtonDidTap
    case settingsButtonDidTap
    case searchButtonDidTap
    case bookmarksButtonDidTap
    case saveRouteAsTrackButtonDidTap

    case updateRouteBuildingProgress(CGFloat, routerType: MWMRouterType)
    case updateNavigationInfo(MWMNavigationDashboardEntity)
    case updateElevationInfo(RouteElevationPreviewData?, activePointDistance: Double?)
    case updateVisibleAreaInsets(UIEdgeInsets)
    case updateNavigationInfoAvailableArea(CGRect)
    case updateSearchState(SearchOnMapState)
    case updateDrivingOptionsState(MWMDrivingOptionsState)

    case didUpdatePresentationStep(NavigationDashboardModalPresentationStep)
    case setHidden(Bool)
    case close
  }
}

extension MWMRouterType: CaseIterable {
  public static var allCases: [MWMRouterType] = [
    .vehicle,
    .pedestrian,
    .publicTransport,
    .bicycle,
    .ruler,
  ]

  func image(for isSelected: Bool, traits: UITraitCollection = .current) -> UIImage {
    var image: UIImage
    switch self {
    case .vehicle:
      image = UIImage(resource: .navigationDashboardCar)
    case .pedestrian:
      image = UIImage(resource: .navigationDashboardWalk)
    case .publicTransport:
      image = UIImage(resource: .navigationDashboardTrain)
    case .bicycle:
      image = UIImage(resource: .navigationDashboardBike)
    case .ruler:
      image = UIImage(resource: .navigationDashboardRuler)
    @unknown default:
      fatalError("Unknown router type")
    }
    let color = isSelected ? InterfaceStyleSheet.accent : InterfaceStyleSheet.ink.withAlphaComponent(0.6)
    return image.withTintColor(color.resolvedColor(with: traits), renderingMode: .alwaysOriginal)
  }
}
