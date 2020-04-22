
import UIKit
import AVFoundation
import ScrollingContentViewController
import AVKit

class DetailViewController: ScrollingContentViewController, StoryboardInitialViewController {

    weak var coordinator: Coordinator?
    var viewModel: DetailViewModel! {
        didSet {
            infoView.viewModel = viewModel
            tagsCollectionViewController.viewModel = viewModel
        }
    }
    
    private var stackView: UIStackView!
    private let imageView = TapableImageView()
    private let tagsCollectionViewController = TagsCollectionViewController.fromStoryboard()
    private let commentsStackView = UIStackView()
    private let infoView = InfoView.instantiateFromNib()
    private var avPlayer: AVPlayer?
    private var avPlayerViewController: TapableAVPlayerViewController?
    private let loadCommentsButton = UIButton()
    private var commentsAreShown = false
    private lazy var contextMenuInteraction = UIContextMenuInteraction(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()
                    
        scrollView.showsVerticalScrollIndicator = false
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .top
        
        commentsStackView.axis = .vertical
        commentsStackView.spacing = 25
                
        tagsCollectionViewController.coordinator = coordinator
        addChild(tagsCollectionViewController)
                
        stackView = UIStackView(arrangedSubviews: [imageView,
                                                   infoView,
                                                   tagsCollectionViewController.view,
                                                   commentsStackView])
        stackView.spacing = 40
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing

        tagsCollectionViewController.didMove(toParent: self)

        let hostView = UIView()
        hostView.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: hostView.topAnchor, constant: 2).isActive = true
        stackView.leftAnchor.constraint(equalTo: hostView.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: hostView.rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(lessThanOrEqualTo: hostView.bottomAnchor).isActive = true
        
        contentView = hostView
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        let _ = viewModel.isTagsExpanded.observeNext(with: { [unowned self] _ in
            UIView.animate(withDuration: 0.25) {
                self.view.layoutIfNeeded()
            }
        })
        
        let _ = viewModel.item.observeNext { [unowned self] item in
            self.setup(with: item)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        avPlayer?.pause()
        NotificationCenter.default.removeObserver(self)
    }
            
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: stackView.frame.width, height: stackView.frame.height)
    }
    
    func showImageDetail() {
        guard let image = imageView.image else { return }
        coordinator?.showImageViewController(with: image, from: self)
    }
        
    private func setup(with item: Item) {
        imageView.heightAnchor.constraint(equalTo: view.widthAnchor,
                                          multiplier: CGFloat(item.height) / CGFloat(item.width)).isActive = true
        
        infoView.showCommentsAction = { [unowned self] in self.coordinator?.showComments(viewModel: self.viewModel, from: self) }
        infoView.upvoteAction = { [weak self] in self?.navigation?.showBanner(with: "Han blussert") }
        infoView.downvoteAction = { [weak self] in self?.navigation?.showBanner(with: "Han miesert") }
        
        switch viewModel.mediaType {
        case .image:
            setupImage()
        case .gif:
            setupGif()
        case .video:
            setupVideo(for: item)
        }
    }
        
    func cleanup() {
        avPlayer = nil
        avPlayerViewController = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupImage() {
        imageView.downloadedFrom(link: viewModel.link)
        imageView.addInteraction(contextMenuInteraction)
    }
    
    private func setupGif() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let gif = UIImage.gif(url: self.viewModel.link)
            DispatchQueue.main.async {
                self.imageView.image = gif
            }
        }
        imageView.contentMode = .scaleAspectFit
        imageView.addInteraction(contextMenuInteraction)
    }
    
    private func setupVideo(for item: Item) {
        avPlayer = AVPlayer()
        avPlayerViewController = TapableAVPlayerViewController()
        avPlayerViewController?.delegate = self
        guard let avPlayer = avPlayer else { return }
        guard let avPlayerViewController = avPlayerViewController else { return }
        avPlayerViewController.view.addInteraction(contextMenuInteraction)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DetailViewController.playerItemDidReachEnd(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)

        avPlayerViewController.player = avPlayer
        avPlayerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        avPlayerViewController.view.heightAnchor.constraint(equalToConstant: view.bounds.width * CGFloat(item.height) / CGFloat(item.width)).isActive = true
        addChild(avPlayerViewController)
        stackView.removeArrangedSubview(imageView)
        stackView.insertArrangedSubview(avPlayerViewController.view, at: 0)
        avPlayerViewController.didMove(toParent: self)
        let url = URL(string: viewModel.link)
        let playerItem = AVPlayerItem(url: url!)
        avPlayer.replaceCurrentItem(with: playerItem)
    }
    
    @objc
    func playerItemDidReachEnd(_ notification: NSNotification) {
        if let playerItem = notification.object as? AVPlayerItem {
            if playerItem == avPlayer?.currentItem {
                playerItem.seek(to: CMTime.zero, completionHandler: nil)
                avPlayer?.play()
            }
        }
    }
    
    @objc
    func play() {
        avPlayer?.isMuted = AppSettings.isVideoMuted
        avPlayer?.play()
    }
    
    func stop() {
        avPlayer?.pause()
    }
}



extension DetailViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            return self.createContextMenu()
        }
    }
    
    func createContextMenu() -> UIMenu {
        let downloadAction = UIAction(title: "Download", image: UIImage(systemName: "square.and.arrow.down")) { [unowned self] _ in
            self.download()
        }
        
        let fullscreenAction = UIAction(title: "Vollbild", image: UIImage(systemName: "rectangle.expand.vertical")) { [unowned self] _ in
            self.showImageDetail()
            self.avPlayerViewController?.goFullScreen()
        }
                
        return UIMenu(title: "", children: [downloadAction, fullscreenAction])
    }
}



extension DetailViewController {
    
    func download() {
        guard let connector = coordinator?.pr0grammConnector else { return }
        let item = viewModel.item.value
        let link = connector.link(for: item)
        let downloader = Downloader()
        let url = URL(string: link.link)!
        downloader.loadFileAsync(url: url) { [weak self] successfully in
            DispatchQueue.main.async {
                self?.navigation?.showBanner(with: successfully ? "Download abgeschlossen" : "Download fehlgeschlagen")
            }
        }
    }
}



extension DetailViewController: AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        playerViewController.player?.play()
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        playerViewController.player?.play()
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        
        return HalfSizePresentationController(presentedViewController: presented,
                                              presenting: presenting)
    }
}

class HalfSizePresentationController : UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return CGRect.zero }
        return CGRect(x: 0,
                      y: containerView.bounds.height / 2,
                      width: containerView.bounds.width,
                      height: containerView.bounds.height / 2)
    }
}
