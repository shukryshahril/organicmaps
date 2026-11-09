import UIKit

final class ColorThemeSettingsViewController: MWMTableViewController {
  private let palettes = InterfacePalette.allCases

  init() {
    super.init(style: .insetGrouped)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = L("pref_color_theme_title")
    tableView.register(ColorThemeCell.self, forCellReuseIdentifier: "ColorThemeCell")
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 150
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    palettes.count
  }

  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    L("pref_color_theme_summary")
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ColorThemeCell", for: indexPath) as! ColorThemeCell
    cell.configure(palettes[indexPath.row])
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let palette = palettes[indexPath.row]
    guard palette != InterfacePalette.current else { return }
    InterfacePalette.current = palette
    InterfaceStyleSheet.applyInterfacePreferences()
    tableView.reloadData()
  }
}

private final class ColorThemeCell: MWMTableViewCell {
  private let nameLabel = UILabel()
  private let lightPreview = PalettePreview(isDark: false)
  private let darkPreview = PalettePreview(isDark: true)
  private var palette: InterfacePalette = .forest

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setStyle(.background)
    nameLabel.numberOfLines = 0
    nameLabel.adjustsFontForContentSizeCategory = true

    let previews = UIStackView(arrangedSubviews: [lightPreview, darkPreview])
    previews.axis = .horizontal
    previews.distribution = .fillEqually
    previews.spacing = 10
    let stack = UIStackView(arrangedSubviews: [nameLabel, previews])
    stack.axis = .vertical
    stack.spacing = 10
    stack.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
      stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
      stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
    ])
    isAccessibilityElement = true
    accessibilityHint = L("pref_color_theme_preview_hint")
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(_ palette: InterfacePalette) {
    self.palette = palette
    let name = L(palette.titleKey)
    nameLabel.text = palette == .forest ? "\(name) · \(L("pref_color_theme_default"))" : name
    accessibilityLabel = nameLabel.text
    applyTheme()
  }

  override func applyTheme() {
    super.applyTheme()
    nameLabel.font = InterfaceStyleSheet.headingFont.font
    nameLabel.textColor = InterfaceStyleSheet.ink
    tintColor = InterfaceStyleSheet.accent
    let selected = palette == InterfacePalette.current
    accessoryType = selected ? .checkmark : .none
    accessibilityTraits = selected ? [.button, .selected] : [.button]
    lightPreview.configure(palette)
    darkPreview.configure(palette)
  }
}

/// Fixed light and dark samples are visible together, regardless of the phone's current appearance.
private final class PalettePreview: UIView {
  private let isDark: Bool
  private let modeLabel = UILabel()
  private let searchLabel = UILabel()
  private let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
  private let field = UIView()

  init(isDark: Bool) {
    self.isDark = isDark
    super.init(frame: .zero)
    isAccessibilityElement = false
    accessibilityElementsHidden = true
    modeLabel.text = L(isDark ? "pref_appearance_dark" : "pref_appearance_light")
    modeLabel.numberOfLines = 0
    modeLabel.adjustsFontForContentSizeCategory = true
    searchLabel.text = L("search")
    searchLabel.numberOfLines = 0
    searchLabel.adjustsFontForContentSizeCategory = true
    searchIcon.contentMode = .scaleAspectFit

    let search = UIStackView(arrangedSubviews: [searchIcon, searchLabel])
    search.axis = .horizontal
    search.alignment = .center
    search.spacing = 5
    search.translatesAutoresizingMaskIntoConstraints = false
    field.addSubview(search)
    let content = UIStackView(arrangedSubviews: [modeLabel, field])
    content.axis = .vertical
    content.spacing = 8
    content.translatesAutoresizingMaskIntoConstraints = false
    addSubview(content)
    NSLayoutConstraint.activate([
      content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
      content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
      content.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
      search.leadingAnchor.constraint(equalTo: field.leadingAnchor, constant: 7),
      search.trailingAnchor.constraint(equalTo: field.trailingAnchor, constant: -7),
      search.topAnchor.constraint(equalTo: field.topAnchor, constant: 8),
      search.bottomAnchor.constraint(equalTo: field.bottomAnchor, constant: -8),
      searchIcon.widthAnchor.constraint(equalToConstant: 14),
      searchIcon.heightAnchor.constraint(equalToConstant: 14),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(_ palette: InterfacePalette) {
    let colors = palette.colors(isDark: isDark)
    backgroundColor = InterfaceStyleSheet.uiColor(colors.background)
    layer.cornerRadius = InterfaceStyleSheet.isPixel ? 0 : 10
    layer.borderWidth = InterfaceStyleSheet.isPixel ? 2 : 1
    layer.borderColor = InterfaceStyleSheet.uiColor(colors.border).withAlphaComponent(0.5).cgColor
    modeLabel.font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 12, weight: .medium))
    modeLabel.textColor = InterfaceStyleSheet.uiColor(colors.ink)
    field.backgroundColor = InterfaceStyleSheet.uiColor(colors.surface)
    field.layer.cornerRadius = InterfaceStyleSheet.isPixel ? 0 : 6
    searchIcon.tintColor = InterfaceStyleSheet.uiColor(colors.accent)
    searchLabel.textColor = InterfaceStyleSheet.uiColor(colors.ink)
    searchLabel.font = UIFontMetrics.default.scaledFont(for: InterfaceStyleSheet.isPixel
      ? .monospacedSystemFont(ofSize: 13, weight: .regular) : .systemFont(ofSize: 13))
  }
}
