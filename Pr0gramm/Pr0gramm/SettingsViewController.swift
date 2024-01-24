
@propertyWrapper
struct CodableAppStorage<T: Codable> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.data(forKey: key),
                  let value = try? JSONDecoder().decode(T.self, from: data) else {
                return defaultValue
            }
            return value
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: key)
            }
        }
    }
}

import SwiftUI
import StoreKit

struct SettingsView: View {
    @State private var isOverlayShown = false

    @AppStorage("selectedTheme") var selectedTheme: Int = 1
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("isVideoMuted") var isVideoMuted: Bool = false
    @AppStorage("isAutoPlay") var isAutoPlay: Bool = true
    @AppStorage("isShowSeenBagdes") var isShowSeenBagdes: Bool = true
    @AppStorage("isPictureInPictureEnabled") var isPictureInPictureEnabled: Bool = true
    @AppStorage("postCount") var postCount: Int = 4
    @AppStorage("isMediaHeightLimitEnabled") var isMediaHeightLimitEnabled: Bool = false
    @AppStorage("isDeactivateNsfwOnAppStart") var isDeactivateNsfwOnAppStart: Bool = false
    @AppStorage("isMuteOnUnnecessaryMusic") var isMuteOnUnnecessaryMusic: Bool = false
    @CodableAppStorage("latestSearchStrings", defaultValue: []) var latestSearchStrings: [String]

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Unterstütze mich"),
                        footer: Text("Da ich immer wieder gefragt werde, ob und wie man mich unterstützen kann: Lade einfach meine anderen Apps herunter. Ich würde mich auch über eine (gute) Bewertung im AppStore freuen. Vielen Dank!")) {
                    Button("Downloade meine andere App") {
                        displayOverlay()
                    }
                }
                
                Section(header: Text("Theme")) {
                    ThemeSelectionView()
                }
                
                Section(header: Text("Anzahl der Hochlads pro Reihe")) {
                    PostCountSelectionView()
                }
                
                Section(header: Text("Allgemein")) {
                    Toggle("Gesehen Indikator anzeigen", isOn: $isShowSeenBagdes)
                    Toggle("Medien auf Bildschirmhöhe begrenzen", isOn: $isMediaHeightLimitEnabled)
                    Toggle("NSFW/NSFL bei Appstart deaktivieren", isOn: $isDeactivateNsfwOnAppStart)
                    Text("Datenbank: \(ActionsManager.shared.dataBaseSize ?? "Fehler")")
                }
                
                Section(header: Text("Video")) {
                    Toggle("Videos stumm starten", isOn: $isVideoMuted)
                    Toggle("Videos automatisch starten", isOn: $isAutoPlay)
                    Toggle("Bild in Bild Modus", isOn: $isPictureInPictureEnabled)
                    Toggle("Stumm bei Tag \"unnötige Musik\"", isOn: $isMuteOnUnnecessaryMusic)
                }
            }
            .navigationTitle("Einstellungen")
            .listStyle(GroupedListStyle())
        }
    }
    
    private func displayOverlay() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let config = SKOverlay.AppConfiguration(appIdentifier: "1249686798", position: .bottomRaised)
            let overlay = SKOverlay(configuration: config)
            overlay.present(in: scene)
        }
    }
}
