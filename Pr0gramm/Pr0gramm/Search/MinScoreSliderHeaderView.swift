
import UIKit

class MinScoreSliderHeaderView: UIView, NibView {
    
    var viewModel: SearchViewModel!
    @IBOutlet private var slider: UISlider!
    @IBOutlet private var descriptionLabel: UILabel!
    private let interval: Int = 100
    
    @IBAction func sliderValueDidChange(_ sender: UISlider) {
        let newValue = (sender.value / Float(interval)).rounded() * Float(interval)
        sender.setValue(newValue, animated: false)
        viewModel.minScoreSliderValue.value = Int(newValue)
        descriptionLabel.text = "Minimaler Benis: \(Int(newValue))"
    }
}
