
import UIKit
import AVKit
import SafariServices

class Coordinator {
    
    let pr0grammConnector = Pr0grammConnector()
    private let navigationController = NavigationController()
    private let tabbarController = UITabBarController()
    
    init() {
        navigationController.coordinator = self
    }
    
    func startViewController() -> UIViewController {
        let viewController = PostsOverviewCollectionViewController.fromStoryboard()
        viewController.viewModel = PostsOverviewViewModel(style: .main, connector: pr0grammConnector)
        viewController.coordinator = self
        navigationController.style = .main
        navigationController.viewControllers = [viewController]
        
        let downloadedFilesTableViewController = DownloadedFilesTableViewController.fromStoryboard()
        downloadedFilesTableViewController.coordinator = self
        downloadedFilesTableViewController.loadViewIfNeeded()
        let downloadedFilesNavigationController = NavigationController()
        downloadedFilesNavigationController.viewControllers = [downloadedFilesTableViewController]
        
        let settingsViewController = SettingsViewController()
        settingsViewController.loadViewIfNeeded()
        let settingsNavigationController = NavigationController()
        settingsNavigationController.viewControllers = [settingsViewController]
        
        let searchViewController = SearchTableViewController.fromStoryboard()
        searchViewController.viewModel = SearchViewModel(connector: pr0grammConnector)
        searchViewController.coordinator = self
        searchViewController.loadViewIfNeeded()
        let searchNavigationController = NavigationController()
        searchNavigationController.style = .search
        searchNavigationController.viewControllers = [searchViewController]
        
        let userInfoViewController = UserInfoViewController.fromStoryboard()
        userInfoViewController.viewModel = UserInfoViewModel(connector: pr0grammConnector)
        userInfoViewController.coordinator = self
        userInfoViewController.loadViewIfNeeded()
        let profileNavigationController = NavigationController()
        profileNavigationController.coordinator = self
        profileNavigationController.style = .user
        profileNavigationController.viewControllers = [userInfoViewController]

        tabbarController.setViewControllers([navigationController,
                                             searchNavigationController,
                                             profileNavigationController,
                                             downloadedFilesNavigationController,
                                             settingsNavigationController], animated: false)
        return tabbarController
    }
    
    @objc
    func showLogin() {
        let viewController = LoginViewController.fromStoryboard()
        viewController.coordinator = self
        let navigationController = NavigationController(rootViewController: viewController)
        navigationController.style = .dismissable
        navigationController.isModalInPresentation = true
        self.navigationController.present(navigationController, animated: true)
    }
        
    func showDetail(from viewController: UIViewController,
                    with viewModel: PostsOverviewViewModel,
                    at indexPath: IndexPath) {
        
        let detailViewController = DetailCollectionViewController.fromStoryboard()
        detailViewController.coordinator = self
        detailViewController.viewModel = viewModel
        viewController.navigationController?.pushViewController(detailViewController, animated: true)
        detailViewController.scrollTo(indexPath: indexPath)
    }
    
    func showShareSheet(with items: [Any], from view: UIView) {
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        ac.popoverPresentationController?.sourceView = view
        ac.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2,
                                                              y: UIScreen.main.bounds.height * 2/3,
                                                              width: 0,
                                                              height: 0)
        tabbarController.present(ac, animated: true)
    }
    
    func showVideo(with url: URL) {
        let avPlayerViewController = AVPlayerViewController()
        let avPlayer = AVPlayer()
        avPlayerViewController.player = avPlayer
        let playerItem = AVPlayerItem(url: url)
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayer.isMuted = AppSettings.isVideoMuted
        avPlayer.play()
        tabbarController.present(avPlayerViewController, animated: true)
    }
    
    func showImageViewController(with image: UIImage, from viewController: UIViewController) {
        let imageViewController = ImageDetailViewController.fromStoryboard()
        imageViewController.image = image
        let navigationController = NavigationController(rootViewController: imageViewController)
        navigationController.style = .dismissable
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .crossDissolve
        viewController.present(navigationController, animated: true)
    }
    
    func showSearchResult(for tag: String, from viewController: UIViewController) {
        let searchResultViewController = PostsOverviewCollectionViewController.fromStoryboard()
        searchResultViewController.title = tag
        searchResultViewController.viewModel = PostsOverviewViewModel(style: .search(tags: [tag]),
                                                                      connector: pr0grammConnector)
        searchResultViewController.coordinator = self
        viewController.navigationController?.pushViewController(searchResultViewController, animated: true)
    }
    
    func showUserPosts(for style: PostsOverviewStyle, navigationController: UINavigationController) {
        let searchResultViewController = PostsOverviewCollectionViewController.fromStoryboard()
        searchResultViewController.viewModel = PostsOverviewViewModel(style: style,
                                                                      connector: pr0grammConnector)
        searchResultViewController.coordinator = self
        navigationController.pushViewController(searchResultViewController, animated: true)
    }

    
    func showUserProfile(for name: String, viewController: UIViewController) {
        let userInfoViewController = UserInfoViewController.fromStoryboard()
        userInfoViewController.viewModel = UserInfoViewModel(name: name, connector: pr0grammConnector)
        userInfoViewController.coordinator = self
        let profileNavigationController = NavigationController()
        profileNavigationController.coordinator = self
        profileNavigationController.style = .dismissable
        profileNavigationController.modalPresentationStyle = .fullScreen
        profileNavigationController.viewControllers = [userInfoViewController]
        navigationController.present(profileNavigationController, animated: true)
    }
    
    func showReplyForPost(viewModel: DetailViewModel) {
        let viewController = ReplyViewController.fromStoryboard()
        viewController.viewModel = viewModel
        let navigationController = NavigationController(rootViewController: viewController)
        navigationController.style = .dismissable
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController.present(navigationController, animated: true)
    }

    func showReply(for comment: Comment,
                   viewModel: DetailViewModel,
                   from presentingViewController: CommentsViewController) {
        let viewController = ReplyViewController.fromStoryboard()
        viewController.viewModel = viewModel
        viewController.comment = comment
        let navigationController = NavigationController(rootViewController: viewController)
        navigationController.style = .dismissable
        navigationController.modalPresentationStyle = .fullScreen
        presentingViewController.present(navigationController, animated: true)
    }
    
    func showCollections(viewModel: UserInfoViewModel,
                         navigationController: UINavigationController) {
        let viewController = CollectionsTableViewController.fromStoryboard()
        viewController.viewModel = viewModel
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func showWebViewViewController(for url: URL,
                                  from presentingViewController: UIViewController) {
        let webViewViewController = SFSafariViewController(url: url)
        presentingViewController.present(webViewViewController, animated: true)
    }
    
    @objc
    func logout() {
        pr0grammConnector.logout()
    }
}
