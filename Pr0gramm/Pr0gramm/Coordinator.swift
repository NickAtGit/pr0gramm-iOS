
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
        viewController.tabBarItem = UITabBarItem(title: "Top",
                                                 image: UIImage(systemName: "list.bullet"),
                                                 selectedImage: nil)
        
        let downloadedFilesTableViewController = DownloadedFilesTableViewController.fromStoryboard()
        downloadedFilesTableViewController.coordinator = self
        downloadedFilesTableViewController.tabBarItem = UITabBarItem(title: "Downloads",
                                                                     image: UIImage(systemName: "square.and.arrow.down"),
                                                                     selectedImage: nil)
        
        tabbarController.setViewControllers([navigationController, downloadedFilesTableViewController], animated: false)
        
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
    
    func showDetail(with items: [Item], at indexPath: IndexPath, isSearch: Bool = false) {
        let viewController = DetailCollectionViewController.fromStoryboard()
        viewController.isSearch = isSearch
        viewController.coordinator = self
        viewController.items = items
        navigationController.pushViewController(viewController, animated: true)
        viewController.scrollTo(indexPath: indexPath)
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
    
    func showSearchResult(for tag: String, from presentingViewController: UIViewController) {
        pr0grammConnector.searchItems(for: [tag]) { items in
            let viewController = MainCollectionViewController.fromStoryboard()
            viewController.title = tag
            viewController.isSearch = true
            viewController.coordinator = self
            viewController.items = items
            let navigationController = NavigationController(rootViewController: viewController)
            navigationController.style = .dismissable
            navigationController.modalPresentationStyle = .fullScreen
            presentingViewController.present(navigationController, animated: true)
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
