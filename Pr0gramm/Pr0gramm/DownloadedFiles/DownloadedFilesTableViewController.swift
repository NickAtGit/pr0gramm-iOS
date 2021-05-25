
import UIKit
import AVKit

class DownloadedFilesTableViewController: UITableViewController, Storyboarded {
    
    weak var coordinator: Coordinator?
    private let cellIdentifier = "downloadedFileCell"
    private var files: [URL]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Downloads"
        view.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        tabBarItem = UITabBarItem(title: "Downloads",
                                  image: UIImage(systemName: "square.and.arrow.down"),
                                  selectedImage: UIImage(systemName: "square.and.arrow.down.fill"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFiles()
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files?.count ?? 0
    }
    
    private func loadFiles() {
        DispatchQueue.global().async {
            let files = FileManager.default.urls(for: .documentDirectory)?.sorted { $0.creationDate > $1.creationDate }
            DispatchQueue.main.async {
                self.files = files
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! DownloadedFileTableViewCell
        guard let fileURL = files?[indexPath.row] else { return cell }
        cell.fileNameLabel.text = fileURL.lastPathComponent
        cell.fileInfoLabel.text = "\(Strings.timeString(for: fileURL.creationDate))" + ", " + (fileURL.filesizeNicelyformatted ?? "")
        
        if fileURL.lastPathComponent.hasSuffix(".mp4") {
            cell.previewImageView.thumbnailImageFromVideoUrl(url: fileURL)
        } else {
            DispatchQueue.global().async {
                let image = UIImage(contentsOfFile: fileURL.path)
                DispatchQueue.main.async {
                    cell.previewImageView.image = image
                }
            }
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
            
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let fileURL = files?[indexPath.row] else { return nil }

        let deleteAction = UIContextualAction(style: .destructive, title: "Löschen",
          handler: { action, view, completionHandler in
            do {
                try FileManager.default.removeItem(at: fileURL)
                self.tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.files?.remove(at: indexPath.row)
                self.tableView.endUpdates()
            } catch {
                print(error)
            }
            completionHandler(true)
        })
        deleteAction.backgroundColor = UIColor.red.withAlphaComponent(0.25)
        
        let shareAction = UIContextualAction(style: .normal, title: "Teilen",
          handler: { action, view, completionHandler in
            DispatchQueue.main.async {
                self.shareFile(at: fileURL)
            }
            completionHandler(true)
        })
        shareAction.backgroundColor = UIColor.green.withAlphaComponent(0.25)
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, shareAction])
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        return view
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
        self.coordinator?.showShareSheet(with: items, from: view)
    }
}


class DownloadedFileTableViewCell: UITableViewCell {
    @IBOutlet var previewImageView: UIImageView!
    @IBOutlet var fileNameLabel: UILabel!
    @IBOutlet var fileInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fileNameLabel.textColor = #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.9568627451, alpha: 1)
        fileInfoLabel.textColor = #colorLiteral(red: 0.5333333333, green: 0.5333333333, blue: 0.5333333333, alpha: 1)
    }
}
