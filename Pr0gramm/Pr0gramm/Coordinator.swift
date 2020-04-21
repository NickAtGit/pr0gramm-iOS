
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
        let viewController = MainCollectionViewController.fromStoryboard()
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
        searchViewController.coordinator = self
        searchViewController.connector = pr0grammConnector
        searchViewController.loadViewIfNeeded()
        let searchNavigationController = NavigationController()
        searchNavigationController.viewControllers = [searchViewController]
        
        tabbarController.setViewControllers([navigationController,
                                             searchNavigationController,
                                             downloadedFilesNavigationController,
                                             settingsNavigationController], animated: false)
        return tabbarController
    }
    
    @objc
    func showLogin() {
        let viewController = LoginViewController.fromStoryboard()
        viewController.coordinator = self
        let detailNavigationController = NavigationController(rootViewController: viewController)
        detailNavigationController.style = .dismissable
        navigationController.present(detailNavigationController, animated: true)
    }
    
    func showOverview() {
        let viewController = MainCollectionViewController.fromStoryboard()
        viewController.coordinator = self
        navigationController.viewControllers = [viewController]
    }
    
    func showDetail(from viewController: UIViewController,
                    with items: [Item],
                    at indexPath: IndexPath,
                    isSearch: Bool = false) {
        
        let detailViewController = DetailCollectionViewController.fromStoryboard()
        detailViewController.isSearch = isSearch
        detailViewController.coordinator = self
        detailViewController.items = items
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
        avPlayer.isMuted = false
        avPlayerViewController.player = avPlayer
        let playerItem = AVPlayerItem(url: url)
        avPlayer.replaceCurrentItem(with: playerItem)
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
        pr0grammConnector.searchItems(for: [tag]) { [unowned self] items in
            let searchResultViewController = MainCollectionViewController.fromStoryboard()
            searchResultViewController.title = tag
            searchResultViewController.isSearch = true
            searchResultViewController.coordinator = self
            searchResultViewController.items = items
            viewController.navigationController?.pushViewController(searchResultViewController, animated: true)
        }
    }
    
    func showComments(viewModel: DetailViewModel, from presentingViewController: DetailViewController) {
        let viewController = CommentsViewController.fromStoryboard()
        viewController.viewModel = viewModel
        let navigationController = NavigationController(rootViewController: viewController)
        navigationController.style = .dragable
        navigationController.transitioningDelegate = presentingViewController
        navigationController.modalPresentationStyle = .custom
        presentingViewController.present(navigationController, animated: true)
    }
    
    @objc
    func logout() {
        pr0grammConnector.logout()
    }
}
