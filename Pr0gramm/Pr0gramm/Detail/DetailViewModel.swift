
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
    let postTime = Observable<String?>(nil)
    
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
            self?.comments = itemInfo.comments
        }
    }
    
    func vote(_ vote: Vote) {
        connector.vote(id: item.value.id, value: vote, type: .voteItem)
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
