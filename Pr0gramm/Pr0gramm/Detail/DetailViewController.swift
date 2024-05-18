
import UIKit
import AVFoundation
import ScrollingContentViewController
import AVKit
import Combine

class DetailViewController: ScrollingContentViewController, Storyboarded {

    weak var coordinator: Coordinator?
    var viewModel: DetailViewModel! {
        didSet {
            infoView.viewModel = viewModel
            tagsCollectionViewController.viewModel = viewModel
        }
    }
    
    private var stackView: UIStackView!
    private var imageView = TapableImageView()
    private let tagsCollectionViewController = TagsCollectionViewController.fromStoryboard()
    private let infoView = InfoView.fromNib()
    private var avPlayer: AVPlayer?
    private var avPlayerViewController: TapableAVPlayerViewController?
    private let loadCommentsButton = UIButton()
    private var commentsAreShown = false
    private lazy var contextMenuInteraction = UIContextMenuInteraction(delegate: self)
    private var commentsViewController: CommentsViewController?
    private var navigation: NavigationController? { navigationController as? NavigationController }
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.showsVerticalScrollIndicator = false
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .top
                        
        tagsCollectionViewController.coordinator = coordinator
        addChild(tagsCollectionViewController)
                
        stackView = UIStackView(arrangedSubviews: [imageView,
                                                   infoView,
                                                   tagsCollectionViewController.view])
        stackView.spacing = 30
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing

        tagsCollectionViewController.didMove(toParent: self)

        let hostView = UIView()
        hostView.translatesAutoresizingMaskIntoConstraints = false
        hostView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: hostView.topAnchor, constant: 2).isActive = true
        stackView.leftAnchor.constraint(equalTo: hostView.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: hostView.rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(lessThanOrEqualTo: hostView.bottomAnchor, constant: -25).isActive = true
        
        contentView = hostView
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        viewModel.$isTagsExpanded
            .sink { [weak self] _ in
                UIView.animate(withDuration: 0.25) {
                    self?.view.layoutIfNeeded()
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$item
            .sink { [weak self] item in
                self?.setup(with: item)
            }
            .store(in: &subscriptions)
                
        viewModel.$isCommentsButtonHidden
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.addComments()
                    self?.view.layoutSubviews()
                }
            }
            .store(in: &subscriptions)
        
        viewModel.tags
            .sink { [weak self] tags in
                if AppSettings.isMuteOnUnnecessaryMusic,
                   !AppSettings.isVideoMuted {
                    let containsUnnecessaryMusicTag = tags.first(where: {
                        $0.tag.caseInsensitiveCompare("unnötige Musik") == .orderedSame
                    })

                    let containsNecessaryMusicTag = tags.first(where: {
                        $0.tag.caseInsensitiveCompare("nötige Musik") == .orderedSame
                    })

                    if let containsNecessaryMusicTag,
                       let containsUnnecessaryMusicTag {
                        self?.avPlayer?.isMuted = containsUnnecessaryMusicTag.confidence > containsNecessaryMusicTag.confidence
                    } else if containsUnnecessaryMusicTag != nil {
                        self?.avPlayer?.isMuted = true
                    }
                }
            }
            .store(in: &subscriptions)
        
        viewModel.addTagsButtonTap.sink { [weak self] tapped in
            let alertController = UIAlertController(title: "Tags hinzufügen", message: "Tags bitte kommasepariert eingeben", preferredStyle: .alert)
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "süßvieh, awww, OC"
            }
            let saveAction = UIAlertAction(title: "Absenden", style: .default, handler: { alert -> Void in
                let firstTextField = alertController.textFields![0] as UITextField
                self?.viewModel.submitTags(firstTextField.text ?? "")
            })
            let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: { (action : UIAlertAction!) -> Void in })

            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self?.present(alertController, animated: true, completion: nil)
        }
        .store(in: &subscriptions)
        
        NotificationCenter
            .default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                self?.view.layoutIfNeeded()
            }
            .store(in: &subscriptions)
                
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handleZoom))
        imageView.addGestureRecognizer(pinch)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        avPlayerViewController?.allowsPictureInPicturePlayback = AppSettings.isPictureInPictureEnabled
        avPlayer?.isMuted = AppSettings.isVideoMuted
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        avPlayer?.pause()
        NotificationCenter.default.removeObserver(self)
    }
    
    func showImageDetail() {
        guard let image = imageView.image else { return }
        coordinator?.showImageViewController(with: image, from: self)
    }
        
    private func setup(with item: Item) {
        setupMediaHeight(mediaView: imageView, item: item)
        
        infoView.showReplyAction = { [unowned self] in self.coordinator?.showReplyForPost(viewModel: self.viewModel) }
        infoView.showCommentsAction = { [unowned self] in self.showComments() }
        infoView.upvoteAction = { [weak self] in self?.navigation?.showBanner(with: "Han blussert") }
        infoView.downvoteAction = { [weak self] in self?.navigation?.showBanner(with: "Han miesert") }
        infoView.showUserAction = { [weak self] name in
            guard let navigationController = self?.navigationController else { return }
            self?.coordinator?.showUserProfile(for: name, viewController: navigationController)
        }
        
        switch item.mediaType {
        case .image, .gif:
            setupImage(for: item)
        case .video:
            setupVideo(for: item)
        }
    }
        
    func cleanup() {
        avPlayer = nil
        avPlayerViewController = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupImage(for item: Item) {
        imageView.downloadedFrom(url: item.mediaURL)
        imageView.addInteraction(contextMenuInteraction)
    }
    
    private func setupVideo(for item: Item) {
        let avPlayer = AVPlayer()
        let avPlayerViewController = TapableAVPlayerViewController()
        avPlayerViewController.delegate = self
                
        NotificationCenter.default
            .publisher(for: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
            .sink { [weak self] notification in
                
                if let playerItem = notification.object as? AVPlayerItem {
                    if playerItem == self?.avPlayer?.currentItem {
                        playerItem.seek(to: CMTime.zero, completionHandler: nil)
                        self?.avPlayer?.play()
                    }
                }
            }
            .store(in: &subscriptions)

        avPlayerViewController.player = avPlayer
        avPlayerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(avPlayerViewController)
        stackView.removeArrangedSubview(imageView)
        stackView.insertArrangedSubview(avPlayerViewController.view, at: 0)
        avPlayerViewController.didMove(toParent: self)
        setupMediaHeight(mediaView: avPlayerViewController.view, item: item)
        let playerItem = AVPlayerItem(url: item.mediaURL)
        avPlayer.replaceCurrentItem(with: playerItem)
        self.avPlayer = avPlayer
        self.avPlayerViewController = avPlayerViewController
        avPlayerViewController.view.addInteraction(contextMenuInteraction)
    }
    
    @objc
    func play() {
        if AppSettings.isAutoPlay { avPlayer?.play() }
        
        if viewModel.isSeen {
            imageView.addSeenBadge()
            avPlayerViewController?.addSeenBadge()
        } else {
            viewModel.isSeen = true
        }

        if viewModel.item.isSticky {
            imageView.addStickyBadge()
            avPlayerViewController?.addStickyBadge()
        }
    }
    
    func stop() {
        avPlayer?.pause()
    }
    
    private func addComments() {
        guard commentsViewController == nil else { return }
        commentsViewController = CommentsViewController.fromStoryboard()
        commentsViewController?.viewModel = viewModel
        commentsViewController?.coordinator = coordinator
        commentsViewController?.embed(in: self)
    }
    
    private func showComments() {
        commentsViewController?.expand()
    }
    
    private func setupMediaHeight(mediaView: UIView, item: Item) {
        let isEnableHeightLimit = AppSettings.isMediaHeightLimitEnabled
        
        mediaView.heightAnchor.constraint(equalTo: view.widthAnchor,
                                          multiplier: CGFloat(item.height) / CGFloat(item.width)).isActive = !isEnableHeightLimit
        
        let constant: CGFloat = -(infoView.frame.height + tagsCollectionViewController.view.frame.height + 88)
        mediaView.heightAnchor.constraint(equalTo: view.heightAnchor,
                                          constant: constant).isActive = isEnableHeightLimit
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
            self.download(directory: .documentDirectory)
        }
        
        let fullscreenAction = UIAction(title: "Vollbild", image: UIImage(systemName: "rectangle.expand.vertical")) { [unowned self] _ in
            self.showImageDetail()
            self.avPlayerViewController?.goFullScreen()
        }
        
        let saveToCameraRollAction = UIAction(title: "In Fotos speichern", image: UIImage(systemName: "photo")) { [unowned self] _ in
            if let image = self.imageView.image {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            } else {
                self.download(directory: .cachesDirectory)
            }
        }
        
        let shareAction = UIAction(title: "Link teilen", image: UIImage(systemName: "square.and.arrow.up")) { [unowned self] _ in
            self.coordinator?.showShareSheet(with: [self.viewModel.shareLink], from: imageView)
        }
        
        let shareDirectAction = UIAction(title: "Direktlink teilen", image: UIImage(systemName: "square.and.arrow.up")) { [unowned self] _ in
            self.coordinator?.showShareSheet(with: [self.viewModel.item.url], from: imageView)
        }
        
        let browserAction = UIAction(title: "Im Browser öffnen", image: UIImage(systemName: "safari")) { [unowned self] _ in
            UIApplication.shared.open(self.viewModel.shareLink)
        }

        return UIMenu(title: "", children: [downloadAction, fullscreenAction, saveToCameraRollAction, shareAction, shareDirectAction, browserAction])
    }
}

extension DetailViewController {
    
    func download(directory: FileManager.SearchPathDirectory) {
        guard let itemInfo = viewModel.itemInfo else { return }
        let item = viewModel.item
        let firstFourTags = itemInfo.tags.sorted { $0.confidence > $1.confidence }
            .prefix(4)
            .reduce("", {$0 + ($1.tag) + "-" })
            .dropLast()
            .replacingOccurrences(of: "/", with: "-")
        let fileName = String(firstFourTags)
        let downloader = Downloader()
        let url = item.mediaURL
        downloader.loadFileAsync(url: url, fileName: fileName, directory: directory) { [weak self] successfully, toPath  in
            if directory == .cachesDirectory {
                guard let path = toPath else { return }
                UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil)
            } else if directory == .documentDirectory {
                DispatchQueue.main.async {
                    self?.navigation?.showBanner(with: successfully ? "Download abgeschlossen" : "Download fehlgeschlagen")
                }
            }
        }
    }
}

extension DetailViewController: AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController,
                              willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        playerViewController.player?.play()
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController,
                              willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        playerViewController.player?.play()
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController,
                              restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }
}

extension DetailViewController {
      
    @objc
    func handleZoom(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .ended:
            guard let image = imageView.image else { return }
            coordinator?.showImageViewController(with: image, from: self)
        default:
            break
        }
    }
}
