
import UIKit
import AVFoundation

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        
        let activityIndator = UIActivityIndicatorView(style: .large)
        activityIndator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndator)
        activityIndator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityIndator.startAnimating()
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
                activityIndator.stopAnimating()
            }
        }.resume()
    }

    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
    
    func thumbnailImageFromVideoUrl(url: URL) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumnailTime = CMTimeMake(value: 2, timescale: 1)
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
                let thumbNailImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    self.image = thumbNailImage
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.image = nil
                }
            }
        }
    }
    
    func enableZoom() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
        isUserInteractionEnabled = true
        addGestureRecognizer(pinchGesture)
    }
    
    @objc
    private func startZooming(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
        sender.view?.transform = scale
        sender.scale = 1
    }
}

