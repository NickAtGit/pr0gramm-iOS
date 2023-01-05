
import Foundation
import Combine

class DetailViewModel: ObservableObject {
    
    var loggedInUserName: String? { connector.userName }
    @Published var connector: Pr0grammConnector
    @Published var item: Item
    @Published var itemInfo: ItemInfo?
    @Published var points: String?
    @Published var userName: String?
    @Published var isTagsExpanded = false
    @Published var isTagsExpandButtonHidden = true
    @Published var isCommentsButtonHidden = true
    @Published var currentVote = Vote.neutral
    @Published var comments: [Comment]?
    @Published var postTime: String?

    var isSeen: Bool {
        get { ActionsManager.shared.retrieveAction(for: item.id)?.seen ?? false }
        set { ActionsManager.shared.saveAction(for: item.id, seen: newValue) }
    }
    let initialPointCount: Int
    lazy var upvotes = item.up
    lazy var downvotes = item.down
    lazy var shouldShowPoints = item.date < Date(timeIntervalSinceNow: -3600)
    let addTagsButtonTap = PassthroughSubject<Bool, Never>()
    let tags = CurrentValueSubject<[Tags], Never>([])
    
    var shareLink: URL {
        URL(string: "https://pr0gramm.com/\(item.promoted == 0 ? "new" : "top")/\(item.id)")!
    }
    
    init(item: Item,
         connector: Pr0grammConnector) {
        self.item = item
        self.connector = connector
        let points = item.up - item.down
        self.initialPointCount = points
        self.userName = item.user
        self.postTime = Strings.timeString(for: item.date)
        let pointsString = shouldShowPoints ? "\(points)" : "•••"
        self.points = pointsString

        connector.loadItemInfo(for: item.id) { [weak self] itemInfo in
            guard let itemInfo,
                  let self else { return }

            let hasComments = itemInfo.comments.count != 0
            
            DispatchQueue.main.async {
                self.isCommentsButtonHidden = !hasComments
                self.itemInfo = itemInfo
                self.tags.value = itemInfo.tags.sorted { $0.confidence > $1.confidence }
            }

            guard hasComments else { return }
            self.sortComments(itemInfo.comments)
        }
    }
    
    func addComment(_ comment: Comment, parentComment: Comment? = nil) {
        
        if let parentComment = parentComment {
            guard let index = comments?.firstIndex(of: parentComment) else { return }
            comments?.insert(comment, at: index + 1)
            connector.postComment(to: item.id, parentId: parentComment.id, comment: comment.content)
        } else {
            comments?.insert(comment, at: 0)
            isCommentsButtonHidden = false
            connector.postComment(to: item.id, comment: comment.content)
        }
    }
    
    func vote(_ vote: Vote) {
        currentVote = vote
        connector.vote(id: item.id, value: vote, type: .voteItem)
        
        switch vote {
        case .neutral:
            ActionsManager.shared.saveAction(for: item.id, action: VoteAction.itemNeutral.rawValue)
        case .up:
            ActionsManager.shared.saveAction(for: item.id, action: VoteAction.itemUp.rawValue)
        case .down:
            ActionsManager.shared.saveAction(for: item.id, action: VoteAction.itemDown.rawValue)
        case .favorite:
            ActionsManager.shared.saveAction(for: item.id, action: VoteAction.itemFavorite.rawValue)
        }
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
    
    func addTagsTapped() {
        addTagsButtonTap.send(true)
    }
    
    func submitTags(_ tags: String) {
        let tags = tags
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}
            .joined(separator: ",")
        
        connector.addTags(tags, for: item.id) { [weak self] result in
            switch result {
            case .success(let tags):
                self?.tags.send(tags)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func isAuthorUser(for comment: Comment) -> Bool { comment.name == connector.userName }
    func isAuthorOP(for comment: Comment) -> Bool { comment.name == item.user }
    
    private func sortComments(_ comments: [Comment]) {
        let parentNodes = comments.filter { $0.parent == 0 }.map { Node(value: $0) }
        let childNodes = comments.filter { $0.parent != 0 }.map { Node(value: $0) }
        self.sortComments(parentNodes: parentNodes, childNodes: childNodes)
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
            self.comments = commentsArray
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
