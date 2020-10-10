
import UIKit

enum PostsOverviewStyle: Equatable {
    case main, search(tags: [String]), user(name: String), collection(user: String, name: String, keyword: String)
}

class PostsOverviewViewModel: PostsLoadable {
    
    var items: [Item] {
        var items = [Item]()
        allItems.forEach { items += $0.items }
        return items
    }
    
    var style: PostsOverviewStyle
    var connector: Pr0grammConnector
    var allItems: [AllItems] = []
    var isAtEnd = false
    
    init(style: PostsOverviewStyle,
         connector: Pr0grammConnector) {
        
        self.style = style
        self.connector = connector
    }
    
    var title: String {
        switch style {
            
        case .main:
            switch AppSettings.sorting(for: .main) {
            case .top: return "Beliebt"
            case .neu: return "Neu"
            }
        case .search(let tags):
            return tags.first ?? ""
        case .user(let name):
            return name
        case .collection(_, let collectionName, _):
            return collectionName
        }
    }
    
    var tabBarItem: UITabBarItem? {
        switch style {
        case .main:
            let sorting = AppSettings.sorting(for: .main)
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
        default:
            return nil
        }
    }
    
    func thumbLink(for item: Item) -> String {
        return connector.thumbLink(for: item)
    }
}


protocol PostsLoadable: class {
    var style: PostsOverviewStyle { get set }
    var connector: Pr0grammConnector { get set }
    var allItems: [AllItems] { get set }
    var items: [Item] { get }
    var isAtEnd: Bool { get set }
}

extension PostsLoadable {
    
    func loadItems(more: Bool = false,
                   isRefresh: Bool = false,
                   completion: @escaping (Bool) -> Void) {
        
        if !isRefresh { guard !isAtEnd else { return } }
        
        var afterId: Int?
        
        switch style {
        case .main:
            if more {
                afterId = AppSettings.sorting(for: .main) == .top ? items.last?.promoted : items.last?.id
            }
            connector.fetchItems(sorting: AppSettings.sorting(for: .main),
                                 flags: Array(AppSettings.flags(for: .main)),
                                 afterId: afterId) { [weak self] items in
                                    guard let items = items else { completion(false); return }
                                    if isRefresh { self?.allItems.removeAll() }
                                    self?.allItems.append(items)
                                    self?.isAtEnd = items.atEnd
                                    completion(true)
            }
        case .search(let tags):
            if more {
                afterId = AppSettings.sorting(for: .search) == .top ? items.last?.promoted : items.last?.id
            }
            connector.search(sorting: AppSettings.sorting(for: .search),
                             flags: Array(AppSettings.flags(for: .search)),
                             for: tags,
                             afterId: afterId) { [weak self] items in
                                guard let items = items else { completion(false); return }
                                if isRefresh { self?.allItems.removeAll() }
                                self?.allItems.append(items)
                                self?.isAtEnd = items.atEnd
                                completion(true)
            }
        case .user(let name):
            if more {
                afterId = AppSettings.sorting(for: .user) == .top ? items.last?.promoted : items.last?.id
            }
            connector.fetchUserItems(sorting: AppSettings.sorting(for: .user),
                                     flags: Array(AppSettings.flags(for: .user)),
                                     userName: name,
                                     afterId: afterId) { [weak self] items in
                                        guard let items = items else { completion(false); return }
                                        if isRefresh { self?.allItems.removeAll() }
                                        self?.allItems.append(items)
                                        self?.isAtEnd = items.atEnd
                                        completion(true)
            }
        case .collection(let userName, _, let keyword):
            if more {
                afterId = AppSettings.sorting(for: .user) == .top ? items.last?.promoted : items.last?.id
            }
            connector.fetchUserCollection(sorting: AppSettings.sorting(for: .user),
                                          flags: Array(AppSettings.flags(for: .user)),
                                          userName: userName,
                                          collectionName: keyword,
                                          afterId: afterId) { [weak self] items in
                                            guard let items = items else { completion(false); return }
                                            if isRefresh { self?.allItems.removeAll() }
                                            self?.allItems.append(items)
                                            self?.isAtEnd = items.atEnd
                                            completion(true)
            }
        }
    }
}
