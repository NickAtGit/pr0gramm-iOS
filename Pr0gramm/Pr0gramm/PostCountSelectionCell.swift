import UIKit
import Static

final class PostCountSelectionCell: UITableViewCell, Cell {

    @IBOutlet var segmentedControl: UISegmentedControl!
    
    static func nib() -> UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    func configure(row: Row) {
        segmentedControl.selectedSegmentIndex = AppSettings.postCount - 3
        segmentedControl.setTitle("3", forSegmentAt: 0)
        segmentedControl.setTitle("4", forSegmentAt: 1)
        segmentedControl.setTitle("5", forSegmentAt: 2)
        segmentedControl.setTitle("6", forSegmentAt: 3)
    }
    
    @IBAction func themeSegmentedControlDidChangeValue(_ sender: UISegmentedControl) {
        AppSettings.postCount = sender.selectedSegmentIndex + 3
    }
}
