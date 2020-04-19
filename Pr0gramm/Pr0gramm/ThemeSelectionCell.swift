
import UIKit
import Static

final class ThemeSelectionCell: UITableViewCell, Cell {

    @IBOutlet var segmentedControl: UISegmentedControl!
    
    static func nib() -> UINib? {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    func configure(row: Row) {
        segmentedControl.selectedSegmentIndex = AppSettings.selectedTheme
        segmentedControl.setTitle("Blau", forSegmentAt: 0)
        segmentedControl.setTitle("Orange", forSegmentAt: 1)
        segmentedControl.setTitle("Grün", forSegmentAt: 2)
        segmentedControl.setTitle("Pink", forSegmentAt: 3)
        segmentedControl.setTitle("Gelb", forSegmentAt: 4)
    }
    
    @IBAction func themeSegmentedControlDidChangeValue(_ sender: UISegmentedControl) {
        AppSettings.selectedTheme = sender.selectedSegmentIndex
        Theming.applySelectedPersistedTheme()
    }
}
