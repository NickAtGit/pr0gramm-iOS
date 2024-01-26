import SwiftUI
import StoreKit

struct SettingsView: View {
    @State private var isOverlayShown = false

    @AppStorage(#keyPath(AppSettings.isShowSeenBagdes))
    var isShowSeenBagdes: Bool = AppSettings.isShowSeenBagdes
    @AppStorage(#keyPath(AppSettings.isMediaHeightLimitEnabled))
    var isMediaHeightLimitEnabled: Bool = AppSettings.isMediaHeightLimitEnabled
    @AppStorage(#keyPath(AppSettings.isDeactivateNsfwOnAppStart))
    var isDeactivateNsfwOnAppStart: Bool = AppSettings.isDeactivateNsfwOnAppStart
  
    @AppStorage(#keyPath(AppSettings.isVideoMuted))
    var isVideoMuted: Bool = AppSettings.isVideoMuted
    @AppStorage(#keyPath(AppSettings.isAutoPlay))
    var isAutoPlay: Bool = AppSettings.isAutoPlay
    @AppStorage(#keyPath(AppSettings.isPictureInPictureEnabled))
    var isPictureInPictureEnabled: Bool = AppSettings.isPictureInPictureEnabled
    @AppStorage(#keyPath(AppSettings.isMuteOnUnnecessaryMusic))
    var isMuteOnUnnecessaryMusic: Bool = AppSettings.isMuteOnUnnecessaryMusic

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
                    HStack {
                        Text("Datenbank")
                        Spacer()
                        Text(ActionsManager.shared.dataBaseSize ?? "Fehler").foregroundStyle(.secondary)
                    }
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

#Preview {
    SettingsView()
}
