
import UIKit

class CommentsViewController: UIViewController, StoryboardInitialViewController {
    
    var viewModel: DetailViewModel!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        view.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        
        let _ = viewModel.comments.observeNext { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension CommentsViewController: UITableViewDelegate {
    
}

extension CommentsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.comments.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell
        cell.detailViewModel = viewModel
        cell.comment = viewModel.comments.value?[indexPath.row]
        cell.delegate = self
        return cell
    }
}

extension CommentsViewController: CommentCellDelegate {
    func didPostReply(for comment: Comment) {
        viewModel.addComment(Comment(with: "test", depth: comment.depth + 1), parentComment: comment)
//        guard let index = viewModel.comments.value?.firstIndex(of: comment) else { return }
//        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
}
