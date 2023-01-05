
import Foundation
import Combine

class SearchViewModel {

    @Published var searchText = ""
    @Published var minScoreSliderValue = 0
    private let connector: Pr0grammConnector
    private var subscriptions = Set<AnyCancellable>()
    
    init(connector: Pr0grammConnector) {
        self.connector = connector
        
        $minScoreSliderValue
            .sink { [unowned self] value in
                self.searchText = value == 0 ? "" : "!s:\(value) "
            }
            .store(in: &subscriptions)
    }
}
