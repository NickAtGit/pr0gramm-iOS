
import UIKit

enum FlagsPosition: String {
    case main
    case search
    case user
}

class FlagsViewController: UIViewController, Storyboarded {
        
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var sortingSegmentedControl: UISegmentedControl!
    @IBOutlet private var sfwSwitch: UISwitch!
    @IBOutlet private var nsfwSwitch: UISwitch!
    @IBOutlet private var nsflSwitch: UISwitch!
    @IBOutlet private var flagStackViews: [UIStackView]!
    
    var currentFlags: [Flags] = []
    var flagsPosition: FlagsPosition!
    var changedClosure: ActionClosure?
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sortingSegmentedControl.selectedSegmentIndex = AppSettings.sorting(for: flagsPosition) == .top ? 0 : 1
        
        let flags = AppSettings.flags(for: flagsPosition)
        sfwSwitch.isOn = flags.contains(.sfw)
        nsfwSwitch.isOn = flags.contains(.nsfw)
        nsflSwitch.isOn = flags.contains(.nsfl)
        flagStackViews.forEach { $0.isHidden = !AppSettings.isLoggedIn }

        preferredContentSize = CGSize(width: 200, height: stackView.bounds.height + 40)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        changedClosure?()
    }
    
    @IBAction func sortingSegmentedControlChanged(_ sender: UISegmentedControl) {
        AppSettings.setSorting(sender.selectedSegmentIndex == 0 ? .top : .neu, for: flagsPosition)
    }
    
    @IBAction func sfwSwitchChanged(_ sender: UISwitch) {
        var currentFlags = AppSettings.flags(for: flagsPosition)
        let _ = sender.isOn ? currentFlags.update(with: .sfw) : currentFlags.remove(.sfw)
        AppSettings.setFlags(currentFlags, for: flagsPosition)
    }
    
    @IBAction func nsfwSwitchChanged(_ sender: UISwitch) {
        var currentFlags = AppSettings.flags(for: flagsPosition)
        let _ = sender.isOn ? currentFlags.update(with: .nsfw) : currentFlags.remove(.nsfw)
        AppSettings.setFlags(currentFlags, for: flagsPosition)
    }
    
    @IBAction func nsflSwitchChanged(_ sender: UISwitch) {
        var currentFlags = AppSettings.flags(for: flagsPosition)
        let _ = sender.isOn ? currentFlags.update(with: .nsfl) : currentFlags.remove(.nsfl)
        AppSettings.setFlags(currentFlags, for: flagsPosition)
    }
}

protocol FlagsPopoverShowable {}

extension FlagsPopoverShowable where Self: UIViewController & UIPopoverPresentationControllerDelegate {
    
    func setupFlagsPopover(for flagsPosition: FlagsPosition, changedClosure: ActionClosure? = nil) {
        
        precondition(adaptivePresentationStyle?(for: self.presentationController!) == UIModalPresentationStyle.none)
        
        let flagsViewController = FlagsViewController.fromStoryboard()
        flagsViewController.flagsPosition = flagsPosition
        flagsViewController.changedClosure = changedClosure
        
        let flagsItem = BarButtonItem(image: UIImage(systemName: "list.dash"),
                                           style: .plain) { barButtonItem in
            
            flagsViewController.modalPresentationStyle = .popover
            
            let popover: UIPopoverPresentationController = flagsViewController.popoverPresentationController!
            popover.barButtonItem = barButtonItem
            popover.permittedArrowDirections = .up
            popover.sourceView = self.view
            popover.delegate = self
            self.present(flagsViewController, animated: true)
        }
        navigationItem.rightBarButtonItem = flagsItem
    }
}
