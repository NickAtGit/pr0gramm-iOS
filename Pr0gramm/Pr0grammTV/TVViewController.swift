
import UIKit
import AVFoundation

class TVViewController: UIViewController, Pr0grammConnectorDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var tagsTableView: UITableView!
    @IBOutlet var tagsViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var pointsLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    
    let pr0grammConnector = Pr0grammConnector()
    let avPlayer = AVPlayer()
    var avPlayerLayer = AVPlayerLayer()
    var itemInfo: ItemInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagsTableView.delegate = self
        tagsTableView.dataSource = self
        pr0grammConnector.delegate = self
        
        addGestureRecognizers(with: .left, for: #selector(TVViewController.leftSwipe(_:)))
        addGestureRecognizers(with: .right, for: #selector(TVViewController.rightSwipe(_:)))
        addGestureRecognizers(with: .up, for: #selector(TVViewController.upSwipe(_:)))
        addGestureRecognizers(with: .down, for: #selector(TVViewController.downSwipe(_:)))
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(TVViewController.playerItemDidReachEnd(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
    }
    
    func addGestureRecognizers(with direction: UISwipeGestureRecognizerDirection, for selector: Selector) {
        let gestureRecognizer = UISwipeGestureRecognizer(target: self, action: selector)
        gestureRecognizer.direction = direction
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    func didReceiveData() {}
    
    @objc
    func leftSwipe(_ tapGestureRecognizer: UITapGestureRecognizer) {
        if let item = pr0grammConnector.lastItem() {
            updateView(with: item)
        }
    }
    
    @objc
    func rightSwipe(_ tapGestureRecognizer: UITapGestureRecognizer) {
        if let item = pr0grammConnector.nextItem() {
            updateView(with: item)
        }
    }

    @objc
    func downSwipe(_ tapGestureRecognizer: UITapGestureRecognizer) {
        tagsViewWidthConstraint.constant = 0
        avPlayerLayer.frame = imageView.layer.frame
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    func upSwipe(_ tapGestureRecognizer: UITapGestureRecognizer) {
        tagsViewWidthConstraint.constant = 400
        avPlayerLayer.frame = imageView.layer.frame
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func updateView(with item: Items) {
        imageView.image = nil
        avPlayer.replaceCurrentItem(with: nil)
        
        pointsLabel.text = "\(item.up - item.down)"
        authorLabel.text = item.user
        
        if let link = pr0grammConnector.imageLink(for: item) {
            imageView.isHidden = false
            imageView.downloadedFrom(link: link)
        } else {
            imageView.isHidden = true
            avPlayerLayer = AVPlayerLayer(player: avPlayer)
            avPlayerLayer.frame = view.layer.frame
            view.layer.insertSublayer(avPlayerLayer, at: 0)
            let link = pr0grammConnector.videoLink(for: item)
            if let url = URL(string: link) {
                let playerItem = AVPlayerItem(url: url)
                avPlayer.replaceCurrentItem(with: playerItem)
                avPlayer.play()
            }
        }
        
        pr0grammConnector.loadItemInfo(for: item.id) { itemInfo in
            DispatchQueue.main.async {
                self.itemInfo = itemInfo
                self.tagsTableView.reloadData()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        avPlayerLayer.frame = view.layer.frame
    }
    
    @objc
    func playerItemDidReachEnd(_ notification: NSNotification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: kCMTimeZero, completionHandler: nil)
            avPlayer.play()
        }
    }
}

extension TVViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let itemInfo = itemInfo else { return 0 }
        return itemInfo.tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let text = itemInfo?.tags[indexPath.row].tag
        cell.textLabel?.text = text
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        cell.textLabel?.textColor = #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.backgroundColor = #colorLiteral(red: 0.1215686275, green: 0.1333333333, blue: 0.1450980392, alpha: 1)
        cell.textLabel?.layer.borderColor = UIColor.white.cgColor
        cell.textLabel?.layer.borderWidth = 2
        cell.textLabel?.layer.cornerRadius = cell.textLabel!.intrinsicContentSize.height / 2
        cell.textLabel?.clipsToBounds = true
        return cell
    }
}

extension UIStackView {
    
    func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}

extension Array {
    func split() -> (left: [Element], right: [Element]) {
        let ct = self.count
        let half = ct / 2
        let leftSplit = self[0 ..< half]
        let rightSplit = self[half ..< ct]
        return (left: Array(leftSplit), right: Array(rightSplit))
    }
}
