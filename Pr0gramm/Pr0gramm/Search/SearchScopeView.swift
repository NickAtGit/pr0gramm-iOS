
import UIKit
import Bond

class SearchScopeView: UIView, NibView {
    
    var viewModel: SearchViewModel! {
        didSet {
            segmentedControl.reactive.selectedSegmentIndex.bind(to: viewModel.sorting)
        }
    }
    
    @IBOutlet var segmentedControl: UISegmentedControl!
}
