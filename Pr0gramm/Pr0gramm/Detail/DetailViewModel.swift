
import Foundation
import Bond

enum MediaType {
    case image, gif, video
}

class DetailViewModel {
    
    let item: Observable<Item>
    let itemInfo = Observable<ItemInfo?>(nil)
    let connector: Pr0grammConnector
    let points = Observable<String?>(nil)
    let userName = Observable<String?>(nil)
    let isTagsExpanded = Observable<Bool>(false)
    let isTagsExpandButtonHidden = Observable<Bool>(true)
    let isCommentsButtonHidden = Observable<Bool>(true)
    let initialPointCount: Int
    let comments = Observable<[Comments]?>(nil)
    let link: String
    let mediaType: MediaType
    let postTime = Observable<String?>(nil)
    lazy var upvotes = item.value.up
    lazy var downvotes = item.value.down
    
    init(item: Item, connector: Pr0grammConnector) {
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
    
    func vote(_ vote: Vote) {
        connector.vote(id: item.value.id, value: vote, type: .voteItem)
    }
    
    private func sortComments(_ comments: [Comments]) {
        let parentNodes = comments.filter { $0.parent == 0 }.map { Node(value: $0) }
        let childNodes = comments.filter { $0.parent != 0 }.map { Node(value: $0) }
        DispatchQueue.main.async {
            self.sortComments(parentNodes: parentNodes, childNodes: childNodes)
        }
    }
    
    private func sortComments(parentNodes: [Node<Comments>], childNodes: [Node<Comments>]) {
        
        let parentNodes = parentNodes
        var childNodes = childNodes
                        
        if let firstChild = childNodes.first {
            
            let parentId = firstChild.value.parent!
            if let parentNode = parentNodes.first(where: { $0.value.id == parentId }) {
                firstChild.value.depth = parentNode.value.depth + 1
                parentNode.add(child: firstChild)
                childNodes.removeFirst()
                sortComments(parentNodes: parentNodes, childNodes: childNodes)
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
                        sortComments(parentNodes: parentNodes, childNodes: childNodes)
                    }
                }
                
                childNodes.forEach {
                    if let foundNode = $0.search(id: parentId) {
                        firstChild.value.depth = foundNode.value.depth + 1
                        foundNode.add(child: firstChild)
                        childNodes.removeFirst()
                        sortComments(parentNodes: parentNodes, childNodes: childNodes)
                    }
                }
            }
        } else {
            let sortedNodes = parentNodes.sorted { $0.value.confidence ?? 0 > $1.value.confidence ?? 0 }
            convertCommentNodesToArray(nodes: sortedNodes, currentArray: [])
        }
    }
    
    private func convertCommentNodesToArray(nodes: [Node<Comments>], currentArray: [Comments]) {
        var nodes = nodes
        var commentsArray = currentArray
        
        if let firstNode = nodes.first {
            commentsArray.append(firstNode.value)
            
            if firstNode.children.count > 0 {
                let remainingNodes = nodes.dropFirst()
                let sortedChildren = firstNode.children.sorted { $0.value.confidence ?? 0 > $1.value.confidence ?? 0 }
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

extension Node where T == Comments {
    
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
        "Id: \(value.id ?? -1), parent: \(value.parent ?? -1)"
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

class Strings {
    static let timeString = "vor %d %@"
    static let year = "Jahr"
    static let years = "Jahren"
    static let month = "Monat"
    static let months = "Monaten"
    static let week = "Woche"
    static let weeks = "Wochen"
    static let day = "Tag"
    static let days = "Tagen"
    static let hour = "Stunde"
    static let hours = "Stunden"
    static let minute = "Minute"
    static let minutes = "Minuten"
    static let momentAgo = "vor einem Moment"
    
    static func timeString(for date: Date) -> String {
        let intervalDate = Date(timeIntervalSince1970:Date().timeIntervalSince1970 - date.timeIntervalSince1970)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day, .month, .year, .weekOfMonth], from: intervalDate)
        let years = components.year! - 1970
        let months = components.month! - 1
        let weeks = components.weekOfMonth! - 1
        let days = components.day! - 1
        let hours = components.hour! - 1
        let minutes = components.minute!
        
        var value = 0
        var period = ""
        if (years > 0) {
            value = years
            if (years == 1) {
                period = Strings.year
            } else {
                period = Strings.years
            }
        } else if (months > 0) {
            value = months
            if (months == 1) {
                period = Strings.month
            } else {
                period = Strings.months
            }
        } else if (weeks > 0) {
            value = weeks
            if (weeks == 1) {
                period = Strings.week
            } else {
                period = Strings.weeks
            }
        } else if (days > 0) {
            value = days
            if (days == 1) {
                period = Strings.day
            } else {
                period = Strings.days
            }
        } else if (hours > 0) {
            value = hours
            if (hours == 1) {
                period = Strings.hour
            } else {
                period = Strings.hours
            }
        } else if (minutes > 0) {
            value = minutes
            if (minutes == 1) {
                period = Strings.minute
            } else{
                period = Strings.minutes
            }
        } else {
            return Strings.momentAgo
        }
        
        return String(format: Strings.timeString, value, period)
    }
}
