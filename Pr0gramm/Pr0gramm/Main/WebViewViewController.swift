
import UIKit
import WebKit

class WebViewViewController: UIViewController {
    
    private let webView = WKWebView()

    override func loadView() {
        self.view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let safariItem = UIBarButtonItem(image: UIImage(systemName: "safari"), style: .plain, target: self, action: #selector(openInSafari))
        let shareItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showShareSheet))

        navigationItem.rightBarButtonItems = [safariItem, shareItem]
    }
    
    func loadUrl(_ url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    @objc
    func openInSafari() {
        guard let url = webView.url else { return }
        UIApplication.shared.open(url)
    }
    
    @objc
    func showShareSheet() {
        guard let url = webView.url else { return }
        let ac = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(ac, animated: true)
    }
}
