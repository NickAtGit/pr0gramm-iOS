
import Foundation

@objc
protocol SettingsConfigurable {}

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
        if AppSettings.sfwActive { flags.append(.sfw) }
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
