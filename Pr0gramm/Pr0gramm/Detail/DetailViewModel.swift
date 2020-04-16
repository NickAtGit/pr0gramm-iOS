
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
    var comments: [Comments]?
    let link: String
    let mediaType: MediaType
    
    init(item: Item, connector: Pr0grammConnector) {
        self.item = Observable<Item>(item)
        self.connector = connector
        self.initialPointCount = item.up - item.down
        points.value = "\(item.up - item.down)"
        userName.value = item.user
        let link = connector.link(for: item)
        self.link = link.link
        mediaType = link.mediaType
        
        connector.loadItemInfo(for: item.id) { [weak self] itemInfo in
            guard let itemInfo = itemInfo else { return }
            self?.itemInfo.value = itemInfo
            self?.isCommentsButtonHidden.value = itemInfo.comments.count == 0
            self?.comments = itemInfo.comments
        }
    }
    
    func vote(_ vote: Vote) {
        connector.vote(id: item.value.id, value: vote, type: .voteItem)
    }
}
