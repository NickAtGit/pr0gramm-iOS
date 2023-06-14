
import Foundation
import UIKit

@objc
protocol SettingsConfigurable {}

@objc
protocol UserSettingsConfigurable {
    static var isLoggedIn: Bool { get set }
    static var selectedTheme: Int { get set }
    static var isVideoMuted: Bool { get set }
    static var isAutoPlay: Bool { get set }
    static var isShowSeenBagdes: Bool { get set }
    static var isPictureInPictureEnabled: Bool { get set }
    static var latestSearchStrings: [String] { get set }
    static var postCount: Int { get set }
    static var isMediaHeightLimitEnabled: Bool { get set }
    static var isDeactivateNsfwOnAppStart: Bool { get set }
    static var isMuteOnUnnecessaryMusic: Bool { get set }
}

@objc
protocol SortingSettingsConfigurable {
    static var sorting: Int { get set }
}

@objc
protocol FlagFilterSettingsConfigurable {
    static var sfwActive: Bool { get set }
    static var nsfwActive: Bool { get set }
    static var nsflActive: Bool { get set }
}

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
    static var sfwActive: Bool {
        get { return AppSettings.value(for: #keyPath(sfwActive)) ?? true }
        set { AppSettings.updateDefaults(for: #keyPath(sfwActive), value: newValue) }
    }
    
    static var nsfwActive: Bool {
        get { return AppSettings.value(for: #keyPath(nsfwActive)) ?? false }
        set { AppSettings.updateDefaults(for: #keyPath(nsfwActive), value: newValue) }
    }

    static var nsflActive: Bool {
        get { return AppSettings.value(for: #keyPath(nsflActive)) ?? false }
        set { AppSettings.updateDefaults(for: #keyPath(nsflActive), value: newValue) }
    }
    
    static var currentFlags: [Flags] {
        var flags: [Flags] = []
        guard AppSettings.isLoggedIn else { return [.sfw] }
        if AppSettings.sfwActive { flags.append(.sfw); flags.append(.nsfp) }
        if AppSettings.nsfwActive { flags.append(.nsfw) }
        if AppSettings.nsflActive { flags.append(.nsfl) }
        return flags
    }
}

extension AppSettings: SortingSettingsConfigurable {
    static var sorting: Int {
        get { return AppSettings.value(for: #keyPath(sorting)) ?? 1 }
        set { AppSettings.updateDefaults(for: #keyPath(sorting), value: newValue) }
    }
}

extension AppSettings: UserSettingsConfigurable {
    static var selectedTheme: Int {
        get { return AppSettings.value(for: #keyPath(selectedTheme)) ?? 1 }
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
        get { return AppSettings.value(for: #keyPath(isAutoPlay)) ?? true }
        set { AppSettings.updateDefaults(for: #keyPath(isAutoPlay), value: newValue) }
    }
    
    static var isShowSeenBagdes: Bool {
        get { return AppSettings.value(for: #keyPath(isShowSeenBagdes)) ?? true }
        set { AppSettings.updateDefaults(for: #keyPath(isShowSeenBagdes), value: newValue) }
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
        get { return AppSettings.value(for: #keyPath(postCount)) ?? 4 }
        set { AppSettings.updateDefaults(for: #keyPath(postCount), value: newValue) }
    }
    
    static var isMediaHeightLimitEnabled: Bool {
        get { return AppSettings.value(for: #keyPath(isMediaHeightLimitEnabled)) ?? false }
        set { AppSettings.updateDefaults(for: #keyPath(isMediaHeightLimitEnabled), value: newValue) }
    }
    
    static var isDeactivateNsfwOnAppStart: Bool {
        get { return AppSettings.value(for: #keyPath(isDeactivateNsfwOnAppStart)) ?? false }
        set { AppSettings.updateDefaults(for: #keyPath(isDeactivateNsfwOnAppStart), value: newValue) }
    }
    
    static var isMuteOnUnnecessaryMusic: Bool {
        get { return AppSettings.value(for: #keyPath(isMuteOnUnnecessaryMusic)) ?? false }
        set { AppSettings.updateDefaults(for: #keyPath(isMuteOnUnnecessaryMusic), value: newValue) }
    }
}
