
import Foundation

class TVViewModel {
    
    let connector: Pr0grammConnector

    var isAtEnd = false
    var allItems: [AllItems] = []

    var items: [Item] {
        var items = [Item]()
        allItems.forEach { items += $0.items }
        return items
    }
    
    init(connector: Pr0grammConnector) {
        self.connector = connector
    }
    
    func loadItems(more: Bool = false,
                   isRefresh: Bool = false,
                   completion: @escaping (Bool) -> Void) {
        
        if !isRefresh { guard !isAtEnd else { return } }
        
        let sorting = Sorting.top
        let flags = [Flags.nsfw, Flags.sfw]
        var afterId: Int?
        
        if more {
            afterId = sorting == .top ? items.last?.promoted : items.last?.id
        }
        
        connector.fetchItems(sorting: sorting,
                             flags: flags,
                             afterId: afterId) { [unowned self] items in
                                guard let items = items else { completion(false); return }
                                if isRefresh { self.allItems.removeAll() }
                                self.allItems.append(items)
                                self.isAtEnd = items.atEnd
                                completion(true)
        }
    }
}
