
import Foundation

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
