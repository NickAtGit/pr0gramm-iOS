
import UIKit

enum PostsOverviewStyle {
    case main, search(tags: [String]), user
}

class PostsOverviewViewModel {
    
    var items: [Item] {
        var items = [Item]()
        allItems.forEach { items += $0.items }
        return items
    }

    let style: PostsOverviewStyle
    let refreshable: Bool
    private let connector: Pr0grammConnector
    private var sorting: Sorting { Sorting(rawValue: AppSettings.sorting)! }
    private var allItems: [AllItems] = []

    init(style: PostsOverviewStyle,
         connector: Pr0grammConnector,
         refreshable: Bool = false) {
        
        self.style = style
        self.connector = connector
        self.refreshable = refreshable
    }
    
    var title: String {
        switch style {
            
        case .main:
            switch sorting {
            case .top: return "Beliebt"
            case .neu: return "Neu"
            }
        case .search(let tags):
            return tags.first ?? ""
        case .user:
            return connector.userName ?? ""
        }
    }
        
    var tabBarItem: UITabBarItem? {
        switch style {
        case .main:
            let sorting = Sorting(rawValue: AppSettings.sorting)!
            switch sorting {
            case .top:
                return UITabBarItem(title: "Beliebt",
                                    image: UIImage(systemName: "circle.grid.3x3"),
                                    selectedImage: UIImage(systemName: "circle.grid.3x3.fill"))
                
            case .neu:
                return UITabBarItem(title: "Neu",
                                    image: UIImage(systemName: "circle.grid.3x3"),
                                    selectedImage: UIImage(systemName: "circle.grid.3x3.fill"))
            }
        case .user:
            return UITabBarItem(title: "Profil",
                                image: UIImage(systemName: "person.circle"),
                                selectedImage: UIImage(systemName: "person.circle.fill"))
        default:
            return nil
        }
    }
    
    func loadItems(more: Bool = false, isRefresh: Bool = false, completion: @escaping (Bool) -> Void) {
        let sorting = Sorting(rawValue: AppSettings.sorting)!
        let flags = AppSettings.currentFlags
        var afterId: Int?
        
        if more {
            afterId = sorting == .top ? items.last?.promoted : items.last?.id
        }
        
        switch style {
        case .main:
            connector.fetchItems(sorting: sorting,
                                 flags: flags,
                                 afterId: afterId) { [weak self] items in
                                    guard let items = items else { completion(false); return }
                                    if isRefresh { self?.allItems.removeAll() }
                                    self?.allItems.append(items)
                                    completion(true)
            }
        case .search(let tags):
            connector.search(sorting: sorting,
                             flags: flags,
                             for: tags,
                             afterId: afterId) { [weak self] items in
                                guard let items = items else { completion(false); return }
                                if isRefresh { self?.allItems.removeAll() }
                                self?.allItems.append(items)
                                completion(true)
            }
            break
        case .user:
            connector.fetchUserItems(sorting: sorting,
                                     flags: flags,
                                     more: more)
        }
    }
    
    func thumbLink(for item: Item) -> String {
        return connector.thumbLink(for: item)
    }
}
