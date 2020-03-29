
import UIKit
import AVKit
import ImageScrollView

class Coordinator {
    
    let pr0grammConnector = Pr0grammConnector()
    let navigationController = NavigationController()
    let tabbarController = UITabBarController()
    
    init() {
        navigationController.coordinator = self
    }
    
    func startViewController() -> UIViewController {
        
        if pr0grammConnector.isLoggedIn {
            let viewController = MainCollectionViewController.fromStoryboard()
            viewController.coordinator = self
            navigationController.viewControllers = [viewController]
            
            let downloadedFilesTableViewController = DownloadedFilesTableViewController.fromStoryboard()
            downloadedFilesTableViewController.coordinator = self
            tabbarController.setViewControllers([navigationController, downloadedFilesTableViewController], animated: false)
            return tabbarController
        } else {
            let viewController = LoginViewController.fromStoryboard()
            viewController.coordinator = self
            navigationController.style = .login
            navigationController.viewControllers = [viewController]
            return navigationController
        }
    }
    
    func showLogin() {
        let viewController = LoginViewController.fromStoryboard()
        viewController.coordinator = self
        navigationController.viewControllers = [viewController]
    }
    
    func showOverview() {
        let viewController = MainCollectionViewController.fromStoryboard()
        viewController.coordinator = self
        navigationController.viewControllers = [viewController]
    }
    
    func showDetail(for item: Item, at indexPath: IndexPath) {
        let viewController = DetailCollectionViewController.fromStoryboard()
        viewController.coordinator = self
        let detailNavigationController = NavigationController(rootViewController: viewController)
        detailNavigationController.style = .detail
        detailNavigationController.modalPresentationStyle = .fullScreen
        navigationController.present(detailNavigationController, animated: true)
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
    
    func showImageViewController(with image: UIImage) {
        let viewController = ImageDetailViewController.fromStoryboard()
        viewController.image = image
        tabbarController.present(viewController, animated: true)
    }
    
    @objc
    func logout() {
        pr0grammConnector.logout()
        showLogin()
    }
}
