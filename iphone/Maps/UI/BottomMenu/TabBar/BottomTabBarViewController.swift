class BottomTabBarViewController: UIViewController {
  var presenter: BottomTabBarPresenterProtocol!

  @IBOutlet var searchButton: MWMButton!
  @IBOutlet var helpButton: MWMButton!
  @IBOutlet var bookmarksButton: MWMButton!
  @IBOutlet var moreButton: MWMButton!
  @IBOutlet var downloadBadge: UIView!

  private var avaliableArea = CGRect.zero
  @objc var isHidden: Bool = false {
    didSet {
      updateFrame(animated: true)
    }
  }

  @objc var isApplicationBadgeHidden: Bool = true {
    didSet {
      updateBadge()
    }
  }

  @objc static var controller: BottomTabBarViewController? { MWMMapViewControlsManager.manager()?.tabBarController }

  override func viewDidLoad() {
    super.viewDidLoad()
    searchButton.accessibilityLabel = L("search")
    bookmarksButton.accessibilityLabel = L("bookmarks")
    moreButton.accessibilityLabel = L("menu")
    searchButton.imageName = "ic_menu_search"
    bookmarksButton.imageName = "ic_menu_bookmark_list"
    moreButton.imageName = "ic_menu"
    helpButton.imageName = "personal_about"
    view.alpha = 0 // Hide the view until it receives a first available area update.
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    presenter.viewWillAppear()
  }

  func updateAboutButtonIcon(isCrowdfunding: Bool) {
    helpButton.accessibilityLabel = L("about_menu_title")
    helpButton.imageName = isCrowdfunding ? "personal_support" : "personal_about"
    updateBadge()
  }

  static func updateAvailableArea(_ frame: CGRect) {
    BottomTabBarViewController.controller?.updateAvailableArea(frame)
  }

  @IBAction func onSearchButtonPressed(_: Any) {
    presenter.onSearchButtonPressed()
  }

  @IBAction func onHelpButtonPressed(_: Any) {
    presenter.onHelpButtonPressed()
  }

  @IBAction func onBookmarksButtonPressed(_: Any) {
    presenter.onBookmarksButtonPressed()
  }

  @IBAction func onMenuButtonPressed(_: Any) {
    presenter.onMenuButtonPressed()
  }

  private func updateAvailableArea(_ frame: CGRect) {
    avaliableArea = frame
    updateFrame(animated: false)
    view.layoutIfNeeded()
  }

  private func updateFrame(animated: Bool) {
    if avaliableArea == .zero {
      return
    }
    let newFrame = CGRect(x: avaliableArea.minX,
                          y: isHidden ? avaliableArea.minY + avaliableArea.height : avaliableArea.minY,
                          width: avaliableArea.width,
                          height: avaliableArea.height)
    let alpha: CGFloat = isHidden ? 0 : 1
    if animated {
      UIView.animate(withDuration: AppConstants.defaultAnimationDuration,
                     delay: 0,
                     options: [.beginFromCurrentState],
                     animations: {
                       self.view.frame = newFrame
                       self.view.alpha = alpha
                     }, completion: nil)
    } else {
      view.frame = newFrame
      view.alpha = alpha
    }
  }

  private func updateBadge() {
    downloadBadge.isHidden = isApplicationBadgeHidden
  }
}
