
import UIKit
import AVKit

class DownloadedFilesTableViewController: UITableViewController, StoryboardInitialViewController {
    
    weak var coordinator: Coordinator?
    private let cellIdentifier = "downloadedFileCell"
    private var files: [URL]? {
        return FileManager.default.urls(for: .documentDirectory)?.sorted { $0.creationDate > $1.creationDate }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Downloads"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! DownloadedFileTableViewCell
        guard let fileURL = files?[indexPath.row] else { return cell }
        cell.fileNameLabel.text = fileURL.lastPathComponent + "\n" + (fileURL.filesizeNicelyformatted ?? "") + "\n" + "\(fileURL.creationDate)"
        
        if fileURL.lastPathComponent.hasSuffix(".mp4") {
            cell.previewImageView.thumbnailImageFromVideoUrl(url: fileURL)
        } else {
            cell.previewImageView.image = UIImage(contentsOfFile: fileURL.path)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let fileURL = files?[indexPath.row] else { return }
        if fileURL.lastPathComponent.hasSuffix(".mp4") {
            coordinator?.showVideo(with: fileURL)
        } else {
            coordinator?.showImageViewController(with: UIImage(contentsOfFile: fileURL.path)!, from: self)
        }
    }
            
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let fileURL = files?[indexPath.row] else { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: "Löschen",
          handler: { (action, view, completionHandler) in
            do {
                try FileManager.default.removeItem(at: fileURL)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print(error)
            }
            completionHandler(true)
        })
        deleteAction.backgroundColor = .red
        
        let shareAction = UIContextualAction(style: .normal, title: "Teilen",
          handler: { (action, view, completionHandler) in
            self.shareFile(at: fileURL)
            completionHandler(true)
        })
        shareAction.backgroundColor = .blue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        return configuration
    }
    
    private func shareFile(at url: URL) {
        let path = url.path

        let file: Any

        if path.hasSuffix(".mp4") {
            file = URL(fileURLWithPath: path)
        } else {
            file = UIImage(contentsOfFile: path)!
        }

        let items = [file]
        DispatchQueue.main.async {
            self.coordinator?.showShareSheet(with: items)
        }
    }
}


class DownloadedFileTableViewCell: UITableViewCell {
    @IBOutlet var previewImageView: UIImageView!
    @IBOutlet var fileNameLabel: UILabel!
}
