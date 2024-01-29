
import UIKit
import AVKit

protocol SeenBadgeShowable {
    var badgeView: UIView? { get set }
}
extension SeenBadgeShowable where Self: UIView {
    mutating func addSeenBadge() {
        guard AppSettings.isShowSeenBagdes else { return }
        guard badgeView == nil else { return }
        badgeView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        badgeView?.backgroundColor = .Theme.richtigesGrau
        badgeView?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(badgeView!)
        badgeView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        badgeView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        badgeView?.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        badgeView?.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        badgeView?.transform = CGAffineTransform(scaleX: 0, y: 0)
        badgeView?.layoutIfNeeded()
        badgeView?.layer.cornerRadius = (badgeView?.bounds.height ?? 0) / 2
        badgeView?.alpha = 0.5
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.badgeView?.transform = .identity
        }
    }
}

extension SeenBadgeShowable where Self: AVPlayerViewController {
    mutating func addSeenBadge() {
        guard AppSettings.isShowSeenBagdes else { return }
        guard badgeView == nil else { return }
        badgeView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        badgeView?.backgroundColor = .Theme.richtigesGrau
        badgeView?.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(badgeView!)
        badgeView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        badgeView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
        badgeView?.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        badgeView?.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        badgeView?.transform = CGAffineTransform(scaleX: 0, y: 0)
        badgeView?.layoutIfNeeded()
        badgeView?.layer.cornerRadius = (badgeView?.bounds.height ?? 0) / 2
        badgeView?.alpha = 0.5

        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.badgeView?.transform = .identity
        }
    }
}
