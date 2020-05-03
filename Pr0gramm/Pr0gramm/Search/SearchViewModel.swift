
import Foundation
import Bond

class SearchViewModel {
    
    let connector: Pr0grammConnector
    let sorting = Observable<Int>(0)
    
    init(connector: Pr0grammConnector) {
        self.connector = connector
    }
    
    func search(for tag: String, completion: @escaping ([Item]?) -> Void) {
        connector.searchItems(for: [tag], sorting: Sorting(rawValue: sorting.value)!) { items in
            completion(items)
        }
    }
}
