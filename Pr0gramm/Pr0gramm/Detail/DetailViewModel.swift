
import Foundation
import Bond

enum MediaType {
    case image, gif, video
}

class DetailViewModel {
    
    var loggedInUserName: String? { connector.userName }
    let item: Observable<Item>
    let itemInfo = Observable<ItemInfo?>(nil)
    let connector: Pr0grammConnector
    let points = Observable<String?>(nil)
    let userName = Observable<String?>(nil)
    let isTagsExpanded = Observable<Bool>(false)
    let isTagsExpandButtonHidden = Observable<Bool>(true)
    let isCommentsButtonHidden = Observable<Bool>(true)
    var isSeen: Bool {
        get {
            ActionsManager.shared.retrieveAction(for: item.value.id)?.seen ?? false
        }
        set {
            ActionsManager.shared.saveAction(for: item.value.id, seen: newValue)
        }
    }
    let initialPointCount: Int
    let comments = Observable<[Comment]?>(nil)
    let link: String
    let mediaType: MediaType
    let postTime = Observable<String?>(nil)
    lazy var upvotes = item.value.up
    lazy var downvotes = item.value.down
    
    init(item: Item,
         connector: Pr0grammConnector) {
        self.item = Observable<Item>(item)
        self.connector = connector
        let points = item.up - item.down
        self.initialPointCount = points
        self.points.value = "\(points)"
        self.userName.value = item.user
        let link = connector.link(for: item)
        self.link = link.link
        self.mediaType = link.mediaType
        self.postTime.value = Strings.timeString(for: self.item.value.date)
                
        connector.loadItemInfo(for: item.id) { [weak self] itemInfo in
            guard let itemInfo = itemInfo else { return }
            self?.itemInfo.value = itemInfo
            self?.isCommentsButtonHidden.value = itemInfo.comments.count == 0
            self?.sortComments(itemInfo.comments)
        }
    }
    
    func addComment(_ comment: Comment, parentComment: Comment? = nil) {
        
        if let parentComment = parentComment {
            guard let index = comments.value?.firstIndex(of: parentComment) else { return }
            comments.value?.insert(comment, at: index + 1)
            connector.postComment(to: item.value.id, parentId: parentComment.id, comment: comment.content)
        } else {
            comments.value?.insert(comment, at: 0)
            isCommentsButtonHidden.value = false
            connector.postComment(to: item.value.id, comment: comment.content)
        }
    }
    
    func vote(_ vote: Vote) {
        connector.vote(id: item.value.id, value: vote, type: .voteItem)
    }
    
    func search(for tag: String, completion: @escaping ([Item]?) -> Void) {
        let sorting = Sorting(rawValue: AppSettings.sorting)!
        let flags = AppSettings.currentFlags

        connector.search(sorting: sorting, flags: flags, for: [tag]) { items in
            DispatchQueue.main.async {
                completion(items?.items)
            }
        }
    }
    
    func isAuthorUser(for comment: Comment) -> Bool { comment.name == connector.userName }
    func isAuthorOP(for comment: Comment) -> Bool { comment.name == item.value.user }
    
    private func sortComments(_ comments: [Comment]) {
        let parentNodes = comments.filter { $0.parent == 0 }.map { Node(value: $0) }
        let childNodes = comments.filter { $0.parent != 0 }.map { Node(value: $0) }
        DispatchQueue.main.async {
            self.sortComments(parentNodes: parentNodes, childNodes: childNodes)
        }
    }
    
    private func sortComments(parentNodes: [Node<Comment>], childNodes: [Node<Comment>]) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            let parentNodes = parentNodes
            var childNodes = childNodes

            if let firstChild = childNodes.first {
                
                let parentId = firstChild.value.parent!
                if let parentNode = parentNodes.first(where: { $0.value.id == parentId }) {
                    firstChild.value.depth = parentNode.value.depth + 1
                    parentNode.add(child: firstChild)
                    childNodes.removeFirst()
                    self.sortComments(parentNodes: parentNodes, childNodes: childNodes)
                } else {
                    //Comment is child of child
                    //Search children for parent
                    //Search also parentNodes, they may have a child already that is the parent
                    //of the current child we are looking at
                                
                    parentNodes.forEach {
                        if let foundNode = $0.search(id: parentId) {
                            firstChild.value.depth = foundNode.value.depth + 1
                            foundNode.add(child: firstChild)
                            childNodes.removeFirst()
                            self.sortComments(parentNodes: parentNodes, childNodes: childNodes)
                        }
                    }
                    
                    childNodes.forEach {
                        if let foundNode = $0.search(id: parentId) {
                            firstChild.value.depth = foundNode.value.depth + 1
                            foundNode.add(child: firstChild)
                            childNodes.removeFirst()
                            self.sortComments(parentNodes: parentNodes, childNodes: childNodes)
                        }
                    }
                }
            } else {
                let sortedNodes = parentNodes.sorted { $0.value.confidence > $1.value.confidence }
                self.convertCommentNodesToArray(nodes: sortedNodes, currentArray: [])
            }
        }
    }
    
    private func convertCommentNodesToArray(nodes: [Node<Comment>], currentArray: [Comment]) {
        var nodes = nodes
        var commentsArray = currentArray
        
        if let firstNode = nodes.first {
            commentsArray.append(firstNode.value)
            
            if firstNode.children.count > 0 {
                let remainingNodes = nodes.dropFirst()
                let sortedChildren = firstNode.children.sorted { $0.value.confidence > $1.value.confidence }
                convertCommentNodesToArray(nodes: sortedChildren + remainingNodes, currentArray: commentsArray)
            } else {
                nodes.removeFirst()
                convertCommentNodesToArray(nodes: nodes, currentArray: commentsArray)
            }
        } else {
            self.comments.value = commentsArray
        }
    }
}

fileprivate class Node<T> {
    var value: T
    weak var parent: Node?
    var children: [Node] = []
    
    init(value: T) {
        self.value = value
    }
    
    func add(child: Node) {
        children.append(child)
        child.parent = self
    }
}

extension Node where T == Comment {
    
    func search(id: Int) -> Node? {
        if id == self.value.id {
            return self
        }
        for child in children {
            if let found = child.search(id: id) {
                return found
            }
        }
        return nil
    }
    
    var description: String {
        "Id: \(value.id), parent: \(value.parent ?? -1)"
    }
}

extension Node where T: Equatable {
    func search(value: T) -> Node? {
        if value == self.value {
            return self
        }
        for child in children {
            if let found = child.search(value: value) {
                return found
            }
        }
        return nil
    }
}
