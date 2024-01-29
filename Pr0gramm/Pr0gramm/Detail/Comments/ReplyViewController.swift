
import UIKit
import ScrollingContentViewController

class ReplyViewController: ScrollingContentViewController, Storyboarded {
    
    var viewModel: DetailViewModel!
    var comment: Comment?
    
    @IBOutlet private var commentView: UIView!
    @IBOutlet private var separatorView: SeparatorView!
    @IBOutlet private var commentTextView: UITextView!
    @IBOutlet private var authorLabel: UILabel!
    @IBOutlet private var userClassView: UIImageView!
    @IBOutlet private var pointsLabel: UILabel!
    @IBOutlet private var opLabel: BadgeLabel!
    @IBOutlet private var replyTextView: UITextView!
    @IBOutlet private var commentTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var replyTextViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        shouldResizeContentViewForKeyboard = true
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

        replyTextView.textContainerInset = .zero
        replyTextView.textContainer.lineFragmentPadding = 0
        replyTextView.becomeFirstResponder()
        
        let sendBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(didTapSend))
        navigationItem.rightBarButtonItem = sendBarButtonItem

        guard let comment = comment else {
            commentView.isHidden = true
            separatorView.isHidden = true
            return
        }
        commentTextView.textContainerInset = .zero
        commentTextView.textContainer.lineFragmentPadding = 0
        commentTextView.text = comment.content

        authorLabel.text = comment.name
        userClassView.image = comment.mark.icon
        pointsLabel.text = "\(comment.up - comment.down)"
        opLabel.isHidden = !viewModel.isAuthorOP(for: comment)
        
        commentTextView.delegate = self
        replyTextView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        guard comment != nil else { return }
        commentTextViewHeightConstraint.constant = commentTextView.contentSize.height > 200 ? 200 : commentTextView.contentSize.height
    }
    
    @objc
    func didTapSend() {
        guard let text = replyTextView.text,
            !text.isEmpty,
            let userName = viewModel.loggedInUserName else { return }
        
        let depth = (self.comment?.depth ?? -1) + 1
        let comment = Comment(with: text, name: userName, depth: depth)
        viewModel.addComment(comment, parentComment: self.comment)
        dismiss(animated: true)
    }
    
    @IBAction func showEmojiChooser(_ sender: Any) {
        let emojiChooser = AsciiEmojiChooserTableViewController.fromStoryboard()
        present(emojiChooser, animated: true)
    }
}

extension ReplyViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView === commentTextView {
            commentTextViewHeightConstraint.constant = commentTextView.contentSize.height
        } else if textView === replyTextView {
            replyTextViewHeightConstraint.constant = replyTextView.contentSize.height
            scrollView.scrollFirstResponderToVisible(animated: true)
        }
    }
}

