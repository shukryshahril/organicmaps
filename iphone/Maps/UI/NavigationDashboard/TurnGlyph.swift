import UIKit

/// Raised, rounded turn icons drawn in the palette accent. Names match the stock asset names.
@objc(MWMTurnGlyph)
final class TurnGlyph: NSObject {
  private enum Shape {
    case straight, slight, turn, sharp, uturn, exit, roundabout, finish
  }

  private struct Spec {
    let shape: Shape
    let mirrored: Bool
  }

  private static let specs: [String: Spec] = [
    "straight": Spec(shape: .straight, mirrored: false),
    "slight_right": Spec(shape: .slight, mirrored: false),
    "slight_left": Spec(shape: .slight, mirrored: true),
    "simple_right": Spec(shape: .turn, mirrored: false),
    "simple_left": Spec(shape: .turn, mirrored: true),
    "sharp_right": Spec(shape: .sharp, mirrored: false),
    "sharp_left": Spec(shape: .sharp, mirrored: true),
    "uturn_left": Spec(shape: .uturn, mirrored: false),
    "uturn_right": Spec(shape: .uturn, mirrored: true),
    "ic_exit_highway_to_right": Spec(shape: .exit, mirrored: false),
    "ic_exit_highway_to_left": Spec(shape: .exit, mirrored: true),
    "round": Spec(shape: .roundabout, mirrored: false),
    "finish_point": Spec(shape: .finish, mirrored: false),
  ]

  private static var cache: [String: UIImage] = [:]
  private static let cacheLock = NSLock()

  /// `name` is a stock turn asset name; a `_then` suffix gives the small next-turn icon.
  @objc(imageNamed:) static func image(named name: String) -> UIImage? {
    let isNext = name.hasSuffix("_then")
    let base = isNext ? String(name.dropLast("_then".count)) : name
    guard let spec = specs[base] else { return UIImage(named: name) }
    let key = "\(base)|\(isNext)|\(InterfacePalette.current.rawValue)"
    cacheLock.lock()
    defer { cacheLock.unlock() }
    if let cached = cache[key] { return cached }

    let size: CGFloat = isNext ? 28 : 64
    let asset = UIImageAsset()
    for isDark in [false, true] {
      let colors = Colors(isNext: isNext, isDark: isDark)
      let traits = UITraitCollection(traitsFrom: [UITraitCollection(userInterfaceStyle: isDark ? .dark : .light),
                                                  UITraitCollection(displayScale: UIScreen.main.scale)])
      asset.register(render(spec, size: size, colors: colors), with: traits)
    }
    let image = asset.image(with: UITraitCollection.current)
    cache[key] = image
    return image
  }

  // MARK: Colours

  private struct Colors {
    let faceTop: UIColor
    let faceBottom: UIColor
    let side: UIColor
    let detail: UIColor

    init(isNext: Bool, isDark: Bool) {
      let palette = InterfacePalette.current
      if isNext {
        // On the surface chip the glyph itself carries the accent.
        let accent = InterfaceStyleSheet.uiColor(palette.colors(isDark: isDark).accent)
        faceTop = accent.mixed(with: .white, amount: 0.22)
        faceBottom = accent
        side = accent.mixed(with: .black, amount: 0.38)
        detail = InterfaceStyleSheet.uiColor(palette.colors(isDark: isDark).surface)
      } else {
        // On the filled accent banner the glyph is a raised white tile.
        let accent = InterfaceStyleSheet.uiColor(palette.colors(isDark: false).accent)
        faceTop = .white
        faceBottom = UIColor(white: 0.9, alpha: 1)
        side = accent.mixed(with: .black, amount: 0.45)
        detail = accent
      }
    }
  }

  // MARK: Geometry (100 × 100 design grid, y down)

  private static let stroke: CGFloat = 15

  private static func paths(for shape: Shape) -> (shaft: CGPath, ring: CGPath?, heads: [CGPath], detail: CGPath?) {
    let shaft = CGMutablePath()
    var ring: CGPath?
    var heads: [CGPath] = []
    var detail: CGPath?
    switch shape {
    case .straight:
      shaft.move(to: CGPoint(x: 50, y: 92))
      shaft.addLine(to: CGPoint(x: 50, y: 40))
      heads.append(head(at: CGPoint(x: 50, y: 10), angle: -.pi / 2))
    case .slight:
      shaft.move(to: CGPoint(x: 36, y: 92))
      shaft.addLine(to: CGPoint(x: 36, y: 66))
      shaft.addQuadCurve(to: CGPoint(x: 54, y: 46), control: CGPoint(x: 36, y: 54))
      heads.append(head(at: CGPoint(x: 75, y: 25), angle: -.pi / 4))
    case .turn:
      shaft.move(to: CGPoint(x: 28, y: 92))
      shaft.addLine(to: CGPoint(x: 28, y: 60))
      shaft.addQuadCurve(to: CGPoint(x: 44, y: 44), control: CGPoint(x: 28, y: 44))
      shaft.addLine(to: CGPoint(x: 54, y: 44))
      heads.append(head(at: CGPoint(x: 84, y: 44), angle: 0))
    case .sharp:
      shaft.move(to: CGPoint(x: 24, y: 92))
      shaft.addLine(to: CGPoint(x: 24, y: 40))
      shaft.addQuadCurve(to: CGPoint(x: 42, y: 22), control: CGPoint(x: 24, y: 22))
      shaft.addLine(to: CGPoint(x: 54, y: 38))
      heads.append(head(at: CGPoint(x: 72, y: 66), angle: atan2(28, 18)))
    case .uturn:
      shaft.move(to: CGPoint(x: 68, y: 92))
      shaft.addLine(to: CGPoint(x: 68, y: 44))
      shaft.addArc(center: CGPoint(x: 50, y: 44), radius: 18, startAngle: 0, endAngle: .pi, clockwise: true)
      shaft.addLine(to: CGPoint(x: 32, y: 52))
      heads.append(head(at: CGPoint(x: 32, y: 84), angle: .pi / 2))
    case .exit:
      let road = CGMutablePath()
      road.move(to: CGPoint(x: 34, y: 92))
      road.addLine(to: CGPoint(x: 34, y: 12))
      detail = road
      shaft.move(to: CGPoint(x: 34, y: 92))
      shaft.addLine(to: CGPoint(x: 34, y: 74))
      shaft.addQuadCurve(to: CGPoint(x: 52, y: 50), control: CGPoint(x: 34, y: 58))
      heads.append(head(at: CGPoint(x: 73, y: 29), angle: -.pi / 4))
    case .roundabout:
      // Centred ring so the exit number label sits inside it; the exit head is smaller to stay distinct.
      ring = CGPath(ellipseIn: CGRect(x: 30, y: 30, width: 40, height: 40), transform: nil)
      shaft.move(to: CGPoint(x: 50, y: 70))
      shaft.addLine(to: CGPoint(x: 50, y: 96))
      heads.append(head(at: CGPoint(x: 50, y: 2), angle: -.pi / 2, scale: 0.72))
    case .finish:
      let pin = CGMutablePath()
      pin.addArc(center: CGPoint(x: 50, y: 40), radius: 26, startAngle: .pi * 0.8, endAngle: .pi * 0.2, clockwise: false)
      pin.addQuadCurve(to: CGPoint(x: 50, y: 92), control: CGPoint(x: 62, y: 72))
      pin.addQuadCurve(to: CGPoint(x: 50 - 26 * cos(.pi * 0.2), y: 40 + 26 * sin(.pi * 0.2)),
                       control: CGPoint(x: 38, y: 72))
      pin.closeSubpath()
      heads.append(pin)
      detail = CGPath(ellipseIn: CGRect(x: 40, y: 30, width: 20, height: 20), transform: nil)
    }
    return (shaft, ring, heads, detail)
  }

  /// Rounded arrowhead whose tip sits at `tip`, pointing along `angle`.
  private static func head(at tip: CGPoint, angle: CGFloat, scale: CGFloat = 1) -> CGPath {
    let triangle = CGMutablePath()
    triangle.move(to: CGPoint(x: 0, y: 0))
    triangle.addLine(to: CGPoint(x: -26, y: -19))
    triangle.addLine(to: CGPoint(x: -26, y: 19))
    triangle.closeSubpath()
    let rounded = triangle.copy(strokingWithWidth: 7, lineCap: .round, lineJoin: .round, miterLimit: 1)
    let combined = CGMutablePath()
    combined.addPath(triangle)
    combined.addPath(rounded)
    var transform = CGAffineTransform(translationX: tip.x, y: tip.y).rotated(by: angle).scaledBy(x: scale, y: scale).translatedBy(x: -3.5, y: 0)
    return combined.copy(using: &transform) ?? combined
  }

  // MARK: Rendering

  private static func render(_ spec: Spec, size: CGFloat, colors: Colors) -> UIImage {
    let (shaft, ring, heads, detail) = paths(for: spec.shape)
    let k = size / 100
    var transform = CGAffineTransform(scaleX: spec.mirrored ? -k : k, y: k)
      .concatenating(CGAffineTransform(translationX: spec.mirrored ? size : 0, y: 0))
    let stroked = shaft.copy(strokingWithWidth: stroke, lineCap: .round, lineJoin: .round, miterLimit: 1)
    let shape = CGMutablePath()
    shape.addPath(stroked, transform: transform)
    if let ring {
      shape.addPath(ring.copy(strokingWithWidth: stroke * 0.75, lineCap: .round, lineJoin: .round, miterLimit: 1),
                    transform: transform)
    }
    heads.forEach { shape.addPath($0, transform: transform) }
    let detailPath = detail.flatMap { path -> CGPath? in
      let width: CGFloat = spec.shape == .exit ? stroke * 0.55 : 0
      let source = width > 0 ? path.copy(strokingWithWidth: width, lineCap: .round, lineJoin: .round, miterLimit: 1)
        : path
      return source.copy(using: &transform)
    }

    let depth = max(1.5, size * 0.055)
    let format = UIGraphicsImageRendererFormat.preferred()
    format.opaque = false
    let bounds = CGRect(x: 0, y: 0, width: size, height: size)
    return UIGraphicsImageRenderer(bounds: bounds, format: format).image { context in
      let cg = context.cgContext
      let mask = maskImage(shape, size: size, scale: format.scale)

      // Behind the main road on exits: a quieter lane in the side colour.
      if spec.shape == .exit, let detailPath {
        cg.addPath(detailPath)
        cg.setFillColor(colors.side.withAlphaComponent(0.55).cgColor)
        cg.fillPath()
      }

      // Raised side and soft drop shadow.
      cg.saveGState()
      cg.setShadow(offset: CGSize(width: 0, height: depth * 0.8), blur: depth * 1.4,
                   color: UIColor.black.withAlphaComponent(0.28).cgColor)
      cg.translateBy(x: 0, y: depth)
      cg.addPath(shape)
      cg.setFillColor(colors.side.cgColor)
      cg.fillPath(using: .winding)
      cg.restoreGState()

      // Face with a top-lit gradient.
      cg.saveGState()
      cg.clip(to: bounds, mask: mask)
      let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                colors: [colors.faceTop.cgColor, colors.faceBottom.cgColor] as CFArray,
                                locations: [0, 1])!
      cg.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size), options: [])

      // Bright rim along the upper edges.
      cg.beginTransparencyLayer(auxiliaryInfo: nil)
      cg.setFillColor(UIColor.white.withAlphaComponent(0.55).cgColor)
      cg.fill(bounds)
      cg.setBlendMode(.destinationOut)
      cg.draw(mask, in: bounds.offsetBy(dx: 0, dy: max(1, size * 0.03)))
      cg.endTransparencyLayer()
      cg.restoreGState()

      if spec.shape == .finish, let detailPath {
        cg.addPath(detailPath)
        cg.setFillColor(colors.detail.cgColor)
        cg.fillPath()
      }
    }
  }

  /// A mask is the robust way to union stroked outlines whose sub-paths wind in different directions.
  private static func maskImage(_ path: CGPath, size: CGFloat, scale: CGFloat) -> CGImage {
    let pixels = Int((size * scale).rounded(.up))
    let context = CGContext(data: nil, width: pixels, height: pixels, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue)!
    context.scaleBy(x: scale, y: scale)
    context.addPath(path)
    context.setFillColor(gray: 1, alpha: 1)
    context.fillPath(using: .winding)
    return context.makeImage()!
  }
}

private extension UIColor {
  func mixed(with other: UIColor, amount: CGFloat) -> UIColor {
    var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
    var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
    getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    other.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
    return UIColor(red: r1 + (r2 - r1) * amount, green: g1 + (g2 - g1) * amount,
                   blue: b1 + (b2 - b1) * amount, alpha: a1 + (a2 - a1) * amount)
  }
}
