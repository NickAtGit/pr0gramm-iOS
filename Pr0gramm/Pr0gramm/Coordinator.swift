
import UIKit
import AVKit

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
    
    func showShareSheet(with items: [Any]) {
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
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
        navigationController.style = .dragable
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

    func showReplyForPost(viewModel: DetailViewModel) {
        let viewController = ReplyViewController.fromStoryboard()
        viewController.viewModel = viewModel
        let navigationController = NavigationController(rootViewController: viewController)
        navigationController.style = .dismissable
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController.present(navigationController, animated: true)
    }

    func showReply(for comment: Comment, viewModel: DetailViewModel, from presentingViewController: CommentsViewController) {
        let viewController = ReplyViewController.fromStoryboard()
        viewController.viewModel = viewModel
        viewController.comment = comment
        let navigationController = NavigationController(rootViewController: viewController)
        navigationController.style = .dismissable
        navigationController.modalPresentationStyle = .fullScreen
        presentingViewController.present(navigationController, animated: true)
    }
    
    @objc
    func logout() {
        pr0grammConnector.logout()
    }
}
