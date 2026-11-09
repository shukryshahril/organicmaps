import UIKit

/// Shared symbols for app controls; map features retain their cartographic icons.
enum InterfaceIcon: String, CaseIterable {
  case search, bookmarks, menu, about, support
  case zoomIn, zoomOut, locating, location, follow, followHeading
  case addPlace, updateMap, record, stopRecording, download, settings, share
  case outdoor, contours, hiking, cycling, transit, satellite, chooseOnMap, close
  case routeFrom, routeTo, startNavigation, destination, routeSettings, swap, saveRoute, coordinates, coordinateFormat, externalApp
  case help, reorder, bookmarkRemove, bookmarkRestore

  var symbolName: String {
    switch self {
    case .search: return "magnifyingglass"
    case .bookmarks: return "bookmark"
    case .menu: return "slider.horizontal.3"
    case .about: return "info.circle"
    case .support: return "heart"
    case .zoomIn: return "plus"
    case .zoomOut: return "minus"
    case .locating: return "arrow.triangle.2.circlepath"
    case .location: return "location"
    case .follow: return "location.fill"
    case .followHeading: return "location.north.line.fill"
    case .addPlace: return "mappin.and.ellipse"
    case .updateMap: return "exclamationmark.arrow.triangle.2.circlepath"
    case .record: return "record.circle"
    case .stopRecording: return "stop.circle.fill"
    case .download: return "arrow.down.circle"
    case .settings: return "gearshape"
    case .share: return "square.and.arrow.up"
    case .outdoor: return "leaf"
    case .contours: return "map"
    case .hiking: return "figure.walk"
    case .cycling: return "bicycle"
    case .transit: return "tram"
    case .satellite: return "globe"
    case .chooseOnMap: return "mappin.circle"
    case .close: return "xmark"
    case .routeFrom: return "arrow.up.forward.circle"
    case .routeTo: return "arrow.triangle.turn.up.right.diamond.fill"
    case .startNavigation: return "location.north.fill"
    case .destination: return "flag.checkered"
    case .routeSettings: return "slider.horizontal.3"
    case .swap: return "arrow.up.arrow.down"
    case .saveRoute: return "square.and.arrow.down"
    case .coordinates: return "scope"
    case .coordinateFormat: return "chevron.up.chevron.down"
    case .externalApp: return "arrow.up.right.square"
    case .help: return "questionmark.circle"
    case .reorder: return "line.3.horizontal"
    case .bookmarkRemove: return "bookmark.slash"
    case .bookmarkRestore: return "arrow.uturn.backward.circle"
    }
  }

  private var fallbackAsset: String {
    switch self {
    case .search: return "ic_menu_search"
    case .bookmarks: return "ic_menu_bookmark_list"
    case .menu: return "ic_menu"
    case .about: return "logo"
    case .support: return "ic_menu_donate"
    case .zoomIn: return "btn_zoom_in"
    case .zoomOut: return "btn_zoom_out"
    case .locating: return "btn_pending"
    case .location: return "btn_get_position"
    case .follow: return "btn_follow"
    case .followHeading: return "btn_follow_and_rotate"
    case .addPlace: return "ic_menu_add_place"
    case .updateMap: return "ic_menu_add_place_exclamation"
    case .record, .stopRecording: return "ic_menu_track_recording"
    case .download: return "ic_menu_download"
    case .settings: return "ic_menu_settings"
    case .share: return "ic_menu_share"
    case .outdoor: return "btn_menu_outdoors"
    case .contours: return "btn_menu_isomaps"
    case .hiking: return "btn_menu_hiking"
    case .cycling: return "btn_menu_cycling"
    case .transit: return "btn_menu_subway"
    case .satellite: return "btn_menu_satellite"
    case .chooseOnMap: return "ic_search_mode_map"
    case .close: return "ic_close"
    case .routeFrom: return "ic_route_from"
    case .routeTo, .startNavigation, .destination: return "ic_route_to"
    case .routeSettings: return "ic_menu_settings"
    case .swap: return "ic_swap"
    case .saveRoute: return "ic24PxImport"
    case .coordinates: return "ic_placepage_coordinate"
    case .coordinateFormat: return "ic_placepage_change"
    case .externalApp: return "ic_open_in_app"
    case .help: return "ic_questionmark"
    case .reorder: return "ic_move_list"
    case .bookmarkRemove: return "ic_bookmarks_on"
    case .bookmarkRestore: return "ic_bookmarks_off"
    }
  }

  var image: UIImage { image(canvasSize: 28) }
  var boldImage: UIImage { image(canvasSize: 28, weight: .bold) }
  // Leave room for the circular header background without clipping the glyph's corners.
  var boldCircleImage: UIImage { image(canvasSize: 36, weight: .bold) }

  // A consistent canvas prevents wide symbols stretching or changing the control layout.
  func image(canvasSize: CGFloat, weight: UIImage.SymbolWeight = .medium) -> UIImage {
    let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: weight)
    let source = UIImage(systemName: symbolName, withConfiguration: configuration)
      ?? UIImage(named: fallbackAsset) ?? UIImage()
    let size = source.size
    guard size.width > 0, size.height > 0 else { return source }
    // A smaller close glyph gives the cross breathing room inside compact buttons.
    let glyphSize: CGFloat = self == .close ? 20 : 24
    let scale = min(glyphSize / size.width, glyphSize / size.height)
    let rect = CGRect(x: (canvasSize - size.width * scale) / 2,
                      y: (canvasSize - size.height * scale) / 2,
                      width: size.width * scale, height: size.height * scale)
    return UIGraphicsImageRenderer(size: CGSize(width: canvasSize, height: canvasSize)).image { _ in
      source.withTintColor(.black, renderingMode: .alwaysOriginal).draw(in: rect)
    }.withRenderingMode(.alwaysTemplate)
  }
}

/// Resolve only explicitly migrated controls, preserving other legacy button assets and animations.
@objc(MWMInterfaceIcons)
final class InterfaceIcons: NSObject {
  @objc static func boldImage(forAssetName name: String) -> UIImage? {
    let icons: [String: InterfaceIcon] = [
      "ic_route_from": .routeFrom, "ic_route_to": .routeTo, "personal_start": .startNavigation,
      "ic_bookmarks_off": .bookmarks, "ic_bookmarks_on": .bookmarkRemove,
      "personal_bookmark_restore": .bookmarkRestore,
    ]
    return icons[name]?.boldImage
  }

  @objc static func image(forAssetName name: String?) -> UIImage? {
    guard let name else { return nil }
    let icons: [String: InterfaceIcon] = [
      "ic_menu_search": .search, "ic_menu_bookmark_list": .bookmarks, "ic_menu": .menu,
      "personal_about": .about, "personal_support": .support,
      "btn_zoom_in": .zoomIn, "btn_zoom_out": .zoomOut, "btn_pending": .locating,
      "btn_get_position": .location, "btn_follow": .follow, "btn_follow_and_rotate": .followHeading,
    ]
    return icons[name]?.image
  }
}
