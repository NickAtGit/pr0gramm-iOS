
import Foundation

@objc
protocol SettingsConfigurable {}

@objc
protocol UserSettingsConfigurable {
    static var isLoggedIn: Bool { get set }
    static var selectedTheme: Int { get set }
    static var isVideoMuted: Bool { get set }
    static var isAutoPlay: Bool { get set }
    static var isShowSeenBagdes: Bool { get set }
    static var isUseLeftRightQuickTap: Bool { get set }
    static var isPictureInPictureEnabled: Bool { get set }
    static var latestSearchStrings: [String] { get set }
    static var postCount: Int { get set }
}

@objc
protocol FlagFilterSettingsConfigurable {}

class AppSettings {
    
    fileprivate static func updateDefaults(for key: String, value: Any) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    fileprivate static func value<T>(for key: String) -> T? {
        return UserDefaults.standard.value(forKey: key) as? T
    }
}

extension AppSettings: SettingsConfigurable {}

extension AppSettings: FlagFilterSettingsConfigurable {
    
    static func setFlags(_ flags: Set<Flags>, for flagsPosition: FlagsPosition) {
        UserDefaults.standard.set(Array(flags.map({$0.rawValue})), forKey: flagsPosition.rawValue)
    }
    
    static func flags(for flagsPosition: FlagsPosition) -> Set<Flags> {
        let flagsRaw = UserDefaults.standard.value(forKey: flagsPosition.rawValue) as? [Int] ?? [Flags.sfw.rawValue]
        let flags = flagsRaw.map({ Flags(rawValue: $0)! })
        return Set(flags)
    }
    
    static func setSorting(_ sorting: Sorting, for flagsPosition: FlagsPosition) {
        UserDefaults.standard.set(sorting.rawValue, forKey: flagsPosition.rawValue + "_sorting")
    }
    
    static func sorting(for flagsPosition: FlagsPosition) -> Sorting {
        let sortingRaw = UserDefaults.standard.value(forKey: flagsPosition.rawValue + "_sorting") as? Int ?? Sorting.top.rawValue
        return Sorting(rawValue: sortingRaw) ?? .top
    }
}

extension AppSettings: UserSettingsConfigurable {
    static var selectedTheme: Int {
        get { return AppSettings.value(for: #keyPath(selectedTheme)) ?? 0 }
        set { AppSettings.updateDefaults(for: #keyPath(selectedTheme), value: newValue) }
    }
    
    static var isLoggedIn: Bool {
        get { return AppSettings.value(for: #keyPath(isLoggedIn)) ?? false }
        set { AppSettings.updateDefaults(for: #keyPath(isLoggedIn), value: newValue) }
    }
    
    static var isVideoMuted: Bool {
        get { return AppSettings.value(for: #keyPath(isVideoMuted)) ?? false }
        set { AppSettings.updateDefaults(for: #keyPath(isVideoMuted), value: newValue) }
    }
    
    static var isAutoPlay: Bool {
        get { return AppSettings.value(for: #keyPath(isAutoPlay)) ?? false }
        set { AppSettings.updateDefaults(for: #keyPath(isAutoPlay), value: newValue) }
    }
    
    static var isShowSeenBagdes: Bool {
        get { return AppSettings.value(for: #keyPath(isShowSeenBagdes)) ?? false }
        set { AppSettings.updateDefaults(for: #keyPath(isShowSeenBagdes), value: newValue) }
    }
    
    static var isUseLeftRightQuickTap: Bool {
        get { return AppSettings.value(for: #keyPath(isUseLeftRightQuickTap)) ?? false }
        set { AppSettings.updateDefaults(for: #keyPath(isUseLeftRightQuickTap), value: newValue) }
    }
    
    static var isPictureInPictureEnabled: Bool {
        get { return AppSettings.value(for: #keyPath(isPictureInPictureEnabled)) ?? true }
        set { AppSettings.updateDefaults(for: #keyPath(isPictureInPictureEnabled), value: newValue) }
    }
    
    static var latestSearchStrings: [String] {
        get { return AppSettings.value(for: #keyPath(latestSearchStrings)) ?? [] }
        set { AppSettings.updateDefaults(for: #keyPath(latestSearchStrings), value: newValue) }
    }
    
    static var postCount: Int {
        get { return AppSettings.value(for: #keyPath(postCount)) ?? 3 }
        set { AppSettings.updateDefaults(for: #keyPath(postCount), value: newValue) }
    }
}
