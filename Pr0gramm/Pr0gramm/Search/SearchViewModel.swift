
import Foundation
import Bond

class SearchViewModel {

    let searchText = Observable<String>("")
    let minScoreSliderValue = Observable<Int>(0)
    private let connector: Pr0grammConnector
    
    init(connector: Pr0grammConnector) {
        self.connector = connector
        
        let _ = minScoreSliderValue.observeNext { [unowned self] value in
            self.searchText.value = value == 0 ? "" : "!s:\(value) "
        }
    }
}
