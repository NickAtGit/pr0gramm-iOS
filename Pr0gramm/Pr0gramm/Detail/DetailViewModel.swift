
import Foundation
import Bond

class DetailViewModel {
    
    let item: Observable<Item>
    let itemInfo = Observable<ItemInfo?>(nil)
    let connector: Pr0grammConnector
    
    let points = Observable<String?>(nil)
    let userName = Observable<String?>(nil)
    let isTagsExpanded = Observable<Bool>(false)
    let isTagsExpandButtonHidden = Observable<Bool>(true)
    let isCommentsButtonHidden = Observable<Bool>(true)

    var comments: [Comments]?
    
    init(item: Item, connector: Pr0grammConnector) {
        self.item = Observable<Item>(item)
        self.connector = connector
        
        points.value = "\(item.up - item.down)"
        userName.value = item.user
        
        connector.loadItemInfo(for: item.id) { [weak self] itemInfo in
            guard let itemInfo = itemInfo else { return }
            self?.itemInfo.value = itemInfo
            self?.isCommentsButtonHidden.value = itemInfo.comments.count == 0
            self?.comments = itemInfo.comments
        }
    }
    
    func vote(_ vote: Vote) {
        connector.vote(itemId: "\(item.value.id)", value: vote.rawValue)
    }
    
    func imageLink() -> String? {
        return connector.imageLink(for: item.value)
    }
    
    func videoLink() -> String? {
        return connector.videoLink(for: item.value)
    }
}
