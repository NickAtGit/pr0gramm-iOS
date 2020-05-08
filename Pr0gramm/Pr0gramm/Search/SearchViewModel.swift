
import Foundation
import Bond

class SearchViewModel {
    
    let connector: Pr0grammConnector
    let sorting = Observable<Int>(0)
    
    init(connector: Pr0grammConnector) {
        self.connector = connector
    }
    
    func search(for tag: String, completion: @escaping ([Item]?) -> Void) {
        connector.search(sorting: Sorting(rawValue: sorting.value)!,
                         flags: AppSettings.currentFlags,
                         for: [tag]) { items in
                            guard let items = items else { completion(nil); return }
                            completion(items.items)
        }
    }
}
