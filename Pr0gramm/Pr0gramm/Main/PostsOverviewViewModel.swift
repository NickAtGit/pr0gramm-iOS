
import UIKit

enum PostsOverviewStyle: Equatable {
    case main, search(tags: [String]), user(name: String), collection(user: String, name: String, keyword: String)
}

class PostsOverviewViewModel: ObservableObject, PostsLoadable {

    var queue = DispatchQueue(label: "com.readerWriter", qos: .userInitiated, attributes: .concurrent)
    
    @Published var items: [Item] = []
    
    var style: PostsOverviewStyle
    var connector: Pr0grammConnector
    var sorting: Sorting { Sorting(rawValue: AppSettings.sorting)! }
    var allItems: [AllItems] = [] {
        didSet {
            self.items = allItems.flatMap { $0.items }
        }
    }
    var isAtEnd = false
    
    init(style: PostsOverviewStyle,
         connector: Pr0grammConnector) {
        
        self.style = style
        self.connector = connector
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
        case .user(let name):
            return name
        case .collection(_, let collectionName, _):
            return collectionName
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
        default:
            return nil
        }
    }
}


protocol PostsLoadable: AnyObject {
    var style: PostsOverviewStyle { get set }
    var connector: Pr0grammConnector { get set }
    var sorting: Sorting { get }
    var allItems: [AllItems] { get set }
    var items: [Item] { get }
    var isAtEnd: Bool { get set }
    var queue: DispatchQueue { get set }
}

extension PostsLoadable {
    
    func loadItems(more: Bool = false,
                   isRefresh: Bool = false,
                   completion: @escaping (Bool) -> Void) {
        
        if !isRefresh { guard !isAtEnd else { return } }
        
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
                self?.queue.async(flags: .barrier) {
                    if isRefresh { self?.allItems.removeAll() }
                    self?.allItems.append(items)
                }
                self?.isAtEnd = items.atEnd
                completion(true)
            }
        case .search(let tags):
            connector.search(sorting: sorting,
                             flags: flags,
                             for: tags,
                             afterId: afterId) { [weak self] items in
                guard let items = items else { completion(false); return }
                self?.queue.async(flags: .barrier) {
                    if isRefresh { self?.allItems.removeAll() }
                    self?.allItems.append(items)
                }
                self?.isAtEnd = items.atEnd
                completion(true)
            }
        case .user(let name):
            connector.fetchUserItems(sorting: sorting,
                                     flags: flags,
                                     userName: name,
                                     afterId: afterId) { [weak self] items in
                guard let items = items else { completion(false); return }
                self?.queue.async(flags: .barrier) {
                    if isRefresh { self?.allItems.removeAll() }
                    self?.allItems.append(items)
                }
                self?.isAtEnd = items.atEnd
                completion(true)
            }
        case .collection(let userName, _, let keyword):
            connector.fetchUserCollection(sorting: sorting,
                                          flags: flags,
                                          userName: userName,
                                          collectionName: keyword,
                                          afterId: afterId) { [weak self] items in
                guard let items = items else { completion(false); return }
                self?.queue.async(flags: .barrier) {
                    if isRefresh { self?.allItems.removeAll() }
                    self?.allItems.append(items)
                }
                self?.isAtEnd = items.atEnd
                completion(true)
            }
        }
    }
}
