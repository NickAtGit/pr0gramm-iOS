
import UIKit
import AVKit

protocol StickyBadgeShowable {
    var stickyBadgeView: UIView? { get set }
}

extension StickyBadgeShowable where Self: UIView {
    mutating func addStickyBadge() {
        guard stickyBadgeView == nil else { return }
        stickyBadgeView = UIImageView(image: UIImage(systemName: "bookmark.circle.fill"))
        stickyBadgeView?.backgroundColor = UIColor(resource: .grau)
        stickyBadgeView?.tintColor = UIColor(resource: .sticky)
        stickyBadgeView?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stickyBadgeView!)
        stickyBadgeView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        stickyBadgeView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        stickyBadgeView?.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        stickyBadgeView?.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        stickyBadgeView?.transform = CGAffineTransform(scaleX: 0, y: 0)
        stickyBadgeView?.layoutIfNeeded()
        stickyBadgeView?.layer.cornerRadius = (stickyBadgeView?.bounds.height ?? 0) / 2
        stickyBadgeView?.alpha = 0.5
      
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.stickyBadgeView?.transform = .identity
        }
    }
}

extension StickyBadgeShowable where Self: AVPlayerViewController {
    mutating func addStickyBadge() {
        guard stickyBadgeView == nil else { return }
        stickyBadgeView = UIImageView(image: UIImage(systemName: "bookmark.circle.fill"))
        stickyBadgeView?.backgroundColor = UIColor(resource: .grau)
        stickyBadgeView?.tintColor = UIColor(resource: .sticky)
        stickyBadgeView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stickyBadgeView!)
        stickyBadgeView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        stickyBadgeView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        stickyBadgeView?.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        stickyBadgeView?.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        stickyBadgeView?.transform = CGAffineTransform(scaleX: 0, y: 0)
        stickyBadgeView?.layoutIfNeeded()
        stickyBadgeView?.layer.cornerRadius = (stickyBadgeView?.bounds.height ?? 0) / 2
        stickyBadgeView?.alpha = 0.5

        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.stickyBadgeView?.transform = .identity
        }
    }
}
