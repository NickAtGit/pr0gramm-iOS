
import UIKit

class FlagsViewController: UIViewController, Storyboarded {
        
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var sortingSegmentedControl: UISegmentedControl!
    @IBOutlet private var sfwSwitch: UISwitch!
    @IBOutlet private var nsfwSwitch: UISwitch!
    @IBOutlet private var nsflSwitch: UISwitch!
    @IBOutlet private var flagStackViews: [UIStackView]!
    
    var currentFlags: [Flags] = []
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sortingSegmentedControl.selectedSegmentIndex = AppSettings.sorting == Sorting.top.rawValue ? 0 : 1
        sfwSwitch.isOn = AppSettings.sfwActive
        nsfwSwitch.isOn = AppSettings.nsfwActive
        nsflSwitch.isOn = AppSettings.nsflActive
        flagStackViews.forEach { $0.isHidden = !AppSettings.isLoggedIn }
        preferredContentSize = CGSize(width: 200, height: stackView.bounds.height + 40)
    }
    
    @IBAction func sortingSegmentedControlChanged(_ sender: UISegmentedControl) {
        AppSettings.sorting = sender.selectedSegmentIndex == 0 ? Sorting.top.rawValue : Sorting.neu.rawValue
    }
    
    @IBAction func sfwSwitchChanged(_ sender: UISwitch) {
        AppSettings.sfwActive = sender.isOn
    }
    
    @IBAction func nsfwSwitchChanged(_ sender: UISwitch) {
        AppSettings.nsfwActive = sender.isOn
    }
    
    @IBAction func nsflSwitchChanged(_ sender: UISwitch) {
        AppSettings.nsflActive = sender.isOn
    }
}
