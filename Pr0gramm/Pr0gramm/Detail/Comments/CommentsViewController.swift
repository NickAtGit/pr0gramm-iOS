
import UIKit

class CommentsViewController: UIViewController, StoryboardInitialViewController {
    
    weak var coordinator: Coordinator?
    var viewModel: DetailViewModel!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var draggerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.reloadData()
        
        let _ = viewModel.comments.observeNext { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(detectPan(sender:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        draggerView.addGestureRecognizer(panGesture)

    }
    
    var height: NSLayoutConstraint?
    var hostingViewController: UIViewController?
    
    func embed(in viewController: UIViewController) {
        self.hostingViewController = viewController
        viewController.view.addSubview(view)
        viewController.addChild(self)
        view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        let left = view.leftAnchor.constraint(equalTo: viewController.view.leftAnchor)
        let right = view.rightAnchor.constraint(equalTo: viewController.view.rightAnchor)
        let bottom = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor)
        height = view.heightAnchor.constraint(equalToConstant: draggerView.bounds.height)
        NSLayoutConstraint.activate([left, right, bottom, height!])
        didMove(toParent: viewController)
    }
    
    func show(from view: UIView) {
        self.height?.constant = view.bounds.height
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.2,
                       options: [],
                       animations: {
                        view.layoutIfNeeded()
        })
    }
    
    private var currentHeight: CGFloat = 30

    @objc
    func detectPan(sender: UIPanGestureRecognizer) {
        
        if sender.state == .began  {
            currentHeight = height!.constant
        }

        if sender.state == .changed {
            let drag = sender.location(in: self.hostingViewController?.view) // nach oben -100
            var newHeight = (self.hostingViewController?.view.bounds.height)! - drag.y
            
            if newHeight < draggerView.bounds.height + 20 {
                newHeight = 30
            }
            
            if newHeight > (self.hostingViewController?.view.bounds.height)! {
                newHeight = (self.hostingViewController?.view.bounds.height)!
            }
            
            height?.constant = newHeight
            
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
        }

        if sender.state == .ended || sender.state == .cancelled {
            //Do Something if interested when dragging ended.
            currentHeight = height!.constant
        }
    }
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
    func requestedReply(for comment: Comment) {
        coordinator?.showReply(for: comment, viewModel: viewModel, from: self)
    }
}
