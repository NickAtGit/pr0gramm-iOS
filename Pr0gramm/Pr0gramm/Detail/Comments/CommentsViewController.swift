
import UIKit

class CommentsViewController: UIViewController, Storyboarded, UIScrollViewDelegate, UITableViewDelegate {
    
    weak var coordinator: Coordinator?
    var viewModel: DetailViewModel!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var draggerView: UIView!
    private var topConstraint: NSLayoutConstraint!
    private weak var hostingViewController: UIViewController?
    private lazy var currentHeight: CGFloat = draggerView.bounds.height
    private let feedback = UIImpactFeedbackGenerator(style: .soft)
    private var isAnimating = false
    private var firstDrag = true

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
                
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(detectPan(sender:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        draggerView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(expand))
        tapGesture.numberOfTapsRequired = 2
        draggerView.addGestureRecognizer(tapGesture)
    
    }
    
    func embed(in viewController: UIViewController) {
        self.hostingViewController = viewController
        viewController.view.addSubview(view)
        viewController.addChild(self)
        view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        topConstraint = view.topAnchor.constraint(equalTo: viewController.view.topAnchor,
                                                  constant: viewController.view.bounds.maxY - draggerView.bounds.height)
        let left = view.leftAnchor.constraint(equalTo: viewController.view.leftAnchor)
        let right = view.rightAnchor.constraint(equalTo: viewController.view.rightAnchor)
        let height = view.heightAnchor.constraint(equalToConstant: viewController.view.bounds.height)
        NSLayoutConstraint.activate([left, right, topConstraint, height])
        didMove(toParent: viewController)
    }
        
    @objc
    func detectPan(sender: UIPanGestureRecognizer) {
        
        reloadDataIfNeeded()
        
        guard let hostingViewController = self.hostingViewController else { return }
        
        if sender.state == .began {
            feedback.prepare()
            UIView.animate(withDuration: 0.25) {
                self.draggerView.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
            }
        }

        if sender.state == .changed {
            let drag = sender.location(in: hostingViewController.view)
            topConstraint.constant = drag.y
        }

        if sender.state == .ended || sender.state == .cancelled {
            
            let y = self.view.frame.minY
            let velocity = sender.velocity(in: hostingViewController.view)
            let translation = sender.translation(in: hostingViewController.view)
            let height =  hostingViewController.view.frame.maxY
                        
            if velocity.y >= 0 {
                if y + translation.y >= height / 2 {
                    topConstraint.constant = height - draggerView.frame.height
                    
                    UIView.animate(withDuration: 0.25) {
                        self.draggerView.backgroundColor = .clear
                    }
                } else {
                    topConstraint.constant = height / 2
                }
            } else {
                if y + translation.y >= height / 2 {
                    topConstraint.constant = height / 2
                } else {
                    topConstraint.constant = 0
                }
            }
                        
            UIView.animate(withDuration: 0.25,
                           delay: 0.0,
                           options: [.allowUserInteraction, .curveEaseInOut],
                           animations: {
                            hostingViewController.view.layoutIfNeeded()
            }, completion: { _ in
                self.feedback.impactOccurred()
            })
            
            updateInsets()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y < -100 {
            guard !isAnimating else { return }
            isAnimating = true
            //Kill further scrolls
            scrollView.panGestureRecognizer.isEnabled = false;
            scrollView.panGestureRecognizer.isEnabled = true;

            let height = hostingViewController?.view.frame.maxY ?? 0
            self.topConstraint.constant = height - draggerView.frame.height
            
            UIView.animate(withDuration: 0.25,
                           delay: 0.0,
                           options: [.allowUserInteraction, .curveEaseInOut],
                           animations: {
                            self.hostingViewController?.view.layoutIfNeeded()
                            self.draggerView.backgroundColor = .clear
            }, completion: { _ in
                self.feedback.impactOccurred()
                self.isAnimating = false
            })
            
            updateInsets()
        }
    }
    
    @objc
    func expand() {
        self.topConstraint.constant = 0
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: [.allowUserInteraction, .curveEaseInOut],
                       animations: {
                        self.hostingViewController?.view.layoutIfNeeded()
                        self.draggerView.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.0862745098, blue: 0.09411764706, alpha: 1)
        })
        
        reloadDataIfNeeded()
        updateInsets()
    }
    
    private func reloadDataIfNeeded() {
        guard firstDrag else { return }
        firstDrag = false
        tableView.reloadData()
        
        let _ = viewModel.comments.observeNext { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    
    private func updateInsets() {
        tableView.contentInset.bottom = self.topConstraint.constant
        tableView.verticalScrollIndicatorInsets.bottom = self.topConstraint.constant
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
